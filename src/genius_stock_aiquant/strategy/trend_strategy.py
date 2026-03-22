"""Trend-following strategy (moving averages, trend filters)."""

from __future__ import annotations

from .base import BaseStrategy


class TrendStrategy(BaseStrategy):
    def name(self) -> str:
        return "trend"
