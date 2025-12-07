-- 04_joins_komplex_loesungen.sql
-- Joins (fortgeschritten) – Lösungen

-- Aufgabe 1
-- Produkte mit Kategorie, Standardrezept, Zutaten und Mengen

SELECT
    p.produkt_id,
    p.name         AS produkt,
    k.bezeichnung  AS kategorie,
    r.rezept_id,
    r.name         AS rezept,
    z.zutat_id,
    z.name         AS zutat,
    rz.menge
FROM
    produkte           p,
    produktkategorien  k,
    produkt_rezept     pr,
    rezepte            r,
    rezept_zutat       rz,
    zutaten            z
WHERE
    p.kategorie_id = k.kategorie_id
    AND p.produkt_id = pr.produkt_id
    AND pr.rezept_id = r.rezept_id
    AND r.rezept_id = rz.rezept_id
    AND rz.zutat_id = z.zutat_id;


-- Aufgabe 2
-- Bestellungen mit Kunde, Filiale, Artikelanzahl und Summenmenge

SELECT
    b.bestellung_id,
    k.name      AS kunde,
    f.name      AS filiale,
    SUM(bp.anzahl)              AS gesamt_menge,
    COUNT(bp.positions_nr)      AS anzahl_produkte
FROM
    bestellungen        b,
    kunden              k,
    filialen            f,
    bestell_positionen  bp
WHERE
    b.kunde_id   = k.kunde_id
    AND b.filiale_id = f.filiale_id
    AND b.bestellung_id = bp.bestellung_id
GROUP BY
    b.bestellung_id,
    k.name,
    f.name;


-- Aufgabe 3
-- Filiale mit den meisten Bestellungen

SELECT
    f.filiale_id,
    f.name,
    COUNT(b.bestellung_id) AS anzahl_bestellungen
FROM
    filialen f
LEFT JOIN
    bestellungen b
ON
    f.filiale_id = b.filiale_id
GROUP BY
    f.filiale_id,
    f.name
ORDER BY
    anzahl_bestellungen DESC
LIMIT 1;


-- Aufgabe 4
-- Drei teuerste Bestellungen (Summe aller Positionen)

SELECT
    b.bestellung_id,
    SUM(
        bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
    ) AS gesamtbetrag
FROM
    bestellungen        b,
    bestell_positionen  bp
WHERE
    b.bestellung_id = bp.bestellung_id
GROUP BY
    b.bestellung_id
ORDER BY
    gesamtbetrag DESC
LIMIT 3;


-- Aufgabe 5
-- Produkte, die in keiner Bestellung vorkommen

SELECT
    p.produkt_id,
    p.name
FROM
    produkte p
LEFT JOIN
    bestell_positionen bp
ON
    p.produkt_id = bp.produkt_id
WHERE
    bp.produkt_id IS NULL;


-- Aufgabe 6
-- Mitarbeiter, die Backaufträge geplant haben

SELECT DISTINCT
    m.mitarbeiter_id,
    m.vorname,
    m.nachname
FROM
    backauftraege b,
    mitarbeiter   m
WHERE
    b.geplant_von = m.mitarbeiter_id;


-- Aufgabe 7
-- Rezepte mit allen Zutaten und Mengen

SELECT
    r.rezept_id,
    r.name     AS rezept,
    z.zutat_id,
    z.name     AS zutat,
    rz.menge
FROM
    rezepte      r,
    rezept_zutat rz,
    zutaten      z
WHERE
    r.rezept_id = rz.rezept_id
    AND rz.zutat_id = z.zutat_id
ORDER BY
    r.rezept_id,
    z.name;


-- Aufgabe 8
-- Lieferungen mit von/zu-Filiale, Produkt und Menge

SELECT
    l.lieferung_id,
    fvon.name AS von_filiale,
    fzu.name  AS zu_filiale,
    p.name    AS produkt,
    lp.anzahl
FROM
    lieferungen          l,
    filialen             fvon,
    filialen             fzu,
    lieferung_positionen lp,
    produkte             p
WHERE
    l.von_filiale_id = fvon.filiale_id
    AND l.zu_filiale_id = fzu.filiale_id
    AND l.lieferung_id = lp.lieferung_id
    AND lp.produkt_id = p.produkt_id;


-- Aufgabe 9
-- Filialen, die Backaufträge ODER Lieferungen haben

SELECT DISTINCT
    f.filiale_id,
    f.name
FROM
    filialen f
LEFT JOIN
    backauftraege b
ON
    f.filiale_id = b.filiale_id
LEFT JOIN
    lieferungen l
ON
    f.filiale_id = l.von_filiale_id
    OR f.filiale_id = l.zu_filiale_id
WHERE
    b.backauftrag_id IS NOT NULL
    OR l.lieferung_id IS NOT NULL;


-- Aufgabe 10
-- Produkte, die sowohl in Bestellungen als auch in Lieferungen vorkommen

SELECT DISTINCT
    p.produkt_id,
    p.name
FROM
    produkte             p,
    bestell_positionen   bp,
    lieferung_positionen lp
WHERE
    p.produkt_id = bp.produkt_id
    AND p.produkt_id = lp.produkt_id;
