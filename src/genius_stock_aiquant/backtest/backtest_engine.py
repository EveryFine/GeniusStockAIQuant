"""Core backtest engine with portfolio and risk management."""

from __future__ import annotations

from typing import TYPE_CHECKING, Dict, List, Optional

import numpy as np
import pandas as pd

from genius_stock_aiquant.strategy.models import BacktestMetrics, TradeSignal
from genius_stock_aiquant.strategy.portfolio_manager import PortfolioManager

if TYPE_CHECKING:
    from genius_stock_aiquant.strategy.base import BaseStrategy
    from genius_stock_aiquant.strategy.trend_strategy import TrendStrategy


class BacktestResults:
    """Container for backtest output."""

    def __init__(
        self,
        portfolio: PortfolioManager,
        metrics: BacktestMetrics,
        equity_curve: List[float],
        trade_history: pd.DataFrame,
    ):
        self.portfolio = portfolio
        self.metrics = metrics
        self.equity_curve = equity_curve
        self.trade_history = trade_history

    def summary(self) -> str:
        """Return formatted summary of backtest results."""
        m = self.metrics
        summary = f"""
===== BACKTEST RESULTS =====
Total Return:        {m.total_return:>10.2f}%
Annual Return:       {m.annual_return:>10.2f}%
Sharpe Ratio:        {m.sharpe_ratio:>10.2f}
Max Drawdown:        {m.max_drawdown:>10.2f}%
Win Rate:            {m.win_rate:>10.2f}%

Trade Statistics:
  Total Trades:      {m.total_trades:>10}
  Winning Trades:    {m.winning_trades:>10}
  Losing Trades:     {m.losing_trades:>10}
  Avg Win:           {m.avg_win:>10.2f}%
  Avg Loss:          {m.avg_loss:>10.2f}%
  Profit Factor:     {m.profit_factor:>10.2f}

Holding Period:
  Max:               {m.max_holding_days:>10} days
  Min:               {m.min_holding_days:>10} days
=============================
        """
        return summary

    def to_html(self) -> str:
        """Export results as HTML report."""
        html = f"""
        <html>
        <head><title>Backtest Report</title></head>
        <body>
        <h1>Backtest Results</h1>
        <pre>{self.summary()}</pre>
        <h2>Trade History</h2>
        {self.trade_history.to_html()}
        </body>
        </html>
        """
        return html


