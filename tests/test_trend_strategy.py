"""Unit tests for trend strategy components."""

import unittest
from datetime import datetime

import pandas as pd

from genius_stock_aiquant.strategy.models import (
    Position,
    SignalIndicators,
    TradeSignal,
)
from genius_stock_aiquant.strategy.portfolio_manager import PortfolioManager
from genius_stock_aiquant.strategy.trend_strategy import TrendStrategy


class TestSignalIndicators(unittest.TestCase):
    """Test signal indicator logic."""

    def test_ma_trend_bullish(self):
        """Test bullish MA trend detection."""
        indicators = SignalIndicators(
            ma5=100, ma20=95, ma60=90, vol20_avg=1000000,
            volume=1200000, close=100, date=pd.Timestamp.now(),
        )
        self.assertTrue(indicators.ma_trend_bullish())
        self.assertTrue(indicators.ma_crossover_bullish())

    def test_ma_trend_bearish(self):
        """Test bearish MA trend."""
        indicators = SignalIndicators(
            ma5=90, ma20=95, ma60=100, vol20_avg=1000000,
            volume=1200000, close=90, date=pd.Timestamp.now(),
        )
        self.assertFalse(indicators.ma_trend_bullish())
        self.assertFalse(indicators.ma_crossover_bullish())

    def test_volume_above_avg(self):
        """Test volume condition."""
        indicators = SignalIndicators(
            ma5=100, ma20=99, ma60=98, vol20_avg=1000000,
            volume=1200000, close=100, date=pd.Timestamp.now(),
        )
        self.assertTrue(indicators.volume_above_avg(1.2))
        self.assertFalse(indicators.volume_above_avg(1.5))


class TestPosition(unittest.TestCase):
    """Test position tracking."""

    def test_position_open(self):
        """Test open position."""
        pos = Position(
            symbol="000001.SZ",
            entry_date=pd.Timestamp("2024-01-01"),
            entry_price=10.0,
            shares=100,
        )
        self.assertTrue(pos.is_open())
        self.assertIsNone(pos.exit_price)

    def test_position_close(self):
        """Test position closing."""
        pos = Position(
            symbol="000001.SZ",
            entry_date=pd.Timestamp("2024-01-01"),
            entry_price=10.0,
            shares=100,
        )
        pos.realize_pnl(11.0, pd.Timestamp("2024-01-02"))

        self.assertFalse(pos.is_open())
        self.assertEqual(pos.pnl, 100)  # (11-10)*100
        self.assertAlmostEqual(pos.pnl_pct, 0.1, places=2)

    def test_unrealized_pnl(self):
        """Test unrealized P&L calculation."""
        pos = Position(
            symbol="000001.SZ",
            entry_date=pd.Timestamp("2024-01-01"),
            entry_price=10.0,
            shares=100,
        )
        unrealized = pos.unrealized_pnl(11.0)
        self.assertEqual(unrealized, 100)

        unrealized_pct = pos.unrealized_pnl_pct(11.0)
        self.assertAlmostEqual(unrealized_pct, 0.1, places=2)


class TestTrendStrategy(unittest.TestCase):
    """Test trend strategy signal generation."""

    def setUp(self):
        """Set up strategy instance."""
        self.strategy = TrendStrategy(
            ma_short=5, ma_mid=20, ma_long=60,
            vol_multiplier=1.2,
            stop_loss_pct=0.08,
            take_profit_pct=0.15,
        )

    def test_buy_signal_bullish_trend(self):
        """Test buy signal generation on bullish trend."""
        bar = pd.Series({
            "symbol": "000001.SZ",
            "date": pd.Timestamp("2024-01-01"),
            "close": 10.0,
            "ma5": 10.1,
            "ma20": 9.9,
            "ma60": 9.5,
            "volume": 1200000,
            "vol_avg": 1000000,
        })

        signal = self.strategy.generate_buy_signal(bar)
        self.assertIsNotNone(signal)
        self.assertEqual(signal.signal_type, "buy")
        self.assertEqual(signal.price, 10.0)

    def test_no_buy_signal_bearish_trend(self):
        """Test no buy signal on bearish trend."""
        bar = pd.Series({
            "symbol": "000001.SZ",
            "date": pd.Timestamp("2024-01-01"),
            "close": 10.0,
            "ma5": 9.5,
            "ma20": 10.0,
            "ma60": 10.2,
            "volume": 1200000,
            "vol_avg": 1000000,
        })

        signal = self.strategy.generate_buy_signal(bar)
        self.assertIsNone(signal)

    def test_sell_signal_stop_loss(self):
        """Test stop loss signal."""
        bar = pd.Series({
            "symbol": "000001.SZ",
            "date": pd.Timestamp("2024-01-02"),
            "close": 9.0,  # 10% loss
            "ma5": 9.0,
            "ma20": 9.0,
        })

        signal = self.strategy.generate_sell_signal(bar, entry_price=10.0)
        self.assertIsNotNone(signal)
        self.assertEqual(signal.reason, "stop_loss")

    def test_sell_signal_take_profit(self):
        """Test take profit signal."""
        bar = pd.Series({
            "symbol": "000001.SZ",
            "date": pd.Timestamp("2024-01-02"),
            "close": 11.6,  # 16% profit
            "ma5": 11.5,
            "ma20": 11.5,
        })

        signal = self.strategy.generate_sell_signal(bar, entry_price=10.0)
        self.assertIsNotNone(signal)
        self.assertEqual(signal.reason, "take_profit")

    def test_sell_signal_trend_break(self):
        """Test trend break signal."""
        bar = pd.Series({
            "symbol": "000001.SZ",
            "date": pd.Timestamp("2024-01-02"),
            "close": 10.5,
            "ma5": 9.8,  # Below MA20
            "ma20": 10.0,
        })

        signal = self.strategy.generate_sell_signal(bar, entry_price=10.0)
        self.assertIsNotNone(signal)
        self.assertEqual(signal.reason, "trend_break")


