-- 06_subqueries_loesungen.sql
-- Übungsblatt 06 – Subqueries

--------------------------------------------------
-- Aufgabe 1
-- Produkte, die teurer sind als der durchschnittliche Produktpreis
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name,
    p.standardpreis
FROM
    produkte p
WHERE
    p.standardpreis >
    (
        SELECT AVG(standardpreis)
        FROM produkte
    );


--------------------------------------------------
-- Aufgabe 2
-- Kunden, die mehr Bestellungen haben als der Durchschnitt
--------------------------------------------------
SELECT
    k.kunde_id,
    k.name
FROM
    kunden k
WHERE
    k.kunde_id IN (
        SELECT
            b.kunde_id
        FROM
            bestellungen b
        GROUP BY
            b.kunde_id
        HAVING
            COUNT(*) >
            (
                SELECT AVG(cnt)
                FROM (
                    SELECT
                        COUNT(*) AS cnt
                    FROM
                        bestellungen
                    GROUP BY
                        kunde_id
                ) x
            )
    );


--------------------------------------------------
-- Aufgabe 3
-- Produkte, die in mehr als 2 Rezepten vorkommen
-- (Semi-Join über IN)
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name
FROM
    produkte p
WHERE
    p.produkt_id IN (
        SELECT
            pr.produkt_id
        FROM
            produkt_rezept pr
        GROUP BY
            pr.produkt_id
        HAVING
            COUNT(pr.rezept_id) > 2
    );


--------------------------------------------------
-- Aufgabe 4
-- Produkte, die mindestens einmal geliefert wurden
-- (Semi-Join per IN)
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name
FROM
    produkte p
WHERE
    p.produkt_id IN (
        SELECT DISTINCT
            lp.produkt_id
        FROM
            lieferung_positionen lp
    );


--------------------------------------------------
-- Aufgabe 5
-- Produkte, die nie geliefert wurden
-- (Anti-Join per NOT IN)
--------------------------------------------------
SELECT
    p.produkt_id,
    p.name
FROM
    produkte p
WHERE
    p.produkt_id NOT IN (
        SELECT DISTINCT
            lp.produkt_id
        FROM
            lieferung_positionen lp
    );


--------------------------------------------------
-- Aufgabe 6
-- Kunden, die Bestellungen mit Gesamtwert > Durchschnitt aller Bestellungen haben
--------------------------------------------------
SELECT
    k.kunde_id,
    k.name
FROM
    kunden k
WHERE
    k.kunde_id IN (
        SELECT
            b.kunde_id
        FROM
            bestellungen b,
            bestell_positionen bp
        WHERE
            b.bestellung_id = bp.bestellung_id
        GROUP BY
            b.kunde_id
        HAVING
            SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)) >
            (
                SELECT AVG(bestellwert)
                FROM (
                    SELECT
                        SUM(bp2.anzahl * bp2.einzelpreis * (1 - bp2.rabatt_prozent / 100.0)) AS bestellwert
                    FROM
                        bestellungen b2,
                        bestell_positionen bp2
                    WHERE
                        b2.bestellung_id = bp2.bestellung_id
                    GROUP BY
                        b2.bestellung_id
                ) t
            )
    );


--------------------------------------------------
-- Aufgabe 7
-- Teuerste Bestellung pro Kunde
--------------------------------------------------
SELECT
    b.bestellung_id,
    b.kunde_id,
    k.name,
    SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)) AS gesamtbetrag
FROM
    bestellungen b,
    kunden k,
    bestell_positionen bp
WHERE
    b.kunde_id = k.kunde_id
    AND b.bestellung_id = bp.bestellung_id
GROUP BY
    b.bestellung_id,
    b.kunde_id,
    k.name
HAVING
    SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)) =
    (
        SELECT
            MAX(summe)
        FROM (
            SELECT
                SUM(bp2.anzahl * bp2.einzelpreis * (1 - bp2.rabatt_prozent / 100.0)) AS summe
            FROM
                bestellungen b2,
                bestell_positionen bp2
            WHERE
                b2.bestellung_id = bp2.bestellung_id
                AND b2.kunde_id = b.kunde_id
            GROUP BY
                b2.bestellung_id
        ) x
    );


--------------------------------------------------
-- Aufgabe 8
-- Filialen, deren Mitarbeiteranzahl über dem Durchschnitt liegt
--------------------------------------------------
SELECT
    f.filiale_id,
    f.name
FROM
    filialen f
WHERE
    f.filiale_id IN (
        SELECT
            m.filiale_id
        FROM
            mitarbeiter m
        GROUP BY
            m.filiale_id
        HAVING
            COUNT(*) >
            (
                SELECT AVG(cnt)
                FROM (
                    SELECT
                        COUNT(*) AS cnt
                    FROM
                        mitarbeiter
                    GROUP BY
                        filiale_id
                ) t
            )
    );


--------------------------------------------------
-- Aufgabe 9
-- Backaufträge, deren Gesamtteiglingsmenge über dem Durchschnitt liegt
--------------------------------------------------
SELECT
    b.backauftrag_id
FROM
    backauftraege b
WHERE
    b.backauftrag_id IN (
        SELECT
            bap.backauftrag_id
        FROM
            backauftrag_positionen bap
        GROUP BY
            bap.backauftrag_id
        HAVING
            SUM(bap.anzahl_teiglinge) >
            (
                SELECT AVG(summe)
                FROM (
                    SELECT
                        SUM(anzahl_teiglinge) AS summe
                    FROM
                        backauftrag_positionen
                    GROUP BY
                        backauftrag_id
                ) x
            )
    );


--------------------------------------------------
-- Aufgabe 10
-- Kunden mit Bestellungen ausschließlich über 10 €
--------------------------------------------------
-- Idee:
-- 1. Kunden ausschließen, die irgendeine Bestellung <= 10 € haben
-- 2. nur Kunden mit mindestens einer Bestellung behalten

SELECT
    k.kunde_id,
    k.name
FROM
    kunden k
WHERE
    k.kunde_id NOT IN (
        -- Kunden mit mindestens einer „kleinen“ Bestellung (<= 10 €)
        SELECT
            b.kunde_id
        FROM
            bestellungen b,
            bestell_positionen bp
        WHERE
            b.bestellung_id = bp.bestellung_id
        GROUP BY
            b.kunde_id,
            b.bestellung_id
        HAVING
            SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)) <= 10
    )
    AND k.kunde_id IN (
        -- Kunden, die überhaupt mindestens eine Bestellung haben
        SELECT DISTINCT
            b2.kunde_id
        FROM
            bestellungen b2
    );


--------------------------------------------------
-- Aufgabe 11
-- Produkte, deren Preis = Maximum ihrer Kategorie ist
--------------------------------------------------
SELECT
    p.*
FROM
    produkte p
WHERE
    p.standardpreis =
    (
        SELECT
            MAX(p2.standardpreis)
        FROM
            produkte p2
        WHERE
            p2.kategorie_id = p.kategorie_id
    );


--------------------------------------------------
-- Aufgabe 12
-- Produkte, deren Preis = Minimum ihrer Kategorie ist
--------------------------------------------------
SELECT
    p.*
FROM
    produkte p
WHERE
    p.standardpreis =
    (
        SELECT
            MIN(p2.standardpreis)
        FROM
            produkte p2
        WHERE
            p2.kategorie_id = p.kategorie_id
    );
