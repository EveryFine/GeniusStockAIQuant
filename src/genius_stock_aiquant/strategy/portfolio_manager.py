"""Portfolio management for backtest execution."""

from __future__ import annotations

from typing import Dict, List, Optional

import pandas as pd

from .models import Position, TradeRecord, TradeSignal


class PortfolioManager:
    """Manages positions, cash, and trades during backtest."""

    def __init__(
        self,
        initial_capital: float,
        max_positions: int = 6,
        position_size_pct: float = 0.05,
    ):
        """
        Initialize portfolio manager.

        Args:
            initial_capital: Starting capital in CNY
            max_positions: Maximum concurrent positions
            position_size_pct: Fraction of capital per position (5%)
        """
        self.initial_capital = initial_capital
        self.current_cash = initial_capital
        self.max_positions = max_positions
        self.position_size_pct = position_size_pct

        self.positions: Dict[str, Position] = {}  # symbol -> Position
        self.trade_history: List[TradeRecord] = []
        self.equity_curve: List[float] = [initial_capital]

    def calculate_position_shares(self, price: float) -> int:
        """Calculate shares to buy based on position size."""
        buy_amount = self.initial_capital * self.position_size_pct
        shares = int(buy_amount / price)
        return shares

    def can_open_position(self) -> bool:
        """Check if can open new position."""
        return len(self.positions) < self.max_positions

    def open_position(
        self, signal: TradeSignal, quantity: Optional[int] = None
    ) -> bool:
        """
        Open a new position.

        Returns:
            True if successful, False if insufficient capital or max positions reached
        """
        if not self.can_open_position():
            return False

        if signal.symbol in self.positions:
            return False

        shares = quantity or self.calculate_position_shares(signal.price)
        cost = shares * signal.price

        if cost > self.current_cash:
            return False

        # Create position
        pos = Position(
            symbol=signal.symbol,
            entry_date=signal.date,
            entry_price=signal.price,
            shares=shares,
        )
        self.positions[signal.symbol] = pos

        # Record trade
        trade = TradeRecord(
            symbol=signal.symbol,
            trade_date=signal.date,
            trade_type="buy",
            price=signal.price,
            shares=shares,
            reason=signal.reason,
            position=pos,
        )
        self.trade_history.append(trade)

        # Update cash
        self.current_cash -= cost

        return True

    def close_position(self, symbol: str, exit_signal: TradeSignal) -> bool:
        """
        Close position.

        Returns:
            True if closed successfully
        """
        if symbol not in self.positions:
            return False

        pos = self.positions[symbol]
        if not pos.is_open():
            return False

        proceeds = pos.shares * exit_signal.price
        pos.realize_pnl(exit_signal.price, exit_signal.date)

        # Record trade
        trade = TradeRecord(
            symbol=symbol,
            trade_date=exit_signal.date,
            trade_type="sell",
            price=exit_signal.price,
            shares=pos.shares,
            reason=exit_signal.reason,
            position=pos,
        )
        self.trade_history.append(trade)

        # Update cash
        self.current_cash += proceeds

        # Remove from open positions
        del self.positions[symbol]

        return True

    def get_current_equity(self, prices: Dict[str, float]) -> float:
        """
        Calculate current portfolio equity.

        Args:
            prices: Symbol -> current price mapping
        """
        equity = self.current_cash
        for symbol, pos in self.positions.items():
            if pos.is_open() and symbol in prices:
                equity += pos.shares * prices[symbol]
        return equity

    def record_equity_snapshot(self, prices: Dict[str, float]) -> None:
        """Record equity snapshot for equity curve."""
        equity = self.get_current_equity(prices)
        self.equity_curve.append(equity)

    def get_position_summary(self, prices: Dict[str, float]) -> pd.DataFrame:
        """Get summary of all open positions."""
        data = []
        for symbol, pos in self.positions.items():
            if pos.is_open() and symbol in prices:
                current_price = prices[symbol]
                unrealized_pnl = pos.unrealized_pnl(current_price)
                unrealized_pnl_pct = pos.unrealized_pnl_pct(current_price)
                data.append({
                    "symbol": symbol,
                    "entry_price": pos.entry_price,
                    "current_price": current_price,
                    "shares": pos.shares,
                    "unrealized_pnl": unrealized_pnl,
                    "unrealized_pnl_pct": unrealized_pnl_pct * 100,
                })
        return pd.DataFrame(data)

    def get_trade_history_df(self) -> pd.DataFrame:
        """Convert trade history to DataFrame."""
        data = []
        for trade in self.trade_history:
            data.append({
                "date": trade.trade_date,
                "symbol": trade.symbol,
                "type": trade.trade_type,
                "price": trade.price,
                "shares": trade.shares,
                "amount": trade.amount,
                "reason": trade.reason,
            })
        return pd.DataFrame(data)

    def get_closed_trades(self) -> List[Position]:
        """Get all closed positions."""
        return [
            pos
            for pos in self.positions.values()
            if not pos.is_open()
        ] + [
            trade.position
            for trade in self.trade_history
            if trade.position and not trade.position.is_open()
        ]
