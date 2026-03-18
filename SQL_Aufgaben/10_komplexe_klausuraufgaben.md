# 10 – Komplexe Klausuraufgaben (Hohe Schwierigkeit)

## Aufgabe 1  
Finde das Produkt mit dem höchsten Gesamtumsatz, 
und gib zusätzlich aus:
- Kategorie
- Gesamtmenge
- Anzahl unterschiedlicher Kunden

## Aufgabe 2  
Berechne für jede Filiale:
- anzahl_bestellungen
- gesamtumsatz
- durchschnittliche Bestellgröße
- umsatz pro Mitarbeiter

Sortiere nach Umsatz absteigend.

## Aufgabe 3  
Kundenprofilanalyse:
Finde für jeden Geschäftskunden:
- gesamtumsatz
- durchschnittlicher Bestellwert
- teuerstes Produkt je Kunde
- meistbestelltes Produkt je Kunde

## Aufgabe 4  
Erstelle eine Abfrage, die:
- alle Produkte auflistet,
- ihren Gesamtumsatz,
- die Anzahl Rezepte,
- die Anzahl Lieferungen,
- und das Verhältnis „Bestellmenge zu Liefermenge“.

Sortiere nach Umsatz DESC.

## Aufgabe 5  
Backauftrag-Produktionsanalyse:
Für jeden Backauftrag:
- Summe aller Teiglinge
- beteiligte Produkte
- Name des zuständigen Mitarbeiters
- Filialname
- Dauer: startzeit_ist – startzeit_geplant

Ordne Backaufträge nach Dauer.

## Aufgabe 6  
Ermittle das komplexeste Rezept:
- mit den meisten Zutaten
- inklusive Mengen
- Gesamtmaterialkosten (mit lieferant_zutat verknüpft!)

## Aufgabe 7  
Ermittle für jeden Monat:
- Gesamtumsatz,
- Anzahl Bestellungen,
- Durchschn. Warenkorbgröße,
- Top-Produkt des Monats,
- umsatzstärksten Kunden.

## Aufgabe 8  
Erstelle eine Multifilter-Abfrage für ein Dashboard:
- optionaler Filter: Filiale
- optionaler Filter: Zeitraum
- optionaler Filter: Kundentyp
- dynamischer Umsatz pro Tag

(Hier brauchst du WHERE-Ketten mit OR-Blöcken oder COALESCE-Filtern)

## Aufgabe 9  
Finde alle Produkte, die:
- selten verkauft wurden (< 5 Verkäufe),
- selten geliefert wurden (< 3 Lieferungen),
- in keinem Backauftrag vorkamen,
- aber ein vollständiges Rezept besitzen.

## Aufgabe 10  
„Alles-in-einem“-Klausuraufgabe:
Erstelle eine Abfrage zur vollständigen Produktanalyse:
- Basis: produkt_id, name, preis
- Kategorie
- Anzahl Bestellungen
- Gesamtumsatz
- Anzahl Lieferungen
- Anzahl Rezepte
- Anzahl Zutaten (Distinct)
- Flag: „wird kaum gekauft“ (weniger als 10 Einheiten)
- Flag: „im Trend“ (letzte 14 Tage > 3 Bestellungen)
