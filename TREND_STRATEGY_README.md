# A股趋势交易量化策略完整实现

## 概述

本实现提供了一个模块化、可扩展的A股趋势交易量化策略系统，包含以下核心模块：

- **TrendStrategy**: 基于移动平均线交叉的趋势交易策略
- **PortfolioManager**: 组合管理、风险控制、持仓跟踪
- **DataAdapter**: 数据接口适配，从PostgreSQL读取数据
- **BacktestEngine**: 完整的回测引擎，包含绩效评估

## 快速开始

### 1. 环境配置

确保已配置PostgreSQL数据库连接（见 `.env.example`）：

```bash
# 设置数据库环境变量
export DATABASE_URL="postgresql://user:password@localhost:5432/genius_stock"
# 或者分别设置
export GSAQ_PG_HOST=localhost
export GSAQ_PG_DB=genius_stock
export GSAQ_PG_USER=postgres
export GSAQ_PG_PASSWORD=password
```

### 2. 运行回测

```bash
cd scripts/
python trend_strategy_backtest.py
```

## 策略说明

### 交易规则

#### 入场信号（买入）
```
条件1: 趋势确认
  - MA5 > MA20 > MA60（多头排列）

条件2: 量价确认
  - 成交量 > 20日均量 × 1.2

执行: 满足以上两个条件时买入
```

#### 出场信号（卖出）
```
优先级1: 止损 (entry_price * 92%)
  - 亏损达到 -8% 时强制卖出

优先级2: 止盈 (entry_price * 115%)
  - 盈利达到 +15% 时自动卖出

优先级3: 趋势反转
  - MA5 < MA20 时卖出
  - 价格跌破 MA20 时卖出
```

### 参数说明

```python
TrendStrategy(
    ma_short=5,        # 短期移动平均线（5日）
    ma_mid=20,         # 中期移动平均线（20日）
    ma_long=60,        # 长期移动平均线（60日）
    vol_multiplier=1.2,  # 成交量倍数
    stop_loss_pct=0.08,  # 止损百分比（8%）
    take_profit_pct=0.15, # 止盈百分比（15%）
)
```

### 组合管理

```python
PortfolioManager(
    initial_capital=1_000_000,  # 初始资金
    max_positions=6,  # 最多同时持有6个头寸
    position_size_pct=0.05,  # 每个头寸占资金的5%
)
```

## 核心模块详解

### 1. TrendStrategy (趋势策略)

**文件**: `src/genius_stock_aiquant/strategy/trend_strategy.py`

```python
strategy = TrendStrategy(ma_short=5, ma_mid=20, ma_long=60)

# 生成买入信号
buy_signal = strategy.generate_buy_signal(bar)

# 生成卖出信号
sell_signal = strategy.generate_sell_signal(bar, entry_price)
```

**关键方法**:
- `generate_buy_signal()`: 基于趋势和量价生成买入信号
- `generate_sell_signal()`: 根据止损/止盈/趋势反转生成卖出信号

### 2. PortfolioManager (组合管理器)

**文件**: `src/genius_stock_aiquant/strategy/portfolio_manager.py`

```python
portfolio = PortfolioManager(initial_capital=1_000_000)

# 开仓
portfolio.open_position(buy_signal)

# 平仓
portfolio.close_position(symbol, exit_signal)

# 获取当前权益
equity = portfolio.get_current_equity(prices)

# 获取交易历史
trade_df = portfolio.get_trade_history_df()
```

**功能**:
- 位置管理（开仓/平仓/覆盖）
- 资金管理（现金跟踪）
- 风险监控（仓位限制）
- 交易记录

### 3. DataAdapter (数据适配器)

**文件**: `src/genius_stock_aiquant/strategy/data_adapter.py`

```python
adapter = DataAdapter()

# 加载单只股票数据
df = adapter.load_stock_ohlcv("000001.SZ", "2024-01-01", "2024-12-31")

# 计算技术指标
df = adapter.calculate_indicators(df, ma_periods=(5, 20, 60))

# 批量加载并准备数据
backtest_data = adapter.prepare_backtest_data(
    symbols=["000001.SZ", "000858.SZ"],
    start_date="2024-01-01",
    end_date="2024-12-31",
)
```

**特性**:
- 自动缓存避免重复读取
- 计算多种技术指标（MA, ATR等）
- 数据验证和清理

### 4. BacktestEngine (回测引擎)

**文件**: `src/genius_stock_aiquant/backtest/backtest_engine.py`

```python
engine = BacktestEngine(
    initial_capital=1_000_000,
    max_positions=6,
    commission=0.0001,  # 手续费
)

results = engine.backtest(stock_data, strategy)

# 查看结果
print(results.summary())
print(results.trade_history)
```

**输出指标**:
- 总收益率 (%)
- 年化收益率 (%)
- 夏普比率
- 最大回撤 (%)
- 胜率 (%)
- 交易统计（总交易数、盈利交易等）
- 持仓期统计

