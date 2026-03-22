# GeniusStockAIQuant 数据库表列详细说明文档

## 概述

本文档详细列举数据库中所有表的列定义及中文说明，包括61个表，223个索引。

---

## 1. 基础信息表

### 1.1 artist - 艺术品相关信息表

| 列名 | 类型 | 说明 |
|------|------|------|
| name | varchar(120) | 艺术家或作品名称 |
| artist_id | serial | 艺术品ID (主键) |

---

### 1.2 stock_exchange - 证券交易所信息表

| 列名 | 类型 | 说明 |
|------|------|------|
| name | varchar(120) | 交易所名称（如：上海证券交易所、深圳证券交易所） |
| city | varchar(120) | 城市名称 |
| akshare_abb | varchar(20) | AKShare缩写代码 |
| yfinance_abb | varchar(20) | yfinance缩写代码 |
| stock_count | integer | 上市股票数量 |
| id | serial | 主键ID |

---

### 1.3 stock_info - 股票基本信息表

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| market_value | double precision | 总市值 |
| traded_market_value | double precision | 流通市值 |
| industry | varchar(50) | 行业 |
| offering_date | date | 上市时间 |
| short_name | varchar(20) | 股票简称 |
| total_share_capital | double precision | 总股本 |
| outstanding_shares | double precision | 流通股本 |
| exchange | varchar(10) | 交易所 |
| id | serial | 主键ID |

---

## 2. K线价格数据表

### 2.1 stock_history - AKShare日K线数据（原始价格）

**数据来源**: AKShare  
**更新频率**: 日更  
**索引**: symbol, date

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| date | date | 日期 |
| open | double precision | 开盘价 |
| close | double precision | 收盘价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| volume | integer | 成交量 |
| turnover | double precision | 成交额 |
| range | double precision | 振幅 |
| change_rate | double precision | 涨跌幅 |
| change_amount | double precision | 涨跌额 |
| turnover_rate | double precision | 换手率 |
| id | serial | 主键ID |

**用途**: 基础K线数据，用于策略回测和技术分析

---

### 2.2 stock_history_qfq - AKShare日K线数据（前复权）

**说明**: 向前复权处理，历史价格经过除权因子调整，适合长期趋势分析

**列结构**: 与 `stock_history` 相同

**索引**: date

---

### 2.3 stock_history_hfq - AKShare日K线数据（后复权）

**说明**: 向后复权处理，保留最近价格的原始值，适合近期分析和实盘操作

**列结构**: 与 `stock_history` 相同

---

### 2.4 stock_history_bao_k - BaoStock K线数据（原始价格）

**数据来源**: BaoStock  
**更新频率**: 日更  
**索引**: date, code, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| code | varchar(20) | 股票代码（BaoStock格式，待市场标识） |
| symbol | varchar(20) | 标准股票代码 |
| name | varchar(40) | 股票名称 |
| date | date | 日期 |
| open | double precision | 开盘价 |
| close | double precision | 收盘价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| volume | bigint | 成交量 |
| pre_close | double precision | 前收盘价 |
| amount | double precision | 成交额（单位：人民币元） |
| adjust_flag | integer | 复权状态（1：后复权，2：前复权，3：不复权；此表全为3） |
| turn | double precision | 换手率 |
| trade_status | integer | 交易状态（1：正常交易，0：停牌） |
| change_rate | double precision | 涨跌幅（百分比） |
| pe_ttm | double precision | 滚动市盈率 |
| pb_mrq | double precision | 市净率 |
| ps_ttm | double precision | 滚动市销率 |
| pcf_ncf_ttm | double precision | 滚动市现率 |
| is_st | integer | 是否ST股（1：是，0：否） |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: BaoStock数据源的原始K线数据，包含丰富的财务指标

---

### 2.5 stock_history_bao_k_qfq - BaoStock K线数据（前复权）

**说明**: BaoStock数据的前复权版本

**列结构**: 与 `stock_history_bao_k` 相同

---

### 2.6 stock_history_bao_k_hfq - BaoStock K线数据（后复权）

**说明**: BaoStock数据的后复权版本

**列结构**: 与 `stock_history_bao_k` 相同

---

## 3. 实时行情表

### 3.1 stock_zh_a_spot_em_realtime - 实时行情数据（东财）

**数据来源**: AKShare  
**更新频率**: 实时（交易时段）  
**索引**: symbol, trade_date, collect_time, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| collect_time | time | 时间 |
| symbol | varchar(20) | 代码 |
| name | varchar(40) | 名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| change_amount | double precision | 涨跌额 |
| volume | integer | 成交量 |
| turnover | double precision | 成交额 |
| range | double precision | 振幅 |
| high | double precision | 最高 |
| low | double precision | 最低 |
| open | double precision | 今开 |
| pre_close | double precision | 昨收 |
| volume_ratio | double precision | 量比 |
| turnover_rate | double precision | 换手率 |
| forward_pe_ratio | double precision | 市盈率-动态 |
| pb_mrq | double precision | 市净率 |
| market_value | double precision | 总市值 |
| traded_market_value | double precision | 流通市值 |
| up_speed | double precision | 涨速 |
| change_rate_5min | double precision | 5分钟涨跌 |
| change_rate_60d | double precision | 60日涨跌幅 |
| change_rate_ytd | double precision | 年初至今涨跌幅 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 捕捉日内波动，支持高频数据分析

---

### 3.2 stock_zh_a_spot_em - 东财行情快照

**说明**: 继承自 stock_zh_a_spot_em_realtime，为日度或定点的行情汇总数据

**列结构**: 与 `stock_zh_a_spot_em_realtime` 相同

**索引**: symbol, trade_date, collect_time, updated_at, created_at

---

### 3.3 stock_zh_a_spot_sina_realtime - 新浪实时行情

