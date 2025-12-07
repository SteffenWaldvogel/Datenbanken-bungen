-- 10_komplexe_klausuraufgaben_loesungen.sql
-- Übungsblatt 10 – Komplexe Klausuraufgaben
-- Beispiel-Lösungen (eine von mehreren möglichen Varianten)

--------------------------------------------------
-- Aufgabe 1
-- Produkt mit höchstem Gesamtumsatz:
-- Kategorie, Gesamtmenge, Anzahl unterschiedlicher Kunden
--------------------------------------------------
WITH produkt_stats AS (
    SELECT
        p.produkt_id,
        p.name               AS produkt,
        k.bezeichnung        AS kategorie,
        SUM(bp.anzahl)       AS gesamtmenge,
        COUNT(DISTINCT b.kunde_id) AS anzahl_kunden,
        SUM(
            bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
        ) AS umsatz
    FROM
        produkte p,
        produktkategorien k,
        bestell_positionen bp,
        bestellungen b
    WHERE
        p.kategorie_id   = k.kategorie_id
        AND p.produkt_id = bp.produkt_id
        AND b.bestellung_id = bp.bestellung_id
    GROUP BY
        p.produkt_id,
        p.name,
        k.bezeichnung
)
SELECT *
FROM produkt_stats
ORDER BY umsatz DESC
LIMIT 1;


--------------------------------------------------
-- Aufgabe 2
-- Filialanalyse:
-- anzahl_bestellungen, gesamtumsatz, durchschnittliche Bestellgröße,
-- Umsatz pro Mitarbeiter
--------------------------------------------------
WITH bestellwerte AS (
    SELECT
        b.filiale_id,
        b.bestellung_id,
        SUM(bp.anzahl) AS artikelanzahl,
        SUM(
            bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
        ) AS bestellwert
    FROM
        bestellungen b,
        bestell_positionen bp
    WHERE
        b.bestellung_id = bp.bestellung_id
    GROUP BY
        b.filiale_id,
        b.bestellung_id
),
filial_stats AS (
    SELECT
        f.filiale_id,
        f.name AS filiale,
        COUNT(bw.bestellung_id)                         AS anzahl_bestellungen,
        COALESCE(SUM(bw.bestellwert), 0)                AS gesamtumsatz,
        COALESCE(AVG(bw.artikelanzahl), 0)              AS durchschnitt_bestellgroesse,
        COUNT(DISTINCT m.mitarbeiter_id)                AS anzahl_mitarbeiter
    FROM
        filialen f
    LEFT JOIN bestellwerte bw
        ON f.filiale_id = bw.filiale_id
    LEFT JOIN mitarbeiter m
        ON f.filiale_id = m.filiale_id
    GROUP BY
        f.filiale_id,
        f.name
)
SELECT
    filiale_id,
    filiale,
    anzahl_bestellungen,
    gesamtumsatz,
    durchschnitt_bestellgroesse,
    anzahl_mitarbeiter,
    CASE
        WHEN anzahl_mitarbeiter > 0
            THEN gesamtumsatz / anzahl_mitarbeiter
        ELSE NULL
    END AS umsatz_pro_mitarbeiter
FROM
    filial_stats
ORDER BY
    gesamtumsatz DESC;


--------------------------------------------------
-- Aufgabe 3
-- Kundenprofilanalyse (GESCHAEFT):
-- gesamtumsatz, durchschnittlicher Bestellwert,
-- meistbestelltes Produkt je Kunde
--------------------------------------------------
-- Schritt 1: Bestellwerte pro Bestellung
WITH bestellwerte AS (
    SELECT
        b.bestellung_id,
        b.kunde_id,
        SUM(
            bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
        ) AS bestellwert
    FROM
        bestellungen b,
        bestell_positionen bp
    WHERE
        b.bestellung_id = bp.bestellung_id
    GROUP BY
        b.bestellung_id,
        b.kunde_id
),
-- Schritt 2: Produktmengen je Kunde
kunde_produkt_mengen AS (
    SELECT
        b.kunde_id,
        bp.produkt_id,
        SUM(bp.anzahl) AS gesamtmenge
    FROM
        bestellungen b,
        bestell_positionen bp
    WHERE
        b.bestellung_id = bp.bestellung_id
    GROUP BY
        b.kunde_id,
        bp.produkt_id
),
-- Schritt 3: meistbestelltes Produkt je Kunde
top_produkt_je_kunde AS (
    SELECT
        kpm.kunde_id,
        kpm.produkt_id
    FROM
        kunde_produkt_mengen kpm
    WHERE
        kpm.gesamtmenge = (
            SELECT
                MAX(kpm2.gesamtmenge)
            FROM
                kunde_produkt_mengen kpm2
            WHERE
                kpm2.kunde_id = kpm.kunde_id
        )
)
SELECT
    k.kunde_id,
    k.name,
    SUM(bw.bestellwert)                 AS gesamtumsatz,
    AVG(bw.bestellwert)                 AS durchschnittlicher_bestellwert,
    tp.produkt_id,
    p.name AS meistbestelltes_produkt
