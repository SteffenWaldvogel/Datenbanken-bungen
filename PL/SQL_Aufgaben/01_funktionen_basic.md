# 01 – Funktionen (Basics)

Ziel: Erste PL/pgSQL-Funktionen schreiben und ausführen.

---

## Aufgabe 1 – Einfache Begrüßungsfunktion

Schreibe eine Funktion `fn_hello_bakery()`, die **keinen Parameter** hat und einen Text zurückgibt, z. B.:

> 'Willkommen in der Bäckerei-Datenbank!'

- Rückgabetyp: `TEXT`
- Sprache: `plpgsql`

---

## Aufgabe 2 – Vollständiger Kundenname

Schreibe eine Funktion `fn_kundenname(k_id INT)`, die zu einer `kunde_id` den Kundennamen zurückgibt.

- Parameter: `k_id INT`
- Rückgabetyp: `TEXT`
- Verhalten:
  - wenn der Kunde existiert → `name`
  - wenn nicht → `'UNBEKANNT'`

---

## Aufgabe 3 – Anzahl Bestellungen eines Kunden

Schreibe eine Funktion `fn_bestellanzahl_kunde(k_id INT)`, die die Anzahl der Bestellungen eines Kunden zurückgibt.

- Rückgabetyp: `INT`
- Nutze eine `SELECT COUNT(*) INTO ...`-Abfrage.

---

## Aufgabe 4 – Gesamtumsatz eines Kunden

Schreibe eine Funktion `fn_umsatz_kunde(k_id INT)`, die den Gesamtumsatz (in EUR) eines Kunden berechnet.

- Basis: `bestellungen` + `bestell_positionen`
- Umsatz = SUM(anzahl * einzelpreis * (1 - rabatt_prozent/100))
- Rückgabetyp: `NUMERIC(12,2)`
- Falls keine Bestellungen vorliegen → `0.00` zurückgeben.

---

## Aufgabe 5 – Produktpreis abrufen

Schreibe eine Funktion `fn_preis_produkt(p_id INT)`, die den `standardpreis` eines Produkts zurückgibt.

- Rückgabetyp: `NUMERIC(8,2)`
- Wenn Produkt nicht existiert → `NULL`

---

## Aufgabe 6 – Ist Produkt vegan?

Schreibe eine Funktion `fn_ist_vegan(p_id INT)`, die `BOOLEAN` zurückgibt.

- TRUE, wenn `ist_vegan = TRUE`
- FALSE, wenn `ist_vegan = FALSE` oder Produkt nicht existiert.

---

## Aufgabe 7 – Rabattstufe beschreiben

Schreibe eine Funktion `fn_rabatt_stufe(k_id INT)`, die einen `TEXT` zurückgibt:

- `<name>: kein Rabatt` (<= 0)
- `<name>: normaler Rabatt` (1–10)
- `<name>: VIP-Rabatt` (> 10)
- Kunde nicht gefunden → `'Kunde nicht vorhanden'`