**数据来源**: AKShare (新浪行情数据)  
**更新频率**: 实时（交易时段）  
**官方文档**: https://akshare.akfamily.xyz/data/stock/stock.html#id21  
**索引**: symbol, code, trade_date, collect_time, created_at, updated_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| collect_time | timestamp | 采集时间 |
| code | varchar(20) | 股票代码（带市场标识，如：sz000001） |
| symbol | varchar(20) | 股票代码（不带市场标识，如：000001） |
| name | varchar(40) | 股票名称 |
| latest_price | double precision | 最新价 |
| change_amount | double precision | 涨跌额 |
| change_rate | double precision | 涨跌幅（%） |
| buy_in | double precision | 买入价（买盘价） |
| sell_out | double precision | 卖出价（卖盘价） |
| pre_close | double precision | 昨收价 |
| open | double precision | 今开价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| volume | integer | 成交量 |
| turnover | double precision | 成交额 |
| data_timestamp | time | 数据时间戳 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 从新浪财经获取实时行情数据，支持高频数据采集和日内波动分析

---

## 4. 交易日历表

### 4.1 stock_trade_date - 交易日期日历

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期（仅包含实际交易日） |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, updated_at, created_at

**用途**: 定义有效交易日期，排除周末和假期

---

## 5. 盘口异动表

### 5.1 stock_change_abnormal - 盘口异动监控

**数据来源**: AKShare  
**数据说明**: 盘口异动是指股票在交易中出现的异常交易现象，包括技术形态异动、交易量异动等实时监控的市场事件

**官方文档**: https://akshare.akfamily.xyz/data/stock/stock.html#id403

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码（格式：000001.SZ） |
| date | date | 异动发生日期 |
| event_time | time | 异动发生时间 |
| name | varchar(40) | 股票名称 |
| event | varchar(40) | 异动类型，可选值包括：火箭发射、快速反弹、大笔买入、封涨停板、打开跌停板、有大买盘、竞价上涨、高开5日线、向上缺口、60日新高、60日大幅上涨、加速下跌、高台跳水、大笔卖出、封跌停板、打开涨停板、有大卖盘、竞价下跌、低开5日线、向下缺口、60日新低、60日大幅下跌 |
| attach_info | varchar(40) | 相关信息 |
| created_at | timestamp | 记录创建时间 |
| updated_at | timestamp | 记录更新时间 |
| id | serial | 主键ID |

**索引**: symbol, date, event_time, created_at, updated_at

**异动类型分类**:
- **上涨技术形态**: 火箭发射、快速反弹、高开5日线、向上缺口、60日新高、60日大幅上涨
- **交易量异动（买入）**: 大笔买入、有大买盘、竞价上涨
- **涨停相关**: 封涨停板、打开跌停板
- **下跌技术形态**: 加速下跌、高台跳水、低开5日线、向下缺口、60日新低、60日大幅下跌
- **交易量异动（卖出）**: 大笔卖出、有大卖盘、竞价下跌
- **跌停相关**: 封跌停板、打开涨停板

**用途**: 
- 追踪股票实时交易异动事件
- 识别技术形态和交易量的异常变化
- 支持事件驱动的短线策略
- 实时风险预警和监控

---

## 6. 热点数据表

### 6.1 stock_news - 股票相关新闻

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| pub_time | datetime | 发布时间 |
| title | varchar(200) | 新闻标题 |
| content | varchar(1000) | 新闻内容 |
| source | varchar(50) | 文章来源 |
| link | varchar(500) | 新闻链接 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: symbol, pub_time, updated_at, created_at

**用途**: 收集和分析与股票相关的新闻，用于舆情分析和事件追踪

---

### 6.2 stock_comment - 股票评论数据（千股千评）

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| trade_date | date | 交易日 |
| name | varchar(20) | 股票名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| turnover_rate | double precision | 换手率 |
| pe_ratio | double precision | 市盈率 |
| main_cost | double precision | 主力成本 |
| inst_own_pct | double precision | 机构参与度 |
| overall_score | double precision | 综合得分 |
| rise | integer | 上升 |
| rank | integer | 目前排名 |
| attention_index | double precision | 关注指数 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: symbol, trade_date, updated_at, created_at

**用途**: 分析投资者情绪和市场心态

---

### 6.3 stock_company_event - 上市公司事件

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| event_date | date | 事件日期 |
| date_index | integer | 当天序号 |
| name | varchar(20) | 股票名称 |
| event_type | varchar(20) | 事件类型 |
| event | varchar(5000) | 具体事项 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: symbol, event_date, created_at, updated_at

**用途**: 捕捉公司基本面事件，分析其对股价的影响

---

### 6.4 龙虎榜系列表

#### stock_lhb_detail_em - 龙虎榜详情

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 上榜日 |
| name | varchar(40) | 名称 |
| symbol | varchar(20) | 股票代码 |
| insight | varchar(300) | 解读 |
| close | double precision | 收盘价 |
| change_rate | double precision | 涨跌幅 |
| lhb_in_net | double precision | 龙虎榜净买额 |
| lhb_in_amount | double precision | 龙虎榜买入额 |
| lhb_out_amount | double precision | 龙虎榜卖出额 |
| lhb_amount | double precision | 龙虎榜成交额 |
| total_amount | double precision | 市场总成交额 |
| in_net_per | double precision | 净买额占总成交比 |
| in_amount_per | double precision | 买入额占总成交比 |
| turnover_rate | double precision | 换手率 |
| traded_market_value | double precision | 流通市值 |
| reason | varchar(400) | 上榜原因 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, insight, created_at, updated_at

---

#### stock_lhb_hyyyb_em - 龙虎榜营业部汇总

每日活跃营业部

| 列名 | 类型 | 说明 |
|------|------|------|
| yyb_symbol | varchar(20) | 营业部代码 |
| yyb_name | varchar(40) | 营业部名称 |
| trade_date | date | 上榜日 |
| buy_stock_count | integer | 买入个股数 |
| sell_stock_count | integer | 卖出个股数 |
| buy_amount_total | double precision | 买入总金额 |
| sell_amount_total | double precision | 卖出总金额 |
| net_amount_total | double precision | 总买卖净额 |
| buy_stocks | varchar(5000) | 买入股票 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, updated_at, created_at

---

#### stock_lhb_yyb_detail_em - 龙虎榜营业部详情

**数据来源**: AKShare  
**说明**: 龙虎榜上的每日营业部交易明细，包括营业部买卖的具体股票及金额

