# GeniusStockAIQuant 数据库架构指南

## 概述

本数据库（`fin_store`）包含A股市场的量化交易相关数据，数据来源主要为：
- **AKShare** - 中国股市数据提供商（大部分表）
- **BaoStock** - 财经数据平台（表名包含 `bao_k` 的K线表）

数据库包含以下核心功能模块：
1. **基础信息** - 股票、交易所、艺术家信息
2. **历史价格数据** - 日K线、复权数据、实时数据
3. **市场分析** - 异常波动、板块数据、基金流向
4. **热点数据** - 龙虎榜、新闻、评论、公司事件
5. **量化指标** - 各类排名表、筹码集中度、市场活跃度
6. **账户数据** - 交易账户持仓和操作记录

---

## 表结构详解

### 一、基础信息表

#### 1.1 `stock_exchange` - 证券交易所信息
**数据来源**: AKShare

| 列名 | 类型 | 说明 |
|------|------|------|
| name | varchar(120) | 交易所名称（如：上海证券交易所、深圳证券交易所） |

**用途**: 存储交易所基本信息，支持多个交易所的数据管理

---

#### 1.2 `stock_info` - 股票基本信息
**数据来源**: AKShare

| 列名 | 类型 | 说明 |
|------|------|------|
| market_value | double precision | 市值（单位：元） |
| ... | ... | 其他基本信息字段 |

**用途**: 存储股票的基本面信息，如市值、行业分类等

---

#### 1.3 `artist` - 艺术品相关信息
**数据来源**: 自定义

| 列名 | 类型 | 说明 |
|------|------|------|
| name | varchar(120) | 艺术家或作品名称 |

**用途**: 扩展字段，可能用于多资产类别的支持

---

### 二、价格数据表

#### 2.1 `stock_history` - 股票日K线数据（原始价格）
**数据来源**: AKShare  
**更新频率**: 日更

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码（如：000001.SZ） |
| date | date | 交易日期 |
| open | double precision | 开盘价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| close | double precision | 收盘价 |
| vol | double precision | 成交量（手） |
| amount | double precision | 成交额（元） |

**索引**: 
- `ix_stock_history_symbol` - 按代码查询
- `ix_stock_history_date` - 按日期查询

**用途**: 基础K线数据，用于策略回测和技术分析

---

#### 2.2 `stock_history_qfq` - 股票日K线数据（前复权）
**数据来源**: AKShare  
**更新频率**: 日更

**说明**: 
- QFQ = 前复权（向前复权）
- 将除权除息影响向前调整，使历史价格可对比
- 列结构与 `stock_history` 相同
- **用途**: 用于长期策略回测，确保数据连贯性

---

#### 2.3 `stock_history_hfq` - 股票日K线数据（后复权）
**数据来源**: AKShare  
**更新频率**: 日更

**说明**:
- HFQ = 后复权（向后复权）
- 将除权除息影响向后调整，保留最近日期的原始价格
- 列结构与 `stock_history` 相同
- **用途**: 用于近期分析和实盘操作

---

#### 2.4 `stock_history_bao_k` - BaoStock K线数据（原始价格）
**数据来源**: BaoStock  
**更新频率**: 日更

| 列名 | 类型 | 说明 |
|------|------|------|
| code | varchar(20) | 股票代码（BaoStock格式，如：sh.600000） |
| date | date | 交易日期 |
| open | double precision | 开盘价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| close | double precision | 收盘价 |
| vol | double precision | 成交量 |
| amount | double precision | 成交额 |

**索引**: 
- `ix_stock_history_bao_k_symbol` - 按代码
- `ix_stock_history_bao_k_date` - 按日期

**用途**: BaoStock数据源的原始K线数据

---

#### 2.5 `stock_history_bao_k_qfq` - BaoStock K线数据（前复权）
**数据来源**: BaoStock

**说明**: BaoStock数据的前复权版本，列结构与 `stock_history_bao_k` 相同

---

#### 2.6 `stock_history_bao_k_hfq` - BaoStock K线数据（后复权）
**数据来源**: BaoStock

**说明**: BaoStock数据的后复权版本，列结构与 `stock_history_bao_k` 相同

---

### 三、实时行情表

