-- 05_aggregation_groupby_loesungen.sql
-- Aggregation & GROUP BY – Lösungen

--------------------------------------------------
-- Aufgabe 1 – Anzahl Kunden je Kundentyp
--------------------------------------------------
SELECT
    kunden_typ,
    COUNT(*) AS anzahl_kunden
FROM
    kunden
GROUP BY
    kunden_typ;


--------------------------------------------------
-- Aufgabe 2 – Anzahl Produkte je Kategorie
--------------------------------------------------
SELECT
    k.bezeichnung AS kategorie,
    COUNT(p.produkt_id) AS anzahl_produkte
FROM
    produktkategorien k
LEFT JOIN
    produkte p
ON
    k.kategorie_id = p.kategorie_id
GROUP BY
    k.bezeichnung
ORDER BY
    k.bezeichnung;


--------------------------------------------------
-- Aufgabe 3 – Summe Bestellmengen je Produkt
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name,
    SUM(bp.anzahl) AS gesamtmenge
FROM
    produkte p,
    bestell_positionen bp
WHERE
    p.produkt_id = bp.produkt_id
GROUP BY
    p.produkt_id,
    p.name
ORDER BY
    gesamtmenge DESC;


--------------------------------------------------
-- Aufgabe 4 – Umsatz je Produkt
-- (SUM(anzahl * einzelpreis * (1 - rabatt/100)))
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name,
    SUM(
        bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
    ) AS umsatz
FROM
    produkte p,
    bestell_positionen bp
WHERE
    p.produkt_id = bp.produkt_id
GROUP BY
    p.produkt_id,
    p.name
ORDER BY
    umsatz DESC;


--------------------------------------------------
-- Aufgabe 5 – Top 5 Produkte nach Bestellmenge
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name,
    SUM(bp.anzahl) AS gesamtmenge
FROM
    produkte p,
    bestell_positionen bp
WHERE
    p.produkt_id = bp.produkt_id
GROUP BY
    p.produkt_id,
    p.name
ORDER BY
    gesamtmenge DESC
LIMIT 5;


--------------------------------------------------
-- Aufgabe 6 – Umsatz je Filiale
--------------------------------------------------
SELECT
    f.filiale_id,
    f.name AS filiale,
    SUM(
        bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
    ) AS umsatz
FROM
    filialen f,
    bestellungen b,
    bestell_positionen bp
WHERE
    f.filiale_id      = b.filiale_id
    AND b.bestellung_id = bp.bestellung_id
GROUP BY
    f.filiale_id,
    f.name
ORDER BY
    umsatz DESC;


--------------------------------------------------
-- Aufgabe 7 – Durchschnittspreis je Produktkategorie
--------------------------------------------------
SELECT
    k.bezeichnung AS kategorie,
    AVG(p.standardpreis) AS durchschnittspreis
FROM
    produktkategorien k,
    produkte p
WHERE
    k.kategorie_id = p.kategorie_id
GROUP BY
    k.bezeichnung
ORDER BY
    k.bezeichnung;


--------------------------------------------------
-- Aufgabe 8 – Anzahl Bestellungen je Kunde
--------------------------------------------------
SELECT
    k.kunde_id,
    k.name,
    COUNT(b.bestellung_id) AS anzahl_bestellungen
FROM
    kunden k
LEFT JOIN
    bestellungen b
ON
    k.kunde_id = b.kunde_id
GROUP BY
    k.kunde_id,
    k.name
ORDER BY
    anzahl_bestellungen DESC,
    k.name;


--------------------------------------------------
-- Aufgabe 9 – Summe gelieferter Mengen je Produkt
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name,
    SUM(lp.anzahl) AS gesamt_geliefert
FROM
    produkte p,
    lieferung_positionen lp
WHERE
    p.produkt_id = lp.produkt_id
GROUP BY
    p.produkt_id,
    p.name
ORDER BY
    gesamt_geliefert DESC;


--------------------------------------------------
-- Aufgabe 10 – Durchschnittlicher Rabatt je Kundentyp
--------------------------------------------------
SELECT
    k.kunden_typ,
    AVG(bp.rabatt_prozent) AS durchschnitt_rabatt
FROM
    kunden k,
    bestellungen b,
    bestell_positionen bp
WHERE
    k.kunde_id        = b.kunde_id
    AND b.bestellung_id = bp.bestellung_id
GROUP BY
    k.kunden_typ;


--------------------------------------------------
-- Aufgabe 11 – Mitarbeiter je Rolle
--------------------------------------------------
SELECT
    rolle,
    COUNT(*) AS anzahl_mitarbeiter
FROM
    mitarbeiter
GROUP BY
    rolle
ORDER BY
    rolle;


--------------------------------------------------
-- Aufgabe 12 – Anzahl Rezepte je Produkt
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name,
    COUNT(pr.rezept_id) AS anzahl_rezepte
FROM
    produkte p
LEFT JOIN
    produkt_rezept pr
ON
    p.produkt_id = pr.produkt_id
GROUP BY
    p.produkt_id,
    p.name
ORDER BY
    anzahl_rezepte DESC,
    p.name;


--------------------------------------------------
-- Aufgabe 13 – Teiglingsmenge pro Backauftrag
--------------------------------------------------
SELECT
    b.backauftrag_id,
    SUM(bap.anzahl_teiglinge) AS gesamt_teiglinge
FROM
    backauftraege b,
    backauftrag_positionen bap
WHERE
    b.backauftrag_id = bap.backauftrag_id
GROUP BY
    b.backauftrag_id
ORDER BY
    b.backauftrag_id;


--------------------------------------------------
-- Aufgabe 14 – Gesamtumsatz pro Monat
--------------------------------------------------
SELECT
    DATE_TRUNC('month', b.bestelldatum) AS monat,
    SUM(
        bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
    ) AS umsatz
FROM
    bestellungen b,
    bestell_positionen bp
WHERE
    b.bestellung_id = bp.bestellung_id
GROUP BY
    DATE_TRUNC('month', b.bestelldatum)
ORDER BY
    monat;