**官方文档**: https://akshare.akfamily.xyz/data/stock/stock.html#id314  
**索引**: trade_date, created_at, updated_at

| 列名 | 类型 | 说明 |
|------|------|------|
| yyb_symbol | varchar(20) | 营业部代码 |
| yyb_name | varchar(100) | 营业部名称 |
| yyb_short_name | varchar(100) | 营业部简称 |
| trade_date | date | 交易日期 |
| stock_symbol | varchar(40) | 股票代码 |
| stock_name | varchar(40) | 股票名称 |
| change_rate | double precision | 涨跌幅（%） |
| buy_amount | double precision | 买入金额（元） |
| sell_amount | double precision | 卖出金额（元） |
| net_amount | double precision | 净额（买入金额-卖出金额） |
| reason | varchar(400) | 上榜原因 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 
- 追踪主力营业部的交易行为
- 识别机构布局和主力操作
- 分析龙虎榜营业部的持仓和交易策略

---

## 7. 技术指标表

这些表来自 AKShare 的技术指标数据，用于追踪股票的技术形态和技术信号。官方文档参考：https://akshare.akfamily.xyz/data/stock/stock.html#id425

### 7.1 创新高/创新低

#### stock_rank_cxg - 创新高

**说明**: 追踪在不同时间周期内创新高的股票

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| range_type | varchar(20) | 新高类型（创月新高、半年新高、一年新高、历史新高） |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| change_rate | double precision | 涨跌幅 |
| turnover_rate | double precision | 换手率 |
| latest_price | double precision | 最新价 |
| pre_high | double precision | 前期高点 |
| pre_high_date | date | 前期高点日期 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, range_type, symbol, created_at, updated_at

**用途**: 识别突破前期高点的强势股票

---

#### stock_rank_cxd - 创新低

**说明**: 追踪在不同时间周期内创新低的股票

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| range_type | varchar(20) | 新低类型（创月新低、半年新低、一年新低、历史新低） |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| change_rate | double precision | 涨跌幅 |
| turnover_rate | double precision | 换手率 |
| latest_price | double precision | 最新价 |
| pre_low | double precision | 前期低点 |
| pre_low_date | date | 前期低点日期 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, range_type, symbol, created_at, updated_at

**用途**: 识别跌破前期低点的弱势股票

---

### 7.2 连续形态

#### stock_rank_lxsz - 连续上涨

**说明**: 追踪连续上涨的股票

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| close | double precision | 收盘价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| lz_days | integer | 连涨天数 |
| lz_change_rate | double precision | 连续涨跌幅 |
| turnover_rate | double precision | 累计换手率 |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, symbol, created_at, updated_at

**用途**: 捕捉连续上升的趋势

---

#### stock_rank_lxxd - 连续下跌

**说明**: 追踪连续下跌的股票

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| close | double precision | 收盘价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| lz_days | integer | 连涨天数 |
| lz_change_rate | double precision | 连续涨跌幅 |
| turnover_rate | double precision | 累计换手率 |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, symbol, created_at, updated_at

**用途**: 捕捉连续下降的趋势

---

### 7.3 量价形态

#### stock_rank_cxfl - 持续放量

**说明**: 追踪持续放量的股票

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| change_rate | double precision | 涨跌幅 |
| latest_price | double precision | 最新价 |
| base_date | date | 基准日 |
| fl_days | integer | 放量天数 |
| days_change_rate | double precision | 阶段涨跌幅 |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, symbol, created_at, updated_at

**用途**: 追踪持续放量的股票，量增幅升的技术信号

---

#### stock_rank_cxsl - 持续缩量

**说明**: 追踪持续缩量的股票

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| change_rate | double precision | 涨跌幅 |
| latest_price | double precision | 最新价 |
| base_date | date | 基准日 |
| sl_days | integer | 缩量天数 |
| days_change_rate | double precision | 阶段涨跌幅 |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, symbol, created_at, updated_at

**用途**: 追踪持续缩量的股票，缩量回调的技术信号

---

#### stock_rank_ljqs - 量价齐升

**说明**: 追踪量价齐升的股票

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| latest_price | double precision | 最新价 |
| qs_days | integer | 量价齐升天数 |
| days_change_rate | double precision | 阶段涨幅 |
| turnover_rate | double precision | 累计换手率 |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, symbol, created_at, updated_at

**用途**: 捕捉量价齐升的强势信号

---

#### stock_rank_ljqd - 量价齐跌

**说明**: 追踪量价齐跌的股票（成交量和股票价格同时下跌）

**官方文档**: https://akshare.akfamily.xyz/data/stock/stock.html#id435  
**索引**: trade_date, symbol, created_at, updated_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| latest_price | double precision | 最新价 |
| qd_days | integer | 量价齐跌天数 |
| days_change_rate | double precision | 阶段涨幅（%） |
| turnover_rate | double precision | 累计换手率（%） |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 捕捉量价齐跌的弱势信号，识别可能的底部或进一步下跌的风险

---

### 7.4 突破形态

#### stock_rank_xstp - 向上突破

**说明**: 追踪向上突破各均线的股票

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| range_type | varchar(20) | 突破类型（5日均线、10日均线、20日均线、30日均线、60日均线、90日均线、250日均线、500日均线） |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票简称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| turnover_rate | double precision | 换手率 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, range_type, symbol, created_at, updated_at

**用途**: 识别突破重要均线的技术信号，买入信号

---

#### stock_rank_xxtp - 向下突破

**说明**: 追踪向下突破各均线的股票

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| range_type | varchar(20) | 突破类型（5日均线、10日均线、20日均线、30日均线、60日均线、90日均线、250日均线、500日均线） |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票简称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| turnover_rate | double precision | 换手率 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, range_type, symbol, created_at, updated_at

**用途**: 识别跌破重要均线的技术信号，卖出信号

---

### 7.5 其他技术指标

#### stock_rank_xzjp - 险资举牌

**说明**: 保险公司举牌增持的公告

