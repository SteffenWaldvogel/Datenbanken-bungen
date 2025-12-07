-- 08_dml_insert_update_delete_loesungen.sql
-- Übungsblatt 08 – DML (INSERT / UPDATE / DELETE)

--------------------------------------------------
-- Aufgabe 1
-- Füge einen neuen Kunden ein.
--------------------------------------------------
INSERT INTO kunden (name, email, telefon, kunden_typ, rabatt_prozent)
VALUES ('Bäckerei Testkunde', 'testkunde@example.com', '0151/0000000', 'PRIVAT', 0);


--------------------------------------------------
-- Aufgabe 2
-- Füge ein neues Produkt ein.
-- Beispiel: Neue Zimtschnecke in Kategorie "Zimtschnecken"
--------------------------------------------------
INSERT INTO produkte (kategorie_id, name, standardpreis, ist_glutenfrei, ist_vegan, aktiv)
VALUES (
    (SELECT kategorie_id
     FROM produktkategorien
     WHERE bezeichnung = 'Zimtschnecken'),
    'Hausgemachte Test-Zimtschnecke',
    2.90,
    FALSE,
    FALSE,
    TRUE
);


--------------------------------------------------
-- Aufgabe 3
-- Erhöhe den Preis aller Zimtschnecken um 10 %.
--------------------------------------------------
UPDATE produkte
SET standardpreis = standardpreis * 1.10
WHERE name ILIKE '%zimtschnecke%';


--------------------------------------------------
-- Aufgabe 4
-- Setze Telefonnummer auf Dummywert, wenn sie NULL ist.
--------------------------------------------------
UPDATE kunden
SET telefon = 'unbekannt'
WHERE telefon IS NULL;


--------------------------------------------------
-- Aufgabe 5
-- Erhöhe Rabatt aller Geschäftskunden um 5 Prozentpunkte.
--------------------------------------------------
UPDATE kunden
SET rabatt_prozent = rabatt_prozent + 5
WHERE kunden_typ = 'GESCHAEFT';


--------------------------------------------------
-- Aufgabe 6
-- Lösche alle Produkte, die nicht aktiv sind.
--------------------------------------------------
DELETE FROM produkte
WHERE aktiv = FALSE;


--------------------------------------------------
-- Aufgabe 7
-- Füge eine neue Rezept-Zutat-Beziehung ein.
-- Beispiel: Butter zur "Butter-Zimtschnecke Klassik" hinzufügen.
--------------------------------------------------
INSERT INTO rezept_zutat (rezept_id, zutat_id, menge)
VALUES (
    (SELECT rezept_id FROM rezepte WHERE name = 'Butter-Zimtschnecke Klassik'),
    (SELECT zutat_id  FROM zutaten  WHERE name = 'Butter'),
    0.050  -- 50 g als Beispiel
);


--------------------------------------------------
-- Aufgabe 8
-- Ändere die Rolle eines Mitarbeiters.
-- Beispiel: Mitarbeiter mit Nachname "Verkauf" wird Filialleitung.
--------------------------------------------------
UPDATE mitarbeiter
SET rolle = 'FILIALLEITUNG'
WHERE nachname = 'Verkauf';


--------------------------------------------------
-- Aufgabe 9
-- Lösche alle Lieferungen, die keine Positionen haben.
--------------------------------------------------
DELETE FROM lieferungen l
WHERE NOT EXISTS (
    SELECT 1
    FROM lieferung_positionen lp
    WHERE lp.lieferung_id = l.lieferung_id
);


--------------------------------------------------
-- Aufgabe 10
-- Setze Bestellungen mit Status OFFEN, die älter als 7 Tage sind, auf STORNIERT.
--------------------------------------------------
UPDATE bestellungen
SET status = 'STORNIERT'
WHERE status = 'OFFEN'
  AND bestelldatum < (NOW() - INTERVAL '7 days');


--------------------------------------------------
-- Aufgabe 11
-- Mache aus einem Produkt ein veganes UND glutenfreies Produkt.
-- Beispiel: Ein bestimmtes Produkt per Name.
--------------------------------------------------
UPDATE produkte
SET ist_vegan = TRUE,
    ist_glutenfrei = TRUE
WHERE name = 'Hausgemachte Test-Zimtschnecke';


--------------------------------------------------
-- Aufgabe 12
-- Lösche alle Backaufträge ohne Ist-Startzeit.
--------------------------------------------------
DELETE FROM backauftraege
WHERE startzeit_ist IS NULL;
