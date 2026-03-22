# GeniusStockAIQuant - A-Share Quantitative Trading System

## 📊 Project Overview

**GeniusStockAIQuant** is an intelligent quantitative trading system based on the Chinese A-Share market. The project leverages existing A-Share stock market data and combines AI programming tools (such as Cursor) to build a multi-strategy stock screening, backtesting, and trading system.

## 🎯 Core Features

### 1. **Intelligent Stock Selection Module**
- Quantitative indicator-based stock screening framework
- Support for multiple technical analysis indicator combinations
- Leading stock identification algorithm
- Limit-up stock prediction and filtering

### 2. **Backtesting System**
- Complete historical data backtesting engine
- Support for multi-strategy parallel backtesting
- Detailed performance evaluation metrics
  - Annualized Return
  - Maximum Drawdown
  - Sharpe Ratio
  - Win Rate and Profit/Loss Ratio
- Real-time trading process visualization

### 3. **Entry/Exit Management**
- Flexible entry condition settings
- Dynamic take-profit and stop-loss strategies
- Risk control and position management
- Equity curve tracking

### 4. **Multi-Strategy Support**

#### Trend Strategy
- Mainstream trend identification based on moving averages
- Support for long-term and mid-term trend analysis
- Trend reversal signal detection

#### Limit-Up Strategy
- Limit-up stock prediction
- Short-term trading opportunities following limit-ups
- Limit-up probability calculation

#### Leading Stock Strategy
- Industry leading stock identification
- Leading stock breakout signals
- Leading stock premium analysis

## 💻 Technical Architecture

### Technology Stack
- **Programming Language**: Python 3.8+
- **Data Processing**: pandas, numpy
- **Data Source**: Chinese A-Share historical market data; **PostgreSQL** (`psycopg2-binary`; see `.env.example` for connection and table mapping)
- **Backtesting Framework**: Custom quantitative engine
- **Visualization**: matplotlib, plotly
- **AI Programming Assistant**: Cursor IDE

### Project Structure

The repo uses the **`src` layout** with installable package **`genius_stock_aiquant`** (after `pip install -e .`, import from any working directory). Large files such as raw quotes live under `data/raw` and are ignored by `.gitignore` by default; backtest reports and charts should go under `outputs/`. Keep secrets (API tokens) in environment variables or `.env` (never commit them).

```
GeniusStockAIQuant/
├── README.md
├── README_CN.md
├── README_EN.md
├── pyproject.toml           # Metadata and dependencies (editable install)
├── requirements.txt         # Runtime deps (aligned with pyproject)
├── .gitignore
├── docs/                    # Extra docs (e.g. PostgreSQL read-only user)
├── config/                  # Strategy and system parameters (see strategy_config.json)
├── data/
│   ├── raw/                 # Raw data (directory tracked; contents ignored)
│   └── processed/           # Cleaned / feature data
├── outputs/                 # Backtest exports, plots (contents ignored by default)
├── notebooks/               # Jupyter exploration
├── scripts/                 # CLI entrypoints and batch jobs
├── src/
│   └── genius_stock_aiquant/
│       ├── __init__.py
│       ├── data_loader.py           # Data loading (PostgreSQL by default)
│       ├── data_sources/            # Data sources (PostgreSQL, etc.)
│       ├── stock_selector.py        # Stock screening
│       ├── strategy/
│       │   ├── base.py              # Strategy base / shared interface
│       │   ├── trend_strategy.py    # Trend strategy
│       │   ├── limit_strategy.py    # Limit-up strategy
│       │   └── leader_strategy.py   # Leading stock strategy
│       ├── backtest/
│       │   ├── backtest_engine.py   # Backtesting engine
│       │   └── metrics.py           # Performance metrics
│       └── utils/                   # Shared helpers
└── tests/                   # Unit and smoke tests
```

## 🚀 Quick Start

### Environment Installation
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate     # Windows

# Install dependencies and this package in editable mode (recommended)
pip install -r requirements.txt
pip install -e .

# Optional dev dependencies (e.g. pytest)
pip install -e ".[dev]"
```

### Basic Usage

#### 1. Load Data
```python
from genius_stock_aiquant.data_loader import DataLoader

loader = DataLoader()
# Historical bars for one symbol (use the same code format as in your DB, e.g. Tushare-style 000001.SZ)
stock_data = loader.load_stock_data(
    stock_code='000001.SZ',
    start_date='2023-01-01',
    end_date='2024-12-31',
)
```

> **PostgreSQL**: configure environment variables before running (copy `.env.example` to `.env`). Use `DATABASE_URL` / `GSAQ_DATABASE_URL`, or discrete `GSAQ_PG_HOST`, `GSAQ_PG_DB`, `GSAQ_PG_USER`, etc. Map your table/column names (`ts_code`, `trade_date`, `vol`, …) via `GSAQ_PG_*`. Connectivity check: `python scripts/ping_db.py` (after `pip install -e .`). MA example: `python scripts/example_ma_from_db.py` (optional env: `GSAQ_EXAMPLE_CODE`, `GSAQ_EXAMPLE_START`, `GSAQ_EXAMPLE_END`). **Read-only DB user, grants, and SQL** are documented in [docs/database-postgres-en.md](docs/database-postgres-en.md) (script: [sql/create_readonly_user.sql](sql/create_readonly_user.sql)).

#### 2. Run Strategy Backtest
```python
from genius_stock_aiquant.backtest.backtest_engine import BacktestEngine
from genius_stock_aiquant.strategy.trend_strategy import TrendStrategy

