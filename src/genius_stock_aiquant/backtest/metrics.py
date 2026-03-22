"""Performance metrics (Sharpe, drawdown, win rate, etc.)."""

from __future__ import annotations

from typing import Any, Dict

import pandas as pd


def performance_metrics(returns: pd.Series) -> Dict[str, Any]:
    """Compute standard risk/return statistics from a return series."""
    del returns
    return {}
