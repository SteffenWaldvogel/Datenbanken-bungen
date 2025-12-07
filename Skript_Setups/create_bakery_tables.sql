-- ==============================
-- Bäckerei-Datenmodell für PostgreSQL
-- ==============================

-- (Optional) alles droppen, falls du neu anfangen willst
-- ACHTUNG: das löscht ALLE Tabellen mit diesen Namen.
-- DROP TABLE IF EXISTS lieferung_positionen, lieferungen,
--   bestell_positionen, bestellungen,
--   backauftrag_positionen, backauftraege,
--   ofen, produkt_rezept, rezept_zutat, rezepte,
--   lieferant_zutat, lieferanten, zutaten,
--   produkte, produktkategorien,
--   kunden, mitarbeiter, filialen CASCADE;

-- ==============================
-- Stammdaten
-- ==============================

CREATE TABLE filialen (
    filiale_id      SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    strasse         VARCHAR(100),
    plz             CHAR(5),
    ort             VARCHAR(100),
    telefon         VARCHAR(30),
    oeffnungszeiten VARCHAR(255)
);

CREATE TABLE mitarbeiter (
    mitarbeiter_id  SERIAL PRIMARY KEY,
    filiale_id      INTEGER NOT NULL REFERENCES filialen (filiale_id),
    vorname         VARCHAR(50) NOT NULL,
    nachname        VARCHAR(50) NOT NULL,
    rolle           VARCHAR(30) NOT NULL
                    CHECK (rolle IN ('BAECKER','VERKAEUFER','FAHRER','FILIALLEITUNG','ADMIN')),
    eintrittsdatum  DATE,
    stundenlohn     NUMERIC(7,2)  -- z.B. 99999.99
);

CREATE TABLE kunden (
    kunde_id        SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(100),
    telefon         VARCHAR(30),
    kunden_typ      VARCHAR(20) NOT NULL
                    CHECK (kunden_typ IN ('PRIVAT','GESCHAEFT')),
    rabatt_prozent  NUMERIC(5,2) NOT NULL DEFAULT 0
                    CHECK (rabatt_prozent BETWEEN 0 AND 100)
);

CREATE TABLE produktkategorien (
    kategorie_id    SERIAL PRIMARY KEY,
    bezeichnung     VARCHAR(50) NOT NULL
);

