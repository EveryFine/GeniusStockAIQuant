"""Trend-following strategy (moving averages, trend filters)."""

from __future__ import annotations

from typing import Any, Dict, Optional

import pandas as pd

from .base import BaseStrategy
from .models import SignalIndicators, TradeSignal


class TrendStrategy(BaseStrategy):
    """
    Trend-following strategy using moving average crossovers.

    Rules:
    - BUY: ma5 > ma20 > ma60 (bullish trend) + volume > avg * 1.2
    - SELL: ma5 < ma20 (trend break) OR price < ma20 (support break)
    - Stop Loss: -8% from entry
    - Take Profit: +15% from entry
    """

    def __init__(
        self,
        ma_short: int = 5,
        ma_mid: int = 20,
        ma_long: int = 60,
        vol_multiplier: float = 1.2,
        stop_loss_pct: float = 0.08,
        take_profit_pct: float = 0.15,
    ):
        """
        Initialize trend strategy.

        Args:
            ma_short: Short-term MA period
            ma_mid: Mid-term MA period
            ma_long: Long-term MA period
            vol_multiplier: Volume threshold multiplier
            stop_loss_pct: Stop loss percentage
            take_profit_pct: Take profit percentage
        """
        self.ma_short = ma_short
        self.ma_mid = ma_mid
        self.ma_long = ma_long
        self.vol_multiplier = vol_multiplier
        self.stop_loss_pct = stop_loss_pct
        self.take_profit_pct = take_profit_pct

    def name(self) -> str:
        return "trend_ma_cross"

    def on_bar(self, bar: pd.Series, context: Optional[Dict[str, Any]] = None) -> None:
        """
        Called for each bar to generate signals.

        Expected bar Series columns:
        - close, high, low, open, volume
        - ma5, ma20, ma60, vol_avg
        """
        del context  # unused

    def generate_buy_signal(self, bar: pd.Series) -> Optional[TradeSignal]:
        """Generate buy signal from bar indicators."""
        # Validate required columns
        required = ["close", "volume", f"ma{self.ma_short}",
                   f"ma{self.ma_mid}", f"ma{self.ma_long}", "vol_avg"]
        if not all(col in bar.index for col in required):
            return None

        ma_short_val = bar[f"ma{self.ma_short}"]
        ma_mid_val = bar[f"ma{self.ma_mid}"]
        ma_long_val = bar[f"ma{self.ma_long}"]
        vol_avg = bar["vol_avg"]
        volume = bar["volume"]
        close = bar["close"]

        # Check for NaN
        if pd.isna(ma_short_val) or pd.isna(ma_mid_val) or pd.isna(ma_long_val):
            return None

        # Trend condition: ma5 > ma20 > ma60
        trend_bullish = (ma_short_val > ma_mid_val) and (ma_mid_val > ma_long_val)

        # Volume condition
        vol_surge = volume > vol_avg * self.vol_multiplier

        if trend_bullish and vol_surge:
            indicators = SignalIndicators(
                ma5=float(ma_short_val),
                ma20=float(ma_mid_val),
                ma60=float(ma_long_val),
                vol20_avg=float(vol_avg),
                volume=float(volume),
                close=float(close),
                date=bar.get("date", pd.Timestamp.now()),
            )

            return TradeSignal(
                symbol=bar.get("symbol", "UNKNOWN"),
                date=bar.get("date", pd.Timestamp.now()),
                signal_type="buy",
                price=float(close),
                confidence=0.8,
                reason="ma_trend_bullish + volume_surge",
                indicators=indicators,
            )

        return None

    def generate_sell_signal(
        self, bar: pd.Series, entry_price: float
    ) -> Optional[TradeSignal]:
        """Generate sell signal from bar indicators."""
        required = ["close", f"ma{self.ma_short}", f"ma{self.ma_mid}"]
        if not all(col in bar.index for col in required):
            return None

        close = bar["close"]
        ma_short_val = bar[f"ma{self.ma_short}"]
        ma_mid_val = bar[f"ma{self.ma_mid}"]

        # Stop loss
        if close < entry_price * (1 - self.stop_loss_pct):
            return TradeSignal(
                symbol=bar.get("symbol", "UNKNOWN"),
                date=bar.get("date", pd.Timestamp.now()),
                signal_type="sell",
                price=float(close),
                reason="stop_loss",
            )

        # Take profit
        if close > entry_price * (1 + self.take_profit_pct):
            return TradeSignal(
                symbol=bar.get("symbol", "UNKNOWN"),
                date=bar.get("date", pd.Timestamp.now()),
                signal_type="sell",
                price=float(close),
                reason="take_profit",
            )

        # Trend break: ma5 < ma20
        if pd.notna(ma_short_val) and pd.notna(ma_mid_val):
            if ma_short_val < ma_mid_val:
                return TradeSignal(
                    symbol=bar.get("symbol", "UNKNOWN"),
                    date=bar.get("date", pd.Timestamp.now()),
                    signal_type="sell",
                    price=float(close),
                    reason="trend_break",
                )

        return None
