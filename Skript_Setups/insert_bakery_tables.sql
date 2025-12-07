-- ==========================================
-- INSERT-DATEN FÜR BÄCKEREI-DB (PostgreSQL)
-- ==========================================
-- Voraussetzung: Alle Tabellen aus create_bakery_tables.sql existieren.

-- =========================
-- FILIALEN
-- =========================

INSERT INTO filialen (name, strasse, plz, ort, telefon, oeffnungszeiten) VALUES
('Filiale Innenstadt',    'Hauptstr. 1',   '12345', 'Musterstadt', '01234/11111', 'Mo–Sa 06:00–19:00'),
('Filiale Bahnhof',       'Bahnhofstr. 5', '12345', 'Musterstadt', '01234/22222', 'Mo–So 05:30–20:00'),
('Filiale Gewerbegebiet', 'Industrie 12',  '12346', 'Musterstadt', '01234/33333', 'Mo–Fr 05:00–16:00');

-- =========================
-- MITARBEITER
-- =========================

INSERT INTO mitarbeiter (filiale_id, vorname, nachname, rolle, eintrittsdatum, stundenlohn)
VALUES
((SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 'Anna','Bäcker','BAECKER','2020-03-01', 18.50),
((SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 'Lukas','Verkauf','VERKAEUFER','2021-07-15', 13.80),
((SELECT filiale_id FROM filialen WHERE name = 'Filiale Bahnhof'),
 'Mara','Ofen','BAECKER','2019-09-01', 19.20),
((SELECT filiale_id FROM filialen WHERE name = 'Filiale Gewerbegebiet'),
 'Tim','Fahrer','FAHRER','2022-01-10', 14.50),
((SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 'Julia','Leitung','FILIALLEITUNG','2018-05-01', 21.00);

-- =========================
-- KUNDEN
-- =========================

INSERT INTO kunden (name, email, telefon, kunden_typ, rabatt_prozent) VALUES
('Max Mustermann', 'max@example.com', '0151/111111', 'PRIVAT', 0),
('Büro GmbH',      'einkauf@buero-gmbh.de', '0711/222222', 'GESCHAEFT', 10),
('Fitnessstudio Fit & Stark', 'info@fit-stark.de', '0711/333333', 'GESCHAEFT', 5),
('Lisa Kunde', 'lisa@example.com', '0157/444444', 'PRIVAT', 0);

-- =========================
-- PRODUKTKATEGORIEN
-- =========================

INSERT INTO produktkategorien (bezeichnung) VALUES
('Brot'),
('Brötchen'),
('Kuchen'),
('Zimtschnecken'),
('Snacks'),
('Getränke');

-- =========================
-- ZUTATEN
-- =========================

INSERT INTO zutaten (name, einheit, allergen_info) VALUES
('Weizenmehl Type 550', 'kg', 'Gluten'),
('Vollkornmehl',        'kg', 'Gluten'),
('Wasser',              'l',  NULL),
('Hefe',                'kg', 'Kann Spuren von Gluten enthalten'),
('Zucker',              'kg', NULL),
('Salz',                'kg', NULL),
('Butter',              'kg', 'Milch'),
('Zimt',                'kg', NULL),
('Kakaopulver',         'kg', NULL),
('Schokostückchen',     'kg', 'Milch, Soja'),
('Apfelwürfel',         'kg', NULL),
('Milch',               'l',  'Milch'),
('Ei',                  'Stk','Ei'),
('Pflanzenöl',          'l',  NULL),
('Kaffeebohnen',        'kg', NULL);

-- =========================
-- LIEFERANTEN
-- =========================

INSERT INTO lieferanten (name, strasse, plz, ort, kontaktperson, telefon) VALUES
('Mühlengold KG',       'Mühlenweg 10',  '70001', 'Stuttgart',   'Herr Müller', '0711/555555'),
('Süß & Fein GmbH',     'Zuckerallee 3', '70002', 'Stuttgart',   'Frau Süß',    '0711/666666'),
('Fruchtimport AG',     'Obstring 7',    '70003', 'Stuttgart',   'Herr Apfel',  '0711/777777'),
('Milchhof eG',         'Kuhweg 1',      '70004', 'Stuttgart',   'Frau Kuh',    '0711/888888'),
('Rösterei Schwarz',    'Kaffeegasse 9', '70005', 'Stuttgart',   'Herr Schwarz','0711/999999');

-- =========================
-- LIEFERANT_ZUTAT (N:M)
-- =========================

INSERT INTO lieferant_zutat (lieferant_id, zutat_id, preis_pro_einheit, mindestbestellmenge) VALUES
((SELECT lieferant_id FROM lieferanten WHERE name = 'Mühlengold KG'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Weizenmehl Type 550'),
 0.45, 25.0),
((SELECT lieferant_id FROM lieferanten WHERE name = 'Mühlengold KG'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Vollkornmehl'),
 0.60, 25.0),
((SELECT lieferant_id FROM lieferanten WHERE name = 'Süß & Fein GmbH'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Zucker'),
 0.80, 10.0),
((SELECT lieferant_id FROM lieferanten WHERE name = 'Süß & Fein GmbH'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Kakaopulver'),
 3.50, 5.0),
((SELECT lieferant_id FROM lieferanten WHERE name = 'Süß & Fein GmbH'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Schokostückchen'),
 4.20, 5.0),
((SELECT lieferant_id FROM lieferanten WHERE name = 'Fruchtimport AG'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Apfelwürfel'),
 2.00, 10.0),
((SELECT lieferant_id FROM lieferanten WHERE name = 'Milchhof eG'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Butter'),
 4.00, 5.0),
((SELECT lieferant_id FROM lieferanten WHERE name = 'Milchhof eG'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Milch'),
 0.90, 20.0),
((SELECT lieferant_id FROM lieferanten WHERE name = 'Milchhof eG'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Ei'),
 0.12, 180.0),
((SELECT lieferant_id FROM lieferanten WHERE name = 'Rösterei Schwarz'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Kaffeebohnen'),
 12.00, 5.0);

-- =========================
-- REZEPTE
-- =========================

INSERT INTO rezepte (name, beschreibung, arbeitszeit_minuten, backzeit_minuten) VALUES
('Butter-Zimtschnecke Klassik',
 'Hefeteigschnecke mit Butter-Zimt-Füllung.',
 30, 12),
('Schoko-Zimtschnecke',
 'Zimtschnecke mit zusätzlicher Schokofüllung und Schokostückchen.',
 35, 13),
('Apfel-Zimt-Schnecke',
 'Zimtschnecke mit Apfelstückchen.',
 35, 14),
('Vollkornbrot Rustikal',
 'Kräftiges Vollkornbrot mit langer Teigführung.',
 40, 45),
('Baguette Hell',
 'Knuspriges Weißbrot mit hoher Kruste.',
 30, 22),
('Filterkaffee Klassik',
 'Gebrühter Filterkaffee aus mittlerer Röstung.',
 5, 0);

-- =========================
-- REZEPT_ZUTAT (N:M)
-- =========================

-- Butter-Zimtschnecke Klassik
INSERT INTO rezept_zutat (rezept_id, zutat_id, menge) VALUES
((SELECT rezept_id FROM rezepte WHERE name = 'Butter-Zimtschnecke Klassik'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Weizenmehl Type 550'),
 0.250),
((SELECT rezept_id FROM rezepte WHERE name = 'Butter-Zimtschnecke Klassik'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Wasser'),
 0.100),
((SELECT rezept_id FROM rezepte WHERE name = 'Butter-Zimtschnecke Klassik'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Hefe'),
 0.010),
((SELECT rezept_id FROM rezepte WHERE name = 'Butter-Zimtschnecke Klassik'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Zucker'),
 0.040),
((SELECT rezept_id FROM rezepte WHERE name = 'Butter-Zimtschnecke Klassik'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Butter'),
 0.050),
((SELECT rezept_id FROM rezepte WHERE name = 'Butter-Zimtschnecke Klassik'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Zimt'),
 0.005),
((SELECT rezept_id FROM rezepte WHERE name = 'Butter-Zimtschnecke Klassik'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Salz'),
 0.005);

-- Schoko-Zimtschnecke
INSERT INTO rezept_zutat (rezept_id, zutat_id, menge) VALUES
((SELECT rezept_id FROM rezepte WHERE name = 'Schoko-Zimtschnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Weizenmehl Type 550'),
 0.250),
((SELECT rezept_id FROM rezepte WHERE name = 'Schoko-Zimtschnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Wasser'),
 0.100),
((SELECT rezept_id FROM rezepte WHERE name = 'Schoko-Zimtschnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Hefe'),
 0.010),
((SELECT rezept_id FROM rezepte WHERE name = 'Schoko-Zimtschnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Zucker'),
 0.050),
((SELECT rezept_id FROM rezepte WHERE name = 'Schoko-Zimtschnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Butter'),
 0.050),
((SELECT rezept_id FROM rezepte WHERE name = 'Schoko-Zimtschnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Zimt'),
 0.005),
((SELECT rezept_id FROM rezepte WHERE name = 'Schoko-Zimtschnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Schokostückchen'),
 0.040);

-- Apfel-Zimt-Schnecke
INSERT INTO rezept_zutat (rezept_id, zutat_id, menge) VALUES
((SELECT rezept_id FROM rezepte WHERE name = 'Apfel-Zimt-Schnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Weizenmehl Type 550'),
 0.250),
((SELECT rezept_id FROM rezepte WHERE name = 'Apfel-Zimt-Schnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Wasser'),
 0.100),
((SELECT rezept_id FROM rezepte WHERE name = 'Apfel-Zimt-Schnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Hefe'),
 0.010),
((SELECT rezept_id FROM rezepte WHERE name = 'Apfel-Zimt-Schnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Zucker'),
 0.040),
((SELECT rezept_id FROM rezepte WHERE name = 'Apfel-Zimt-Schnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Butter'),
 0.050),
((SELECT rezept_id FROM rezepte WHERE name = 'Apfel-Zimt-Schnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Zimt'),
 0.005),
((SELECT rezept_id FROM rezepte WHERE name = 'Apfel-Zimt-Schnecke'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Apfelwürfel'),
 0.050);

-- Vollkornbrot Rustikal
INSERT INTO rezept_zutat (rezept_id, zutat_id, menge) VALUES
((SELECT rezept_id FROM rezepte WHERE name = 'Vollkornbrot Rustikal'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Vollkornmehl'),
 0.500),
((SELECT rezept_id FROM rezepte WHERE name = 'Vollkornbrot Rustikal'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Wasser'),
 0.350),
((SELECT rezept_id FROM rezepte WHERE name = 'Vollkornbrot Rustikal'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Hefe'),
 0.005),
((SELECT rezept_id FROM rezepte WHERE name = 'Vollkornbrot Rustikal'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Salz'),
 0.010);

-- Baguette Hell
INSERT INTO rezept_zutat (rezept_id, zutat_id, menge) VALUES
((SELECT rezept_id FROM rezepte WHERE name = 'Baguette Hell'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Weizenmehl Type 550'),
 0.350),
((SELECT rezept_id FROM rezepte WHERE name = 'Baguette Hell'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Wasser'),
 0.230),
((SELECT rezept_id FROM rezepte WHERE name = 'Baguette Hell'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Hefe'),
 0.005),
((SELECT rezept_id FROM rezepte WHERE name = 'Baguette Hell'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Salz'),
 0.008);

-- Filterkaffee Klassik
INSERT INTO rezept_zutat (rezept_id, zutat_id, menge) VALUES
((SELECT rezept_id FROM rezepte WHERE name = 'Filterkaffee Klassik'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Kaffeebohnen'),
 0.015),
((SELECT rezept_id FROM rezepte WHERE name = 'Filterkaffee Klassik'),
 (SELECT zutat_id FROM zutaten WHERE name = 'Wasser'),
 0.200);

-- =========================
-- PRODUKTE
-- =========================

INSERT INTO produkte (kategorie_id, name, standardpreis, ist_glutenfrei, ist_vegan, aktiv)
VALUES
((SELECT kategorie_id FROM produktkategorien WHERE bezeichnung = 'Zimtschnecken'),
 'Butter-Zimtschnecke', 2.50, FALSE, FALSE, TRUE),
((SELECT kategorie_id FROM produktkategorien WHERE bezeichnung = 'Zimtschnecken'),
 'Schoko-Zimtschnecke', 2.80, FALSE, FALSE, TRUE),
((SELECT kategorie_id FROM produktkategorien WHERE bezeichnung = 'Zimtschnecken'),
 'Apfel-Zimt-Schnecke', 2.90, FALSE, FALSE, TRUE),
((SELECT kategorie_id FROM produktkategorien WHERE bezeichnung = 'Brot'),
 'Vollkornbrot Rustikal 750g', 4.20, FALSE, FALSE, TRUE),
((SELECT kategorie_id FROM produktkategorien WHERE bezeichnung = 'Brot'),
 'Baguette Hell', 2.10, FALSE, TRUE, TRUE),
((SELECT kategorie_id FROM produktkategorien WHERE bezeichnung = 'Getränke'),
 'Filterkaffee klein', 1.80, TRUE, TRUE, TRUE),
((SELECT kategorie_id FROM produktkategorien WHERE bezeichnung = 'Getränke'),
 'Filterkaffee groß', 2.20, TRUE, TRUE, TRUE);

-- =========================
-- PRODUKT_REZEPT
-- =========================

INSERT INTO produkt_rezept (produkt_id, rezept_id, ist_standardrezept) VALUES
((SELECT produkt_id FROM produkte WHERE name = 'Butter-Zimtschnecke'),
 (SELECT rezept_id  FROM rezepte  WHERE name = 'Butter-Zimtschnecke Klassik'),
 TRUE),
((SELECT produkt_id FROM produkte WHERE name = 'Schoko-Zimtschnecke'),
 (SELECT rezept_id  FROM rezepte  WHERE name = 'Schoko-Zimtschnecke'),
 TRUE),
((SELECT produkt_id FROM produkte WHERE name = 'Apfel-Zimt-Schnecke'),
 (SELECT rezept_id  FROM rezepte  WHERE name = 'Apfel-Zimt-Schnecke'),
 TRUE),
((SELECT produkt_id FROM produkte WHERE name = 'Vollkornbrot Rustikal 750g'),
 (SELECT rezept_id  FROM rezepte  WHERE name = 'Vollkornbrot Rustikal'),
 TRUE),
((SELECT produkt_id FROM produkte WHERE name = 'Baguette Hell'),
 (SELECT rezept_id  FROM rezepte  WHERE name = 'Baguette Hell'),
 TRUE),
((SELECT produkt_id FROM produkte WHERE name = 'Filterkaffee klein'),
 (SELECT rezept_id  FROM rezepte  WHERE name = 'Filterkaffee Klassik'),
 TRUE),
((SELECT produkt_id FROM produkte WHERE name = 'Filterkaffee groß'),
 (SELECT rezept_id  FROM rezepte  WHERE name = 'Filterkaffee Klassik'),
 TRUE);

-- =========================
-- OFEN
-- =========================

INSERT INTO ofen (filiale_id, bezeichnung, max_temp, kapazitaet_bleche) VALUES
((SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 'Ofen 1 Innenstadt', 280, 8),
((SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 'Ofen 2 Innenstadt', 260, 6),
((SELECT filiale_id FROM filialen WHERE name = 'Filiale Bahnhof'),
 'Ofen Bahnhof', 260, 6),
((SELECT filiale_id FROM filialen WHERE name = 'Filiale Gewerbegebiet'),
 'Ofen Produktion', 300, 10);

-- =========================
-- BACKAUFTRAEGE
-- =========================

INSERT INTO backauftraege (filiale_id, ofen_id, geplant_von, startzeit_geplant, startzeit_ist, status)
VALUES
(
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 (SELECT ofen_id FROM ofen WHERE bezeichnung = 'Ofen 1 Innenstadt'),
 (SELECT mitarbeiter_id FROM mitarbeiter WHERE vorname = 'Anna' AND nachname = 'Bäcker'),
 '2025-12-01 05:30', '2025-12-01 05:35', 'IN_ARBEIT'
),
(
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 (SELECT ofen_id FROM ofen WHERE bezeichnung = 'Ofen 2 Innenstadt'),
 (SELECT mitarbeiter_id FROM mitarbeiter WHERE vorname = 'Anna' AND nachname = 'Bäcker'),
 '2025-12-01 06:30', NULL, 'GEPLANT'
),
(
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Bahnhof'),
 (SELECT ofen_id FROM ofen WHERE bezeichnung = 'Ofen Bahnhof'),
 (SELECT mitarbeiter_id FROM mitarbeiter WHERE vorname = 'Mara' AND nachname = 'Ofen'),
 '2025-12-01 05:00', '2025-12-01 05:00', 'FERTIG'
);

-- =========================
-- BACKAUFTRAG_POSITIONEN
-- =========================

INSERT INTO backauftrag_positionen (backauftrag_id, positions_nr, produkt_id, anzahl_teiglinge)
VALUES
((SELECT backauftrag_id FROM backauftraege
  WHERE filiale_id = (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt')
    AND status = 'IN_ARBEIT'
    LIMIT 1),
 1,
 (SELECT produkt_id FROM produkte WHERE name = 'Butter-Zimtschnecke'),
 60),
((SELECT backauftrag_id FROM backauftraege
  WHERE filiale_id = (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt')
    AND status = 'IN_ARBEIT'
    LIMIT 1),
 2,
 (SELECT produkt_id FROM produkte WHERE name = 'Schoko-Zimtschnecke'),
 40),
((SELECT backauftrag_id FROM backauftraege
  WHERE filiale_id = (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt')
    AND status = 'GEPLANT'
    LIMIT 1),
 1,
 (SELECT produkt_id FROM produkte WHERE name = 'Apfel-Zimt-Schnecke'),
 30),
((SELECT backauftrag_id FROM backauftraege
  WHERE filiale_id = (SELECT filiale_id FROM filialen WHERE name = 'Filiale Bahnhof')
    AND status = 'FERTIG'
    LIMIT 1),
 1,
 (SELECT produkt_id FROM produkte WHERE name = 'Baguette Hell'),
 40);

-- =========================
-- BESTELLUNGEN
-- =========================

INSERT INTO bestellungen (kunde_id, filiale_id, bestelldatum, abholdatum, status, zahlungsart)
VALUES
((SELECT kunde_id FROM kunden WHERE name = 'Max Mustermann'),
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 '2025-12-01 07:10', '2025-12-01 07:30', 'OFFEN', 'BAR'),
((SELECT kunde_id FROM kunden WHERE name = 'Büro GmbH'),
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 '2025-12-01 06:30', '2025-12-01 09:00', 'IN_PRODUKTION', 'RECHNUNG'),
((SELECT kunde_id FROM kunden WHERE name = 'Fitnessstudio Fit & Stark'),
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Bahnhof'),
 '2025-12-01 05:45', '2025-12-01 06:15', 'ABGEHOLT', 'EC'),
((SELECT kunde_id FROM kunden WHERE name = 'Lisa Kunde'),
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 '2025-12-01 08:00', NULL, 'OFFEN', 'BAR');

-- =========================
-- BESTELL_POSITIONEN
-- =========================

INSERT INTO bestell_positionen (bestellung_id, positions_nr, produkt_id, anzahl, einzelpreis, rabatt_prozent)
VALUES
-- Max Mustermann
((SELECT bestellung_id FROM bestellungen
  WHERE kunde_id = (SELECT kunde_id FROM kunden WHERE name = 'Max Mustermann')
  LIMIT 1),
 1,
 (SELECT produkt_id FROM produkte WHERE name = 'Butter-Zimtschnecke'),
 2, 2.50, 0),
((SELECT bestellung_id FROM bestellungen
  WHERE kunde_id = (SELECT kunde_id FROM kunden WHERE name = 'Max Mustermann')
  LIMIT 1),
 2,
 (SELECT produkt_id FROM produkte WHERE name = 'Filterkaffee klein'),
 1, 1.80, 0),

-- Büro GmbH
((SELECT bestellung_id FROM bestellungen
  WHERE kunde_id = (SELECT kunde_id FROM kunden WHERE name = 'Büro GmbH')
  LIMIT 1),
 1,
 (SELECT produkt_id FROM produkte WHERE name = 'Butter-Zimtschnecke'),
 20, 2.50, 10),
((SELECT bestellung_id FROM bestellungen
  WHERE kunde_id = (SELECT kunde_id FROM kunden WHERE name = 'Büro GmbH')
  LIMIT 1),
 2,
 (SELECT produkt_id FROM produkte WHERE name = 'Schoko-Zimtschnecke'),
 10, 2.80, 10),
((SELECT bestellung_id FROM bestellungen
  WHERE kunde_id = (SELECT kunde_id FROM kunden WHERE name = 'Büro GmbH')
  LIMIT 1),
 3,
 (SELECT produkt_id FROM produkte WHERE name = 'Filterkaffee groß'),
 5, 2.20, 0),

-- Fitnessstudio
((SELECT bestellung_id FROM bestellungen
  WHERE kunde_id = (SELECT kunde_id FROM kunden WHERE name = 'Fitnessstudio Fit & Stark')
  LIMIT 1),
 1,
 (SELECT produkt_id FROM produkte WHERE name = 'Apfel-Zimt-Schnecke'),
 8, 2.90, 5),

-- Lisa Kunde
((SELECT bestellung_id FROM bestellungen
  WHERE kunde_id = (SELECT kunde_id FROM kunden WHERE name = 'Lisa Kunde')
  LIMIT 1),
 1,
 (SELECT produkt_id FROM produkte WHERE name = 'Baguette Hell'),
 1, 2.10, 0),
((SELECT bestellung_id FROM bestellungen
  WHERE kunde_id = (SELECT kunde_id FROM kunden WHERE name = 'Lisa Kunde')
  LIMIT 1),
 2,
 (SELECT produkt_id FROM produkte WHERE name = 'Butter-Zimtschnecke'),
 1, 2.50, 0);

-- =========================
-- LIEFERUNGEN (zwischen Filialen)
-- =========================

INSERT INTO lieferungen (von_filiale_id, zu_filiale_id, lieferdatum, fahrer_id)
VALUES
(
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Gewerbegebiet'),
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt'),
 '2025-11-30',
 (SELECT mitarbeiter_id FROM mitarbeiter WHERE vorname = 'Tim' AND nachname = 'Fahrer')
),
(
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Gewerbegebiet'),
 (SELECT filiale_id FROM filialen WHERE name = 'Filiale Bahnhof'),
 '2025-11-30',
 (SELECT mitarbeiter_id FROM mitarbeiter WHERE vorname = 'Tim' AND nachname = 'Fahrer')
);

-- =========================
-- LIEFERUNG_POSITIONEN
-- =========================

INSERT INTO lieferung_positionen (lieferung_id, positions_nr, produkt_id, anzahl)
VALUES
((SELECT lieferung_id FROM lieferungen
  WHERE zu_filiale_id = (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt')
  LIMIT 1),
 1,
 (SELECT produkt_id FROM produkte WHERE name = 'Vollkornbrot Rustikal 750g'),
 30),
((SELECT lieferung_id FROM lieferungen
  WHERE zu_filiale_id = (SELECT filiale_id FROM filialen WHERE name = 'Filiale Innenstadt')
  LIMIT 1),
 2,
 (SELECT produkt_id FROM produkte WHERE name = 'Baguette Hell'),
 40),
((SELECT lieferung_id FROM lieferungen
  WHERE zu_filiale_id = (SELECT filiale_id FROM filialen WHERE name = 'Filiale Bahnhof')
  LIMIT 1),
 1,
 (SELECT produkt_id FROM produkte WHERE name = 'Vollkornbrot Rustikal 750g'),
 20),
((SELECT lieferung_id FROM lieferungen
  WHERE zu_filiale_id = (SELECT filiale_id FROM filialen WHERE name = 'Filiale Bahnhof')
  LIMIT 1),
 2,
 (SELECT produkt_id FROM produkte WHERE name = 'Butter-Zimtschnecke'),
 50);
