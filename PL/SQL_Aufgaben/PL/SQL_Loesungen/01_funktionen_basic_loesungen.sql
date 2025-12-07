-- 01_funktionen_basic_loesungen.sql
-- Lösungen zu: 01 – Funktionen (Basics)
-- Sprache: PostgreSQL / PLpgSQL

------------------------------------------------------------
-- Aufgabe 1 – fn_hello_bakery()
-- Gibt nur einen Begrüßungstext zurück.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_hello_bakery()
RETURNS TEXT
AS $$
BEGIN
    RETURN 'Willkommen in der Bäckerei-Datenbank!';
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Aufgabe 2 – fn_kundenname(k_id INT)
-- Gibt den Kundennamen zurück oder 'UNBEKANNT', wenn nicht vorhanden.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_kundenname(k_id INT)
RETURNS TEXT
AS $$
DECLARE
    v_name  TEXT;
BEGIN
    SELECT name
    INTO v_name
    FROM kunden
    WHERE kunde_id = k_id;

    IF NOT FOUND THEN
        RETURN 'UNBEKANNT';
    END IF;

    RETURN v_name;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Aufgabe 3 – fn_bestellanzahl_kunde(k_id INT)
-- Anzahl der Bestellungen eines Kunden.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_bestellanzahl_kunde(k_id INT)
RETURNS INT
AS $$
DECLARE
    v_anzahl INT;
BEGIN
    SELECT COUNT(*)
    INTO v_anzahl
    FROM bestellungen
    WHERE kunde_id = k_id;

    -- Wenn Kunde keine Bestellungen hat, ist COUNT(*) automatisch 0.
    RETURN v_anzahl;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Aufgabe 4 – fn_umsatz_kunde(k_id INT)
-- Gesamtumsatz eines Kunden:
-- SUM(anzahl * einzelpreis * (1 - rabatt_prozent / 100))
-- Wenn keine Bestellungen -> 0.00
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_umsatz_kunde(k_id INT)
RETURNS NUMERIC(12,2)
AS $$
DECLARE
    v_umsatz NUMERIC(12,2);
BEGIN
    SELECT
        COALESCE(SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)), 0.00)
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


------------------------------------------------------------
-- Aufgabe 5 – fn_preis_produkt(p_id INT)
-- Gibt den Standardpreis eines Produkts zurück.
-- Wenn Produkt nicht existiert -> NULL.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_preis_produkt(p_id INT)
RETURNS NUMERIC(8,2)
AS $$
DECLARE
    v_preis NUMERIC(8,2);
BEGIN
    SELECT standardpreis
    INTO v_preis
    FROM produkte
    WHERE produkt_id = p_id;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    RETURN v_preis;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Aufgabe 6 – fn_ist_vegan(p_id INT)
-- TRUE, wenn Produkt existiert und ist_vegan = TRUE
-- FALSE, wenn Produkt nicht existiert oder nicht vegan ist.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_ist_vegan(p_id INT)
RETURNS BOOLEAN
AS $$
DECLARE
    v_flag BOOLEAN;
BEGIN
    SELECT ist_vegan
    INTO v_flag
    FROM produkte
    WHERE produkt_id = p_id;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    IF v_flag IS TRUE THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Aufgabe 7 – fn_rabatt_stufe(k_id INT)
-- Liefert eine Textbeschreibung der Rabattstufe:
--   "<name>: kein Rabatt"       (<= 0)
--   "<name>: normaler Rabatt"   (1–10)
--   "<name>: VIP-Rabatt"        (> 10)
-- Kunde nicht gefunden -> "Kunde nicht vorhanden"
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_rabatt_stufe(k_id INT)
RETURNS TEXT
AS $$
DECLARE
    v_name    TEXT;
    v_rabatt  INT;
    v_result  TEXT;
BEGIN
    SELECT name, rabatt_prozent
    INTO v_name, v_rabatt
    FROM kunden
    WHERE kunde_id = k_id;

    IF NOT FOUND THEN
        RETURN 'Kunde nicht vorhanden';
    END IF;

    IF v_rabatt <= 0 THEN
        v_result := v_name || ': kein Rabatt';
    ELSIF v_rabatt BETWEEN 1 AND 10 THEN
        v_result := v_name || ': normaler Rabatt';
    ELSE
        v_result := v_name || ': VIP-Rabatt';
    END IF;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;
