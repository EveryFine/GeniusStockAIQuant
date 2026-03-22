"""PostgreSQL data source (mocked; no real DB required)."""

from __future__ import annotations

from contextlib import contextmanager
from unittest import mock

import pandas as pd
import pytest

from genius_stock_aiquant.data_loader import DataLoader
from genius_stock_aiquant.data_sources.postgres import (
    PostgresTableConfig,
    fetch_daily_ohlcv,
    load_postgres_config_from_env,
)


def test_load_postgres_config_from_env_missing_returns_none(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.delenv("GSAQ_DATABASE_URL", raising=False)
    monkeypatch.delenv("GSAQ_PG_DB", raising=False)
    monkeypatch.delenv("GSAQ_PG_USER", raising=False)
    assert load_postgres_config_from_env() is None


def test_load_postgres_config_from_env_url(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("DATABASE_URL", "postgresql://u:p@localhost:5432/db")
    out = load_postgres_config_from_env()
    assert out is not None
    connect_kwargs, mapping = out
    assert connect_kwargs["dsn"].startswith("postgresql://")
    assert mapping.table == "stock_daily"


def test_data_loader_requires_config(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("DATABASE_URL", raising=False)
    monkeypatch.delenv("GSAQ_DATABASE_URL", raising=False)
    monkeypatch.delenv("GSAQ_PG_DB", raising=False)
    monkeypatch.delenv("GSAQ_PG_USER", raising=False)
    loader = DataLoader()
    with pytest.raises(ValueError, match="PostgreSQL is not configured"):
        loader.load_stock_data("000001.SZ", "2023-01-01", "2023-12-31")


def test_fetch_daily_ohlcv_uses_read_sql(monkeypatch: pytest.MonkeyPatch) -> None:
    cfg = PostgresTableConfig(
        schema="public",
        table="daily",
        code_column="ts_code",
        date_column="trade_date",
        open_column="open",
        high_column="high",
        low_column="low",
        close_column="close",
        volume_column="vol",
        amount_column="amount",
    )
    fake = pd.DataFrame(
        {
            "stock_code": ["000001.SZ"],
            "date": [pd.Timestamp("2023-01-03")],
            "open": [1.0],
            "high": [1.1],
            "low": [0.9],
            "close": [1.05],
            "volume": [1000.0],
            "amount": [1e6],
        }
    )
    with mock.patch("genius_stock_aiquant.data_sources.postgres.pd.read_sql_query", return_value=fake):
        df = fetch_daily_ohlcv(mock.Mock(), cfg, "000001.SZ", "2023-01-01", "2023-12-31")
    assert len(df) == 1
    assert df["close"].iloc[0] == 1.05


def test_data_loader_with_mocked_pg(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("DATABASE_URL", "postgresql://u:p@localhost:5432/db")
    fake = pd.DataFrame(
        {
            "stock_code": ["000001.SZ"],
            "date": [pd.Timestamp("2023-01-03")],
            "open": [1.0],
            "high": [1.1],
            "low": [0.9],
            "close": [1.05],
            "volume": [1000.0],
            "amount": [1e6],
        }
    )

    @contextmanager
    def _noop_connect(_kwargs: object) -> object:
        yield mock.Mock()

    with mock.patch("genius_stock_aiquant.data_loader.postgres_connect", _noop_connect):
        with mock.patch(
            "genius_stock_aiquant.data_loader.fetch_daily_ohlcv", return_value=fake
        ):
            loader = DataLoader()
            df = loader.load_stock_data("000001.SZ", "2023-01-01", "2023-12-31")
    assert len(df) == 1
