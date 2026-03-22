# GeniusStockAIQuant 数据库字典

## 1. 数据来源说明

### 1.1 AKShare (中国股票数据)
- **官方网站**: https://www.akshare.xyz/
- **说明**: 提供A股市场的日K线、实时行情、热点数据等
- **数据特点**: 覆盖沪深京三市，数据更新及时，API友好
- **使用表**: 除了 `stock_history_bao_k*` 外的所有表

### 1.2 BaoStock (财经数据平台)
- **官方网站**: http://baostock.com/
- **说明**: 提供股票K线数据、财务数据、机器学习数据等
- **数据特点**: 历史数据完整，K线数据准确
- **使用表**: `stock_history_bao_k`, `stock_history_bao_k_qfq`, `stock_history_bao_k_hfq`

---

## 2. 股票代码格式说明

### 2.1 标准格式 (AKShare主要使用)
```
沪深京三市统一使用以下格式：
- 深圳A股: 000001.SZ (后缀 .SZ)
- 上海A股: 600000.SH (后缀 .SH)
- 北京A股: 430000.BJ (后缀 .BJ)

例子：
- 平安银行: 000001.SZ
- 浦发银行: 600000.SH
- 新三板股票: 430000.BJ
```

### 2.2 BaoStock格式
```
使用数字和小数点组合：
- 上海股票: sh.600000
- 深圳股票: sz.000001

例子：
- 平安银行: sz.000001
- 浦发银行: sh.600000
```

### 2.3 新浪格式
```
简化格式：
- 上海股票: sh600000
- 深圳股票: sz000001

例子：
- 平安银行: sz000001
- 浦发银行: sh600000
```

---

## 3. 价格数据表详解

### 3.1 复权说明

#### 原始数据 (stock_history)
- **定义**: 未经处理的原始价格数据
- **用途**: 保留原始交易数据，用于计算真实成交额
- **注意**: 股权除息会导致价格断层，不适合长期技术分析

```
例：10送10转10派1元
除权前: 收盘价 100 元
除权后: 收盘价 100 * (1-0.01) / (1+10/10+10/10) = 约 50 元
```

#### 前复权 (stock_history_qfq)
- **定义**: 向前复权（向前调整）
- **原理**: 将历史价格按除权因子调整，使得除权前后价格连贯
- **用途**: 
  - 长期趋势分析
  - 历史回测
  - 技术分析
- **特点**: 
  - 最近价格会被调整
  - 历史价格更可比较
  - 交易金额需要自行转换

```
调整公式：历史价格 = 历史价格 × 除权因子
```

#### 后复权 (stock_history_hfq)
- **定义**: 向后复权（向后调整）
- **原理**: 将最近价格保留不变，历史价格向后调整
- **用途**: 
  - 近期分析
  - 实盘操作
  - 日内交易
- **特点**: 
  - 最近价格是真实价格
  - 历史价格被调整
  - 容易计算实际成本

```
调整公式：最近价格保持不变，历史价格 = 历史价格 × 除权因子
```

### 3.2 如何选择

| 应用场景 | 推荐使用 | 原因 |
|--------|--------|------|
| 长期策略回测 | stock_history_qfq | 数据连贯，适合长期分析 |
| 近期分析 | stock_history_hfq | 最近价格准确，易于计算成本 |
| 实盘操作 | stock_history_hfq | 与市场价格一致 |
| K线绘制 | stock_history_hfq | 视觉效果更佳 |
| 成交额分析 | stock_history | 原始数据，便于计算 |
| 高频交易 | stock_history_hfq | 准确的实时价格 |
| 基金持仓分析 | stock_history_qfq | 长期趋势分析 |

---

## 4. 热点数据表使用指南

### 4.1 龙虎榜 (stock_lhb_*)

#### 概念解释
- **龙虎榜**: 沪深交易所每日发布，成交异常的前十名股票信息
- **内容**: 包含游资名单、机构买卖、成交金额等

#### 表关系

```
stock_lhb_detail_em
    ↓ 分组汇总
stock_lhb_hyyyb_em (营业部汇总)
    ↓ 向下钻取
stock_lhb_yyb_detail_em (营业部详情)
```

#### 应用案例

```python
# 获取频繁上榜的营业部（游资）
SELECT yyb_symbol, COUNT(*) as cnt
FROM stock_lhb_hyyyb_em
WHERE trade_date >= DATE(NOW()) - INTERVAL '30 days'
GROUP BY yyb_symbol
ORDER BY cnt DESC
LIMIT 20;

# 分析特定股票的龙虎榜历史
SELECT * FROM stock_lhb_detail_em
WHERE insight LIKE '%000001%'
ORDER BY trade_date DESC;
```

---

## 5. 基金流向表使用指南

### 5.1 基金流向的含义

| 指标 | 说明 | 应用 |
|------|------|------|
| 超大单 | 成交额>1000万的单笔交易 | 机构行为 |
| 大单 | 成交额100-1000万 | 中等资金 |
| 中单 | 成交额20-100万 | 小投资者 |
| 小单 | 成交额<20万 | 零售投资者 |

