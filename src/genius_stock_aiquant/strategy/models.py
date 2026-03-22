"""Data models for trading signals and orders."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional

import pandas as pd


@dataclass
class SignalIndicators:
    """Technical indicators used for trading signals."""

    ma5: float
    ma20: float
    ma60: float
    vol20_avg: float
    volume: float
    close: float
    date: pd.Timestamp

    def ma_trend_bullish(self) -> bool:
        """Check if moving averages show bullish trend."""
        return self.ma5 > self.ma20 > self.ma60

    def ma_crossover_bullish(self) -> bool:
        """Check if short MA crossed above long MA."""
        return self.ma5 > self.ma20

    def volume_above_avg(self, multiplier: float = 1.2) -> bool:
        """Check if volume exceeds average."""
        return self.volume > self.vol20_avg * multiplier


@dataclass
class TradeSignal:
    """Trading signal for entry or exit."""

    symbol: str
    date: pd.Timestamp
    signal_type: str  # "buy", "sell"
    price: float
    confidence: float = 1.0  # 0-1
    reason: str = ""
    indicators: Optional[SignalIndicators] = None


@dataclass
class Position:
    """Open trading position."""

    symbol: str
    entry_date: pd.Timestamp
    entry_price: float
    shares: int
    exit_date: Optional[pd.Timestamp] = None
    exit_price: Optional[float] = None
    pnl: Optional[float] = None  # Realized P&L
    pnl_pct: Optional[float] = None

    def is_open(self) -> bool:
        """Check if position is still open."""
        return self.exit_date is None

    def realize_pnl(self, exit_price: float, exit_date: pd.Timestamp) -> None:
        """Close position and realize P&L."""
        self.exit_price = exit_price
        self.exit_date = exit_date
        self.pnl = (exit_price - self.entry_price) * self.shares
        self.pnl_pct = (exit_price - self.entry_price) / self.entry_price

    def unrealized_pnl(self, current_price: float) -> float:
        """Calculate unrealized P&L."""
        if not self.is_open():
            return self.pnl or 0.0
        return (current_price - self.entry_price) * self.shares

    def unrealized_pnl_pct(self, current_price: float) -> float:
        """Calculate unrealized P&L percentage."""
        if not self.is_open():
            return self.pnl_pct or 0.0
        return (current_price - self.entry_price) / self.entry_price


@dataclass
class TradeRecord:
    """Historical trade record."""

    symbol: str
    trade_date: pd.Timestamp
    trade_type: str  # "buy", "sell"
    price: float
    shares: int
    amount: float = field(init=False)
    reason: str = ""
    position: Optional[Position] = None

    def __post_init__(self):
        self.amount = self.price * self.shares


@dataclass
class BacktestMetrics:
    """Aggregated backtest performance metrics."""

    total_return: float  # Percentage
    annual_return: float  # Percentage
    sharpe_ratio: float
    max_drawdown: float  # Percentage
    win_rate: float  # Percentage
    total_trades: int
    winning_trades: int
    losing_trades: int
    avg_win: float
    avg_loss: float
    profit_factor: float
    max_holding_days: int
    min_holding_days: int