class BacktestEngine:
    """Backtest engine for running strategies on historical data."""

    def __init__(
        self, initial_capital: float, max_positions: int = 6, commission: float = 0.0001
    ):
        """
        Initialize backtest engine.

        Args:
            initial_capital: Starting capital in CNY
            max_positions: Maximum concurrent positions
            commission: Commission rate (0.01% default)
        """
        self.initial_capital = initial_capital
        self.max_positions = max_positions
        self.commission = commission
        self._strategies: List[BaseStrategy] = []

    def add_strategy(self, strategy: BaseStrategy) -> None:
        """Add strategy to backtest."""
        self._strategies.append(strategy)

    def backtest(
        self, stock_data: pd.DataFrame, strategy: Optional[TrendStrategy] = None
    ) -> BacktestResults:
        """
        Run backtest on stock data.

        Args:
            stock_data: DataFrame with columns [symbol, date, open, high, low, close, volume, ma5, ma20, ma60, vol_avg]
            strategy: TrendStrategy instance (or use first added strategy)

        Returns:
            BacktestResults with performance metrics and trade log
        """
        if strategy is None:
            if not self._strategies:
                raise ValueError("No strategy provided and none added")
            strategy = self._strategies[0]  # type: ignore

        # Validate data
        required_cols = ["symbol", "date", "close", "volume", "ma5", "ma20", "ma60", "vol_avg"]
        if not all(col in stock_data.columns for col in required_cols):
            raise ValueError(f"Missing required columns. Need: {required_cols}")

        # Initialize portfolio
        portfolio = PortfolioManager(
            initial_capital=self.initial_capital,
            max_positions=self.max_positions,
        )

        # Sort data by date and symbol
        stock_data = stock_data.sort_values(["date", "symbol"]).reset_index(drop=True)
        dates = sorted(stock_data["date"].unique())

        # Backtest loop
        for current_date in dates:
            day_data = stock_data[stock_data["date"] == current_date]

            # Close positions check
            for symbol in list(portfolio.positions.keys()):
                sym_data = day_data[day_data["symbol"] == symbol]
                if sym_data.empty:
                    continue

                bar = sym_data.iloc[0]
                pos = portfolio.positions[symbol]
                exit_signal = strategy.generate_sell_signal(bar, pos.entry_price)

                if exit_signal is not None:
                    portfolio.close_position(symbol, exit_signal)

            # Open new positions
            if portfolio.can_open_position():
                # Sort by volume for liquidity preference
                day_data_sorted = day_data.sort_values("volume", ascending=False)

                for _, bar in day_data_sorted.iterrows():
                    if not portfolio.can_open_position():
                        break

                    if bar["symbol"] in portfolio.positions:
                        continue

                    buy_signal = strategy.generate_buy_signal(bar)
                    if buy_signal is not None:
                        portfolio.open_position(buy_signal)

            # Record equity snapshot
            prices = {
                row["symbol"]: row["close"]
                for _, row in day_data.iterrows()
            }
            portfolio.record_equity_snapshot(prices)

        # Calculate metrics
        metrics = self._calculate_metrics(portfolio)

        # Create trade history
        trade_history = portfolio.get_trade_history_df()

        return BacktestResults(portfolio, metrics, portfolio.equity_curve, trade_history)

    def _calculate_metrics(self, portfolio: PortfolioManager) -> BacktestMetrics:
        """Calculate performance metrics."""
        equity_curve = np.array(portfolio.equity_curve)
        returns = np.diff(equity_curve) / equity_curve[:-1]

        # Return metrics
        total_return = (equity_curve[-1] - equity_curve[0]) / equity_curve[0]
        annual_return = total_return  # Simplified; adjust for actual trading days

        # Sharpe ratio
        sharpe_ratio = (
            np.mean(returns) / np.std(returns) * np.sqrt(252)
            if np.std(returns) > 0
            else 0
        )

        # Max drawdown
        cumsum = np.cumprod(1 + returns)
        running_max = np.maximum.accumulate(cumsum)
        drawdown = (cumsum - running_max) / running_max
        max_drawdown = np.min(drawdown) if len(drawdown) > 0 else 0

        # Trade metrics
        closed_trades = [
            pos
            for pos in portfolio.positions.values()
            if not pos.is_open()
        ]
        if not closed_trades:
            # Extract from trade history
            closed_trades = []
            for trade in portfolio.trade_history:
                if trade.position and not trade.position.is_open():
                    closed_trades.append(trade.position)

        winning = [p for p in closed_trades if p.pnl_pct is not None and p.pnl_pct > 0]
        losing = [p for p in closed_trades if p.pnl_pct is not None and p.pnl_pct <= 0]

        avg_win = np.mean([p.pnl_pct for p in winning]) * 100 if winning else 0
        avg_loss = np.mean([p.pnl_pct for p in losing]) * 100 if losing else 0

        profit_factor = (
            abs(sum(p.pnl or 0 for p in winning) / sum(p.pnl or 0 for p in losing))
            if losing
            else 0
        )

        holding_days = []
        for pos in closed_trades:
            if pos.exit_date is not None and pos.entry_date is not None:
                holding_days.append((pos.exit_date - pos.entry_date).days)

        return BacktestMetrics(
            total_return=total_return * 100,
            annual_return=annual_return * 100,
            sharpe_ratio=sharpe_ratio,
            max_drawdown=max_drawdown * 100,
            win_rate=(len(winning) / len(closed_trades) * 100) if closed_trades else 0,
            total_trades=len(portfolio.trade_history) // 2,  # Buy + sell pairs
            winning_trades=len(winning),
            losing_trades=len(losing),
            avg_win=avg_win,
            avg_loss=avg_loss,
            profit_factor=profit_factor,
            max_holding_days=max(holding_days) if holding_days else 0,
            min_holding_days=min(holding_days) if holding_days else 0,
        )