FROM
    kunden k,
    bestellwerte bw
LEFT JOIN top_produkt_je_kunde tp
    ON bw.kunde_id = tp.kunde_id
LEFT JOIN produkte p
    ON tp.produkt_id = p.produkt_id
WHERE
    k.kunde_id = bw.kunde_id
    AND k.kunden_typ = 'GESCHAEFT'
GROUP BY
    k.kunde_id,
    k.name,
    tp.produkt_id,
    p.name
ORDER BY
    gesamtumsatz DESC;


--------------------------------------------------
-- Aufgabe 4
-- Produktanalyse:
-- Gesamtumsatz, Anzahl Rezepte, Anzahl Lieferungen,
-- Anzahl Zutaten, Verhältnis Bestellmenge zu Liefermenge
--------------------------------------------------
WITH bestell_agg AS (
    SELECT
        bp.produkt_id,
        SUM(bp.anzahl) AS bestellte_menge,
        SUM(
            bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
        ) AS umsatz
    FROM
        bestell_positionen bp
    GROUP BY
        bp.produkt_id
),
liefer_agg AS (
    SELECT
        lp.produkt_id,
        SUM(lp.anzahl) AS gelieferte_menge,
        COUNT(*)       AS anzahl_lieferungen
    FROM
        lieferung_positionen lp
    GROUP BY
        lp.produkt_id
),
rezept_anzahl AS (
    SELECT
        pr.produkt_id,
        COUNT(pr.rezept_id) AS anzahl_rezepte
    FROM
        produkt_rezept pr
    GROUP BY
        pr.produkt_id
),
zutaten_anzahl AS (
    SELECT
        pr.produkt_id,
        COUNT(DISTINCT rz.zutat_id) AS anzahl_zutaten
    FROM
        produkt_rezept pr,
        rezept_zutat rz
    WHERE
        pr.rezept_id = rz.rezept_id
    GROUP BY
        pr.produkt_id
)
SELECT
    p.produkt_id,
    p.name,
    p.standardpreis,
    k.bezeichnung                    AS kategorie,
    COALESCE(b.bestellte_menge, 0)   AS bestellte_menge,
    COALESCE(b.umsatz, 0)           AS gesamtumsatz,
    COALESCE(r.anzahl_rezepte, 0)   AS anzahl_rezepte,
    COALESCE(za.anzahl_zutaten, 0)  AS anzahl_zutaten,
    COALESCE(l.anzahl_lieferungen, 0) AS anzahl_lieferungen,
    COALESCE(l.gelieferte_menge, 0) AS gelieferte_menge,
    CASE
        WHEN l.gelieferte_menge IS NULL OR l.gelieferte_menge = 0
            THEN NULL
        ELSE b.bestellte_menge::NUMERIC / l.gelieferte_menge
    END AS verhaeltnis_bestellung_zu_lieferung
FROM
    produkte p
LEFT JOIN produktkategorien k ON p.kategorie_id = k.kategorie_id
LEFT JOIN bestell_agg      b ON p.produkt_id    = b.produkt_id
LEFT JOIN liefer_agg       l ON p.produkt_id    = l.produkt_id
LEFT JOIN rezept_anzahl    r ON p.produkt_id    = r.produkt_id
LEFT JOIN zutaten_anzahl   za ON p.produkt_id   = za.produkt_id
ORDER BY
    gesamtumsatz DESC NULLS LAST;


