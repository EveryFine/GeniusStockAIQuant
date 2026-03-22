"""Load and normalize A-share market data."""

from __future__ import annotations

import pandas as pd


class DataLoader:
    """Load OHLCV and related fields from local or remote sources."""

    def load_stock_data(
        self,
        stock_code: str,
        start_date: str,
        end_date: str,
    ) -> pd.DataFrame:
        raise NotImplementedError(
            "Implement loading from data/raw (or your data provider) for "
            f"{stock_code} between {start_date} and {end_date}."
        )