| 列名 | 类型 | 说明 |
|------|------|------|
| pub_date | date | 举牌公告日 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| current_price | double precision | 现价 |
| change_rate | double precision | 涨跌幅 |
| pub_owner | varchar(200) | 举牌方 |
| increase_amount | varchar(20) | 增持数量 |
| increase_amount_per | double precision | 增持数量占总股本比例 |
| total_amount | varchar(20) | 变动后持股总数 |
| total_amount_per | double precision | 变动后持股比例 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: pub_date, symbol, created_at, updated_at

**用途**: 追踪机构资金进出的重要信号

---



## 8. 个股资金流向表

### 个股资金流向表

#### stock_fund_single_intraday - 个股日内资金流向

**数据来源**: AKShare  
**说明**: 追踪单只股票日内资金流动情况，根据成交额进行流身剖析，识别资金流入和流出

**官方文档**: https://akshare.akfamily.xyz/data/stock/stock.html#id171  
**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| change_rate_rank | double precision | 当天涨跌幅排名 |
| turnover_rate | double precision | 换手率 |
| fund_in | double precision | 流入资金 |
| fund_out | double precision | 流出资金 |
| net_amount | double precision | 净额 |
| turnover | double precision | 成交额 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, symbol, updated_at, created_at

---

#### stock_fund_single_rank - 个股资金流排名

**说明**: 个股在不同时间周期内的资金流向排名，周期：3日，5日，10日，20日

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| range_type | varchar(20) | 排名周期：3日，5日，10日，20日 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 阶段涨跌幅 |
| change_rate_rank | double precision | 阶段涨跌幅排名 |
| turnover_rate | double precision | 连续换手率 |
| fund_in_net | double precision | 流入资金净额 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**索引**: trade_date, range_type, symbol, updated_at, created_at

**用途**: 识别不同周期内资金流入最多的股票

---

#### stock_fund_single_detail_intraday - 个股详细日内资金流向

**说明**: 提供资金是否进入（流入）为主，提供资金专项分类（主力、超大单、大单、中单、小单）的详细流向数据

**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅(%) |
| main_in_rank | double precision | 当天主力净流入排名 |
| main_in_net | double precision | 今日主力净流入-净额(元) |
| main_in_per | double precision | 今日主力净流入-净占比(%) |
| huge_in_net | double precision | 今日超大单净流入-净额(元) |
| huge_in_per | double precision | 今日超大单净流入-净占比(%) |
| big_in_net | double precision | 今日大单净流入-净额(元) |
| big_in_per | double precision | 今日大单净流入-净占比(%) |
| middle_in_net | double precision | 今日中单净流入-净额(元) |
| middle_in_per | double precision | 今日中单净流入-净占比(%) |
| small_in_net | double precision | 今日小单净流入-净额(元) |
| small_in_per | double precision | 今日小单净流入-净占比(%) |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**资金批量说明**:
- **主力资金**: 最大金额等级为主
- **超大单**: 单笔轮努比>在个股季度均量的 20 个（或更高）
- **大单**: 单笔轮努比在个股季度均量的 5~20 个
- **中单**: 单笔轮努比在个股季度均量的 2~5 个
- **小单**: 其他单笔

---

#### stock_fund_single_detail_rank - 个股详细资金流排名

**说明**: 详细分类资金的排名数据，按不同时间阶段排名（主力、超大单等）

**索引**: trade_date, range_type, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| range_type | varchar(20) | 排名周期：3日、5日、10日 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅(%) |
| main_in_rank | double precision | 主力净流入排名 |
| main_in_net | double precision | 主力净流入-净额(元) |
| main_in_per | double precision | 主力净流入-净占比(%) |
| huge_in_net | double precision | 超大单净流入-净额(元) |
| huge_in_per | double precision | 超大单净流入-净占比(%) |
| big_in_net | double precision | 大单净流入-净额(元) |
| big_in_per | double precision | 大单净流入-净占比(%) |
| middle_in_net | double precision | 中单净流入-净额(元) |
| middle_in_per | double precision | 中单净流入-净占比(%) |
| small_in_net | double precision | 小单净流入-净额(元) |
| small_in_per | double precision | 小单净流入-净占比(%) |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 识别不同时间段上主力资金流入最多的股票

---

#### stock_fund_single_detail_realtime - 个股实时资金流向

**说明**: 高频更新的实时资金流向数据，提供资金的分纵上流向

**索引**: trade_date, symbol, collect_time, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| collect_time | time | 采集时间 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅(%) |
| main_in_rank | double precision | 当天主力净流入排名 |
| main_in_net | double precision | 今日主力净流入-净额(元) |
| main_in_per | double precision | 今日主力净流入-净占比(%) |
| huge_in_net | double precision | 今日超大单净流入-净额(元) |
| huge_in_per | double precision | 今日超大单净流入-净占比(%) |
| big_in_net | double precision | 今日大单净流入-净额(元) |
| big_in_per | double precision | 今日大单净流入-净占比(%) |
| middle_in_net | double precision | 今日中单净流入-净额(元) |
| middle_in_per | double precision | 今日中单净流入-净占比(%) |
| small_in_net | double precision | 今日小单净流入-净额(元) |
| small_in_per | double precision | 今日小单净流入-净占比(%) |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**特点**: 
- 实时更新频率高，适合事中监控
- 两种批量模式：日内实时(高频)与季度实时(低频)的组合
| id | serial | 主ID |

**特点**: 
- 实时更新频率高，适合事中监控
- 两种批量模式：日内实时(高频)与季底实时(低频)的组合

---

### 概念板块资金流向

#### stock_fund_concept_intraday - 概念板块日内资金流向

**数据来源**: AKShare  
**说明**: 追踪概念板块日内资金流动情况，根据成交额进行流向分析，识别资金流入和流出

**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 概念板块代码 |
| name | varchar(40) | 概念板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| turnover_rate | double precision | 换手率 |
| fund_in | double precision | 流入资金 |
| fund_out | double precision | 流出资金 |
| net_amount | double precision | 净额 |
| turnover | double precision | 成交额 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 追踪概念板块整体的资金流动趋势，识别热点概念

---

#### stock_fund_concept_rank - 概念板块资金流排名

**说明**: 概念板块在不同时间周期内的资金流向排名，周期：3日、5日、10日

