-- 04_trigger_baeckerei_logik_loesungen.sql
-- Lösungen zu: 04 – Trigger in der Bäckerei-Datenbank
-- Sprache: PostgreSQL / PL/pgSQL
-- Hinweis: ALTER TABLE-Befehle nur 1x ausführen.


/* =========================================================
   Aufgabe 1 – Timestamp beim Einfügen von Bestellungen
   Spalte: erstellt_am TIMESTAMP DEFAULT NOW()
   Trigger: BEFORE INSERT, setzt erstellt_am falls NULL
   ========================================================= */

-- Falls noch nicht vorhanden:
-- ALTER TABLE bestellungen
--   ADD COLUMN IF NOT EXISTS erstellt_am TIMESTAMP DEFAULT NOW();

CREATE OR REPLACE FUNCTION trf_bestellung_set_erstellt()
RETURNS TRIGGER
AS $$
BEGIN
    IF NEW.erstellt_am IS NULL THEN
        NEW.erstellt_am := NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_bestellung_set_erstellt ON bestellungen;

CREATE TRIGGER tr_bestellung_set_erstellt
BEFORE INSERT ON bestellungen
FOR EACH ROW
EXECUTE FUNCTION trf_bestellung_set_erstellt();


/* =========================================================
   Aufgabe 2 – Status bei neuer Bestellung automatisch setzen
   Wenn NEW.status NULL -> 'OFFEN'
   ========================================================= */

CREATE OR REPLACE FUNCTION trf_bestellung_default_status()
RETURNS TRIGGER
AS $$
BEGIN
    IF NEW.status IS NULL THEN
        NEW.status := 'OFFEN';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_bestellung_default_status ON bestellungen;

CREATE TRIGGER tr_bestellung_default_status
BEFORE INSERT ON bestellungen
FOR EACH ROW
EXECUTE FUNCTION trf_bestellung_default_status();


/* =========================================================
   Aufgabe 3 – Logging von Preisänderungen
   Tabelle: preislog
   Trigger: BEFORE UPDATE OF standardpreis ON produkte
   ========================================================= */

-- Logging-Tabelle anlegen (falls noch nicht vorhanden):
-- Achtung: Typen ggf. an deine Produkte anpassen

CREATE TABLE IF NOT EXISTS preislog (
    log_id        SERIAL PRIMARY KEY,
    produkt_id    INT NOT NULL,
    alter_preis   NUMERIC(8,2),
    neuer_preis   NUMERIC(8,2),
    geaendert_am  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION trf_preislog_schreiben()
RETURNS TRIGGER
AS $$
BEGIN
    -- Nur loggen, wenn sich der Preis wirklich ändert
    IF NEW.standardpreis IS DISTINCT FROM OLD.standardpreis THEN
        INSERT INTO preislog (produkt_id, alter_preis, neuer_preis, geaendert_am)
        VALUES (OLD.produkt_id, OLD.standardpreis, NEW.standardpreis, NOW());
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_preislog_schreiben ON produkte;

CREATE TRIGGER tr_preislog_schreiben
BEFORE UPDATE OF standardpreis ON produkte
FOR EACH ROW
EXECUTE FUNCTION trf_preislog_schreiben();


/* =========================================================
   Aufgabe 4 – Rabatt-Validierung
   rabatt_prozent muss zwischen 0 und 50 liegen
   BEFORE INSERT OR UPDATE auf kunden
   ========================================================= */

CREATE OR REPLACE FUNCTION trf_kunden_rabatt_validierung()
RETURNS TRIGGER
AS $$
BEGIN
    IF NEW.rabatt_prozent < 0 OR NEW.rabatt_prozent > 50 THEN
        RAISE EXCEPTION 'Rabatt % außerhalb des erlaubten Bereichs (0–50)', NEW.rabatt_prozent;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_kunden_rabatt_validierung ON kunden;

CREATE TRIGGER tr_kunden_rabatt_validierung
BEFORE INSERT OR UPDATE ON kunden
FOR EACH ROW
EXECUTE FUNCTION trf_kunden_rabatt_validierung();


/* =========================================================
   Aufgabe 5 – Auto-Bestellstatus bei leeren Positionen
   AFTER DELETE auf bestell_positionen:
   Wenn keine Positionen mehr -> status = 'LEER'
   ========================================================= */

CREATE OR REPLACE FUNCTION trf_bestellung_leer_setzen()
RETURNS TRIGGER
AS $$
DECLARE
    v_anzahl INT;
BEGIN
    -- Zähle verbleibende Positionen der betroffenen Bestellung
    SELECT COUNT(*)
    INTO v_anzahl
    FROM bestell_positionen
    WHERE bestellung_id = OLD.bestellung_id;

    IF v_anzahl = 0 THEN
        UPDATE bestellungen
        SET status = 'LEER'
        WHERE bestellung_id = OLD.bestellung_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_bestellung_leer_setzen ON bestell_positionen;

CREATE TRIGGER tr_bestellung_leer_setzen
AFTER DELETE ON bestell_positionen
FOR EACH ROW
EXECUTE FUNCTION trf_bestellung_leer_setzen();


/* =========================================================
   Aufgabe 6 – Änderungslog für Kunden
   Tabelle: kundenlog
   Trigger: BEFORE/AFTER INSERT, UPDATE, DELETE auf kunden
   ========================================================= */

-- Logging-Tabelle:
CREATE TABLE IF NOT EXISTS kundenlog (
    log_id     SERIAL PRIMARY KEY,
    kunde_id   INT,
    aktion     TEXT,
    alt_name   TEXT,
    neu_name   TEXT,
    zeitpunkt  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION trf_kundenlog()
RETURNS TRIGGER
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO kundenlog (kunde_id, aktion, alt_name, neu_name, zeitpunkt)
        VALUES (NEW.kunde_id, 'INSERT', NULL, NEW.name, NOW());

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO kundenlog (kunde_id, aktion, alt_name, neu_name, zeitpunkt)
        VALUES (NEW.kunde_id, 'UPDATE', OLD.name, NEW.name, NOW());

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO kundenlog (kunde_id, aktion, alt_name, neu_name, zeitpunkt)
        VALUES (OLD.kunde_id, 'DELETE', OLD.name, NULL, NOW());

        RETURN OLD;
    END IF;

    -- Fallback
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_kundenlog ON kunden;

CREATE TRIGGER tr_kundenlog
AFTER INSERT OR UPDATE OR DELETE ON kunden
FOR EACH ROW
EXECUTE FUNCTION trf_kundenlog();
