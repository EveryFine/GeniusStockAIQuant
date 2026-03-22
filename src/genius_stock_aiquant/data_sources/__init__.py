"""Pluggable market data sources (PostgreSQL, files, etc.)."""

from .postgres import (
    PostgresTableConfig,
    fetch_daily_ohlcv,
    load_postgres_config_from_env,
    postgres_connect,
    ping_postgres,
)

__all__ = [
    "PostgresTableConfig",
    "fetch_daily_ohlcv",
    "load_postgres_config_from_env",
    "postgres_connect",
    "ping_postgres",
]
