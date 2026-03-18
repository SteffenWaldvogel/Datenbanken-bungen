# 📘 Anleitung: Tabellen und Daten in PostgreSQL anlegen

Diese kurze Anleitung zeigt dir, **wie du das Query Tool öffnest** und dort die beiden SQL‑Skripte im Ordner "Skript_Setups" ausführst:

- `create_bakery_tables.sql` (Tabellen anlegen)
- `insert_bakery_tables.sql` (Beispieldaten einfügen)

---

# 1. Query Tool in pgAdmin öffnen

## Schritt-für-Schritt:

1. Starte **pgAdmin 4**
2. Links im Browser-Baum:
   - Klicke auf **Servers**
   - Klicke auf **PostgreSQL <Version>**
   - Klappe **Databases** aus
   - Klicke auf **bakery_db**
3. Rechtsklick auf **bakery_db**
4. Wähle **Query Tool**

Jetzt öffnet sich oben ein neuer Tab mit einem SQL‑Editor – dort führen wir alles aus.

---

# 2. Tabellen anlegen

Im Query Tool:

1. Öffne die Datei `create_bakery_tables.sql`  
2. Kopiere ihren gesamten Inhalt
3. Füge ihn oben in das Query Tool ein
4. Klicke auf den **Play‑Button** (▶) oben links zum Ausführen

Damit werden **alle Tabellen** der Bäckerei‑Datenbank erstellt.

---

# 3. Beispieldaten einfügen

Im gleichen Query Tool oder in einem neuen Tab:

1. Öffne die Datei `insert_bakery_tables.sql`
2. Kopiere den kompletten Inhalt
3. Füge ihn ins Query Tool ein
4. Klicke wieder auf **Ausführen (▶)**

Damit werden alle Beispielwerte eingefügt:
- Filialen  
- Mitarbeiter  
- Kunden  
- Produkte  
- Rezepte  
- Bestellungen  
- Lieferungen  
- usw.

---

# 4. Schnelltest

Um zu prüfen, ob alles funktioniert hat:

```sql
SELECT * FROM filialen;
```

Wenn Zeilen zurückkommen, ist deine Datenbank bereit.

---

Fertig!  
Du kannst jetzt alle Übungen im Projekt direkt ausführen.
