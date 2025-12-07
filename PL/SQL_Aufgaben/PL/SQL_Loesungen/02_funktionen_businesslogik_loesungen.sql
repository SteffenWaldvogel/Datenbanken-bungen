-- 02_funktionen_businesslogik_loesungen.sql
-- Lösungen zu: 02 – Funktionen mit Businesslogik
-- Sprache: PostgreSQL / PL/pgSQL


------------------------------------------------------------
-- Aufgabe 1 – fn_versandkosten(k_id INT)
-- PRIVAT    -> 4.90
-- GESCHAEFT -> 0.00
-- sonst / nicht gefunden -> 9.90
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_versandkosten(k_id INT)
RETURNS NUMERIC(6,2)
AS $$
DECLARE
    v_typ   TEXT;
    v_kosten NUMERIC(6,2);
BEGIN
    SELECT kunden_typ
    INTO v_typ
    FROM kunden
    WHERE kunde_id = k_id;

    IF NOT FOUND THEN
        -- Kunde nicht vorhanden -> „teuerster“ Standardversand
        RETURN 9.90;
    END IF;

    IF v_typ = 'PRIVAT' THEN
        v_kosten := 4.90;
    ELSIF v_typ = 'GESCHAEFT' THEN
        v_kosten := 0.00;
    ELSE
        v_kosten := 9.90;
    END IF;

    RETURN v_kosten;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Aufgabe 2 – fn_kundentyp(k_id INT)
-- Wenn Name 'GmbH' oder 'AG' enthält -> 'GESCHAEFT'
-- sonst -> 'PRIVAT'
-- Wenn Kunde nicht existiert -> 'UNBEKANNT'
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_kundentyp(k_id INT)
RETURNS TEXT
AS $$
DECLARE
    v_name TEXT;
BEGIN
    SELECT name
    INTO v_name
    FROM kunden
    WHERE kunde_id = k_id;

    IF NOT FOUND THEN
        RETURN 'UNBEKANNT';
    END IF;

    -- einfache String-Heuristik, case-insensitive
    IF v_name ILIKE '%gmbh%' OR v_name ILIKE '%ag%' THEN
        RETURN 'GESCHAEFT';
    ELSE
        RETURN 'PRIVAT';
    END IF;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Aufgabe 3 – fn_ist_verfuegbar(p_id INT, menge INT)
-- Für die Übung:
--   menge <= 20 -> TRUE
--   menge > 20  -> FALSE
-- Zusätzlich: wenn Produkt nicht existiert -> FALSE
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_ist_verfuegbar(p_id INT, menge INT)
RETURNS BOOLEAN
AS $$
DECLARE
    v_dummy INT;
BEGIN
    -- optional: prüfen, ob das Produkt existiert
    SELECT 1
    INTO v_dummy
    FROM produkte
    WHERE produkt_id = p_id;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    IF menge <= 20 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Aufgabe 4 – fn_umsatzklasse_kunde(k_id INT)
-- nutzt den Gesamtumsatz und klassifiziert:
--   < 100       -> 'LOW'
--   100–499.99  -> 'MID'
--   >= 500      -> 'HIGH'
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_umsatzklasse_kunde(k_id INT)
RETURNS TEXT
AS $$
DECLARE
    v_umsatz NUMERIC(12,2);
BEGIN
    -- hier demonstrativ Aufruf der Funktion aus Blatt 01
    v_umsatz := fn_umsatz_kunde(k_id);

    IF v_umsatz < 100 THEN
        RETURN 'LOW';
    ELSIF v_umsatz < 500 THEN
        RETURN 'MID';
    ELSE
        RETURN 'HIGH';
    END IF;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Aufgabe 5 – fn_neuer_rabatt(k_id INT)
-- basierend auf Umsatzklasse:
--   'LOW' -> 0
--   'MID' -> 5
--   'HIGH' -> 10
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_neuer_rabatt(k_id INT)
RETURNS INTEGER
AS $$
DECLARE
    v_klasse TEXT;
BEGIN
    v_klasse := fn_umsatzklasse_kunde(k_id);

    IF v_klasse = 'LOW' THEN
        RETURN 0;
    ELSIF v_klasse = 'MID' THEN
        RETURN 5;
    ELSIF v_klasse = 'HIGH' THEN
        RETURN 10;
    ELSE
        -- falls jemand die Funktion kaputt konfiguriert hat:
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Aufgabe 6 – fn_kundeninfo(k_id INT)
-- Gibt z. B. zurück:
--   "Kunde 5: Bäckerei Meyer (Typ GESCHAEFT), Rabatt 10 %"
------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_kundeninfo(k_id INT)
RETURNS TEXT
AS $$
DECLARE
    v_name   TEXT;
    v_typ    TEXT;
    v_rabatt INT;
    v_result TEXT;
BEGIN
    SELECT name, kunden_typ, rabatt_prozent
    INTO v_name, v_typ, v_rabatt
    FROM kunden
    WHERE kunde_id = k_id;

    IF NOT FOUND THEN
        RETURN 'Kunde ' || k_id || ' existiert nicht';
    END IF;

    v_result :=
        'Kunde ' || k_id || ': ' || v_name ||
        ' (Typ ' || v_typ || '), Rabatt ' || v_rabatt || ' %';

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;