#### 3.1 `stock_zh_a_spot_em_realtime` - 实时行情数据（东财）
**数据来源**: AKShare  
**更新频率**: 实时（交易时段）

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| trade_date | date | 交易日期 |
| collect_time | timestamp | 采集时间 |
| ... | ... | 实时价格、成交量等数据 |

**索引**: symbol、trade_date、collect_time

**用途**: 捕捉日内波动，支持高频数据分析

---

#### 3.2 `stock_zh_a_spot_em` - 东财实时行情快照
**数据来源**: AKShare  
**更新频率**: 日更

**说明**: `stock_zh_a_spot_em_realtime` 的汇总或定点快照，存储每日关键时点的行情

---

#### 3.3 `stock_zh_a_spot_sina_realtime` - 新浪实时行情
**数据来源**: AKShare  
**更新频率**: 实时

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码（标准格式） |
| code | varchar(20) | 股票代码（新浪格式） |
| trade_date | date | 交易日期 |
| collect_time | timestamp | 采集时间 |

**用途**: 新浪数据源的实时行情，作为东财数据的补充

---

### 四、交易日期表

#### 4.1 `stock_trade_date` - 交易日期日历
**数据来源**: AKShare

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期（仅包含交易日） |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |

**索引**: 
- `ix_stock_trade_date_trade_date`
- `ix_stock_trade_date_updated_at`

**用途**: 定义有效的交易日期，排除周末和假期

---

### 五、异常波动表

#### 5.1 `stock_change_abnormal` - 异常波动监控
**数据来源**: AKShare  
**更新频率**: 日更

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| date | date | 发生日期 |
| event_time | timestamp | 事件时间 |
| ... | ... | 异常类型、涨跌幅等信息 |

**索引**: symbol、date、event_time

**用途**: 追踪异常价格波动事件，用于风险管理

---

### 六、热点数据表

#### 6.1 `stock_news` - 股票相关新闻
**数据来源**: AKShare  
**更新频率**: 实时

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 相关股票代码 |
| pub_time | timestamp | 发布时间 |
| updated_at | timestamp | 更新时间 |
| created_at | timestamp | 创建时间 |

**索引**: symbol、pub_time、updated_at

**用途**: 收集和分析与股票相关的新闻，用于舆情分析

---

#### 6.2 `stock_comment` - 股票评论数据
**数据来源**: AKShare  
**更新频率**: 日更

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| trade_date | date | 交易日期 |
| ... | ... | 评论内容、评分等 |

**索引**: symbol、trade_date

**用途**: 分析投资者情绪和市场心态

---

#### 6.3 `stock_company_event` - 上市公司事件
**数据来源**: AKShare  
**更新频率**: 日更

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| event_date | date | 事件日期 |
| ... | ... | 事件类型、内容等 |

**索引**: symbol、event_date

**用途**: 捕捉公司基本面事件，分析其对股价的影响

---

#### 6.4 `stock_lhb_detail_em` - 龙虎榜详情
**数据来源**: AKShare  
**更新频率**: 日更

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| insight | varchar | 龙虎榜分析 |

**索引**: trade_date、insight

**用途**: 详细的龙虎榜数据，追踪游资动向

---

#### 6.5 `stock_lhb_hyyyb_em` - 龙虎榜营业部汇总
**数据来源**: AKShare

| 列名 | 类型 | 说明 |
|------|------|------|
| yyb_symbol | varchar(20) | 营业部代码 |
| trade_date | date | 交易日期 |

**用途**: 统计营业部在龙虎榜中的出现频率

---

#### 6.6 `stock_lhb_yyb_detail_em` - 龙虎榜营业部详情
**数据来源**: AKShare

**说明**: 龙虎榜营业部的详细交易信息

---

### 七、股票排名表

以下表格统计各种维度的股票排名，按 `range_type` 区分时间范围（日、周、月等）

#### 7.1 换手率排名表 (stock_rank_cxg / stock_rank_cxd)
**数据来源**: AKShare  
**CXG**: 换手率（股）  
**CXD**: 换手率（点）

---

#### 7.2 连续涨跌排名表 (stock_rank_lxsz / stock_rank_lxxd)
**数据来源**: AKShare  
**LXSZ**: 连续上升周数  
**LXXD**: 连续下降周数

---

