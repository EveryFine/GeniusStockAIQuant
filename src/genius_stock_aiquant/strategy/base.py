"""Shared strategy interface."""

from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any, Dict, Optional

import pandas as pd


class BaseStrategy(ABC):
    """Contract for strategies consumed by the backtest engine."""

    @abstractmethod
    def name(self) -> str:
        """Human-readable strategy label."""

    def on_bar(self, bar: pd.Series, context: Optional[Dict[str, Any]] = None) -> None:
        """Optional hook per bar; override in concrete strategies."""
        del bar, context
