#!/usr/bin/env python3
"""Example: load daily OHLCV from PostgreSQL and compute simple moving averages."""

from __future__ import annotations

import os
import sys

from genius_stock_aiquant.data_loader import DataLoader


def main() -> None:
    code = os.environ.get("GSAQ_EXAMPLE_CODE", "000001.SZ")
    start = os.environ.get("GSAQ_EXAMPLE_START", "2020-01-01")
    end = os.environ.get("GSAQ_EXAMPLE_END", "2024-12-31")

    loader = DataLoader()
    try:
        df = loader.load_stock_data(code, start, end)
    except ValueError as e:
        print(e, file=sys.stderr)
        sys.exit(1)

    if df.empty:
        print("No rows returned; check code format and date range.", file=sys.stderr)
        sys.exit(2)

    df = df.sort_values("date").reset_index(drop=True)
    for w in (5, 20, 60):
        df[f"ma{w}"] = df["close"].rolling(window=w, min_periods=w).mean()

    cols = ["date", "close", "ma5", "ma20", "ma60"]
    print(df[cols].tail(15).to_string(index=False))


if __name__ == "__main__":
    main()
