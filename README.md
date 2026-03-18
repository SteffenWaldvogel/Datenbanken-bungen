# Baeckerei-Datenbank -- PostgreSQL Trainingsprojekt

Dieses Repository stellt eine vollstaendige Uebungsdatenbank zum Thema **Baeckerei** bereit.
Ideal zum Lernen von:

- SQL (SELECT, JOIN, GROUP BY, Views, Subqueries)
- DML (INSERT, UPDATE, DELETE)
- Benutzerrechten (`GRANT`, `REVOKE`, `CREATE USER`)
- prozeduraler SQL-Programmierung in **PL/pgSQL** -- sehr aehnlich zu Oracle PL/SQL

Die Datenbank ist bewusst umfangreich gestaltet (18 Tabellen, N:M-Beziehungen, Fremdschluessel, realistische Daten).

---

# 1. Installation

### Voraussetzungen

- PostgreSQL **15, 16 oder 17**
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

# 2. Datenbank erstellen

## 2.1 Datenbank anlegen

```sql
CREATE DATABASE bakery_db;
```

Verbinden:

```sql
\c bakery_db
```

---

# 3. Schema & Daten importieren

## 3.1 Tabellenstruktur importieren

```sql
\i Skript_Setups/create_bakery_tables.sql
```

## 3.2 Beispieldaten importieren

```sql
\i Skript_Setups/insert_bakery_tables.sql
```

Jetzt stehen alle Daten bereit: Filialen, Mitarbeiter, Kunden, Produkte, Rezepte, Bestellungen, Lieferungen, Backauftraege etc.

---

# 4. Benutzer & Rechte

Die Benutzer und Rechte werden am Ende von `create_bakery_tables.sql` automatisch angelegt.

### Angelegte Benutzer

| Benutzer        | Passwort     | Rechte                            |
|-----------------|--------------|------------------------------------|
| bakery_admin    | admin123     | SELECT, INSERT, UPDATE, DELETE     |
| bakery_azubi    | azubi123     | SELECT, INSERT, UPDATE, DELETE     |
| bakery_readonly | readonly123  | Nur SELECT                         |

---

# 5. SQL-Uebungsaufgaben

Im Ordner `SQL_Aufgaben/`:

- `01_select_basics.md` -- Einfache SELECT-Abfragen
- `02_filter_und_bedingungen.md` -- Filter, Bedingungen, Operatoren
- `03_einfache_joins.md` -- JOINs (Einsteiger)
- `04_joins_komplex.md` -- Komplexe JOINs
- `05_aggregation_groupby.md` -- Aggregation & GROUP BY
- `06_subqueries.md` -- Subqueries
- `07_views.md` -- Views
- `08_dml_insert_update_delete.md` -- INSERT / UPDATE / DELETE
- `09_set_operationen.md` -- Set-Operationen
- `10_komplexe_klausuraufgaben.md` -- Komplexe Klausuraufgaben

Loesungen liegen im Ordner `SQL_Aufgaben/SQL_Loesungen/`.

---

# 6. PL/pgSQL-Uebungsaufgaben

Im Ordner `PL/SQL_Aufgaben/`:

- `Wie_funktioniert_PLSQL_in_Postgre.md` -- Einfuehrung in PL/pgSQL
- `01_funktionen_basic.md` -- Funktionen (Basics)
- `02_funktionen_businesslogik.md` -- Funktionen mit Businesslogik
- `03_prozeduren_und_transaktionen.md` -- Prozeduren & Transaktionen
- `04_trigger_baeckerei_logik.md` -- Trigger
- `05_fehler_schleifen_cursor.md` -- Fehlerbehandlung, Schleifen, Cursors
- `06_mini_projekt.md` -- Mini-Projekt: Bestellpruefung & Reporting

Loesungen liegen im Ordner `PL/SQL_Aufgaben/PL/SQL_Loesungen/`.

---

# 7. PL/pgSQL kurz erklaert

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
    RETURN 'Baeckerei-System laeuft.';
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

# Ziel des Projekts

Dieses Projekt soll ermoeglichen:

- SQL realistisch zu ueben
- komplexe Datenmodelle zu verstehen
- PL/pgSQL (aehnlich PL/SQL) anzuwenden
- Benutzerrechte zu testen
- eine vollstaendige Lernumgebung fuer Kommiliton*innen aufzubauen

Viel Erfolg beim Lernen!