**索引**: trade_date, range_type, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| range_type | varchar(20) | 排名周期：3日、5日、10日 |
| symbol | varchar(20) | 概念板块代码 |
| name | varchar(40) | 概念板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 阶段涨跌幅 |
| turnover_rate | double precision | 连续换手率 |
| fund_in_net | double precision | 流入资金净额 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 识别不同周期内资金流入最多的概念板块

---

#### stock_fund_concept_detail_intraday - 概念板块详细日内资金流向

**说明**: 概念板块资金按批量等级（主力、超大单、大单、中单、小单）分类的日内详细流向

**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 概念板块代码 |
| name | varchar(40) | 概念板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅(%) |
| main_in_rank | double precision | 当天主力净流入排名 |
| main_in_net | double precision | 今日主力净流入-净额(元) |
| main_in_per | double precision | 今日主力净流入-净占比(%) |
| huge_in_net | double precision | 今日超大单净流入-净额(元) |
| huge_in_per | double precision | 今日超大单净流入-净占比(%) |
| big_in_net | double precision | 今日大单净流入-净额(元) |
| big_in_per | double precision | 今日大单净流入-净占比(%) |
| middle_in_net | double precision | 今日中单净流入-净额(元) |
| middle_in_per | double precision | 今日中单净流入-净占比(%) |
| small_in_net | double precision | 今日小单净流入-净额(元) |
| small_in_per | double precision | 今日小单净流入-净占比(%) |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 分析概念板块内机构资金和散户资金的参与情况

---

#### stock_fund_concept_detail_rank - 概念板块详细资金流排名

**说明**: 概念板块按批量等级分类的排名数据，按不同时间周期排名

**索引**: trade_date, range_type, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| range_type | varchar(20) | 排名周期：3日、5日、10日 |
| symbol | varchar(20) | 概念板块代码 |
| name | varchar(40) | 概念板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅(%) |
| main_in_rank | double precision | 主力净流入排名 |
| main_in_net | double precision | 主力净流入-净额(元) |
| main_in_per | double precision | 主力净流入-净占比(%) |
| huge_in_net | double precision | 超大单净流入-净额(元) |
| huge_in_per | double precision | 超大单净流入-净占比(%) |
| big_in_net | double precision | 大单净流入-净额(元) |
| big_in_per | double precision | 大单净流入-净占比(%) |
| middle_in_net | double precision | 中单净流入-净额(元) |
| middle_in_per | double precision | 中单净流入-净占比(%) |
| small_in_net | double precision | 小单净流入-净额(元) |
| small_in_per | double precision | 小单净流入-净占比(%) |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 识别不同周期内主力资金流入最多的概念板块

---

### 行业板块资金流向

#### stock_fund_industry_intraday - 行业板块日内资金流向

**数据来源**: AKShare  
**说明**: 追踪行业板块日内资金流动情况，根据成交额进行流向分析，识别资金流入和流出

**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 行业板块代码 |
| name | varchar(40) | 行业板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| turnover_rate | double precision | 换手率 |
| fund_in | double precision | 流入资金 |
| fund_out | double precision | 流出资金 |
| net_amount | double precision | 净额 |
| turnover | double precision | 成交额 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 追踪行业板块整体的资金流动趋势，识别热门行业

---

#### stock_fund_industry_rank - 行业板块资金流排名

**说明**: 行业板块在不同时间周期内的资金流向排名，周期：3日、5日、10日

**索引**: trade_date, range_type, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| range_type | varchar(20) | 排名周期：3日、5日、10日 |
| symbol | varchar(20) | 行业板块代码 |
| name | varchar(40) | 行业板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 阶段涨跌幅 |
| turnover_rate | double precision | 连续换手率 |
| fund_in_net | double precision | 流入资金净额 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 识别不同周期内资金流入最多的行业板块

---

#### stock_fund_industry_detail_intraday - 行业板块详细日内资金流向

**说明**: 行业板块资金按批量等级（主力、超大单、大单、中单、小单）分类的日内详细流向

**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| symbol | varchar(20) | 行业板块代码 |
| name | varchar(40) | 行业板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅(%) |
| main_in_rank | double precision | 当天主力净流入排名 |
| main_in_net | double precision | 今日主力净流入-净额(元) |
| main_in_per | double precision | 今日主力净流入-净占比(%) |
| huge_in_net | double precision | 今日超大单净流入-净额(元) |
| huge_in_per | double precision | 今日超大单净流入-净占比(%) |
| big_in_net | double precision | 今日大单净流入-净额(元) |
| big_in_per | double precision | 今日大单净流入-净占比(%) |
| middle_in_net | double precision | 今日中单净流入-净额(元) |
| middle_in_per | double precision | 今日中单净流入-净占比(%) |
| small_in_net | double precision | 今日小单净流入-净额(元) |
| small_in_per | double precision | 今日小单净流入-净占比(%) |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 分析行业板块内机构资金和散户资金的参与情况，识别行业主力布局

---

#### stock_fund_industry_detail_rank - 行业板块详细资金流排名

**说明**: 行业板块按批量等级分类的排名数据，按不同时间周期排名

**索引**: trade_date, range_type, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 日期 |
| range_type | varchar(20) | 排名周期：3日、5日、10日 |
| symbol | varchar(20) | 行业板块代码 |
| name | varchar(40) | 行业板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅(%) |
| main_in_rank | double precision | 主力净流入排名 |
| main_in_net | double precision | 主力净流入-净额(元) |
| main_in_per | double precision | 主力净流入-净占比(%) |
| huge_in_net | double precision | 超大单净流入-净额(元) |
| huge_in_per | double precision | 超大单净流入-净占比(%) |
| big_in_net | double precision | 大单净流入-净额(元) |
| big_in_per | double precision | 大单净流入-净占比(%) |
| middle_in_net | double precision | 中单净流入-净额(元) |
| middle_in_per | double precision | 中单净流入-净占比(%) |
| small_in_net | double precision | 小单净流入-净额(元) |
| small_in_per | double precision | 小单净流入-净占比(%) |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 识别不同周期内主力资金流入最多的行业板块，辅助行业选择

---

### 市场综合资金流向

#### stock_fund_big_deal - 大宗交易