# Initialize backtesting engine
engine = BacktestEngine(initial_capital=100000)  # Initial capital: 100,000 CNY

# Load trend strategy
strategy = TrendStrategy()
engine.add_strategy(strategy)

# Execute backtest
results = engine.backtest(stock_data)
print(results.summary())
```

#### 3. Perform Stock Selection Analysis
```python
from genius_stock_aiquant.stock_selector import StockSelector

selector = StockSelector()
selected_stocks = selector.select_stocks(
    method='technical',  # Technical analysis selection
    date='2024-12-31'
)
print(f"Number of selected stocks: {len(selected_stocks)}")
```

## 📈 Key Performance Indicators

| Metric | Description | Target |
|--------|-------------|--------|
| **Annualized Return** | Annual return percentage | > 20% |
| **Maximum Drawdown** | Maximum loss percentage | < -20% |
| **Sharpe Ratio** | Risk-adjusted return | > 1.0 |
| **Win Rate** | Percentage of profitable trades | > 50% |
| **Profit/Loss Ratio** | Average profit / Average loss | > 1.5 |
| **Cumulative Return** | Total return percentage | > 100% |

## 🎓 Strategy Details

### Trend Strategy Workflow
1. **Trend Identification**: Determine main trend using MA20, MA50, MA200 and other moving averages
2. **Entry Signals**: 
   - Stock price pulls back to moving average support with small positive candle
   - Volume complements price action with volume-price synchronization
3. **Position Management**: 
   - Set stop-loss below recent lows (typically 2-3%)
   - Use trailing stop-loss for profit-taking
4. **Exit Signals**:
   - Price breaks below key moving average
   - Stop-loss or take-profit triggered
   - Pattern breakdown occurs

### Limit-Up Strategy Workflow
1. **Pre-forecasting**: 
   - Identify stocks with limit-up potential
   - Based on technical and sentiment indicators
2. **Limit-Up Monitoring**: 
   - Real-time tracking of limit-up stocks
   - Analyze limit-up strength and sustainability
3. **Trading Opportunities**:
   - One-word limit-up: High risk, minimal participation
   - High-open limit-up: Seek pullback entry opportunities
   - Auction limit-up: Requires quick response

### Leading Stock Strategy Workflow
1. **Leading Stock Identification**:
   - Volume Leadership: Among top trading volume in sector
   - Gains Leadership: Outperforms sector gains
   - First Breakout: First to break key resistance levels
2. **Entry Conditions**:
   - Breaks above recent highs
   - Significant volume increase
   - Strong relative strength indicators
3. **Holding Strategy**:
   - Track leading stock movements
   - Set wider stop-loss
   - Add positions on trend confirmation

## 📊 Data Requirements

The project requires the following A-Share data:
- **Daily K-line Data**: Open, close, high, low prices, trading volume, trading amount (amount optional)
- **Time Range**: Recommend at least 3+ years of historical data for backtest validation
- **Stock Coverage**: All A-Share stocks or specific sector/style stocks list
- **PostgreSQL (recommended)**: When history lives in Postgres, connect via environment variables; the daily table should include symbol, trade date, OHLC, volume, etc., with column names aligned to `GSAQ_PG_*` defaults (`ts_code`, `trade_date`, `vol`, …) or your mapped names

## 🔧 Configuration Files

`config/strategy_config.json` - Strategy parameter configuration example:
```json
{
  "trend_strategy": {
    "ma_periods": [20, 50, 200],
    "stop_loss_percent": 2.5,
    "take_profit_percent": 8.0
  },
  "limit_strategy": {
    "prediction_score_threshold": 0.7,
    "volume_multiplier": 1.5
  },
  "leader_strategy": {
    "industry_rank_threshold": 5,
    "breakout_ratio": 0.02
  }
}
```

## 📝 Use Cases

1. **Strategy Development**: Rapidly iterate strategy code using Cursor and other AI tools
2. **Backtest Validation**: Verify strategy effectiveness on historical data
3. **Parameter Optimization**: Grid search for optimal parameter combinations
4. **Paper Trading**: Test strategy performance in simulated environment
5. **Live Trading**: (Use with caution) Trade with proper risk management

## ⚠️ Risk Disclaimer

- **History is not future**: Backtest results do not guarantee future performance
- **Market Risk**: A-Share market has high volatility requiring risk controls
- **Model Risk**: Strategies may suffer from overfitting
- **Execution Risk**: Actual trading may differ due to slippage, fees, etc.
- **Black Swan Events**: Unexpected events may cause strategy failure

**Recommendations**:
- Start with small capital for live trading tests
- Always follow strict risk management rules
- Regularly evaluate strategy performance
- Avoid excessive leverage

## 🛠️ Development Tools

- **IDE**: Visual Studio Code + Cursor extension / Cursor IDE
- **Python Environment**: Python 3.8+
- **Version Control**: Git
- **Package Management**: pip + `requirements.txt` + `pyproject.toml` (editable install)
- **Testing**: pytest (run `pytest` after installing dev extras)

## 📚 Reference Resources

- [Talib Technical Analysis Library](https://github.com/mrjbq7/ta-lib)
- [Tushare - Chinese Stock Data](https://tushare.pro/)
- [Quantitative Trading Basics](https://www.joinquant.com/)
- [Backtesting Framework Reference](https://github.com/backtrader/backtrader)

## 🤝 Collaboration & Issues

Welcome to submit issues, suggestions, and improvement proposals!

## 📄 License

MIT License

## 📧 Contact

For any questions or collaboration opportunities, please feel free to reach out.

---

**Last Updated**: March 2026
**Project Status**: In Development
