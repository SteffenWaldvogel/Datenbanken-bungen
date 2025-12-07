# 02 – Funktionen mit Businesslogik

Ziel: Nicht nur Werte auslesen, sondern Logik und Bedingungen einbauen.

---

## Aufgabe 1 – Versandkosten berechnen

Schreibe eine Funktion `fn_versandkosten(k_id INT)`, die Versandkosten je nach Kundentyp zurückgibt:

- `PRIVAT` → 4.90
- `GESCHAEFT` → 0.00
- Sonst / nicht gefunden → 9.90

Rückgabetyp: `NUMERIC(6,2)`

---

## Aufgabe 2 – Kundentyp-Autoerkennung

Schreibe eine Funktion `fn_kundentyp(k_id INT)`, die:

- `'GESCHAEFT'` zurückgibt, falls der Name z. B. `GmbH` oder `AG` enthält
- sonst `'PRIVAT'`

Ignoriere echte Datenlogik – einfach String-Analyse. Rückgabetyp: `TEXT`.

---

## Aufgabe 3 – Produktverfügbarkeit simulieren

Schreibe eine Funktion `fn_ist_verfuegbar(p_id INT, menge INT)`, die `BOOLEAN` zurückgibt.

- Für diese Übung:
  - Wenn `menge <= 20` → TRUE
  - sonst → FALSE
- Stelle dir das als Platzhalter für ein echtes Lager vor.

---

## Aufgabe 4 – Umsatzklasse eines Kunden

Schreibe eine Funktion `fn_umsatzklasse_kunde(k_id INT)`, die auf Basis des Gesam­tumsatzes (wie in Übung 01) eine Klasse zurückgibt:

- `< 100` → `'LOW'`
- `100 – 499` → `'MID'`
- `>= 500` → `'HIGH'`

Rückgabetyp: `TEXT`.

---

## Aufgabe 5 – Rabatt dynamisch neu berechnen

Schreibe eine Funktion `fn_neuer_rabatt(k_id INT)`, die basierend auf der Umsatzklasse einen Vorschlag macht:

- `LOW` → 0
- `MID` → 5
- `HIGH` → 10

Rückgabetyp: `INTEGER`.

---

## Aufgabe 6 – Formatierte Kundenbeschreibung

Schreibe eine Funktion `fn_kundeninfo(k_id INT)`, die einen String wie:

> `Kunde 5: Bäckerei Meyer (Typ GESCHAEFT), Rabatt 10 %`

zurückgibt.

Verwende `SELECT ... INTO` auf `kunden` und ggf. `COALESCE`.
