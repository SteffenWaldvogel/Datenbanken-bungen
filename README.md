# 🥐 Bäckerei-Datenbank – PostgreSQL Trainingsprojekt

Dieses Repository stellt eine vollständige Übungsdatenbank zum Thema **Bäckerei** bereit.
Ideal zum Lernen von:

- SQL (SELECT, JOIN, GROUP BY, Views, Subqueries)
- DML (INSERT, UPDATE, DELETE)
- Benutzerrechten (`GRANT`, `REVOKE`, `CREATE USER`)
- prozeduraler SQL-Programmierung in **PL/pgSQL** – sehr ähnlich zu Oracle PL/SQL

Die Datenbank ist bewusst umfangreich gestaltet (18 Tabellen, N:M-Beziehungen, Fremdschlüssel, realistische Daten).

---

# 📦 1. Installation

### Voraussetzungen

- PostgreSQL **15 oder 16**
- SQL-Client deiner Wahl:
  - pgAdmin 4
  - DBeaver
  - oder CLI `psql`

Standard-Einstellungen:

```
Host: localhost
Port: 5432
User: postgres
Passwort: (bei Installation gesetzt)
Datenbankname: bakery_db
```

---

# 🍞 2. Datenbank erstellen

## 2.1 Datenbank anlegen

```sql
CREATE DATABASE bakery_db;
```

Verbinden:

```sql
\c bakery_db
```

---

# 📚 3. Schema & Daten importieren

## 3.1 Tabellenstruktur importieren

```sql
\i sql/create_bakery_tables.sql
```

## 3.2 Beispieldaten importieren

```sql
\i sql/insert_bakery_tables.sql
```

Jetzt stehen alle Daten bereit: Filialen, Mitarbeiter, Kunden, Produkte, Rezepte, Bestellungen, Lieferungen, Backaufträge etc.

---

# 🔐 4. Benutzer & Rechte

Ausführen als Superuser:

```sql
\i sql/create_users_and_grants.sql
```

### Angelegte Benutzer

| Benutzer        | Passwort     | Rechte                            |
|-----------------|--------------|------------------------------------|
| bakery_admin    | admin123     | SELECT, INSERT, UPDATE, DELETE     |
| bakery_azubi    | azubi123     | SELECT, INSERT, UPDATE, DELETE     |
| bakery_readonly | readonly123  | Nur SELECT                         |

---

# 🧪 5. Übungsaufgaben

Im Ordner `aufgaben/`:

- 01_setup_und_check.sql – Überprüfung des Setups
- 02_select_basic.md – Einfache SELECT-Abfragen
- 03_joins_aggregate.md – JOINs, GROUP BY, HAVING
- 04_subqueries_views.md – Subqueries & Views
- 05_dml_updates.md – INSERT / UPDATE / DELETE
- 06_rechte_und_user.md – Benutzerrechte

Lösungen liegen im Ordner `loesungen/`.

---

# ⚙️ 6. PL/pgSQL kurz erklärt

Grundstruktur einer Funktion:

```sql
CREATE OR REPLACE FUNCTION funktionsname(parameter ...)
RETURNS datentyp AS $$
DECLARE
    -- Variablen
BEGIN
    -- Logik
    RETURN wert;
END;
$$ LANGUAGE plpgsql;
```

### Beispiel: einfache Funktion

```sql
CREATE OR REPLACE FUNCTION bakery_ping()
RETURNS TEXT AS $$
BEGIN
    RETURN 'Bäckerei-System läuft.';
END;
$$ LANGUAGE plpgsql;
```

### Beispiel: Bestellwert berechnen

```sql
CREATE OR REPLACE FUNCTION bestellwert(p_bestellung_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_summe NUMERIC(10,2);
BEGIN
    SELECT SUM(anzahl * einzelpreis * (1 - rabatt_prozent/100.0))
    INTO v_summe
    FROM bestell_positionen
    WHERE bestellung_id = p_bestellung_id;

    RETURN COALESCE(v_summe, 0);
END;
$$ LANGUAGE plpgsql;
```

---

# 🗂 7. Projektstruktur

```
baeckerei-db-training/
├─ README.md
├─ sql/
│  ├─ create_bakery_tables.sql
│  ├─ insert_bakery_tables.sql
│  ├─ create_users_and_grants.sql
├─ aufgaben/
│  ├─ 01_setup_und_check.sql
│  ├─ 02_select_basic.md
│  ├─ 03_joins_aggregate.md
│  ├─ 04_subqueries_views.md
│  ├─ 05_dml_updates.md
│  ├─ 06_rechte_und_user.md
├─ loesungen/
│  ├─ 02_select_basic_loesungen.sql
│  ├─ 03_joins_aggregate_loesungen.sql
│  ├─ 04_subqueries_views_loesungen.sql
│  ├─ 05_dml_updates_loesungen.sql
│  ├─ 06_rechte_und_user_loesungen.sql
```

---

# 🎯 Ziel des Projekts

Dieses Projekt soll ermöglichen:

- SQL realistisch zu üben  
- komplexe Datenmodelle zu verstehen  
- PL/pgSQL (ähnlich PL/SQL) anzuwenden  
- Benutzerrechte zu testen  
- eine vollständige Lernumgebung für Kommiliton*innen aufzubauen  

Viel Erfolg beim Lernen!
