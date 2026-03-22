"""Core backtest engine (skeleton)."""

from __future__ import annotations

from typing import TYPE_CHECKING, List

import pandas as pd

if TYPE_CHECKING:
    from genius_stock_aiquant.strategy.base import BaseStrategy


class BacktestResults:
    """Container for backtest output."""

    def summary(self) -> str:
        return "Backtest engine not fully implemented; no trades simulated."


class BacktestEngine:
    def __init__(self, initial_capital: float) -> None:
        self.initial_capital = initial_capital
        self._strategies: List[BaseStrategy] = []

    def add_strategy(self, strategy: BaseStrategy) -> None:
        self._strategies.append(strategy)

    def backtest(self, stock_data: pd.DataFrame) -> BacktestResults:
        del stock_data
        return BacktestResults()