## 数据模型

### TradeSignal
```python
@dataclass
class TradeSignal:
    symbol: str              # 股票代码
    date: pd.Timestamp      # 信号时间
    signal_type: str        # "buy" 或 "sell"
    price: float           # 交易价格
    confidence: float      # 信号置信度 (0-1)
    reason: str            # 信号原因
    indicators: Optional[SignalIndicators]  # 技术指标
```

### Position
```python
@dataclass
class Position:
    symbol: str
    entry_date: pd.Timestamp
    entry_price: float
    shares: int
    exit_date: Optional[pd.Timestamp]  # None 表示开仓
    exit_price: Optional[float]
    pnl: Optional[float]     # 已实现盈亏
    pnl_pct: Optional[float] # 盈亏百分比
```

### BacktestMetrics
```python
@dataclass
class BacktestMetrics:
    total_return: float        # 总收益率
    annual_return: float       # 年化收益率
    sharpe_ratio: float        # 夏普比率
    max_drawdown: float        # 最大回撤
    win_rate: float           # 胜率
    total_trades: int         # 总交易数
    winning_trades: int       # 盈利交易
    losing_trades: int        # 亏损交易
    ...
```

## 使用示例

### 基础使用

```python
from genius_stock_aiquant.strategy.trend_strategy import TrendStrategy
from genius_stock_aiquant.strategy.data_adapter import DataAdapter
from genius_stock_aiquant.backtest.backtest_engine import BacktestEngine

# 1. 准备数据
adapter = DataAdapter()
data = adapter.prepare_backtest_data(
    symbols=["000001.SZ", "000858.SZ"],
    start_date="2024-01-01",
    end_date="2024-12-31",
)

# 2. 创建策略
strategy = TrendStrategy(
    ma_short=5,
    ma_mid=20,
    ma_long=60,
    stop_loss_pct=0.08,
    take_profit_pct=0.15,
)

# 3. 运行回测
engine = BacktestEngine(initial_capital=1_000_000)
results = engine.backtest(data, strategy)

# 4. 分析结果
print(results.summary())
print(results.trade_history)
```

### 自定义策略

继承 `BaseStrategy` 并实现自己的逻辑：

```python
from genius_stock_aiquant.strategy.base import BaseStrategy
from genius_stock_aiquant.strategy.models import TradeSignal

class MyCustomStrategy(BaseStrategy):
    def name(self) -> str:
        return "my_custom_strategy"
    
    def generate_buy_signal(self, bar):
        # 实现买入信号逻辑
        if your_condition:
            return TradeSignal(...)
        return None
    
    def generate_sell_signal(self, bar, entry_price):
        # 实现卖出信号逻辑
        if exit_condition:
            return TradeSignal(...)
        return None
```

## 扩展建议

### 1. 高级入场条件
- 加入RSI、MACD等指标的多指标确认
- 考虑日内分钟级别信号
- 加入基本面因子（PE、PB等）

### 2. 动态风险管理
- 根据波动率动态调整止损/止盈
- 动态仓位管理（按波动率或收益调整）
- 热力图展示高风险区域

### 3. 多策略框架
- 实现多策略融合
- 策略权重动态调整
- 组合优化算法

### 4. 实盘对接
- 集成券商API（东财、富途等）
- 风险审计和交易前检查
- 实时监控和告警

## 性能优化

### 数据加载优化
```python
# 使用缓存避免重复加载
adapter = DataAdapter()
data = adapter.prepare_backtest_data(...)  # 第一次加载
# 之后相同数据会使用缓存
clear_cache()  # 需要时清空缓存
```

### 回测速度
- 当前实现支持日线回测，足以处理100+ 只股票
- 对于分钟线数据，考虑使用矢量化操作或Cython优化

## 故障排除

**问题**: 找不到数据库连接
**解决**: 检查环境变量设置，确保PostgreSQL服务运行

**问题**: 数据缺失或NaN
**解决**: 检查数据库中是否存在必要的指标列（ma5, ma20, ma60, vol_avg）

**问题**: 回测结果异常
**解决**: 检查股票数据质量，确保OHLCV数据无缺失

## 文件结构

```
src/genius_stock_aiquant/
├── strategy/
│   ├── base.py                 # 策略基类
│   ├── trend_strategy.py       # 趋势交易策略
│   ├── portfolio_manager.py    # 组合管理
│   ├── data_adapter.py         # 数据适配
│   └── models.py               # 数据模型
├── backtest/
│   ├── backtest_engine.py      # 回测引擎
│   └── metrics.py              # 性能指标
└── data_loader.py              # 数据加载器

scripts/
└── trend_strategy_backtest.py  # 完整示例脚本
```

## 许可证

MIT License

## 贡献

欢迎提交Issues和Pull Requests！
