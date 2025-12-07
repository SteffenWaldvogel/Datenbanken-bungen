-- 07_views_loesungen.sql
-- Übungsblatt 07 – Views

--------------------------------------------------
-- Aufgabe 1
-- View „produktpreise_v“ – Produktname + Preis
--------------------------------------------------
CREATE OR REPLACE VIEW produktpreise_v AS
SELECT
    produkt_id,
    name,
    standardpreis
FROM
    produkte;


--------------------------------------------------
-- Aufgabe 2
-- View „kunden_umsatz_v“:
-- kunde_id, name, gesamtumsatz
--------------------------------------------------
CREATE OR REPLACE VIEW kunden_umsatz_v AS
SELECT
    k.kunde_id,
    k.name,
    COALESCE(
        SUM(
            bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
        ),
        0
    ) AS gesamtumsatz
FROM
    kunden k
LEFT JOIN
    bestellungen b
ON
    k.kunde_id = b.kunde_id
LEFT JOIN
    bestell_positionen bp
ON
    b.bestellung_id = bp.bestellung_id
GROUP BY
    k.kunde_id,
    k.name;


--------------------------------------------------
-- Aufgabe 3
-- View „filial_uebersicht_v“:
-- filiale_id, name, anzahl_mitarbeiter, anzahl_bestellungen
--------------------------------------------------
CREATE OR REPLACE VIEW filial_uebersicht_v AS
SELECT
    f.filiale_id,
    f.name,
    COUNT(DISTINCT m.mitarbeiter_id)    AS anzahl_mitarbeiter,
    COUNT(DISTINCT b.bestellung_id)     AS anzahl_bestellungen
FROM
    filialen f
LEFT JOIN
    mitarbeiter m
ON
    f.filiale_id = m.filiale_id
LEFT JOIN
    bestellungen b
ON
    f.filiale_id = b.filiale_id
GROUP BY
    f.filiale_id,
    f.name;


--------------------------------------------------
-- Aufgabe 4
-- View „top_produkte_v“ – Top 5 nach Bestellmenge
--------------------------------------------------
CREATE OR REPLACE VIEW top_produkte_v AS
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
-- Aufgabe 5
-- View „liefer_uebersicht_v“:
-- lieferung, fahrer, produkt, menge
--------------------------------------------------
CREATE OR REPLACE VIEW liefer_uebersicht_v AS
SELECT
    l.lieferung_id,
    l.lieferdatum,
    m.vorname || ' ' || m.nachname AS fahrer,
    p.name AS produkt,
    lp.anzahl
FROM
    lieferungen          l
LEFT JOIN
    mitarbeiter          m
ON
    l.fahrer_id = m.mitarbeiter_id
JOIN
    lieferung_positionen lp
ON
    l.lieferung_id = lp.lieferung_id
JOIN
    produkte             p
ON
    lp.produkt_id = p.produkt_id;


--------------------------------------------------
-- Aufgabe 6
-- View „backauftrag_detail_v“:
-- backauftrag, filiale, produkt, teiglingsanzahl
--------------------------------------------------
CREATE OR REPLACE VIEW backauftrag_detail_v AS
SELECT
    b.backauftrag_id,
    f.name  AS filiale,
    p.name  AS produkt,
    bap.anzahl_teiglinge
FROM
    backauftraege          b,
    filialen               f,
    backauftrag_positionen bap,
    produkte               p
WHERE
    b.filiale_id      = f.filiale_id
    AND b.backauftrag_id = bap.backauftrag_id
    AND bap.produkt_id    = p.produkt_id;


--------------------------------------------------
-- Aufgabe 7
-- Abfrage auf „kunden_umsatz_v“:
-- Kunden mit höchstem Umsatz
--------------------------------------------------
SELECT
    *
FROM
    kunden_umsatz_v
ORDER BY
    gesamtumsatz DESC
LIMIT 1;


--------------------------------------------------
-- Aufgabe 8
-- View „produkte_ohne_bestellung_v“:
-- Produkte, die nie bestellt wurden
--------------------------------------------------
CREATE OR REPLACE VIEW produkte_ohne_bestellung_v AS
SELECT
    p.*
FROM
    produkte p
LEFT JOIN
    bestell_positionen bp
ON
    p.produkt_id = bp.produkt_id
WHERE
    bp.produkt_id IS NULL;


--------------------------------------------------
-- Aufgabe 9
-- View „filialen_ohne_mitarbeiter_v“:
-- Filialen ohne Mitarbeiter
--------------------------------------------------
CREATE OR REPLACE VIEW filialen_ohne_mitarbeiter_v AS
SELECT
    f.*
FROM
    filialen f
LEFT JOIN
    mitarbeiter m
ON
    f.filiale_id = m.filiale_id
WHERE
    m.mitarbeiter_id IS NULL;