class TestPortfolioManager(unittest.TestCase):
    """Test portfolio management."""

    def setUp(self):
        """Set up portfolio manager."""
        self.pm = PortfolioManager(
            initial_capital=100000,
            max_positions=3,
            position_size_pct=0.1,
        )

    def test_initial_state(self):
        """Test initial portfolio state."""
        self.assertEqual(self.pm.current_cash, 100000)
        self.assertEqual(len(self.pm.positions), 0)

    def test_open_position(self):
        """Test opening a position."""
        signal = TradeSignal(
            symbol="000001.SZ",
            date=pd.Timestamp("2024-01-01"),
            signal_type="buy",
            price=10.0,
            reason="test",
        )

        success = self.pm.open_position(signal)
        self.assertTrue(success)
        self.assertIn("000001.SZ", self.pm.positions)
        self.assertLess(self.pm.current_cash, 100000)

    def test_max_positions_limit(self):
        """Test max positions enforcement."""
        for i in range(3):
            signal = TradeSignal(
                symbol=f"00000{i}.SZ",
                date=pd.Timestamp("2024-01-01"),
                signal_type="buy",
                price=10.0,
            )
            self.assertTrue(self.pm.open_position(signal))

        # Fourth position should fail
        signal = TradeSignal(
            symbol="000099.SZ",
            date=pd.Timestamp("2024-01-01"),
            signal_type="buy",
            price=10.0,
        )
        self.assertFalse(self.pm.open_position(signal))

    def test_close_position(self):
        """Test closing a position."""
        # Open position
        open_signal = TradeSignal(
            symbol="000001.SZ",
            date=pd.Timestamp("2024-01-01"),
            signal_type="buy",
            price=10.0,
        )
        self.pm.open_position(open_signal)
        initial_cash = self.pm.current_cash

        # Close position
        close_signal = TradeSignal(
            symbol="000001.SZ",
            date=pd.Timestamp("2024-01-02"),
            signal_type="sell",
            price=11.0,  # 10% profit
        )
        success = self.pm.close_position("000001.SZ", close_signal)
        self.assertTrue(success)
        self.assertNotIn("000001.SZ", self.pm.positions)
        # Cash increased due to profit
        self.assertGreater(self.pm.current_cash, initial_cash)


class TestTradingDataFrameExport(unittest.TestCase):
    """Test data export functionality."""

    def test_trade_history_export(self):
        """Test exporting trade history to DataFrame."""
        pm = PortfolioManager(100000)

        # Make some trades
        buy_signal = TradeSignal(
            symbol="000001.SZ",
            date=pd.Timestamp("2024-01-01"),
            signal_type="buy",
            price=10.0,
        )
        pm.open_position(buy_signal)

        sell_signal = TradeSignal(
            symbol="000001.SZ",
            date=pd.Timestamp("2024-01-02"),
            signal_type="sell",
            price=11.0,
        )
        pm.close_position("000001.SZ", sell_signal)

        # Export to DataFrame
        df = pm.get_trade_history_df()
        self.assertEqual(len(df), 2)  # buy + sell
        self.assertEqual(df.iloc[0]["type"], "buy")
        self.assertEqual(df.iloc[1]["type"], "sell")


if __name__ == "__main__":
    unittest.main()
