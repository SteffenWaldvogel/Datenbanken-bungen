-- 02 – Filter & Bedingungen – Lösungen

-- Aufgabe 1
SELECT *
FROM produkte
WHERE standardpreis BETWEEN 2.00 AND 4.00;

-- Aufgabe 2
SELECT *
FROM kunden
WHERE name LIKE 'M%';

-- Aufgabe 3
SELECT *
FROM produkte
WHERE kategorie_id IN (1,3,4);

-- Aufgabe 4
SELECT *
FROM mitarbeiter
WHERE eintrittsdatum < DATE '2020-01-01';

-- Aufgabe 5
SELECT *
FROM produkte
WHERE kategorie_id IS NULL;

-- Aufgabe 6
SELECT *
FROM kunden
WHERE telefon NOT LIKE '%015%';

-- Aufgabe 7 (grob: „drei Wörter“ → 2 Leerzeichen)
SELECT *
FROM produkte
WHERE name LIKE '% % %'
  AND name NOT LIKE '% % % %';

-- Aufgabe 8
SELECT *
FROM mitarbeiter
WHERE rolle <> 'VERKAEUFER';

-- Aufgabe 9
SELECT *
FROM kunden
ORDER BY name DESC;

-- Aufgabe 10
SELECT *
FROM produkte
WHERE standardpreis IN (2.99, 3.49, 4.99);

-- Aufgabe 11
SELECT *
FROM produkte
WHERE name >= 'A' AND name < 'L'
ORDER BY name;

-- Aufgabe 12
SELECT *
FROM kunden
WHERE name ILIKE '%a%' AND name ILIKE '%e%';

-- Aufgabe 13
SELECT *
FROM produkte
WHERE standardpreis IS NULL;

-- Aufgabe 14
SELECT *
FROM mitarbeiter
WHERE nachname LIKE '%er';

-- Aufgabe 15
SELECT *
FROM produkte
WHERE ist_vegan = FALSE
  AND ist_glutenfrei = FALSE;
