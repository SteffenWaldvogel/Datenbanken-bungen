-- 06_mini_projekt_loesungen.sql
-- Lösungen zu: 06 – Mini-Projekt: Bestellprüfung & Reporting
-- Sprache: PostgreSQL / PL/pgSQL


/* =========================================================
   Vorbereitung: Spalten / Tabellen
   (nur EINMAL ausführen, dann auskommentieren)
   ========================================================= */

-- Spalte "geprueft" zu bestellungen hinzufügen, falls noch nicht vorhanden:
-- ALTER TABLE bestellungen
--   ADD COLUMN IF NOT EXISTS geprueft BOOLEAN DEFAULT FALSE;

-- Tabelle für Prüf-Logs:
-- Gründe z. B. 'Keine Positionen', 'Warenwert < 5 EUR', 'Kunde ohne gültige Email'
CREATE TABLE IF NOT EXISTS bestellung_prueflog (
    log_id        SERIAL PRIMARY KEY,
    bestellung_id INT      NOT NULL,
    grund         TEXT     NOT NULL,
    zeitpunkt     TIMESTAMP NOT NULL DEFAULT NOW()
);



/* =========================================================
   Teil 1 – fn_bestellung_ok(b_id INT)
   Bedingungen:
   - mindestens eine Position
   - Gesamtwert >= 5.00 EUR
   - Kunde hat E-Mail mit '@'
   ========================================================= */

CREATE OR REPLACE FUNCTION fn_bestellung_ok(p_bestellung_id INT)
RETURNS BOOLEAN
AS $$
DECLARE
    v_anzahl_pos   INT;
    v_gesamtwert   NUMERIC(12,2);
    v_email        TEXT;
BEGIN
    -- Prüfen: gibt es überhaupt Positionen?
    SELECT COUNT(*)
    INTO v_anzahl_pos
    FROM bestell_positionen
    WHERE bestellung_id = p_bestellung_id;

    IF v_anzahl_pos = 0 THEN
        RETURN FALSE;
    END IF;

    -- Gesamtwert berechnen
    SELECT
        COALESCE(SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)), 0.00)
    INTO v_gesamtwert
    FROM
        bestell_positionen bp
    WHERE
        bp.bestellung_id = p_bestellung_id;

    IF v_gesamtwert < 5.00 THEN
        RETURN FALSE;
    END IF;

    -- E-Mail des zugehörigen Kunden prüfen
    SELECT k.email
    INTO v_email
    FROM
        bestellungen b,
        kunden k
    WHERE
        b.kunde_id       = k.kunde_id
        AND b.bestellung_id = p_bestellung_id;

    -- Falls Bestellung oder Kunde nicht gefunden -> nicht ok
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    -- einfache Gültigkeitsprüfung: enthält '@'
    IF v_email IS NULL OR position('@' IN v_email) = 0 THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;



/* =========================================================
   Teil 2/5 – pr_bestellung_pruefen_und_markieren(b_id INT)
   - ruft fn_bestellung_ok auf
   - setzt geprueft = TRUE/FALSE
   - bei FALSE: schreibt in bestellung_prueflog mit Grund
   ========================================================= */

CREATE OR REPLACE PROCEDURE pr_bestellung_pruefen_und_markieren(p_bestellung_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ok          BOOLEAN;
    v_anzahl_pos  INT;
    v_gesamtwert  NUMERIC(12,2);
    v_email       TEXT;
    v_grund       TEXT;
BEGIN
    -- Bestellung überhaupt vorhanden?
    PERFORM 1
    FROM bestellungen
    WHERE bestellung_id = p_bestellung_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Bestellung % existiert nicht – keine Prüfung möglich.', p_bestellung_id;
        RETURN;
    END IF;

    -- Einzelne Gründe bestimmen (für Logging):
    -- 1) Positionen
    SELECT COUNT(*)
    INTO v_anzahl_pos
    FROM bestell_positionen
    WHERE bestellung_id = p_bestellung_id;

    IF v_anzahl_pos = 0 THEN
        v_grund := 'Keine Positionen';
    END IF;

    -- 2) Gesamtwert
    SELECT
        COALESCE(SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)), 0.00)
    INTO v_gesamtwert
    FROM bestell_positionen bp
    WHERE bp.bestellung_id = p_bestellung_id;

    IF v_grund IS NULL AND v_gesamtwert < 5.00 THEN
        v_grund := 'Warenwert < 5 EUR';
    END IF;

    -- 3) Email
    SELECT k.email
    INTO v_email
    FROM
        bestellungen b,
        kunden k
    WHERE
        b.kunde_id       = k.kunde_id
        AND b.bestellung_id = p_bestellung_id;

    IF v_grund IS NULL THEN
        IF NOT FOUND OR v_email IS NULL OR position('@' IN v_email) = 0 THEN
            v_grund := 'Kunde ohne gültige Email';
        END IF;
    END IF;

    -- Jetzt den Gesamtstatus via Funktion prüfen (für Konsistenz):
    v_ok := fn_bestellung_ok(p_bestellung_id);

    IF v_ok THEN
        UPDATE bestellungen
        SET geprueft = TRUE
        WHERE bestellung_id = p_bestellung_id;

        RAISE NOTICE 'Bestellung %: OK, geprueft = TRUE.', p_bestellung_id;
    ELSE
        UPDATE bestellungen
        SET geprueft = FALSE
        WHERE bestellung_id = p_bestellung_id;

        -- Falls noch kein Grund gesetzt wurde, Fallback:
        IF v_grund IS NULL THEN
            v_grund := 'Unbekannter Grund (Prüfregeln prüfen)';
        END IF;

        INSERT INTO bestellung_prueflog (bestellung_id, grund, zeitpunkt)
        VALUES (p_bestellung_id, v_grund, NOW());

        RAISE NOTICE 'Bestellung %: NICHT OK, Grund: %', p_bestellung_id, v_grund;
    END IF;
END;
$$;



/* =========================================================
   Teil 3 – AFTER INSERT Trigger auf bestellungen
   - ruft pr_bestellung_pruefen_und_markieren(NEW.bestellung_id)
   ========================================================= */

CREATE OR REPLACE FUNCTION trf_bestellung_auto_pruefen()
RETURNS TRIGGER
AS $$
BEGIN
    -- direkt nach dem Einfügen prüfen
    CALL pr_bestellung_pruefen_und_markieren(NEW.bestellung_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_bestellung_auto_pruefen ON bestellungen;

CREATE TRIGGER tr_bestellung_auto_pruefen
AFTER INSERT ON bestellungen
FOR EACH ROW
EXECUTE FUNCTION trf_bestellung_auto_pruefen();



/* =========================================================
   Teil 4 – Reporting-View: v_bestellungen_geprueft
   - bestellung_id
   - kunde (Name)
   - filiale (Name)
   - bestelldatum
   - gesamtwert
   - geprueft (TRUE/FALSE)
   ========================================================= */

CREATE OR REPLACE VIEW v_bestellungen_geprueft AS
SELECT
    b.bestellung_id,
    k.name      AS kunde,
    f.name      AS filiale,
    b.bestelldatum,
    COALESCE(
        SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)),
        0.00
    ) AS gesamtwert,
    b.geprueft
FROM
    bestellungen b
LEFT JOIN kunden k
    ON b.kunde_id = k.kunde_id
LEFT JOIN filialen f
    ON b.filiale_id = f.filiale_id
LEFT JOIN bestell_positionen bp
    ON b.bestellung_id = bp.bestellung_id
GROUP BY
    b.bestellung_id,
    k.name,
    f.name,
    b.bestelldatum,
    b.geprueft;
