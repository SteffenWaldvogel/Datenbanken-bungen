# 04 – Trigger in der Bäckerei-Datenbank

Ziel: Automatisches Verhalten beim Einfügen / Ändern.

---

## Aufgabe 1 – Timestamp beim Einfügen von Bestellungen

Füge (falls noch nicht vorhanden) eine Spalte `erstellt_am TIMESTAMP DEFAULT NOW()` zu `bestellungen` hinzu.

Schreibe einen BEFORE INSERT Trigger `tr_bestellung_set_erstellt`, der:

- beim Einfügen, falls `NEW.erstellt_am` NULL ist, diese auf `NOW()` setzt.

---

## Aufgabe 2 – Status bei neuer Bestellung automatisch setzen

Schreibe einen Trigger, der beim Einfügen einer neuen Bestellung:

- `status` automatisch auf `'OFFEN'` setzt, wenn kein Status angegeben ist.

Triggerfunktion: `trf_bestellung_default_status()`

---

## Aufgabe 3 – Logging von Preisänderungen

Lege eine Tabelle `preislog` an:

- `log_id` SERIAL
- `produkt_id`
- `alter_preis`
- `neuer_preis`
- `geaendert_am TIMESTAMP`

Schreibe einen Trigger auf `produkte` (BEFORE UPDATE), der:

- wenn sich `standardpreis` ändert, einen Eintrag in `preislog` erzeugt.

---

## Aufgabe 4 – Rabatt-Validierung

Erweitere die Logik mit einem BEFORE UPDATE Trigger auf `kunden`, der:

- verhindert, dass `rabatt_prozent` < 0 oder > 50 gesetzt wird.
- bei ungültigem Wert: `RAISE EXCEPTION 'Rabatt außerhalb des erlaubten Bereichs'`.

---

## Aufgabe 5 – Auto-Bestellstatus bei leeren Positionen

Schreibe einen AFTER DELETE Trigger auf `bestell_positionen`, der prüft:

- Wenn eine Bestellung **keine** Positionen mehr hat,
- setze `status` in `bestellungen` automatisch auf `'LEER'`.

---

## Aufgabe 6 – Änderungslog für Kunden

Erstelle eine Tabelle `kundenlog`:

- `log_id` SERIAL
- `kunde_id`
- `aktion` (z. B. 'INSERT', 'UPDATE', 'DELETE')
- `alt_name`
- `neu_name`
- `zeitpunkt TIMESTAMP`

Schreibe einen Trigger, der auf `kunden` bei INSERT, UPDATE und DELETE entsprechend einen Logeintrag schreibt.
