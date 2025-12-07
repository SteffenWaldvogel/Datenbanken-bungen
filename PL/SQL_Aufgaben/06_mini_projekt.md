# 06 – Mini-Projekt: Bestellprüfung & Reporting

Ziel: Mehrere Funktionen, Prozeduren und Trigger zu einem sinnvollen Miniprojekt kombinieren.

---

## Projektidee

Du baust eine einfache Logik für „qualitätsgeprüfte Bestellungen“ auf.

---

## Teil 1 – Prüf-Funktion

Schreibe eine Funktion `fn_bestellung_ok(b_id INT) RETURNS BOOLEAN`, die prüft:

- Hat die Bestellung mindestens eine Position?
- Ist der Gesamtwert >= 5.00 EUR?
- Hat der Kunde eine gültige Email (enthält '@')?

Nur wenn alles erfüllt ist → TRUE, sonst FALSE.

---

## Teil 2 – Prozedur zur Markierung

Erweitere `bestellungen` um eine Spalte `geprueft BOOLEAN DEFAULT FALSE`.

Schreibe eine Prozedur `pr_bestellung_pruefen_und_markieren(b_id INT)`, die:

- `fn_bestellung_ok(b_id)` aufruft,
- wenn TRUE: `geprueft = TRUE` setzt,
- sonst: `geprueft = FALSE` setzt.

---

## Teil 3 – Trigger auf Bestellungen

Schreibe einen AFTER INSERT Trigger auf `bestellungen`, der:

- nach dem Einfügen automatisch `pr_bestellung_pruefen_und_markieren(NEW.bestellung_id)` aufruft.

Ergebnis: Jede neue Bestellung wird automatisch geprüft.

---

## Teil 4 – Reporting-View

Erzeuge eine View `v_bestellungen_geprueft`, die u. a. anzeigt:

- bestellung_id
- kunde (Name)
- filiale (Name)
- bestelldatum
- gesamtwert
- `geprueft` (TRUE/FALSE)

Nutze dazu ggf. eine Aggregation über `bestell_positionen`.

---

## Teil 5 – Bonus: Abgelehnte Bestellungen loggen

Erstelle eine Tabelle `bestellung_prueflog`:

- `log_id` SERIAL
- `bestellung_id`
- `grund` (TEXT)
- `zeitpunkt TIMESTAMP DEFAULT NOW()`

Erweitere die Prozedur `pr_bestellung_pruefen_und_markieren`, so dass bei `geprueft = FALSE` ein Eintrag geschrieben wird, warum die Bestellung durchgefallen ist (z. B. `'Warenwert < 5 EUR'` oder `'Keine Positionen'`).
