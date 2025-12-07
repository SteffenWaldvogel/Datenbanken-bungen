-- 05_fehler_schleifen_cursors_loesungen.sql
-- Lösungen zu: 05 – Fehlerbehandlung, Schleifen und Cursors
-- Sprache: PostgreSQL / PL/pgSQL


/* =========================================================
   Aufgabe 1 – fn_kunden_umsatz_strikt(k_id INT)
   - Gesamtumsatz eines Kunden
   - Wenn Kunde nicht existiert -> EXCEPTION
   ========================================================= */

CREATE OR REPLACE FUNCTION fn_kunden_umsatz_strikt(k_id INT)
RETURNS NUMERIC(12,2)
AS $$
DECLARE
    v_umsatz NUMERIC(12,2);
BEGIN
    -- Prüfen, ob der Kunde existiert
    PERFORM 1
    FROM kunden
    WHERE kunde_id = k_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Kunde % existiert nicht', k_id;
    END IF;

    -- Umsatz berechnen (wie fn_umsatz_kunde)
    SELECT
        COALESCE(
            SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)),
            0.00
        )
    INTO v_umsatz
    FROM
        bestellungen b,
        bestell_positionen bp
    WHERE
        b.bestellung_id = bp.bestellung_id
        AND b.kunde_id   = k_id;

    RETURN v_umsatz;
END;
$$ LANGUAGE plpgsql;



/* =========================================================
   Aufgabe 2 – pr_dummy_zaehler(max_val INT)
   - Zählt von 1 bis max_val
   - Ausgabe via RAISE NOTICE
   - While-/Loop-Struktur üben
   ========================================================= */

CREATE OR REPLACE PROCEDURE pr_dummy_zaehler(p_max_val INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_i INT := 1;
BEGIN
    IF p_max_val <= 0 THEN
        RAISE NOTICE 'p_max_val (% ) <= 0, kein Durchlauf.', p_max_val;
        RETURN;
    END IF;

    LOOP
        RAISE NOTICE 'i = %', v_i;

        v_i := v_i + 1;

        EXIT WHEN v_i > p_max_val;
    END LOOP;
END;
$$;



/* =========================================================
   Aufgabe 3 – pr_liste_alle_produkte()
   - Cursor über produkte
   - Für jede Zeile NOTICE mit ID + Name
   ========================================================= */

CREATE OR REPLACE PROCEDURE pr_liste_alle_produkte()
LANGUAGE plpgsql
AS $$
DECLARE
    cur_produkte CURSOR FOR
        SELECT produkt_id, name
        FROM produkte
        ORDER BY produkt_id;

    v_produkt_id INT;
    v_name       TEXT;
BEGIN
    OPEN cur_produkte;

    LOOP
        FETCH cur_produkte INTO v_produkt_id, v_name;
        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Produkt %: %', v_produkt_id, v_name;
    END LOOP;

    CLOSE cur_produkte;
END;
$$;



/* =========================================================
   Aufgabe 4 – pr_pruefe_rabatt_grenzen()
   - Cursor über kunden
   - Rabatt außerhalb 0–50 melden
   ========================================================= */

CREATE OR REPLACE PROCEDURE pr_pruefe_rabatt_grenzen()
LANGUAGE plpgsql
AS $$
DECLARE
    cur_kunden CURSOR FOR
        SELECT kunde_id, name, rabatt_prozent
        FROM kunden
        ORDER BY kunde_id;

    v_kunde_id      INT;
    v_name          TEXT;
    v_rabatt        INT;
BEGIN
    OPEN cur_kunden;

    LOOP
        FETCH cur_kunden INTO v_kunde_id, v_name, v_rabatt;
        EXIT WHEN NOT FOUND;

        IF v_rabatt < 0 OR v_rabatt > 50 THEN
            RAISE NOTICE 'Kunde % (%): Rabatt % außerhalb 0–50',
                v_kunde_id, v_name, v_rabatt;
        END IF;
    END LOOP;

    CLOSE cur_kunden;
END;
$$;



/* =========================================================
   Aufgabe 5 – pr_sichere_kunde_anlegen(name, email)
   - Insert in kunden
   - Bei UNIQUE-Verletzung auf email -> NOTICE statt Abbruch
   - Voraussetzung: UNIQUE-Constraint auf kunden.email sinnvoll
   ========================================================= */

CREATE OR REPLACE PROCEDURE pr_sichere_kunde_anlegen(
    p_name  TEXT,
    p_email TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO kunden (name, email, telefon, kunden_typ, rabatt_prozent)
    VALUES (p_name, p_email, NULL, 'PRIVAT', 0);

    RAISE NOTICE 'Kunde % mit Email % wurde angelegt.', p_name, p_email;

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Kunde mit Email % existiert bereits – kein Insert.', p_email;
END;
$$;



/* =========================================================
   Aufgabe 6 – pr_aktualisiere_preise_schrittweise(prozent)
   - Cursor über alle Produkte
   - Jedes Produkt nacheinander um X % erhöhen
   - Fortschritt via NOTICE
   ========================================================= */

CREATE OR REPLACE PROCEDURE pr_aktualisiere_preise_schrittweise(p_prozent NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    cur_prod CURSOR FOR
        SELECT produkt_id, name, standardpreis
        FROM produkte
        ORDER BY produkt_id;

    v_produkt_id   INT;
    v_name         TEXT;
    v_preis_alt    NUMERIC(8,2);
    v_preis_neu    NUMERIC(8,2);
    v_faktor       NUMERIC;
BEGIN
    v_faktor := 1 + (p_prozent / 100.0);

    OPEN cur_prod;

    LOOP
        FETCH cur_prod INTO v_produkt_id, v_name, v_preis_alt;
        EXIT WHEN NOT FOUND;

        v_preis_neu := ROUND(v_preis_alt * v_faktor, 2);

        UPDATE produkte
        SET standardpreis = v_preis_neu
        WHERE produkt_id = v_produkt_id;

        RAISE NOTICE
            'Produkt % (%): Preis von % auf % geändert (Faktor %, % %)',
            v_produkt_id, v_name, v_preis_alt, v_preis_neu, v_faktor, p_prozent;
    END LOOP;

    CLOSE cur_prod;
END;
$$;