--------------------------------------------------
-- Aufgabe 5
-- Backauftrag-Produktionsanalyse:
-- Summe Teiglinge, beteiligte Produkte, Mitarbeitername, Filialname, Dauer
--------------------------------------------------
-- Hinweis: Dauer nur sinnvoll, wenn startzeit_ist und startzeit_geplant gesetzt sind.
WITH backauftrag_basis AS (
    SELECT
        b.backauftrag_id,
        b.filiale_id,
        b.geplant_von,
        b.startzeit_geplant,
        b.startzeit_ist,
        SUM(bap.anzahl_teiglinge) AS gesamt_teiglinge
    FROM
        backauftraege b,
        backauftrag_positionen bap
    WHERE
        b.backauftrag_id = bap.backauftrag_id
    GROUP BY
        b.backauftrag_id,
        b.filiale_id,
        b.geplant_von,
        b.startzeit_geplant,
        b.startzeit_ist
),
backauftrag_produkte AS (
    SELECT
        bap.backauftrag_id,
        STRING_AGG(DISTINCT p.name, ', ' ORDER BY p.name) AS produkte
    FROM
        backauftrag_positionen bap,
        produkte p
    WHERE
        bap.produkt_id = p.produkt_id
    GROUP BY
        bap.backauftrag_id
)
SELECT
    bb.backauftrag_id,
    f.name AS filiale,
    m.vorname || ' ' || m.nachname AS verantwortlicher_mitarbeiter,
    bb.gesamt_teiglinge,
    bp.produkte,
    bb.startzeit_geplant,
    bb.startzeit_ist,
    (bb.startzeit_ist - bb.startzeit_geplant) AS dauer
FROM
    backauftrag_basis bb
LEFT JOIN filialen f
    ON bb.filiale_id = f.filiale_id
LEFT JOIN mitarbeiter m
    ON bb.geplant_von = m.mitarbeiter_id
LEFT JOIN backauftrag_produkte bp
    ON bb.backauftrag_id = bp.backauftrag_id
ORDER BY
    bb.startzeit_geplant;


--------------------------------------------------
-- Aufgabe 6
-- Komplexestes Rezept:
-- Rezept mit den meisten Zutaten + Materialkosten (über lieferant_zutat)
--------------------------------------------------
WITH rezept_zutaten AS (
    SELECT
        r.rezept_id,
        r.name AS rezept,
        z.zutat_id,
        z.name AS zutat,
        rz.menge
    FROM
        rezepte r,
        rezept_zutat rz,
        zutaten z
    WHERE
        r.rezept_id = rz.rezept_id
        AND rz.zutat_id = z.zutat_id
),
rezept_anzahl_zutaten AS (
    SELECT
        rezept_id,
        COUNT(*) AS anzahl_zutaten
    FROM
        rezept_zutaten
    GROUP BY
        rezept_id
),
-- sehr vereinfachte Materialkostenberechnung:
-- wir nehmen den MIN(preis_pro_einheit) pro Zutat als „Standardpreis“
zutat_preis AS (
    SELECT
        zutat_id,
        MIN(preis_pro_einheit) AS preis_pro_einheit
    FROM
        lieferant_zutat
    GROUP BY
        zutat_id
),
rezept_kosten AS (
    SELECT
        rz.rezept_id,
        SUM(rz.menge * zp.preis_pro_einheit) AS materialkosten
    FROM
        rezept_zutat rz,
        zutat_preis zp
    WHERE
        rz.zutat_id = zp.zutat_id
    GROUP BY
        rz.rezept_id
)
SELECT
    r.rezept_id,
    r.name AS rezept,
    raz.anzahl_zutaten,
    rk.materialkosten
FROM
    rezepte r,
    rezept_anzahl_zutaten raz,
    rezept_kosten rk
WHERE
    r.rezept_id = raz.rezept_id
    AND r.rezept_id = rk.rezept_id
ORDER BY
    raz.anzahl_zutaten DESC,
    rk.materialkosten DESC
LIMIT 1;


