# PL/pgSQL-Übungen – Wichtige Hinweise

In diesem Ordner übst du **Server-Logik** mit PostgreSQL:
- Funktionen
- Prozeduren
- Trigger
- Fehlerbehandlung

Technisch verwenden wir **PostgreSQL + PL/pgSQL**, nicht Oracle PL/SQL.

---

## 1. Grundgerüst einer Funktion in PostgreSQL

Jede Funktion folgt grob diesem Muster:

```sql
CREATE OR REPLACE FUNCTION fn_beispiel(p_id INT)
RETURNS TEXT
AS $$
DECLARE
    v_name TEXT;
BEGIN
    SELECT name
    INTO v_name
    FROM kunden
    WHERE kunde_id = p_id;

    RETURN v_name;
END;
$$ LANGUAGE plpgsql;
```

Wichtig dabei:
- `$$ ... $$` begrenzt den Funktionsblock.
- `LANGUAGE plpgsql` **muss** am Ende stehen.
- Variablen stehen im `DECLARE`-Block.
- Der Code steckt zwischen `BEGIN` und `END;`.

---

## 2. Unterschiede zu „normalem“ SQL in PostgreSQL

Normale SQL-Statements (im Query Tool):

```sql
SELECT * FROM kunden;
UPDATE produkte SET standardpreis = standardpreis * 1.1;
```

PL/pgSQL dagegen:
- läuft **innerhalb** einer Funktion/Prozedur
- unterstützt:
  - Variablen (`v_sum NUMERIC;`)
  - Kontrollstrukturen (`IF`, `FOR`, `LOOP`)
  - Fehlerbehandlung (`EXCEPTION`)
  - Meldungen (`RAISE NOTICE`)

Typische Besonderheiten:

- **Zuweisung** in PL/pgSQL:

  ```sql
  v_sum := v_sum + 1;
  ```

- **SELECT INTO** statt `SELECT`:

  ```sql
  SELECT rabatt_prozent
  INTO v_rabatt
  FROM kunden
  WHERE kunde_id = p_id;
  ```

- Wenn du das Ergebnis einer Abfrage **ignorieren** willst:

  ```sql
  PERFORM 1
  FROM kunden
  WHERE kunde_id = p_id;
  ```

- Log-Ausgabe:

  ```sql
  RAISE NOTICE 'Kunde % hat Rabatt %', p_id, v_rabatt;
  ```

> Merken: **PL/pgSQL = „SQL + Programmierlogik“**  
> Du schreibst kein einzelnes `SELECT`, sondern „kleine Programme“, die SQL verwenden.

---

## 3. Logikoperatoren und Vergleich

Auch in PL/pgSQL gelten die **SQL-Operatoren**, nicht die aus Programmiersprachen wie C/JavaScript:

- `AND` statt `&&`
- `OR` statt `||`
- `NOT` statt `!`
- `=` statt `==`
- `IS NULL` / `IS NOT NULL` statt `= NULL`

Beispiel:

```sql
IF v_preis > 3.00 AND v_vegan = TRUE THEN
    ...
END IF;
```

---

## 4. Unterschiede zu Oracle PL/SQL (falls ihr das Skript kennt)

Wir emulieren das PL/SQL-Gefühl, aber technisch ist es **PostgreSQL-PL/pgSQL**.  
Ein paar typische Unterschiede:

- Typen:
  - Oracle `NUMBER` → PostgreSQL z. B. `NUMERIC(12,2)` oder `INTEGER`
  - Oracle `VARCHAR2` → PostgreSQL `VARCHAR` oder `TEXT`
- Kein `DUAL` nötig – du kannst z. B. direkt `SELECT 1;` schreiben.
- Sequenzen / IDs meist über `SERIAL` / `GENERATED AS IDENTITY` statt `sequence.NEXTVAL` im Code.
- Prozeduren:
  - Neuere PostgreSQL-Versionen haben `CREATE PROCEDURE ...` + `CALL ...`
  - In vielen Beispielen reicht dir `CREATE FUNCTION ... RETURNS void`.

Praktisch für dieses Repo heißt das:
- Alles ist für **PostgreSQL** ausgelegt.
- Die Syntaxbeispiele aus dem FH-Skript zu PL/SQL sind in die passende **PL/pgSQL-Form** übersetzt.

---

## 5. Wie du die Beispiele testest

1. Im **Query Tool** von pgAdmin:
   - Funktion/Prozedur/Trigger-Definition komplett markieren
   - Ausführen (Blitz-Button).

2. Anschließend Funktion aufrufen, z. B.:

   ```sql
   SELECT fn_umsatz_kunde(1);
   ```

3. Prozeduren:
   - Entweder als Funktion mit `RETURNS void` aufbauen und `SELECT pr_name(...);` aufrufen
   - oder – falls du `CREATE PROCEDURE` benutzt – mit `CALL pr_name(...);`.

---

**Faustregel:**  
Wenn du **nur SELECT/INSERT/UPDATE/DELETE** schreibst → normales SQL.  
Sobald du **BEGIN/END, DECLARE, IF, LOOP** brauchst → PL/pgSQL-Funktion oder -Prozedur.