CREATE TABLE produkte (
    produkt_id      SERIAL PRIMARY KEY,
    kategorie_id    INTEGER NOT NULL REFERENCES produktkategorien (kategorie_id),
    name            VARCHAR(100) NOT NULL,
    standardpreis   NUMERIC(8,2) NOT NULL,
    ist_glutenfrei  BOOLEAN NOT NULL DEFAULT FALSE,
    ist_vegan       BOOLEAN NOT NULL DEFAULT FALSE,
    aktiv           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE zutaten (
    zutat_id        SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    einheit         VARCHAR(20) NOT NULL,      -- kg, g, l, Stk, ...
    allergen_info   VARCHAR(255)
);

CREATE TABLE lieferanten (
    lieferant_id    SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    strasse         VARCHAR(100),
    plz             CHAR(5),
    ort             VARCHAR(100),
    kontaktperson   VARCHAR(100),
    telefon         VARCHAR(30)
);

CREATE TABLE lieferant_zutat (
    lieferant_id        INTEGER NOT NULL REFERENCES lieferanten (lieferant_id),
    zutat_id            INTEGER NOT NULL REFERENCES zutaten (zutat_id),
    preis_pro_einheit   NUMERIC(10,4),
    mindestbestellmenge NUMERIC(10,3),
    PRIMARY KEY (lieferant_id, zutat_id)
);

-- ==============================
-- Rezepte & Produktion
-- ==============================

CREATE TABLE rezepte (
    rezept_id           SERIAL PRIMARY KEY,
    name                VARCHAR(100) NOT NULL,
    beschreibung        TEXT,
    arbeitszeit_minuten INTEGER,
    backzeit_minuten    INTEGER
);

CREATE TABLE rezept_zutat (
    rezept_id   INTEGER NOT NULL REFERENCES rezepte (rezept_id),
    zutat_id    INTEGER NOT NULL REFERENCES zutaten (zutat_id),
    menge       NUMERIC(10,3) NOT NULL,   -- z.B. 0.250 kg
    PRIMARY KEY (rezept_id, zutat_id)
);

CREATE TABLE produkt_rezept (
    produkt_id          INTEGER NOT NULL REFERENCES produkte (produkt_id),
    rezept_id           INTEGER NOT NULL REFERENCES rezepte (rezept_id),
    ist_standardrezept  BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (produkt_id, rezept_id)
);

CREATE TABLE ofen (
    ofen_id         SERIAL PRIMARY KEY,
    filiale_id      INTEGER NOT NULL REFERENCES filialen (filiale_id),
    bezeichnung     VARCHAR(50) NOT NULL,
    max_temp        INTEGER,         -- in °C
    kapazitaet_bleche INTEGER        -- Anzahl Bleche
);

CREATE TABLE backauftraege (
    backauftrag_id      SERIAL PRIMARY KEY,
    filiale_id          INTEGER NOT NULL REFERENCES filialen (filiale_id),
    ofen_id             INTEGER REFERENCES ofen (ofen_id),
    geplant_von         INTEGER REFERENCES mitarbeiter (mitarbeiter_id),
    startzeit_geplant   TIMESTAMP,
    startzeit_ist       TIMESTAMP,
    status              VARCHAR(20) NOT NULL
                        CHECK (status IN ('GEPLANT','IN_ARBEIT','FERTIG','STORNIERT'))
);

CREATE TABLE backauftrag_positionen (
    backauftrag_id      INTEGER NOT NULL REFERENCES backauftraege (backauftrag_id),
    positions_nr        INTEGER NOT NULL,
    produkt_id          INTEGER NOT NULL REFERENCES produkte (produkt_id),
    anzahl_teiglinge    INTEGER NOT NULL CHECK (anzahl_teiglinge > 0),
    PRIMARY KEY (backauftrag_id, positions_nr)
);

-- ==============================
-- Verkauf & Logistik
-- ==============================

CREATE TABLE bestellungen (
    bestellung_id   SERIAL PRIMARY KEY,
    kunde_id        INTEGER NOT NULL REFERENCES kunden (kunde_id),
    filiale_id      INTEGER NOT NULL REFERENCES filialen (filiale_id),
    bestelldatum    TIMESTAMP NOT NULL DEFAULT NOW(),
    abholdatum      TIMESTAMP,
    status          VARCHAR(20) NOT NULL
                    CHECK (status IN ('OFFEN','IN_PRODUKTION','ABGEHOLT','STORNIERT')),
    zahlungsart     VARCHAR(20) NOT NULL
                    CHECK (zahlungsart IN ('BAR','EC','RECHNUNG'))
);

CREATE TABLE bestell_positionen (
    bestellung_id       INTEGER NOT NULL REFERENCES bestellungen (bestellung_id),
    positions_nr        INTEGER NOT NULL,
    produkt_id          INTEGER NOT NULL REFERENCES produkte (produkt_id),
    anzahl              INTEGER NOT NULL CHECK (anzahl > 0),
    einzelpreis         NUMERIC(8,2) NOT NULL,
    rabatt_prozent      NUMERIC(5,2) NOT NULL DEFAULT 0
                        CHECK (rabatt_prozent BETWEEN 0 AND 100),
    PRIMARY KEY (bestellung_id, positions_nr)
);

CREATE TABLE lieferungen (
    lieferung_id    SERIAL PRIMARY KEY,
    von_filiale_id  INTEGER NOT NULL REFERENCES filialen (filiale_id),
    zu_filiale_id   INTEGER NOT NULL REFERENCES filialen (filiale_id),
    lieferdatum     DATE NOT NULL,
    fahrer_id       INTEGER REFERENCES mitarbeiter (mitarbeiter_id)
);

CREATE TABLE lieferung_positionen (
    lieferung_id    INTEGER NOT NULL REFERENCES lieferungen (lieferung_id),
    positions_nr    INTEGER NOT NULL,
    produkt_id      INTEGER NOT NULL REFERENCES produkte (produkt_id),
    anzahl          INTEGER NOT NULL CHECK (anzahl > 0),
    PRIMARY KEY (lieferung_id, positions_nr)
);

-- ==============================
-- Benutzer & Rechte (zum Üben von GRANT)
-- Diese Befehle kannst du auch getrennt ausführen,
-- z.B. in einem eigenen Script: create_users_and_grants.sql
-- ==============================

-- Achtung: CREATE USER geht nur, wenn du als Superuser (z.B. postgres) eingeloggt bist.

CREATE USER bakery_admin   WITH PASSWORD 'admin123';
CREATE USER bakery_azubi   WITH PASSWORD 'azubi123';
CREATE USER bakery_readonly WITH PASSWORD 'readonly123';

-- Rechte auf die Datenbank selbst
GRANT CONNECT ON DATABASE bakery_db TO bakery_admin, bakery_azubi, bakery_readonly;

-- Rechte auf das Schema public
GRANT USAGE ON SCHEMA public TO bakery_admin, bakery_azubi, bakery_readonly;

-- Tabellenrechte:
-- Admin & Azubi: lesen + schreiben
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public
TO bakery_admin, bakery_azubi;

-- Readonly: nur lesen
GRANT SELECT ON ALL TABLES IN SCHEMA public
TO bakery_readonly;

-- Für SERIAL-Spalten: Rechte auf Sequenzen, damit Inserts funktionieren
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public
TO bakery_admin, bakery_azubi;

-- Jetzt kannst du z.B. testen:
--   \c bakery_db bakery_azubi
--   SELECT * FROM filialen;
--   INSERT INTO filialen (name, plz, ort) VALUES ('Filiale Innenstadt', '12345', 'Musterstadt');
