"""Load and normalize A-share market data."""

from __future__ import annotations

import pandas as pd

from genius_stock_aiquant.data_sources.postgres import (
    fetch_daily_ohlcv,
    load_postgres_config_from_env,
    postgres_connect,
)


class DataLoader:
    """Load OHLCV and related fields from PostgreSQL (configured via env) or future sources."""

    def load_stock_data(
        self,
        stock_code: str,
        start_date: str,
        end_date: str,
    ) -> pd.DataFrame:
        loaded = load_postgres_config_from_env()
        if loaded is None:
            raise ValueError(
                "PostgreSQL is not configured. Set DATABASE_URL (or GSAQ_DATABASE_URL) "
                "or GSAQ_PG_HOST / GSAQ_PG_DB / GSAQ_PG_USER (and optional GSAQ_PG_PASSWORD). "
                "See .env.example and README for table column mapping (GSAQ_PG_*)."
            )
        connect_kwargs, mapping = loaded
        with postgres_connect(connect_kwargs) as conn:
            return fetch_daily_ohlcv(
                conn, mapping, stock_code, start_date, end_date
            )
