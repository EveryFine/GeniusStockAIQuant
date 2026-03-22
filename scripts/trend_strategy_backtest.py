"""
Example script demonstrating trend strategy backtest on A-stock data.

This example shows how to:
1. Load stock data using DataAdapter
2. Create and configure TrendStrategy
3. Run backtest with BacktestEngine
4. Analyze results
"""

from __future__ import annotations

import pandas as pd

from genius_stock_aiquant.backtest.backtest_engine import BacktestEngine
from genius_stock_aiquant.strategy.data_adapter import DataAdapter
from genius_stock_aiquant.strategy.trend_strategy import TrendStrategy


def run_backtest_example():
    """Run a complete backtest example."""

    # ============ 1. Configuration ============
    print("=" * 60)
    print("TREND STRATEGY BACKTEST EXAMPLE")
    print("=" * 60)

    symbols = [
        "000001.SZ",  # Example: Ping An Bank
        "000858.SZ",  # Example: Wuliangye
        "601888.SH",  # Example: China State Construction
    ]
    start_date = "2024-01-01"
    end_date = "2024-12-31"
    initial_capital = 1_000_000  # 1M CNY

    print(f"\nConfiguration:")
    print(f"  Symbols: {symbols}")
    print(f"  Period: {start_date} to {end_date}")
    print(f"  Initial Capital: ¥{initial_capital:,.0f}")

    # ============ 2. Load Data ============
    print(f"\nLoading data...")
    adapter = DataAdapter()

    try:
        data = adapter.prepare_backtest_data(
            symbols=symbols,
            start_date=start_date,
            end_date=end_date,
            ma_periods=(5, 20, 60),
        )
        print(f"  Loaded {len(data)} bars for {len(data['symbol'].unique())} symbols")
    except Exception as e:
        print(f"\n  Error loading data: {e}")
        print(f"  Make sure PostgreSQL is configured and tables exist.")
        print(f"  See .env.example for DATABASE_URL setup.")
        return

    # ============ 3. Initialize Strategy ============
    print(f"\nStrategy Configuration:")
    strategy = TrendStrategy(
        ma_short=5,
        ma_mid=20,
        ma_long=60,
        vol_multiplier=1.2,
        stop_loss_pct=0.08,
        take_profit_pct=0.15,
    )
    print(f"  Name: {strategy.name()}")
    print(f"  MAs: {strategy.ma_short}/{strategy.ma_mid}/{strategy.ma_long}-day")
    print(f"  Stop Loss: -{strategy.stop_loss_pct*100:.0f}%")
    print(f"  Take Profit: +{strategy.take_profit_pct*100:.0f}%")

    # ============ 4. Run Backtest ============
    print(f"\nRunning backtest...")
    engine = BacktestEngine(
        initial_capital=initial_capital,
        max_positions=6,
        commission=0.0001,
    )

    results = engine.backtest(data, strategy)
    print("  Backtest completed!")

    # ============ 5. Print Results ============
    print(results.summary())

    # ============ 6. Trade History ============
    if not results.trade_history.empty:
        print("\nTrade History (first 10):")
        print(results.trade_history.head(10).to_string(index=False))

        if len(results.trade_history) > 10:
            print(f"\n... and {len(results.trade_history) - 10} more trades")

    # ============ 7. Open Positions (if any) ============
    if results.portfolio.positions:
        print("\nOpen Positions:")
        print(results.portfolio.get_position_summary({}).to_string(index=False))

    # ============ 8. Equity Curve ============
    print("\nEquity Curve Statistics:")
    equity = pd.Series(results.equity_curve)
    print(f"  Starting Equity: ¥{equity.iloc[0]:,.0f}")
    print(f"  Ending Equity: ¥{equity.iloc[-1]:,.0f}")
    print(f"  Max Equity: ¥{equity.max():,.0f}")
    print(f"  Min Equity: ¥{equity.min():,.0f}")
    print(f"  Peak Return: {(equity.max() / equity.iloc[0] - 1) * 100:.2f}%")

    return results


def analyze_results(results):
    """Perform additional analysis on backtest results."""
    print("\n" + "=" * 60)
    print("DETAILED ANALYSIS")
    print("=" * 60)

    # Monthly returns
    trade_history = results.trade_history
    if not trade_history.empty:
        trade_history["month"] = pd.to_datetime(trade_history["date"]).dt.to_period("M")

        print("\nMonthly Trade Activity:")
        monthly = trade_history.groupby("month").size()
        print(monthly)

        print("\nSymbol Trade Count:")
        by_symbol = trade_history.groupby("symbol").size()
        print(by_symbol)


if __name__ == "__main__":
    results = run_backtest_example()

    if results:
        analyze_results(results)

        # Export to HTML (optional)
        # with open("backtest_report.html", "w") as f:
        #     f.write(results.to_html())
        # print("\nReport exported to backtest_report.html")
