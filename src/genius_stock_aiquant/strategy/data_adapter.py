"""Data adapter for loading stock pool and historical data from PostgreSQL."""

from __future__ import annotations

from datetime import datetime
from typing import Dict, List, Optional, Tuple

import pandas as pd

from genius_stock_aiquant.data_loader import DataLoader


class DataAdapter:
    """
    Adapter for loading stock pool candidates and OHLCV data.
    
    Integrates with existing DataLoader and provides convenient methods
    for backtest data fetching.
    """

    def __init__(self):
        self.data_loader = DataLoader()
        self._data_cache: Dict[str, pd.DataFrame] = {}

    def load_stock_ohlcv(
        self, stock_code: str, start_date: str, end_date: str, use_cache: bool = True
    ) -> pd.DataFrame:
        """
        Load OHLCV data for a stock.

        Args:
            stock_code: Stock symbol (e.g., '000001.SZ')
            start_date: YYYY-MM-DD format
            end_date: YYYY-MM-DD format
            use_cache: Use cached data if available

        Returns:
            DataFrame with OHLCV + adjusted prices
        """
        cache_key = f"{stock_code}_{start_date}_{end_date}"

        if use_cache and cache_key in self._data_cache:
            return self._data_cache[cache_key].copy()

        df = self.data_loader.load_stock_data(stock_code, start_date, end_date)

        # Ensure date column is datetime
        if "date" not in df.columns:
            df = df.reset_index()
        df["date"] = pd.to_datetime(df["date"])
        df = df.sort_values("date").reset_index(drop=True)

        if use_cache:
            self._data_cache[cache_key] = df.copy()

        return df

    def calculate_indicators(
        self, df: pd.DataFrame, ma_periods: Tuple[int, int, int] = (5, 20, 60)
    ) -> pd.DataFrame:
        """
        Calculate technical indicators.

        Args:
            df: DataFrame with OHLCV data (must have 'close' and 'volume')
            ma_periods: Tuple of (ma_short, ma_mid, ma_long)

        Returns:
            DataFrame with added indicator columns
        """
        df = df.copy()
        p_short, p_mid, p_long = ma_periods

        # Moving averages
        df[f"ma{p_short}"] = df["close"].rolling(window=p_short).mean()
        df[f"ma{p_mid}"] = df["close"].rolling(window=p_mid).mean()
        df[f"ma{p_long}"] = df["close"].rolling(window=p_long).mean()

        # Volume average
        df["vol_avg"] = df["volume"].rolling(window=p_mid).mean()

        # ATR (Average True Range) for volatility
        high_low = df["high"] - df["low"]
        high_close = (df["high"] - df["close"].shift()).abs()
        low_close = (df["low"] - df["close"].shift()).abs()
        tr = pd.concat([high_low, high_close, low_close], axis=1).max(axis=1)
        df["atr"] = tr.rolling(window=14).mean()

        return df

    def prepare_backtest_data(
        self,
        symbols: List[str],
        start_date: str,
        end_date: str,
        ma_periods: Tuple[int, int, int] = (5, 20, 60),
    ) -> pd.DataFrame:
        """
        Load and prepare multi-stock data for backtest.

        Args:
            symbols: List of stock symbols
            start_date: YYYY-MM-DD
            end_date: YYYY-MM-DD
            ma_periods: Moving average periods

        Returns:
            Combined DataFrame with all stocks and indicators
        """
        dfs = []

        for symbol in symbols:
            try:
                df = self.load_stock_ohlcv(symbol, start_date, end_date)
                df = self.calculate_indicators(df, ma_periods)
                df["symbol"] = symbol
                dfs.append(df)
            except Exception as e:
                print(f"Failed to load {symbol}: {e}")
                continue

        if not dfs:
            raise ValueError(f"Failed to load any data for symbols: {symbols}")

        combined = pd.concat(dfs, ignore_index=True)
        combined = combined.sort_values(["date", "symbol"]).reset_index(drop=True)

        return combined

    def get_latest_price(
        self, symbol: str, end_date: str
    ) -> Optional[float]:
        """Get latest closing price for a symbol."""
        try:
            df = self.load_stock_ohlcv(symbol, end_date, end_date)
            if df.empty:
                return None
            return float(df.iloc[-1]["close"])
        except Exception:
            return None

    def clear_cache(self) -> None:
        """Clear data cache."""
        self._data_cache.clear()
