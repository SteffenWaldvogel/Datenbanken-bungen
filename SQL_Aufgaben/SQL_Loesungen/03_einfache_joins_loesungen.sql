-- 03 – JOINs (Einsteiger) – Lösungen

--------------------------------------------------
-- Aufgabe 1
-- Alle Bestellungen mit Kundenname und Filialname
--------------------------------------------------
SELECT
    b.bestellung_id,
    b.bestelldatum,
    k.name AS kunde,
    f.name AS filiale
FROM
    bestellungen b
JOIN kunden k ON b.kunde_id = k.kunde_id
JOIN filialen f ON b.filiale_id = f.filiale_id
ORDER BY
    b.bestellung_id;


--------------------------------------------------
-- Aufgabe 2
-- Für jedes Produkt die zugehörige Kategorie
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name AS produkt,
    pk.bezeichnung AS kategorie
FROM
    produkte p
JOIN produktkategorien pk ON p.kategorie_id = pk.kategorie_id
ORDER BY
    pk.bezeichnung,
    p.name;


--------------------------------------------------
-- Aufgabe 3
-- Alle Mitarbeiter mit Filialname
--------------------------------------------------
SELECT
    m.mitarbeiter_id,
    m.vorname,
    m.nachname,
    m.rolle,
    f.name AS filiale
FROM
    mitarbeiter m
JOIN filialen f ON m.filiale_id = f.filiale_id
ORDER BY
    f.name,
    m.nachname;


--------------------------------------------------
-- Aufgabe 4
-- Alle Bestellpositionen inkl. Produktname und Preis
--------------------------------------------------
SELECT
    bp.bestellung_id,
    bp.positions_nr,
    p.name AS produkt,
    bp.anzahl,
    bp.einzelpreis,
    bp.rabatt_prozent
FROM
    bestell_positionen bp
JOIN produkte p ON bp.produkt_id = p.produkt_id
ORDER BY
    bp.bestellung_id,
    bp.positions_nr;


--------------------------------------------------
-- Aufgabe 5
-- Alle Produkte, die in mindestens einem Rezept vorkommen
--------------------------------------------------
SELECT DISTINCT
    p.produkt_id,
    p.name AS produkt
FROM
    produkte p
JOIN produkt_rezept pr ON p.produkt_id = pr.produkt_id
ORDER BY
    p.name;


--------------------------------------------------
-- Aufgabe 6
-- Alle Zutaten, die in keinem Rezept verwendet werden
--------------------------------------------------
SELECT
    z.zutat_id,
    z.name AS zutat
FROM
    zutaten z
LEFT JOIN rezept_zutat rz ON z.zutat_id = rz.zutat_id
WHERE
    rz.zutat_id IS NULL
ORDER BY
    z.name;


--------------------------------------------------
-- Aufgabe 7
-- Alle Filialen und die Anzahl ihrer Mitarbeiter
--------------------------------------------------
SELECT
    f.filiale_id,
    f.name AS filiale,
    COUNT(m.mitarbeiter_id) AS anzahl_mitarbeiter
FROM
    filialen f
LEFT JOIN mitarbeiter m ON f.filiale_id = m.filiale_id
GROUP BY
    f.filiale_id,
    f.name
ORDER BY
    anzahl_mitarbeiter DESC;


--------------------------------------------------
-- Aufgabe 8
-- Alle Bestellungen mit Kunde & Gesamtartikelanzahl
--------------------------------------------------
SELECT
    b.bestellung_id,
    k.name AS kunde,
    COUNT(bp.positions_nr) AS anzahl_positionen,
    SUM(bp.anzahl)         AS gesamtartikelanzahl
FROM
    bestellungen b
JOIN kunden k ON b.kunde_id = k.kunde_id
JOIN bestell_positionen bp ON b.bestellung_id = bp.bestellung_id
GROUP BY
    b.bestellung_id,
    k.name
ORDER BY
    b.bestellung_id;


--------------------------------------------------
-- Aufgabe 9
-- Alle Produkte mit zugehörigem Standardrezept
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name AS produkt,
    r.name AS rezept
FROM
    produkte p
JOIN produkt_rezept pr ON p.produkt_id = pr.produkt_id
JOIN rezepte r ON pr.rezept_id = r.rezept_id
WHERE
    pr.ist_standardrezept = TRUE
ORDER BY
    p.name;


--------------------------------------------------
-- Aufgabe 10
-- Alle Lieferungen mit Fahrername
--------------------------------------------------
SELECT
    l.lieferung_id,
    l.lieferdatum,
    m.vorname || ' ' || m.nachname AS fahrer
FROM
    lieferungen l
LEFT JOIN mitarbeiter m ON l.fahrer_id = m.mitarbeiter_id
ORDER BY
    l.lieferdatum;


--------------------------------------------------
-- Aufgabe 11
-- Alle Produkte, die in einem bestimmten Backauftrag vorkamen
-- (Beispiel: backauftrag_id = 1)
--------------------------------------------------
SELECT
    bap.backauftrag_id,
    p.name AS produkt,
    bap.anzahl_teiglinge
FROM
    backauftrag_positionen bap
JOIN produkte p ON bap.produkt_id = p.produkt_id
WHERE
    bap.backauftrag_id = 1
ORDER BY
    bap.positions_nr;


--------------------------------------------------
-- Aufgabe 12
-- Bestellungen mit mehr als einer Position
--------------------------------------------------
SELECT
    b.bestellung_id,
    k.name AS kunde,
    COUNT(bp.positions_nr) AS anzahl_positionen
FROM
    bestellungen b
JOIN kunden k ON b.kunde_id = k.kunde_id
JOIN bestell_positionen bp ON b.bestellung_id = bp.bestellung_id
GROUP BY
    b.bestellung_id,
    k.name
HAVING
    COUNT(bp.positions_nr) > 1
ORDER BY
    anzahl_positionen DESC;