--------------------------------------------------
-- Aufgabe 7
-- Monatsanalyse:
-- Gesamtumsatz, Anzahl Bestellungen, Ø Warenkorbgröße,
-- Top-Produkt des Monats, umsatzstärkster Kunde des Monats
--------------------------------------------------
-- Grundlage: Bestellwerte + Positionen
WITH bestellwerte AS (
    SELECT
        b.bestellung_id,
        b.kunde_id,
        DATE_TRUNC('month', b.bestelldatum) AS monat,
        SUM(bp.anzahl) AS artikelanzahl,
        SUM(
            bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
        ) AS bestellwert
    FROM
        bestellungen b,
        bestell_positionen bp
    WHERE
        b.bestellung_id = bp.bestellung_id
    GROUP BY
        b.bestellung_id,
        b.kunde_id,
        DATE_TRUNC('month', b.bestelldatum)
),
produkt_monat AS (
    SELECT
        DATE_TRUNC('month', b.bestelldatum) AS monat,
        bp.produkt_id,
        SUM(bp.anzahl) AS gesamtmenge
    FROM
        bestellungen b,
        bestell_positionen bp
    WHERE
        b.bestellung_id = bp.bestellung_id
    GROUP BY
        DATE_TRUNC('month', b.bestelldatum),
        bp.produkt_id
),
top_produkt_monat AS (
    SELECT
        pm.monat,
        pm.produkt_id
    FROM
        produkt_monat pm
    WHERE
        pm.gesamtmenge = (
            SELECT
                MAX(pm2.gesamtmenge)
            FROM
                produkt_monat pm2
            WHERE
                pm2.monat = pm.monat
        )
),
kunde_monat AS (
    SELECT
        bw.monat,
        bw.kunde_id,
        SUM(bw.bestellwert) AS umsatz_kunde_monat
    FROM
        bestellwerte bw
    GROUP BY
        bw.monat,
        bw.kunde_id
),
top_kunde_monat AS (
    SELECT
        km.monat,
        km.kunde_id
    FROM
        kunde_monat km
    WHERE
        km.umsatz_kunde_monat = (
            SELECT
                MAX(km2.umsatz_kunde_monat)
            FROM
                kunde_monat km2
            WHERE
                km2.monat = km.monat
        )
),
monats_aggregat AS (
    SELECT
        bw.monat,
        COUNT(DISTINCT bw.bestellung_id)               AS anzahl_bestellungen,
        SUM(bw.bestellwert)                           AS gesamtumsatz,
        AVG(bw.artikelanzahl)                         AS durchschnitt_warenkorb
    FROM
        bestellwerte bw
    GROUP BY
        bw.monat
)
SELECT
    ma.monat,
    ma.anzahl_bestellungen,
    ma.gesamtumsatz,
    ma.durchschnitt_warenkorb,
    tp.produkt_id,
    p.name  AS top_produkt,
    tk.kunde_id,
    k.name  AS umsatzstaerkster_kunde
FROM
    monats_aggregat ma
LEFT JOIN top_produkt_monat tp
    ON ma.monat = tp.monat
LEFT JOIN produkte p
    ON tp.produkt_id = p.produkt_id
LEFT JOIN top_kunde_monat tk
    ON ma.monat = tk.monat
LEFT JOIN kunden k
    ON tk.kunde_id = k.kunde_id
ORDER BY
    ma.monat;


--------------------------------------------------
-- Aufgabe 8
-- Multifilter-Query für Dashboard:
-- optionale Filter: Filiale, Zeitraum, Kundentyp
-- -> typische Pattern: Parameter als NULL bedeutet "kein Filter"
--------------------------------------------------
-- Annahme: Es gibt (z. B. im Tool / in der Anwendung)
-- Bind-Parameter :p_filiale_id, :p_startdatum, :p_enddatum, :p_kunden_typ
-- In pgAdmin könntest du Platzhalter durch konkrete Werte ersetzen.

SELECT
    DATE_TRUNC('day', b.bestelldatum) AS tag,
    SUM(
        bp.anzahl * bp.einzelpreis * (1 - bp.rabatt_prozent / 100.0)
    ) AS tagesumsatz
FROM
    bestellungen b,
    bestell_positionen bp,
    kunden k
WHERE
    b.bestellung_id = bp.bestellung_id
    AND b.kunde_id = k.kunde_id
    -- optionaler Filialfilter:
    AND ( :p_filiale_id IS NULL OR b.filiale_id = :p_filiale_id )
    -- optionaler Zeitraumfilter:
    AND ( :p_startdatum IS NULL OR b.bestelldatum >= :p_startdatum )
    AND ( :p_enddatum   IS NULL OR b.bestelldatum <  :p_enddatum + INTERVAL '1 day' )
    -- optionaler Kundentyp:
    AND ( :p_kunden_typ IS NULL OR k.kunden_typ = :p_kunden_typ )
