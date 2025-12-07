# 03 – Prozeduren & Transaktionen

Ziel: Änderungen an Daten vornehmen, mehrere Statements kapseln.

---

## Aufgabe 1 – Rabatt für alle Geschäftskunden setzen

Schreibe eine Prozedur `pr_setze_rabatt_geschaeft(rabatt_neu INT)`, die:

- in `kunden` für alle `GESCHAEFT` den `rabatt_prozent` auf `rabatt_neu` setzt.

Keine Rückgabe.

---

## Aufgabe 2 – Kunden anlegen mit Basic-Validierung

Schreibe eine Prozedur `pr_kunde_anlegen(name TEXT, email TEXT, typ TEXT)`, die:

- einen neuen Datensatz in `kunden` anlegt
- `rabatt_prozent` auf 0 setzt
- Wenn `email` kein `@` enthält, soll **KEIN Insert** erfolgen.

Optional: `RAISE NOTICE` bei Fehler.

---

## Aufgabe 3 – Produktpreis erhöhen (in Prozent)

Schreibe eine Prozedur `pr_preiserhoehung_pro_kategorie(kat_id INT, prozent NUMERIC)`, die:

- alle `produkte` in dieser Kategorie um `prozent` % teurer macht.
- Beispiel: `10` → neuer Preis = alter Preis * 1.10

Verwende eine Transaktion (implizit – Standard in PL/pgSQL).

---

## Aufgabe 4 – Bestellung stornieren

Schreibe eine Prozedur `pr_bestellung_stornieren(b_id INT)`, die:

- in `bestellungen` den `status` auf `'STORNIERT'` setzt
- optional das Storno-Datum (neue Spalte) pflegt, falls du eine hast

Wenn die Bestellung nicht existiert → `RAISE NOTICE`.

---

## Aufgabe 5 – Massen-Insert von Testkunden

Schreibe eine Prozedur `pr_testkunden_anlegen(anzahl INT)`, die:

- in einer Schleife `anzahl` Testkunden einfügt:
  - Namen z. B. `Testkunde 1`, `Testkunde 2`, …
  - Typ abwechselnd `PRIVAT` / `GESCHAEFT`

Nutze eine `FOR i IN 1..anzahl LOOP`-Schleife.

---

## Aufgabe 6 – Sammelupdate: VIP-Kunden markieren

Erweitere vorher, falls nötig, die Tabelle `kunden` um eine Spalte `ist_vip BOOLEAN DEFAULT FALSE`.

Schreibe eine Prozedur `pr_setze_vip_ab_umsatz(grenze NUMERIC)`, die:

- alle Kunden mit Gesamtumsatz > `grenze` auf `ist_vip = TRUE` setzt.
