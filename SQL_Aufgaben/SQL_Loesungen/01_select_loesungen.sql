-- 01 – SELECT Basic – Lösungen

-- Aufgabe 1
SELECT produkt_id, name, standardpreis
FROM produkte
ORDER BY name;

-- Aufgabe 2
SELECT produkt_id, name, standardpreis, ist_glutenfrei, ist_vegan
FROM produkte
WHERE name ILIKE '%zimtschnecke%';

-- Aufgabe 3
SELECT kunde_id, name, email, rabatt_prozent
FROM kunden
WHERE kunden_typ = 'GESCHAEFT'
ORDER BY name;

-- Aufgabe 4
SELECT produkt_id, name, standardpreis
FROM produkte
WHERE standardpreis >= 2.50
ORDER BY standardpreis DESC;

-- Aufgabe 5
SELECT filiale_id, name, ort, plz
FROM filialen
ORDER BY ort, name;

-- Aufgabe 6
SELECT kunde_id, name, email
FROM kunden
WHERE email LIKE '%@example.com';

-- Aufgabe 7
SELECT produkt_id, name, standardpreis
FROM produkte
WHERE ist_glutenfrei = FALSE
  AND standardpreis >= 2.50;

-- Aufgabe 8
SELECT kunde_id, name, email, telefon
FROM kunden
WHERE telefon IS NULL;

-- Aufgabe 9
SELECT mitarbeiter_id, vorname, nachname, rolle, filiale_id
FROM mitarbeiter
WHERE rolle = 'BAECKER';

-- Aufgabe 10
SELECT produkt_id, name, standardpreis
FROM produkte
ORDER BY produkt_id
LIMIT 5 OFFSET 5;  -- Produkte 6–10

-- Aufgabe 11
SELECT DISTINCT rolle
FROM mitarbeiter
ORDER BY rolle;

-- Aufgabe 12
SELECT produkt_id, name, standardpreis
FROM produkte
WHERE name LIKE 'Schoko%' OR name LIKE 'Apfel%';

-- Aufgabe 13
SELECT *
FROM produkte
ORDER BY standardpreis
LIMIT 1;

-- Aufgabe 14
SELECT *
FROM kunden
WHERE rabatt_prozent = (
  SELECT MAX(rabatt_prozent) FROM kunden
);

-- Aufgabe 15
SELECT p.produkt_id, p.name, p.standardpreis, k.bezzeichnung
FROM produkte p
JOIN produktkategorien k ON p.kategorie_id = k.kategorie_id
ORDER BY k.bezeichnung, p.standardpreis DESC, p.name;

-- Aufgabe 16
SELECT filiale_id, name, plz, ort
FROM filialen
WHERE plz LIKE '123%';

-- Aufgabe 17
SELECT produkt_id, name, standardpreis
FROM produkte
WHERE name ILIKE '%schoko%'
  AND ist_vegan = FALSE;

-- Aufgabe 18
SELECT kunde_id, name, rabatt_prozent
FROM kunden
WHERE rabatt_prozent BETWEEN 5 AND 15
ORDER BY rabatt_prozent;

-- Aufgabe 19
SELECT produkt_id, name, standardpreis, ist_vegan, ist_glutenfrei
FROM produkte
WHERE standardpreis < 2
   OR name ILIKE '%zimt%'
   OR (ist_vegan = TRUE AND ist_glutenfrei = TRUE);