#### 7.3 涨跌幅排名表 (stock_rank_cxfl / stock_rank_cxsl)
**数据来源**: AKShare  
**CXFL**: 涨幅  
**CXSL**: 跌幅

---

#### 7.4 新高新低排名表 (stock_rank_xstp / stock_rank_xxtp)
**数据来源**: AKShare  
**XSTP**: 新股高点  
**XXTP**: 新股低点

---

#### 7.5 连接成交量排名表 (stock_rank_ljqs / stock_rank_ljqd)
**数据来源**: AKShare  
**LJQS**: 连接上升  
**LJQD**: 连接下降

---

#### 7.6 限制涨停排名 (stock_rank_xzjp)
**数据来源**: AKShare  
**说明**: 涨停板股票排名

---

### 八、基金流向表

#### 8.1 概念板块基金流向 (stock_fund_concept_*)
**数据来源**: AKShare

| 表名 | 说明 |
|------|------|
| stock_fund_concept_intraday | 日内概念板块基金流 |
| stock_fund_concept_rank | 概念板块基金流排名 |
| stock_fund_concept_detail_intraday | 概念板块详细基金流 |
| stock_fund_concept_detail_rank | 概念板块详细基金流排名 |

**用途**: 分析主力资金在概念板块的动向

---

#### 8.2 行业板块基金流向 (stock_fund_industry_*)
**数据来源**: AKShare

| 表名 | 说明 |
|------|------|
| stock_fund_industry_intraday | 日内行业基金流 |
| stock_fund_industry_rank | 行业基金流排名 |
| stock_fund_industry_detail_intraday | 行业详细基金流 |
| stock_fund_industry_detail_rank | 行业详细基金流排名 |

**用途**: 追踪各行业的资金流向变化

---

#### 8.3 个股基金流向 (stock_fund_single_*)
**数据来源**: AKShare

| 表名 | 说明 |
|------|------|
| stock_fund_single_intraday | 个股日内基金流 |
| stock_fund_single_rank | 个股基金流排名 |
| stock_fund_single_detail_intraday | 个股详细基金流 |
| stock_fund_single_detail_rank | 个股详细基金流排名 |
| stock_fund_single_detail_realtime | 个股实时基金流 |

---

#### 8.4 大宗交易 (stock_fund_big_deal)
**数据来源**: AKShare  
**更新频率**: 日更

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| trade_date | date | 交易日期 |
| trade_time | timestamp | 交易时间 |

**用途**: 监控大宗交易，识别机构动向

---

#### 8.5 市场资金流向 (stock_fund_market_detail)
**数据来源**: AKShare

**说明**: 整个市场的资金流向汇总

---

### 九、板块行情表

#### 9.1 板块实时行情 (stock_board_*_em_realtime)
**数据来源**: AKShare  
**更新频率**: 实时

| 表名 | 说明 |
|------|------|
| stock_board_concept_em_realtime | 概念板块实时行情 |
| stock_board_industry_em_realtime | 行业板块实时行情 |

---

#### 9.2 板块汇总行情 (stock_board_*_em)
**数据来源**: AKShare

| 表名 | 说明 |
|------|------|
| stock_board_concept_em | 概念板块行情 |
| stock_board_industry_em | 行业板块行情 |

---

#### 9.3 板块成分 (stock_board_*_cons_em)
**数据来源**: AKShare

| 表名 | 说明 |
|------|------|
| stock_board_concept_cons_em | 概念板块成分股 |
| stock_board_industry_cons_em | 行业板块成分股 |

| 列名 | 类型 | 说明 |
|------|------|------|
| board_name | varchar(40) | 板块名称 |
| ... | ... | 成分股代码、名称等 |

---

### 十、市场活跃度表

#### 10.1 `stock_market_activity_realtime` - 市场活跃度实时数据
**数据来源**: AKShare  
**更新频率**: 实时

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| collect_time | timestamp | 采集时间 |
| ... | ... | 成交总额、涨幅中位数等活跃指标 |

**用途**: 监控整个市场的活跃程度

---

### 十一、筹码集中度表

#### 11.1 `stock_cyq_em` - 筹码集中度分析
**数据来源**: AKShare  
**更新频率**: 日更

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| trade_date | date | 交易日期 |
| ... | ... | 各分位数筹码分布数据 |