GROUP BY
    DATE_TRUNC('day', b.bestelldatum)
ORDER BY
    tag;


--------------------------------------------------
-- Aufgabe 9
-- Produkte, die:
-- - selten verkauft wurden (< 5 Einheiten),
-- - selten geliefert wurden (< 3 Lieferungen),
-- - in keinem Backauftrag vorkamen,
-- - aber mindestens ein Rezept haben.
--------------------------------------------------
WITH bestell_mengen AS (
    SELECT
        bp.produkt_id,
        SUM(bp.anzahl) AS gesamt_bestellt
    FROM
        bestell_positionen bp
    GROUP BY
        bp.produkt_id
),
liefer_mengen AS (
    SELECT
        lp.produkt_id,
        SUM(lp.anzahl)     AS gesamt_geliefert,
        COUNT(*)           AS anzahl_lieferungen
    FROM
        lieferung_positionen lp
    GROUP BY
        lp.produkt_id
),
backauftrag_produkte AS (
    SELECT DISTINCT
        bap.produkt_id
    FROM
        backauftrag_positionen bap
),
produkte_mit_rezept AS (
    SELECT DISTINCT
        pr.produkt_id
    FROM
        produkt_rezept pr
)
SELECT
    p.produkt_id,
    p.name
FROM
    produkte p
LEFT JOIN bestell_mengen bm
    ON p.produkt_id = bm.produkt_id
LEFT JOIN liefer_mengen lm
    ON p.produkt_id = lm.produkt_id
LEFT JOIN backauftrag_produkte bp
    ON p.produkt_id = bp.produkt_id
LEFT JOIN produkte_mit_rezept pmr
    ON p.produkt_id = pmr.produkt_id
WHERE
    COALESCE(bm.gesamt_bestellt, 0) < 5
    AND COALESCE(lm.anzahl_lieferungen, 0) < 3
    AND bp.produkt_id IS NULL
    AND pmr.produkt_id IS NOT NULL;


--------------------------------------------------
-- Aufgabe 10
-- „Alles-in-einem“-Produktanalyse:
-- Flags:
--   - wird_kaum_gekauft (gesamtmenge < 10)
--   - im_trend (Bestellungen der letzten 14 Tage > 3)
--------------------------------------------------
WITH bestell_agg AS (
    SELECT
        bp.produkt_id,
        SUM(bp.anzahl) AS gesamtmenge
    FROM
        bestell_positionen bp
    GROUP BY
        bp.produkt_id
),
trend_agg AS (
    SELECT
        bp.produkt_id,
        COUNT(DISTINCT b.bestellung_id) AS anzahl_bestellungen_14_tage
    FROM
        bestell_positionen bp,
        bestellungen b
    WHERE
        bp.bestellung_id = b.bestellung_id
        AND b.bestelldatum >= NOW() - INTERVAL '14 days'
    GROUP BY
        bp.produkt_id
)
SELECT
    p.produkt_id,
    p.name,
    p.standardpreis,
    k.bezeichnung AS kategorie,
    COALESCE(ba.gesamtmenge, 0) AS gesamtmenge,
    CASE
        WHEN COALESCE(ba.gesamtmenge, 0) < 10 THEN TRUE
        ELSE FALSE
    END AS wird_kaum_gekauft,
    COALESCE(ta.anzahl_bestellungen_14_tage, 0) AS bestellungen_14_tage,
    CASE
        WHEN COALESCE(ta.anzahl_bestellungen_14_tage, 0) > 3 THEN TRUE
        ELSE FALSE
    END AS im_trend
FROM
    produkte p
LEFT JOIN produktkategorien k ON p.kategorie_id = k.kategorie_id
LEFT JOIN bestell_agg ba      ON p.produkt_id    = ba.produkt_id
LEFT JOIN trend_agg  ta       ON p.produkt_id    = ta.produkt_id
ORDER BY
    im_trend DESC,
    wird_kaum_gekauft,
    p.name;
