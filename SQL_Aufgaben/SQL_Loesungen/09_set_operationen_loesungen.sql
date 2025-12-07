-- 09_set_operationen_loesungen.sql
-- Übungsblatt 09 – Mengenoperationen (UNION, INTERSECT, EXCEPT)

--------------------------------------------------
-- Aufgabe 1
-- Produkte, die vegan ODER glutenfrei sind (UNION)
--------------------------------------------------
SELECT
    produkt_id,
    name
FROM
    produkte
WHERE
    ist_vegan = TRUE

UNION

SELECT
    produkt_id,
    name
FROM
    produkte
WHERE
    ist_glutenfrei = TRUE;


--------------------------------------------------
-- Aufgabe 2
-- Produkte, die sowohl in Bestellungen ALS AUCH in Lieferungen vorkommen
-- (INTERSECT)
--------------------------------------------------
SELECT
    produkt_id
FROM
    bestell_positionen

INTERSECT

SELECT
    produkt_id
FROM
    lieferung_positionen;


--------------------------------------------------
-- Aufgabe 3
-- Produkte, die bestellt, aber nie geliefert wurden (EXCEPT)
--------------------------------------------------
SELECT
    produkt_id
FROM
    bestell_positionen

EXCEPT

SELECT
    produkt_id
FROM
    lieferung_positionen;


--------------------------------------------------
-- Aufgabe 4
-- Produkte, die geliefert, aber nie bestellt wurden
--------------------------------------------------
SELECT
    produkt_id
FROM
    lieferung_positionen

EXCEPT

SELECT
    produkt_id
FROM
    bestell_positionen;


--------------------------------------------------
-- Aufgabe 5
-- Filialen mit Mitarbeitern UNION Filialen mit Backaufträgen
--------------------------------------------------
SELECT
    filiale_id
FROM
    mitarbeiter

UNION

SELECT
    filiale_id
FROM
    backauftraege;


--------------------------------------------------
-- Aufgabe 6
-- Kunden, die mindestens eine Bestellung haben
-- INTERSECT Kunden mit Rabatt > 0
--------------------------------------------------
SELECT
    k.kunde_id
FROM
    kunden k,
    bestellungen b
WHERE
    k.kunde_id = b.kunde_id

INTERSECT

SELECT
    kunde_id
FROM
    kunden
WHERE
    rabatt_prozent > 0;


--------------------------------------------------
-- Aufgabe 7
-- Produkte in Rezepten EXCEPT Produkte in Bestellungen
--------------------------------------------------
SELECT
    produkt_id
FROM
    produkt_rezept

EXCEPT

SELECT
    produkt_id
FROM
    bestell_positionen;