**用途**: 分析主力筹码集中情况，判断运作意图

---

### 十二、股票池表

#### 12.1 `stock_pool_zt` - 涨停板股票池
**数据来源**: AKShare  
**更新频率**: 日更

---

#### 12.2 `stock_pool_strong` - 强势股票池
**数据来源**: AKShare  
**更新频率**: 日更

---

#### 12.3 `stock_pool_sub_new` - 次新股票池
**数据来源**: AKShare  
**更新频率**: 日更

---

#### 12.4 `stock_pool_zb` - 主板股票池
**数据来源**: AKShare  
**更新频率**: 日更

---

#### 12.5 `stock_pool_dt` - 跌停股票池
**数据来源**: AKShare  
**更新频率**: 日更

**说明**: 这些表存储符合各种标准的股票代码池，可直接用于策略选股（其中 `stock_pool_dt` 重点用于跌停风险与反弹机会分析）

---

### 十三、账户数据表

#### 13.1 `stock_account_position` - 账户持仓信息
**数据来源**: 用户账户  
**更新频率**: 实时

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| trade_date | date | 交易日期 |
| current_time | timestamp | 当前时间 |
| ... | ... | 持仓数量、成本价、浮盈等 |

**索引**: symbol、trade_date、current_time

**用途**: 跟踪实际持仓状况

---

#### 13.2 `stock_account_action` - 账户操作记录
**数据来源**: 用户账户  
**更新频率**: 实时

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| trade_date | date | 交易日期 |
| current_time | timestamp | 操作时间 |
| type | varchar | 操作类型（买入、卖出等） |

**索引**: symbol、trade_date、current_time、type

**用途**: 记录所有交易操作，用于回测和分析

---

## 列的通用说明

### 时间戳字段

所有表都包含以下标准时间戳：
- **created_at**: 数据记录创建时间
- **updated_at**: 数据记录最后更新时间
- **trade_date**: 交易日期（date类型）
- **collect_time/publish_time**: 数据采集或发布时间（timestamp）

### 股票代码格式

- **AKShare格式**: `000001.SZ` (深圳), `600000.SH` (上海)
- **BaoStock格式**: `sh.600000` (上海), `sz.000001` (深圳)
- **新浪格式**: `sh600000`, `sz000001`

### 索引策略

绝大多数表都建立了以下索引：
- symbol 或 code - 快速按代码查询
- trade_date 或 date - 快速按日期查询
- created_at / updated_at - 快速按时间范围查询

---

## 数据使用建议

### 1. 策略回测
使用 `stock_history` 或 `stock_history_qfq/hfq` 表，配合 `stock_trade_date` 确保交易日期的准确性

### 2. 基本面分析
结合 `stock_info`、`stock_company_event`、`stock_news` 分析公司基本情况

### 3. 热点追踪
使用龙虎榜、股票池、基金流向等表，发现市场热点

### 4. 资金分析
通过 `stock_fund_*` 系列表分析主力资金动向

### 5. 风险控制
参考 `stock_change_abnormal` 和 `stock_market_activity_realtime` 监控风险

### 6. 日内交易
使用 `stock_zh_a_spot_em_realtime` 和 `stock_fund_single_detail_realtime` 进行日内分析

---

## 数据完整性检查

建议定期检查以下内容：

1. **缺失数据**
   ```sql
   -- 检查特定日期缺失的股票数据
   SELECT COUNT(DISTINCT symbol) FROM stock_history 
   WHERE trade_date = '2024-01-01';
   ```

2. **异常值**
   ```sql
   -- 检查异常的涨跌幅
   SELECT * FROM stock_history 
   WHERE (close - open) / open > 0.5;
   ```

3. **重复数据**
   ```sql
   -- 检查重复记录
   SELECT symbol, trade_date, COUNT(*) 
   FROM stock_history 
   GROUP BY symbol, trade_date 
   HAVING COUNT(*) > 1;
   ```

---

## 性能优化建议

1. **使用分区表**: 对于超大表（如实时数据）考虑按日期分区
2. **定期清理**: 删除超过保留期的实时数据
3. **统计信息**: 定期运行 ANALYZE 更新查询计划
4. **连接池**: 使用数据库连接池管理PostgreSQL连接

---

## 更新日期

最后更新：2024年3月22日

