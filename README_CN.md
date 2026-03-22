# GeniusStockAIQuant - A股量化交易系统

## 📊 项目概述

**GeniusStockAIQuant** 是一个基于中国A股市场的智能量化交易系统。项目利用现有的A股股票市场数据，结合AI编程工具（如Cursor）的辅助，构建多策略的股票量化选股、回测和交易系统。

## 🎯 核心功能

### 1. **智能选股模块** 
- 基于量化指标的选股框架
- 支持多种技术分析指标组合
- 龙头股识别算法
- 涨停板预测和筛选

### 2. **回测系统** 
- 完整的历史数据回测引擎
- 支持多策略并行回测
- 详细的性能评估指标
  - 年化收益率
  - 最大回撤
  - 夏普比率
  - 胜率和盈亏比
- 实时交易过程可视化

### 3. **进出场管理** 
- 灵活的进场条件设置
- 动态止盈止损策略
- 风险控制和头寸管理
- 资金曲线追踪

### 4. **多策略支持**

#### 趋势策略
- 基于移动平均线的主流趋势识别
- 支持长期趋势和中期趋势判断
- 趋势反转信号检测

#### 涨停策略
- 涨停板股票预测
- 涨停后的短期交易机会
- 涨停板概率计算

#### 龙头策略
- 行业龙头识别
- 龙头股突破信号
- 龙头溢价分析

## 💻 技术架构

### 技术栈
- **编程语言**: Python 3.8+
- **数据处理**: pandas, numpy
- **数据源**: 中国A股历史行情数据
- **回测框架**: 自研量化引擎
- **可视化**: matplotlib, plotly
- **AI编程助手**: Cursor IDE

### 项目结构
```
GeniusStockAIQuant/
├── README.md                 # 项目说明
├── README_CN.md             # 中文版本
├── README_EN.md             # 英文版本
├── data/                    # 数据目录
│   ├── raw/                # 原始数据
│   └── processed/          # 处理后的数据
├── src/                     # 源代码
│   ├── data_loader.py      # 数据加载模块
│   ├── strategy/           # 策略模块
│   │   ├── trend_strategy.py      # 趋势策略
│   │   ├── limit_strategy.py      # 涨停策略
│   │   └── leader_strategy.py     # 龙头策略
│   ├── backtest/           # 回测引擎
│   │   ├── backtest_engine.py     # 核心回测引擎
│   │   └── metrics.py             # 性能指标计算
│   ├── stock_selector.py   # 选股模块
│   └── utils/              # 工具函数
├── notebooks/              # Jupyter分析笔记本
├── config/                 # 配置文件
└── requirements.txt        # 项目依赖
```

## 🚀 快速开始

### 环境安装
```bash
# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate     # Windows

# 安装依赖
pip install -r requirements.txt
```

### 基础使用

#### 1. 数据加载
```python
from src.data_loader import DataLoader

loader = DataLoader()
# 加载特定股票的历史数据
stock_data = loader.load_stock_data(stock_code='000001', start_date='2023-01-01', end_date='2024-12-31')
```

#### 2. 运行策略回测
```python
from src.backtest.backtest_engine import BacktestEngine
from src.strategy.trend_strategy import TrendStrategy

# 初始化回测引擎
engine = BacktestEngine(initial_capital=100000)  # 初始资金10万

# 加载趋势策略
strategy = TrendStrategy()
engine.add_strategy(strategy)

# 执行回测
results = engine.backtest(stock_data)
print(results.summary())
```

#### 3. 进行选股分析
```python
from src.stock_selector import StockSelector

selector = StockSelector()
selected_stocks = selector.select_stocks(
    method='technical',  # 技术面选股
    date='2024-12-31'
)
print(f"选中股票数: {len(selected_stocks)}")
```

## 📈 核心指标说明

| 指标 | 说明 | 目标值 |
|------|------|--------|
| **年化收益率** | 年收益百分比 | > 20% |
| **最大回撤** | 最大亏损幅度 | < -20% |
| **夏普比率** | 风险调整后的收益 | > 1.0 |
| **胜率** | 盈利交易占比 | > 50% |
| **盈亏比** | 平均盈利/平均亏损 | > 1.5 |
| **累计收益** | 总起始收益幅度 | > 100% |

## 🎓 策略详解

### 趋势策略详细流程
1. **趋势判定**: 基于MA20、MA50、MA200等均线判定主趋势
2. **进场信号**: 
   - 股价回踩均线获得支撑，出现小阳线
   - 成交量配合，量价齐升
3. **持仓管理**: 
   - 设置止损点位（通常在近期低点下方2-3%）
   - 追踪止盈（使用移动止损）
4. **出场信号**:
   - 股价跌破关键均线
   - 触发止损或止盈条件
   - 出现形态破位

### 涨停策略详细流程
1. **前期预测**: 
   - 识别有涨停潜力的股票特征
   - 基于技术面和情绪指标
2. **涨停监测**: 
   - 实时追踪涨停板股票
   - 分析涨停强度和持续性
3. **交易机会**:
   - 一字涨停：风险大，少量参与
   - 高开涨停：寻找回调介入机会
   - 集合竞价涨停：需要快速反应

### 龙头策略详细流程
1. **龙头识别**:
   - 量能领先：成交额在行业前列
   - 涨幅领先：上涨幅度超过板块
   - 首次突破：率先突破关键阻力
2. **进场条件**:
   - 突破前期高点
   - 成交量明显放大
   - 相对强度指标强势
3. **持仓策略**:
   - 跟踪龙头股走势
   - 设置宽松的止损
   - 趋势确认再加仓

## 📊 数据要求

项目需要以下A股数据：
- **日K线数据**: 开盘价、收盘价、最高价、最低价、成交量、成交额
- **时间范围**: 建议至少3年以上历史数据用于回测验证
- **股票覆盖**: 全A股或特定行业/风格的股票列表

## 🔧 配置文件说明

`config/strategy_config.json` - 策略参数配置示例：
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

## 📝 使用场景

1. **策略开发**: 使用Cursor等AI工具快速迭代策略代码
2. **回测验证**: 在历史数据上验证策略有效性
3. **参数优化**: 通过网格搜索找到最优参数组合
4. **实盘模拟**: 在模拟环境中测试策略表现
5. **实时交易**: （需谨慎）结合风控条件进行实时操作

## ⚠️ 风险提示

- **历史不代表未来**: 回测结果不保证未来表现
- **市场风险**: A股市场波动大，需做好风控
- **模型风险**: 策略可能存在过度拟合
- **执行风险**: 实际交易可能因滑点、手续费等产生偏差
- **黑天鹅事件**: 突发事件可能导致策略失效

**建议：** 
- 从小资金开始实盘测试
- 始终遵循严格的风控规则
- 定期评估策略表现
- 不要过度杠杆

## 🛠️ 开发工具

- **IDE**: Visual Studio Code + Cursor插件 / Cursor IDE
- **Python环境**: Python 3.8+
- **版本控制**: Git
- **包管理**: pip + requirements.txt

## 📚 参考资源

- [Talib技术分析库](https://github.com/mrjbq7/ta-lib)
- [tushare - 中国股票数据](https://tushare.pro/)
- [量化交易基础](https://www.joinquant.com/)
- [回测框架参考](https://github.com/backtrader/backtrader)

## 🤝 合作与问题

欢迎提出问题、建议和改进方案！

## 📄 许可证

MIT License

## 📧 联系方式

如有任何问题或合作意向，欢迎联系。

---

**最后更新**: 2026年3月
**项目状态**: 开发中