**数据来源**: AKShare  
**说明**: 记录市场中单笔成交金额超过1000万元的大宗交易，反映机构投资者的大额买卖行为

**官方文档**: https://akshare.akfamily.xyz/data/stock/stock.html#id171  
**索引**: trade_date, symbol, created_at, updated_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票名称 |
| price | double precision | 成交价格 |
| volume | bigint | 成交股数 |
| amount | double precision | 成交金额（元） |
| buyer | varchar(100) | 买方营业部/席位 |
| seller | varchar(100) | 卖方营业部/席位 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 
- 追踪大机构的建仓/减仓行为
- 识别重大资金流向和持股变化
- 分析机构之间的主动性和被动性买卖

---

#### stock_fund_market_detail - 整体市场资金流向汇总

**数据来源**: AKShare  
**说明**: 提供整体市场（沪深京A股市场）的综合资金流向数据，汇总所有股票的资金流入流出

**索引**: trade_date, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| market | varchar(20) | 市场标识（如：A股全市场） |
| fund_in_total | double precision | 总流入金额（元） |
| fund_out_total | double precision | 总流出金额（元） |
| net_amount | double precision | 净流入金额（元） |
| fund_in_count | integer | 流入个股数 |
| fund_out_count | integer | 流出个股数 |
| main_in_net | double precision | 主力净流入-净额(元) |
| main_in_per | double precision | 主力净流入-净占比(%) |
| huge_in_net | double precision | 超大单净流入-净额(元) |
| huge_in_per | double precision | 超大单净流入-净占比(%) |
| big_in_net | double precision | 大单净流入-净额(元) |
| big_in_per | double precision | 大单净流入-净占比(%) |
| middle_in_net | double precision | 中单净流入-净额(元) |
| middle_in_per | double precision | 中单净流入-净占比(%) |
| small_in_net | double precision | 小单净流入-净额(元) |
| small_in_per | double precision | 小单净流入-净占比(%) |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 
- 监控整个市场的资金流动趋势
- 判断市场总体的人气和热度
- 评估机构资金的整体参与程度
- 辅助大盘走势分析和行情判断

---

## 9. 板块表

### 9.1 板块行情表

#### 概念板块

##### stock_board_concept_em - 概念板块行情

**数据来源**: 东方财富  
**说明**: 提供概念板块的日度或定点行情数据，包括价格、涨跌、资金流向等综合信息

**官方文档**: 东方财富-沪深板块-概念板块  
**索引**: symbol, trade_date, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| symbol | varchar(20) | 概念板块代码 |
| name | varchar(40) | 概念板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| change_amount | double precision | 涨跌额 |
| volume | bigint | 成交量 |
| turnover | double precision | 成交额 |
| pre_close | double precision | 昨收价 |
| open | double precision | 开盘价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| turnover_rate | double precision | 换手率 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 
- 追踪概念板块的行情走势
- 分析板块轮动规律
- 支持板块选择和轮动策略

---

##### stock_board_concept_em_realtime - 概念板块实时行情

**数据来源**: 东方财富  
**说明**: 概念板块的实时行情数据，更新频率高，提供日内波动信息

**索引**: symbol, trade_date, collect_time, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| collect_time | time | 采集时间 |
| symbol | varchar(20) | 概念板块代码 |
| name | varchar(40) | 概念板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| change_amount | double precision | 涨跌额 |
| volume | bigint | 成交量 |
| turnover | double precision | 成交额 |
| pre_close | double precision | 昨收价 |
| open | double precision | 开盘价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| turnover_rate | double precision | 换手率 |
| up_count | integer | 上涨股数 |
| down_count | integer | 下跌股数 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 
- 捕捉概念板块的日内波动
- 实时监控板块热度
- 支持日内操作和高频监控

---

#### 行业板块

##### stock_board_industry_em - 行业板块行情

**数据来源**: 东方财富  
**说明**: 提供行业板块的日度或定点行情数据，包括价格、涨跌、资金流向等综合信息

**官方文档**: 东方财富-沪深板块-行业板块  
**索引**: symbol, trade_date, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| symbol | varchar(20) | 行业板块代码 |
| name | varchar(40) | 行业板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| change_amount | double precision | 涨跌额 |
| volume | bigint | 成交量 |
| turnover | double precision | 成交额 |
| pre_close | double precision | 昨收价 |
| open | double precision | 开盘价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| turnover_rate | double precision | 换手率 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 
- 追踪行业板块的行情走势
- 分析行业轮动规律
- 支持行业选择和配置调整

---

##### stock_board_industry_em_realtime - 行业板块实时行情

**数据来源**: 东方财富  
**说明**: 行业板块的实时行情数据，更新频率高，提供日内波动信息

**索引**: symbol, trade_date, collect_time, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| collect_time | time | 采集时间 |
| symbol | varchar(20) | 行业板块代码 |
| name | varchar(40) | 行业板块名称 |
| latest_price | double precision | 最新价 |
| change_rate | double precision | 涨跌幅 |
| change_amount | double precision | 涨跌额 |
| volume | bigint | 成交量 |
| turnover | double precision | 成交额 |
| pre_close | double precision | 昨收价 |
| open | double precision | 开盘价 |
| high | double precision | 最高价 |
| low | double precision | 最低价 |
| turnover_rate | double precision | 换手率 |
| up_count | integer | 上涨股数 |
| down_count | integer | 下跌股数 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 
- 捕捉行业板块的日内波动
- 实时监控行业热度
- 支持日内操作和高频监控

---

### 9.2 板块成分表

#### stock_board_concept_cons_em - 概念板块成分股

**数据来源**: 东方财富  
**说明**: 记录每个概念板块包含的成分股，用于追踪板块内股票构成

**索引**: created_at, updated_at

| 列名 | 类型 | 说明 |
|------|------|------|
| board_name | varchar(40) | 概念板块名称 |
| board_symbol | varchar(40) | 概念板块代码 |
| stock_name | varchar(40) | 成分股名称 |
| stock_symbol | varchar(40) | 成分股代码 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 
- 追踪概念板块的成分股变化
- 识别概念内的核心股票
- 支持板块内个股筛选

