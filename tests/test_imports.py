"""Smoke tests: package imports and minimal API surface."""


def test_import_package() -> None:
    import genius_stock_aiquant as gsaq

    assert hasattr(gsaq, "__version__")


def test_import_public_modules() -> None:
    from genius_stock_aiquant.backtest.backtest_engine import BacktestEngine, BacktestResults
    from genius_stock_aiquant.data_loader import DataLoader
    from genius_stock_aiquant.stock_selector import StockSelector
    from genius_stock_aiquant.strategy.trend_strategy import TrendStrategy

    assert BacktestEngine(100_000) is not None
    assert BacktestResults().summary()
    assert DataLoader() is not None
    assert StockSelector().select_stocks("technical", "2024-12-31") == []
    assert TrendStrategy().name() == "trend"
