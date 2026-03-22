"""PostgreSQL loader for A-share OHLCV-style tables.

Connection and table/column names are read from environment variables so you can
map to your existing schema without code changes.

Supported env (URL wins if set):
  DATABASE_URL or GSAQ_DATABASE_URL — postgresql://user:pass@host:port/dbname

Or discrete:
  GSAQ_PG_HOST (default localhost)
  GSAQ_PG_PORT (default 5432)
  GSAQ_PG_DB  — database name (required if not using URL)
  GSAQ_PG_USER
  GSAQ_PG_PASSWORD — may be empty for local trust auth
  GSAQ_PG_SCHEMA — default public

Table mapping (adjust to match your DDL):
  GSAQ_PG_TABLE — default stock_daily
  GSAQ_PG_CODE_COLUMN — default ts_code  (e.g. 000001.SZ)
  GSAQ_PG_DATE_COLUMN — default trade_date
  GSAQ_PG_OPEN_COLUMN, _HIGH_, _LOW_, _CLOSE_, _VOLUME_, _AMOUNT_
      defaults: open, high, low, close, vol, amount
  Set GSAQ_PG_AMOUNT_COLUMN to empty if you have no amount column (optional field omitted).
"""

from __future__ import annotations

import os
import re
from contextlib import contextmanager
from dataclasses import dataclass
from typing import Any, Dict, Iterator, Optional, Tuple

import pandas as pd

_IDENT = re.compile(r"^[a-zA-Z_][a-zA-Z0-9_]*$")


def _quote_ident(name: str) -> str:
    if not _IDENT.match(name):
        raise ValueError(f"Invalid SQL identifier: {name!r}")
    return name


@dataclass(frozen=True)
class PostgresTableConfig:
    """Table and column mapping for a daily OHLCV table."""

    schema: str
    table: str
    code_column: str
    date_column: str
    open_column: str
    high_column: str
    low_column: str
    close_column: str
    volume_column: str
    amount_column: Optional[str]


def load_postgres_config_from_env() -> Optional[Tuple[Dict[str, Any], PostgresTableConfig]]:
    """Return (psycopg2 connect kwargs including dsn OR discrete params, table config) or None if not configured."""
    url = os.environ.get("DATABASE_URL") or os.environ.get("GSAQ_DATABASE_URL")
    if url:
        connect_kwargs: Dict[str, Any] = {"dsn": url}
    else:
        host = os.environ.get("GSAQ_PG_HOST", "localhost")
        db = os.environ.get("GSAQ_PG_DB") or os.environ.get("GSAQ_PG_DATABASE")
        user = os.environ.get("GSAQ_PG_USER")
        if not db or user is None:
            return None
        connect_kwargs = {
            "host": host,
            "port": int(os.environ.get("GSAQ_PG_PORT", "5432")),
            "dbname": db,
            "user": user,
            "password": os.environ.get("GSAQ_PG_PASSWORD", ""),
        }

    schema = os.environ.get("GSAQ_PG_SCHEMA", "public")
    table = os.environ.get("GSAQ_PG_TABLE", "stock_daily")
    mapping = PostgresTableConfig(
        schema=schema,
        table=table,
        code_column=os.environ.get("GSAQ_PG_CODE_COLUMN", "ts_code"),
        date_column=os.environ.get("GSAQ_PG_DATE_COLUMN", "trade_date"),
        open_column=os.environ.get("GSAQ_PG_OPEN_COLUMN", "open"),
        high_column=os.environ.get("GSAQ_PG_HIGH_COLUMN", "high"),
        low_column=os.environ.get("GSAQ_PG_LOW_COLUMN", "low"),
        close_column=os.environ.get("GSAQ_PG_CLOSE_COLUMN", "close"),
        volume_column=os.environ.get("GSAQ_PG_VOLUME_COLUMN", "vol"),
        amount_column=(
            os.environ.get("GSAQ_PG_AMOUNT_COLUMN", "amount").strip() or None
        ),
    )
    return connect_kwargs, mapping


@contextmanager
def postgres_connect(connect_kwargs: Dict[str, Any]) -> Iterator[Any]:
    import psycopg2

    conn = psycopg2.connect(**connect_kwargs)
    try:
        yield conn
    finally:
        conn.close()


def ping_postgres() -> bool:
    """Run SELECT 1; returns True on success, False if not configured or on error."""
    loaded = load_postgres_config_from_env()
    if loaded is None:
        return False
    connect_kwargs, _ = loaded
    try:
        with postgres_connect(connect_kwargs) as conn:
            cur = conn.cursor()
            cur.execute("SELECT 1")
            cur.fetchone()
        return True
    except Exception:
        return False


def _qualified_table(cfg: PostgresTableConfig) -> str:
    return f'"{_quote_ident(cfg.schema)}"."{_quote_ident(cfg.table)}"'


def fetch_daily_ohlcv(
    conn: Any,
    cfg: PostgresTableConfig,
    stock_code: str,
    start_date: str,
    end_date: str,
) -> pd.DataFrame:
    """Load daily rows for one symbol; returns standardized columns (see below)."""
    qtable = _qualified_table(cfg)
    cols = [
        (cfg.date_column, "date"),
        (cfg.open_column, "open"),
        (cfg.high_column, "high"),
        (cfg.low_column, "low"),
        (cfg.close_column, "close"),
        (cfg.volume_column, "volume"),
    ]
    if cfg.amount_column:
        cols.append((cfg.amount_column, "amount"))

    select_parts = [
        f'"{_quote_ident(cfg.code_column)}" AS stock_code',
    ]
    for src, alias in cols:
        select_parts.append(f'"{_quote_ident(src)}" AS "{alias}"')

    sql = (
        f"SELECT {', '.join(select_parts)} FROM {qtable} "
        f'WHERE "{_quote_ident(cfg.code_column)}" = %s '
        f'AND "{_quote_ident(cfg.date_column)}" >= %s '
        f'AND "{_quote_ident(cfg.date_column)}" <= %s '
        f'ORDER BY "{_quote_ident(cfg.date_column)}" ASC'
    )

    df = pd.read_sql_query(sql, conn, params=[stock_code, start_date, end_date])
    if df.empty:
        cols = ["stock_code", "date", "open", "high", "low", "close", "volume"]
        if cfg.amount_column:
            cols.append("amount")
        return pd.DataFrame(columns=cols)
    if "date" in df.columns:
        df["date"] = pd.to_datetime(df["date"])
    for c in ["open", "high", "low", "close", "volume"]:
        if c in df.columns:
            df[c] = pd.to_numeric(df[c], errors="coerce")
    if "amount" in df.columns:
        df["amount"] = pd.to_numeric(df["amount"], errors="coerce")
    return df