### 5.2 流向指标

- **流入**: 看涨单（主力买入）
- **流出**: 看跌单（主力卖出）
- **净流入** = 流入 - 流出

### 5.3 表层级关系

```
单层级（个股资金流）:
stock_fund_single_intraday        （日内实时）
    ↓ 汇总
stock_fund_single_rank            （排名）
    ↓ 详细化
stock_fund_single_detail_intraday （详细日内）
    ↓ 排序
stock_fund_single_detail_rank     （详细排名）
    ↓ 极高频
stock_fund_single_detail_realtime （实时极高频）

板块级别（相同逻辑）:
stock_fund_concept_*   （概念板块）
stock_fund_industry_*  （行业板块）
stock_fund_market_detail （整体市场）
```

### 5.4 应用案例

```python
# 获取资金流入最多的行业
SELECT symbol, SUM(inflow) as total_inflow
FROM stock_fund_industry_rank
WHERE range_type = 'day'
  AND trade_date >= DATE(NOW()) - INTERVAL '5 days'
GROUP BY symbol
ORDER BY total_inflow DESC
LIMIT 10;

# 个股资金流排名 (日内)
SELECT symbol, inflow, outflow, (inflow - outflow) as net_flow
FROM stock_fund_single_detail_rank
WHERE range_type = 'day'
  AND trade_date = CURRENT_DATE
ORDER BY net_flow DESC
LIMIT 20;
```

---

## 6. 排名表使用指南

### 6.1 时间范围 (range_type)

| 类型 | 说明 | 用途 |
|------|------|------|
| day | 日 | 日内选股 |
| week | 周 | 周线分析 |
| month | 月 | 月线分析 |
| 3m | 3月 | 中期趋势 |
| 6m | 6月 | 中期趋势 |
| 1y | 1年 | 长期趋势 |

### 6.2 常用排名表

| 表名 | 说明 | 场景 |
|------|------|------|
| stock_rank_cxg | 换手率（股数） | 流动性分析 |
| stock_rank_cxfl | 涨幅排名 | 强势股选择 |
| stock_rank_cxsl | 跌幅排名 | 反弹股选择 |
| stock_rank_lxsz | 连续上升周数 | 趋势追踪 |
| stock_rank_xstp | 新股高点 | 新股分析 |
| stock_rank_xzjp | 涨停板 | 热点追踪 |

---

## 7. 板块表使用指南

### 7.1 表结构

```
板块行情 (stock_board_*_em / stock_board_*_em_realtime)
    │
    ├─ 行业板块 (stock_board_industry_em)
    │   └─ 行业成分 (stock_board_industry_cons_em)
    │
    └─ 概念板块 (stock_board_concept_em)
        └─ 概念成分 (stock_board_concept_cons_em)
```

### 7.2 使用示例

```python
# 获取行业板块涨幅排名
SELECT * FROM stock_board_industry_em
WHERE trade_date = CURRENT_DATE
ORDER BY change_percent DESC
LIMIT 10;

# 获取某个概念板块的成分股
SELECT * FROM stock_board_concept_cons_em
WHERE board_name = '5G'
ORDER BY created_at DESC;
```

---

## 8. 账户数据表说明

### 8.1 持仓信息 (stock_account_position)

| 字段 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| trade_date | date | 持仓日期 |
| quantity | bigint | 持仓数量（股） |
| cost_price | double | 成本价（元） |
| current_price | double | 当前价（元） |
| market_value | double | 市值（元） |
| pnl | double | 浮盈（元） |
| pnl_percent | double | 浮盈比率（%） |

### 8.2 操作记录 (stock_account_action)

| 字段 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| trade_date | date | 交易日期 |
| current_time | timestamp | 交易时间 |
| type | varchar | 操作类型 (buy/sell) |
| quantity | bigint | 成交数量（股） |
| price | double | 成交价（元） |
| amount | double | 成交额（元） |
| commission | double | 佣金（元） |

---

## 9. 数据质量检查SQL

### 9.1 缺失数据检查

```sql
-- 检查指定日期是否有数据
SELECT COUNT(DISTINCT symbol) as stock_count
FROM stock_history
WHERE trade_date = '2024-01-02';

-- 检查缺失的交易日
SELECT DISTINCT sh.trade_date
FROM stock_trade_date sh
WHERE sh.trade_date NOT IN (
    SELECT DISTINCT date FROM stock_history
) AND sh.trade_date >= DATE(NOW()) - INTERVAL '30 days';
```

### 9.2 异常值检查

```sql
-- 检查异常大的涨跌幅
SELECT symbol, date, 
       ROUND((close - open) / open * 100, 2) as change_percent,
       close, open
FROM stock_history
WHERE ABS((close - open) / open) > 0.2
  AND date >= DATE(NOW()) - INTERVAL '10 days'
ORDER BY date DESC, change_percent DESC;

-- 检查成交量异常
SELECT symbol, date, vol, 
       AVG(vol) OVER (PARTITION BY symbol ORDER BY date ROWS BETWEEN 20 PRECEDING AND 1 PRECEDING) as avg_vol_20
FROM stock_history
WHERE vol > 200 * AVG(vol) OVER (PARTITION BY symbol ORDER BY date ROWS BETWEEN 20 PRECEDING AND 1 PRECEDING)
  AND date >= DATE(NOW()) - INTERVAL '30 days';
```