---

#### stock_board_industry_cons_em - 行业板块成分股

**数据来源**: 东方财富  
**说明**: 记录每个行业板块包含的成分股，用于追踪行业内股票构成

**索引**: created_at, updated_at

| 列名 | 类型 | 说明 |
|------|------|------|
| board_name | varchar(40) | 行业板块名称 |
| board_symbol | varchar(40) | 行业板块代码 |
| stock_name | varchar(40) | 成分股名称 |
| stock_symbol | varchar(40) | 成分股代码 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**: 
- 追踪行业板块的成分股变化
- 识别行业内的核心股票
- 支持行业内个股筛选和对标分析

---

## 10. 其他表

### 10.1 stock_cyq_em - 筹码集中度分析

**数据来源**: AKShare  
**说明**: 基于历史K线数据计算股票筹码集中度，反映不同成本价格的筹码分布，用于判断主力持仓成本和筹码是否集中

**官方文档**: https://akshare.akfamily.xyz/data/stock/stock.html#id186  
**索引**: symbol, trade_date, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| symbol | varchar(20) | 股票代码 |
| trade_date | date | 交易日期 |
| name | varchar(40) | 股票名称 |
| price | double precision | 当前价格 |
| per_1 | double precision | 1%成本价（1%的筹码在此价格以下） |
| per_5 | double precision | 5%成本价 |
| per_10 | double precision | 10%成本价 |
| per_20 | double precision | 20%成本价 |
| per_30 | double precision | 30%成本价 |
| per_40 | double precision | 40%成本价 |
| per_50 | double precision | 50%成本价（中位数成本） |
| per_60 | double precision | 60%成本价 |
| per_70 | double precision | 70%成本价 |
| per_80 | double precision | 80%成本价 |
| per_90 | double precision | 90%成本价 |
| per_95 | double precision | 95%成本价 |
| per_99 | double precision | 99%成本价（99%的筹码在此价格以下） |
| highest | double precision | 历史最高价 |
| lowest | double precision | 历史最低价 |
| chip_concentration | double precision | 筹码集中度(%) |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**筹码集中度指标说明**:
- **成本价分位数**: 反映不同持仓者的平均成本，例如per_50表示50%的筹码成本在此价格以下
- **筹码集中度**: 衡量主力持仓集中程度，数值越高表示筹码越集中，主力控盘越强
- **应用场景**:
  - 筹码集中且当前价格接近底部筹码：主力可能在建仓，后期拉升概率大
  - 筹码集中且当前价格远高于底部筹码：主力可能在出货，风险较大
  - 筹码分散：市场参与度高，走势可能更波动

**用途**: 
- 判断主力筹码成本和持仓情况
- 分析筹码是否集中和主力控制力度
- 识别建仓、整理、出货等阶段
- 辅助买卖点决策

---

### 10.2 stock_pool_zt - 涨停板股票池

**数据来源**: AKShare

**说明**: 
1. `fin_store_schema.sql`（简化版本）中数据结构为 `trade_date` + `symbol`。
2. `docs/fin_store_complete_schema.sql` 与 ORM 模型 `data/raw/models/stock_pool_zt.py` 提供完整字段定义。可用于短线涨停追踪、封板统计与连板策略。

**官方文档**: https://akshare.akfamily.xyz/data/stock/stock.html#id405

**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票简称 |
| change_rate | double precision | 涨跌幅 |
| latest_price | double precision | 最新价 |
| turnover | double precision | 成交额 |
| traded_market_value | double precision | 流通市值 |
| market_value | double precision | 总市值 |
| turnover_rate | double precision | 换手率 |
| fb_fund | double precision | 封板资金 |
| fb_first_time | time | 首次封板时间 |
| fb_last_time | time | 最后封板时间 |
| zb_count | integer | 炸板次数 |
| zt_status | varchar(20) | 涨停状态（如：一字板/打板/已打开） |
| lb_count | integer | 连板数 |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**应用场景**:
- 涨停/连板股池快速筛选与策略信号输入
- 封板时间点 与 资金位置（fb_fund）分析
- 追踪炸板次数与强弱换手结构
- 行业轮动与涨停池风格切换

**用途**:
- 日内/日末涨停股票池生成、筛选与过虑
- 长短周期连板股统计与复盘
- 风险控制：炸板次数、封板时间与换手率滤网
- 支持直连回测与策略训练数据集构建

---

### 10.2.1 stock_pool_strong - 强势股票池

**数据来源**: AKShare

**说明**: 记录当日强势股，包含涨停价、量价、风格信号。

**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票简称 |
| change_rate | double precision | 涨跌幅 |
| latest_price | double precision | 最新价 |
| zt_price | double precision | 涨停价 |
| turnover | double precision | 成交额 |
| traded_market_value | double precision | 流通市值 |
| market_value | double precision | 总市值 |
| turnover_rate | double precision | 换手率 |
| up_speed | double precision | 涨速 |
| is_new_high | varchar(20) | 是否新高 |
| volume_ratio | double precision | 量比 |
| zt_status | varchar(20) | 涨停状态 |
| reason | varchar(20) | 涨停原因 |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**:
- 识别今日市场强势风口
- 结合涨停状态与量比进行买点过滤

---

### 10.2.2 stock_pool_sub_new - 次新股票池

**数据来源**: AKShare

**说明**: 记录当日次新股池，包含上市天数、破板反弹等窗口信息。

**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票简称 |
| change_rate | double precision | 涨跌幅 |
| latest_price | double precision | 最新价 |
| zt_price | double precision | 涨停价 |
| turnover | double precision | 成交额 |
| traded_market_value | double precision | 流通市值 |
| market_value | double precision | 总市值 |
| turnover_rate | double precision | 换手率 |
| kb_days | integer | 科创板上市天数/次新天数 |
| kb_date | date | 上市日期 |
| offering_date | date | 首发日期 |
| is_new_high | varchar(20) | 是否新高 |
| zt_status | varchar(20) | 涨停状态 |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**:
- 次新股筛选、估值溢价、回归策略研究

---

### 10.2.3 stock_pool_zb - 炸板股票池

**数据来源**: AKShare

