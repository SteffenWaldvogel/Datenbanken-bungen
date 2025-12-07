-- 03_prozeduren_und_transaktionen_loesungen.sql
-- Lösungen zu: 03 – Prozeduren & Transaktionen
-- Sprache: PostgreSQL / PL/pgSQL
-- Aufruf jeweils mit: CALL pr_name(...);


------------------------------------------------------------
-- Aufgabe 1 – pr_setze_rabatt_geschaeft(rabatt_neu INT)
-- Setzt bei allen Geschäftskunden den Rabatt neu.
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_setze_rabatt_geschaeft(rabatt_neu INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE kunden
    SET rabatt_prozent = rabatt_neu
    WHERE kunden_typ = 'GESCHAEFT';

    RAISE NOTICE 'Rabatt für alle GESCHAEFT-Kunden auf % %% gesetzt.', rabatt_neu;
END;
$$;


------------------------------------------------------------
-- Aufgabe 2 – pr_kunde_anlegen(name, email, typ)
-- Legt einen neuen Kunden an, wenn Email ein '@' enthält.
-- Sonst kein Insert + NOTICE.
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_kunde_anlegen(
    p_name  TEXT,
    p_email TEXT,
    p_typ   TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- einfache Prüfung: Email muss ein '@' enthalten
    IF position('@' IN p_email) = 0 THEN
        RAISE NOTICE 'Email % ist ungültig. Kunde % wird NICHT angelegt.', p_email, p_name;
        RETURN;
    END IF;

    INSERT INTO kunden (name, email, telefon, kunden_typ, rabatt_prozent)
    VALUES (p_name, p_email, NULL, p_typ, 0);

    RAISE NOTICE 'Kunde % mit Email % wurde angelegt.', p_name, p_email;
END;
$$;


------------------------------------------------------------
-- Aufgabe 3 – pr_preiserhoehung_pro_kategorie(kat_id, prozent)
-- Erhöht alle Produktpreise einer Kategorie um X Prozent.
-- Beispiel: prozent = 10 -> * 1.10
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_preiserhoehung_pro_kategorie(
    p_kategorie_id INT,
    p_prozent      NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_faktor NUMERIC;
BEGIN
    -- p_prozent = 10 -> Faktor 1.10
    v_faktor := 1 + (p_prozent / 100.0);

    UPDATE produkte
    SET standardpreis = ROUND(standardpreis * v_faktor, 2)
    WHERE kategorie_id = p_kategorie_id;

    RAISE NOTICE 'Preise in Kategorie % um % %% erhöht (Faktor %).',
        p_kategorie_id, p_prozent, v_faktor;
END;
$$;


------------------------------------------------------------
-- Aufgabe 4 – pr_bestellung_stornieren(b_id)
-- Setzt den Status einer Bestellung auf 'STORNIERT'.
-- Falls es die Bestellung nicht gibt -> NOTICE.
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_bestellung_stornieren(p_bestellung_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE bestellungen
    SET status = 'STORNIERT'
    WHERE bestellung_id = p_bestellung_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Bestellung % wurde nicht gefunden – kein Update ausgeführt.',
            p_bestellung_id;
    ELSE
        RAISE NOTICE 'Bestellung % wurde auf STORNIERT gesetzt.',
            p_bestellung_id;
    END IF;
END;
$$;


------------------------------------------------------------
-- Aufgabe 5 – pr_testkunden_anlegen(anzahl)
-- Legt eine bestimmte Anzahl Testkunden an.
-- Namen: 'Testkunde 1', 'Testkunde 2', ...
-- Typ: abwechselnd PRIVAT / GESCHAEFT
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_testkunden_anlegen(p_anzahl INT)
LANGUAGE plpgsql
AS $$
DECLARE
    i        INT;
    v_typ    TEXT;
    v_name   TEXT;
BEGIN
    IF p_anzahl <= 0 THEN
        RAISE NOTICE 'Keine Testkunden angelegt (p_anzahl = %).', p_anzahl;
        RETURN;
    END IF;

    FOR i IN 1..p_anzahl LOOP
        -- abwechselnd PRIVAT / GESCHAEFT
        IF (i % 2) = 1 THEN
            v_typ := 'PRIVAT';
        ELSE
            v_typ := 'GESCHAEFT';
        END IF;

        v_name := 'Testkunde ' || i;

        INSERT INTO kunden (name, email, telefon, kunden_typ, rabatt_prozent)
        VALUES (
            v_name,
            'testkunde' || i || '@example.com',
            NULL,
            v_typ,
            0
        );
    END LOOP;

    RAISE NOTICE '% Testkunden wurden angelegt.', p_anzahl;
END;
$$;


------------------------------------------------------------
-- Aufgabe 6 – pr_setze_vip_ab_umsatz(grenze)
-- Setzt ist_vip = TRUE für alle Kunden mit Gesamtumsatz > grenze.
-- Voraussetzung: Spalte ist_vip BOOLEAN in kunden vorhanden.
--
-- Beispiel zum Anlegen der Spalte (einmalig ausführen):
--   ALTER TABLE kunden ADD COLUMN IF NOT EXISTS ist_vip BOOLEAN DEFAULT FALSE;
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE pr_setze_vip_ab_umsatz(p_grenze NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Sicherheitsnetz: Wenn Spalte fehlt, knallt es – das ist ok für Lernzwecke.
    UPDATE kunden k
    SET ist_vip = TRUE
    WHERE k.kunde_id IN (
        SELECT
            b.kunde_id
        FROM
            bestellungen b,
            bestell_positionen bp
        WHERE
            b.bestellung_id = bp.bestellung_id
        GROUP BY
            b.kunde_id
        HAVING
            SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)) > p_grenze
    );

    RAISE NOTICE 'VIP-Status für Kunden mit Umsatz > % aktualisiert.', p_grenze;
END;
$$;