### 9.3 重复数据检查

```sql
-- 检查重复的K线数据
SELECT symbol, date, COUNT(*) as cnt
FROM stock_history
GROUP BY symbol, date
HAVING COUNT(*) > 1
LIMIT 10;

-- 检查重复的实时数据
SELECT symbol, trade_date, collect_time, COUNT(*) as cnt
FROM stock_zh_a_spot_em_realtime
GROUP BY symbol, trade_date, collect_time
HAVING COUNT(*) > 1
LIMIT 10;
```

---

## 10. 查询性能优化

### 10.1 索引建议

已建立的索引涵盖：
- symbol / code 列（快速代码查询）
- date / trade_date 列（快速日期范围查询）
- created_at / updated_at 列（快速时间戳查询）

### 10.2 查询优化建议

```sql
-- ❌ 慢查询
SELECT * FROM stock_history WHERE EXTRACT(YEAR FROM date) = 2024;

-- ✅ 快查询
SELECT * FROM stock_history WHERE date >= '2024-01-01' AND date < '2025-01-01';

-- ❌ 慢查询
SELECT * FROM stock_history WHERE close * vol > 1000000;

-- ✅ 快查询（预先计算市值）
SELECT * FROM stock_history WHERE amount > 1000000;

-- ❌ 慢查询（全表扫描）
SELECT DISTINCT symbol FROM stock_history;

-- ✅ 快查询（限制条件）
SELECT DISTINCT symbol FROM stock_history WHERE date >= DATE(NOW()) - INTERVAL '1 year';
```

### 10.3 常用查询模板

```sql
-- 获取最新的股票价格
SELECT h1.*
FROM stock_history h1
WHERE date = (SELECT MAX(date) FROM stock_history h2 WHERE h2.symbol = h1.symbol);

-- 计算股票的移动平均线
SELECT symbol, date, close,
       AVG(close) OVER (PARTITION BY symbol ORDER BY date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) as ma20,
       AVG(close) OVER (PARTITION BY symbol ORDER BY date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) as ma50
FROM stock_history
WHERE date >= DATE(NOW()) - INTERVAL '6 months';

-- 获取涨幅最大的前10只股票
SELECT h.symbol, h.date, h.close, h.open, 
       ROUND((h.close - h.open) / h.open * 100, 2) as change_percent
FROM stock_history h
INNER JOIN (
    SELECT symbol, MAX(date) as last_date
    FROM stock_history
    GROUP BY symbol
) latest ON h.symbol = latest.symbol AND h.date = latest.last_date
ORDER BY (h.close - h.open) / h.open DESC
LIMIT 10;
```

---

## 11. 数据更新频率参考

| 表类别 | 更新频率 | 最佳查询时间 |
|--------|--------|-----------|
| K线数据 (stock_history*) | 日更 | 15:30 后 |
| 实时行情 | 实时 | 交易时段 |
| 龙虎榜 | 日更 | 19:00 后 |
| 基金流向 | 日更或更高频 | 16:00 后 |
| 排名数据 | 日更 | 15:30 后 |
| 板块数据 | 实时/日更 | 交易时段 |
| 账户数据 | 实时 | 随时 |

---

## 12. 常见问题解答

### Q1: 为什么要有三种复权方式？
**A**: 
- 原始数据保留真实交易记录
- 前复权方便长期分析（数据连贯）
- 后复权方便实盘操作（价格准确）

### Q2: stock_trade_date 的用途是什么？
**A**: 
- 排除周末和假期
- 用于补全缺失数据
- 验证数据完整性

### Q3: 如何判断数据是否过期？
**A**: 
```sql
-- 检查最新数据日期
SELECT MAX(trade_date) as latest_date
FROM stock_trade_date;
```

### Q4: 基金流向的"流入"包括哪些类型？
**A**: 
- 超大单买入
- 大单买入
- 中单买入
- 小单买入

### Q5: 如何快速找到龙虎榜股票？
**A**:
```sql
SELECT DISTINCT symbol FROM stock_lhb_detail_em
WHERE trade_date >= DATE(NOW()) - INTERVAL '30 days'
ORDER BY trade_date DESC;
```

---

## 13. 最佳实践总结

1. **数据选择原则**
   - 长期分析：使用前复权数据
   - 近期分析：使用后复权或原始数据
   - 实盘操作：使用后复权数据

2. **查询优化原则**
   - 总是使用索引列作为WHERE条件
   - 避免在函数中使用列名
   - 尽早使用WHERE过滤数据

3. **数据验证原则**
   - 定期检查数据完整性
   - 对异常值进行人工审核
   - 保留原始数据不做修改

4. **应用设计原则**
   - 分离热数据和冷数据
   - 使用缓存加速高频查询
   - 定期备份重要数据

---

**最后更新**: 2024年3月22日  
**文档版本**: 1.0

