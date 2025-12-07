# 05 – Fehlerbehandlung, Schleifen und Cursors

Ziel: TRY/CATCH-ähnliche Logik (EXCEPTION), Schleifen, explizite Cursors.

---

## Aufgabe 1 – Exception bei unbekanntem Kunden

Schreibe eine Funktion `fn_kunden_umsatz_strikt(k_id INT)`, die:

- den Gesamtumsatz eines Kunden berechnet (wie vorher),
- **eine Exception wirft**, falls der Kunde nicht existiert.

Nutze einen `EXCEPTION WHEN NO_DATA_FOUND THEN ...`-Block.

(Hinweis: In PostgreSQL: SELECT INTO + `IF NOT FOUND THEN ...` und `RAISE EXCEPTION`.)

---

## Aufgabe 2 – While-Schleife

Schreibe eine Prozedur `pr_dummy_zaehler(max_val INT)`, die:

- von 1 bis `max_val` zählt,
- bei jedem Schritt `RAISE NOTICE 'i = %', i;` ausgibt.

Nutze `LOOP ... EXIT WHEN ... END LOOP;`.

---

## Aufgabe 3 – Cursor über alle Produkte

Schreibe eine Prozedur `pr_liste_alle_produkte()`, die:

- einen Cursor über `produkte` iteriert,
- für jedes Produkt einen `RAISE NOTICE` mit `produkt_id` und `name` ausgibt.

---

## Aufgabe 4 – Rabatt massenhaft prüfen mit Cursor

Schreibe eine Prozedur `pr_pruefe_rabatt_grenzen()`, die:

- mit einem Cursor über alle `kunden` läuft,
- bei jedem Kunden prüft, ob `rabatt_prozent` außerhalb 0–50 liegt,
- und in diesem Fall `RAISE NOTICE` (oder `RAISE WARNING`) ausgibt.

---

## Aufgabe 5 – Fehler beim Insert abfangen

Schreibe eine Prozedur `pr_sichere_kunde_anlegen(name TEXT, email TEXT)`, die:

- versucht, einen Kunden einzufügen,
- bei Verletzung eines UNIQUE-Constraints (z. B. auf `email`) eine Nachricht ausgibt:
  - `RAISE NOTICE 'Kunde mit Email % existiert bereits', email;`
- und dann sauber weiterläuft (nicht komplett abbricht).

Nutze `EXCEPTION WHEN unique_violation THEN ...`.

---

## Aufgabe 6 – Batch-Update mit Schleife

Schreibe eine Prozedur `pr_aktualisiere_preise_schrittweise(prozent NUMERIC)`, die:

- mit einem Cursor über alle Produkte iteriert,
- in jedem Durchlauf **ein** Produkt um `prozent` % erhöht,
- und den Fortschritt per `RAISE NOTICE` ausgibt.