**说明**: 记录当日炸板股票与反弹信誉指标，侧重高风险打板监控。

**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票简称 |
| change_rate | double precision | 涨跌幅 |
| latest_price | double precision | 最新价 |
| zt_price | double precision | 涨停价 |
| turnover | double precision | 成交额 |
| traded_market_value | double precision | 流通市值 |
| market_value | double precision | 总市值 |
| turnover_rate | double precision | 换手率 |
| up_speed | double precision | 涨速 |
| fb_first_time | time | 首次封板时间 |
| zb_count | integer | 炸板次数 |
| zt_status | varchar(20) | 涨停状态 |
| range | double precision | 振幅 |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**:
- 炸板频率与风险控制，避免短线高弹性个股追涨

---

### 10.2.4 stock_pool_dt - 跌停股票池

**数据来源**: AKShare

**说明**: 记录当日跌停股票池，包含跌停价、量价和市场风险警示数据。

**索引**: trade_date, symbol, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| symbol | varchar(20) | 股票代码 |
| name | varchar(40) | 股票简称 |
| change_rate | double precision | 涨跌幅 |
| latest_price | double precision | 最新价 |
| turnover | double precision | 成交额 |
| traded_market_value | double precision | 流通市值 |
| market_value | double precision | 总市值 |
| forward_pe_ratio | double precision | 预测市盈率 |
| turnover_rate | double precision | 换手率 |
| fd_fund | double precision | 跌停资金（或封单资金） |
| fb_last_time | time | 最后封板时间 |
| bs_turnover | double precision | 买卖成交额 |
| lb_count | integer | 连板数 |
| kb_count | integer | 开板次数 |
| industry | varchar(50) | 所属行业 |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**用途**:
- 跌停风险监控、低位抄底筛选、市场恐慌度评估
- 结合连板/科创次新信息防范尾盘炸板

---

### 10.3 stock_market_activity_realtime - 市场活跃度实时数据

**数据来源**: AKShare  
**说明**: 实时监控市场整体的交易活跃程度，包括上涨下跌统计、成交量额等宏观指标

**索引**: trade_date, collect_time, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期 |
| collect_time | timestamp | 采集时间 |
| total_volume | bigint | 总成交量（股） |
| total_amount | double precision | 总成交额（元） |
| up_count | integer | 上涨个股数 |
| down_count | integer | 下跌个股数 |
| unchanged_count | integer | 平盘个股数 |
| up_ratio | double precision | 上涨个股占比(%) |
| down_ratio | double precision | 下跌个股占比(%) |
| limit_up_count | integer | 涨停个股数 |
| limit_down_count | integer | 跌停个股数 |
| avg_turnover_rate | double precision | 平均换手率(%) |
| market_sentiment | varchar(20) | 市场情绪（强势/中性/弱势） |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**市场情绪判断标准**:
- **强势**: 上涨股数占比>55%，涨停>跌停，成交热度高
- **中性**: 上涨股数占比45%-55%，涨停≈跌停，成交正常
- **弱势**: 上涨股数占比<45%，涨停<跌停，成交冷清

**用途**: 
- 监控市场整体参与度和人气
- 判断市场的强弱和转折点
- 参考大盘走势和风险预警
- 辅助择时决策

---

### 10.4 stock_trade_date - 交易日期日历

**数据来源**: AKShare  
**说明**: 定义沪深两市的实际交易日期，排除周末和非交易假期，用于数据对齐和回测

**索引**: trade_date, updated_at, created_at

| 列名 | 类型 | 说明 |
|------|------|------|
| trade_date | date | 交易日期（仅包含实际交易日） |
| week_day | varchar(10) | 星期几（Monday-Sunday） |
| is_holiday | integer | 是否假期（0:正常交易，1:假期） |
| holiday_name | varchar(40) | 假期名称（如春节、端午节等） |
| created_at | timestamp | 创建时间 |
| updated_at | timestamp | 更新时间 |
| id | serial | 主键ID |

**应用场景**:
- **数据对齐**: 确保K线数据和其他日频数据使用的日期一致
- **时间序列分析**: 排除非交易日，保证时间序列的连续性
- **策略回测**: 确保回测中的持仓和交易时点准确有效
- **报告生成**: 明确报告统计周期的起止交易日

**用途**: 
- 定义有效交易日期，排除周末和假期
- 支持时间序列处理和数据对齐
- 辅助回测框架的日期管理
- 生成准确的交易报告

---

## 11. 数据字段类型说明

| 类型 | 说明 | 示例 |
|------|------|------|
| varchar(n) | 可变长字符串 | '000001.SZ' |
| date | 日期类型 | 2024-01-02 |
| time | 时间类型 | 15:30:45 |
| timestamp | 时间戳 | 2024-01-02 15:30:45 |
| datetime | 日期时间 | 2024-01-02 15:30:45 |
| double precision | 双精度浮点数 | 15.87, 100.5 |
| integer | 整数 | 1000, 50 |
| bigint | 大整数 | 10000000 |
| serial | 自增序列 | 1, 2, 3, ... |

---

## 12. 索引设计原则

已建立的索引涵盖以下主要查询模式：

1. **按代码查询**：symbol, code 列索引
2. **按日期范围查询**：date, trade_date, pub_time 列索引
3. **按时间戳查询**：created_at, updated_at 列索引
4. **复合查询**：多列组合索引

总计**223个索引**，充分支持常见查询场景。

---

## 13. 数据量级参考

| 表类别 | 预计行数 | 增长速度 |
|--------|---------|---------|
| K线表（stock_history*） | ~10M行/表 | 日增3000-5000行 |
| 实时行情 | ~100M行 | 日增100K-500K行 |
| 龙虎榜 | ~100K行 | 日增100-200行 |
| 资金流向 | ~50M行 | 日增50K-100K行 |
| 排名表 | ~5M行 | 日增1K-5K行 |
| 板块数据 | ~100K行 | 日增100-500行 |
| 账户数据 | 动态 | 交易时增长 |

---

**文档更新日期**: 2024年3月22日  
**文档版本**: 1.9 - 完善第8-10章详细表定义，补充32个表的完整字段说明和元数据

