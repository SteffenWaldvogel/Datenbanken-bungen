-- 06 – Subqueries – Lösungen (ab Aufgabe 3 mit IN-Varianten)


-- Aufgabe 3
-- Produkte, die in mehr als 2 Rezepten vorkommen (Beispiel mit IN)

SELECT p.produkt_id, p.name
FROM produkte p
WHERE p.produkt_id IN (
    SELECT pr.produkt_id
    FROM produkt_rezept pr
    GROUP BY pr.produkt_id
    HAVING COUNT(pr.rezept_id) > 2
);


-- Aufgabe 4
-- Produkte, die mindestens einmal geliefert wurden (Semi-Join per IN)

SELECT p.produkt_id, p.name
FROM produkte p
WHERE p.produkt_id IN (
    SELECT DISTINCT lp.produkt_id
    FROM lieferung_positionen lp
);


-- Aufgabe 5
-- Produkte, die nie geliefert wurden (Anti-Join per NOT IN)

SELECT p.produkt_id, p.name
FROM produkte p
WHERE p.produkt_id NOT IN (
    SELECT DISTINCT lp.produkt_id
    FROM lieferung_positionen lp
);


-- Aufgabe 6
-- Kunden, deren Gesamtbestellwert > Durchschnitt aller Bestellungen ist

-- Variante mit IN (Kunde wird ausgewählt, wenn seine ID in der Menge der „High-Value“-Kunden liegt)

SELECT k.kunde_id, k.name
FROM kunden k
WHERE k.kunde_id IN (
    SELECT b.kunde_id
    FROM bestellungen b
    JOIN bestell_positionen bp ON b.bestellung_id = bp.bestellung_id
    GROUP BY b.kunde_id
    HAVING SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent/100.0)) >
           (
             SELECT AVG(bestellwert)
             FROM (
               SELECT SUM(bp2.anzahl * bp2.einzelpreis * (1 - bp2.rabatt_prozent/100.0)) AS bestellwert
               FROM bestellungen b2
               JOIN bestell_positionen bp2 ON b2.bestellung_id = bp2.bestellung_id
               GROUP BY b2.bestellung_id
             ) x
           )
);


-- Aufgabe 7
-- Teuerste Bestellung je Kunde
-- (IN nutzt hier die Menge der jeweils maximalen Bestellwerte pro Kunde)

SELECT b.bestellung_id, b.kunde_id, k.name,
       SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent/100.0)) AS gesamt
FROM bestellungen b
JOIN kunden k           ON b.kunde_id = k.kunde_id
JOIN bestell_positionen bp ON b.bestellung_id = bp.bestellung_id
GROUP BY b.bestellung_id, b.kunde_id, k.name
HAVING SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent/100.0))
       IN (
           SELECT MAX(summe)
           FROM (
             SELECT b2.kunde_id,
                    SUM(bp2.anzahl * bp2.einzelpreis * (1 - bp2.rabatt_prozent/100.0)) AS summe
             FROM bestellungen b2
             JOIN bestell_positionen bp2 ON b2.bestellung_id = bp2.bestellung_id
             GROUP BY b2.bestellung_id, b2.kunde_id
           ) t
           WHERE t.kunde_id = b.kunde_id
       );


-- Aufgabe 8
-- Filialen mit mehr Mitarbeitern als der Durchschnitt

SELECT f.filiale_id, f.name
FROM filialen f
WHERE f.filiale_id IN (
    SELECT m.filiale_id
    FROM mitarbeiter m
    GROUP BY m.filiale_id
    HAVING COUNT(*) >
           (
             SELECT AVG(cnt)
             FROM (
               SELECT COUNT(*) AS cnt
               FROM mitarbeiter
               GROUP BY filiale_id
             ) x
           )
);


-- Aufgabe 9
-- Backaufträge mit Gesamtteiglingsmenge > Durchschnitt

SELECT b.backauftrag_id
FROM backauftraege b
WHERE b.backauftrag_id IN (
    SELECT bap.backauftrag_id
    FROM backauftrag_positionen bap
    GROUP BY bap.backauftrag_id
    HAVING SUM(bap.anzahl_teiglinge) >
           (
             SELECT AVG(summe)
             FROM (
               SELECT SUM(anzahl_teiglinge) AS summe
               FROM backauftrag_positionen
               GROUP BY backauftrag_id
             ) x
           )
);


-- Aufgabe 10
-- Kunden mit ausschließlich Bestellungen > 10€
-- (klassisch eher mit NOT EXISTS, hier Demo mit IN für positive Menge)

-- Menge aller Kunden, bei denen es mindestens eine Bestellung <= 10€ gibt:
-- (die müssen wir ausschließen)

SELECT k.kunde_id, k.name
FROM kunden k
WHERE k.kunde_id NOT IN (
    SELECT b.kunde_id
    FROM bestellungen b
    JOIN bestell_positionen bp ON b.bestellung_id = bp.bestellung_id
    GROUP BY b.kunde_id, b.bestellung_id
    HAVING SUM(bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent/100.0)) <= 10
)
AND k.kunde_id IN (
    SELECT DISTINCT b2.kunde_id
    FROM bestellungen b2
);


-- Aufgabe 11
-- Produkte mit Maximumpreis ihrer Kategorie (IN-Variante)

SELECT p.*
FROM produkte p
WHERE (p.kategorie_id, p.standardpreis) IN (
    SELECT p2.kategorie_id,
           MAX(p2.standardpreis)
    FROM produkte p2
    GROUP BY p2.kategorie_id
);


-- Aufgabe 12
-- Produkte mit Minimumpreis ihrer Kategorie (IN-Variante)

SELECT p.*
FROM produkte p
WHERE (p.kategorie_id, p.standardpreis) IN (
    SELECT p2.kategorie_id,
           MIN(p2.standardpreis)
    FROM produkte p2
    GROUP BY p2.kategorie_id
);
