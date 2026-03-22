# PostgreSQL data access

[中文说明](database-postgres.md)

This document explains how to configure **PostgreSQL** for **GeniusStockAIQuant**: recommended **read-only** credentials, what each grant does, and how that maps to project environment variables. The executable SQL template lives at [`sql/create_readonly_user.sql`](../sql/create_readonly_user.sql).

---

## 1. Why a read-only user

- Strategy code and data loading usually need **SELECT** only, not DDL/DML.
- A dedicated read-only role limits damage from mistakes or leaked credentials.
- The project `DataLoader` uses `psycopg2`; put the read-only account in `.env`.

---

## 2. Creating a read-only user (overview)

Run as a **superuser** (or a role with `CREATEROLE` and rights on the target DB) in **psql**. The full script with placeholders is in [`sql/create_readonly_user.sql`](../sql/create_readonly_user.sql).

Replace `gsaq_readonly`, `your_strong_password`, and `your_database` below. If OHLCV tables are not in `public`, change `public` to your schema (e.g. `market`).

```sql
CREATE ROLE gsaq_readonly WITH LOGIN PASSWORD 'your_strong_password'
  NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT CONNECT ON DATABASE your_database TO gsaq_readonly;

\c your_database
GRANT USAGE ON SCHEMA public TO gsaq_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO gsaq_readonly;
```

| Statement | Purpose |
|-----------|---------|
| `CREATE ROLE ... LOGIN` | Login-capable role without superuser / createdb, etc. |
| `GRANT CONNECT ON DATABASE` | Allow connecting to that database |
| `GRANT USAGE ON SCHEMA` | Allow using objects in that schema |
| `GRANT SELECT ON ALL TABLES` | Read-only on **existing** tables at grant time |

### 2.1 Non-`public` schema

```sql
GRANT USAGE ON SCHEMA market TO gsaq_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA market TO gsaq_readonly;
```

### 2.2 Tables created later

`GRANT SELECT ON ALL TABLES` covers tables that exist when you run it. For **future** tables created by a given owner, that owner (or a superuser) can run:

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO gsaq_readonly;
```

---

## 3. Mapping to project configuration

1. Copy [`.env.example`](../.env.example) to `.env` (do not commit secrets).
2. Use the read-only account, e.g.  
   `DATABASE_URL=postgresql://gsaq_readonly:your_strong_password@localhost:5432/your_database`  
   or discrete variables: `GSAQ_PG_HOST`, `GSAQ_PG_DB`, `GSAQ_PG_USER`, `GSAQ_PG_PASSWORD`, etc.
3. Map table/column names with `GSAQ_PG_*` if they differ from defaults (see `.env.example`).
4. Check connectivity: `python scripts/ping_db.py` (after `pip install -e .`).

---

## 4. Security notes

- Never commit `.env` or real passwords.
- Use strong passwords; restrict DB access to trusted networks in production.
- To revoke access, use `REVOKE` / `DROP ROLE` as appropriate (after checking dependencies).

---

## 5. Related files

| File | Purpose |
|------|---------|
| [`sql/create_readonly_user.sql`](../sql/create_readonly_user.sql) | Commented SQL template with placeholders |
| [`.env.example`](../.env.example) | Connection and table-mapping variables |
