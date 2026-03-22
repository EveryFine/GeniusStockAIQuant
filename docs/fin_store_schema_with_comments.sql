-- ============================================================================
-- GeniusStockAIQuant 数据库 DDL 定义（带中文注释）
-- 数据库名: fin_store
-- 用途: A股市场量化交易数据存储
-- 数据来源: AKShare (主要), BaoStock (K线数据)
-- ============================================================================

CREATE DATABASE fin_store WITH OWNER myuser;

-- ============================================================================
-- 基础信息表
-- ============================================================================

-- 证券交易所信息
CREATE TABLE public.stock_exchange (
    name VARCHAR(120) NOT NULL
);
COMMENT ON TABLE public.stock_exchange IS '证券交易所信息（如：上海证券交易所、深圳证券交易所）';
COMMENT ON COLUMN public.stock_exchange.name IS '交易所名称';
ALTER TABLE public.stock_exchange OWNER TO myuser;

-- 股票基本信息
CREATE TABLE public.stock_info (
    market_value DOUBLE PRECISION
);
COMMENT ON TABLE public.stock_info IS '股票基本信息表，包含市值等基本面数据';
COMMENT ON COLUMN public.stock_info.market_value IS '市值（单位：元）';
ALTER TABLE public.stock_info OWNER TO myuser;

-- 艺术品相关信息（扩展表）
CREATE TABLE public.artist (
    name VARCHAR(120) NOT NULL
);
COMMENT ON TABLE public.artist IS '艺术品相关信息表';
COMMENT ON COLUMN public.artist.name IS '艺术家或作品名称';
ALTER TABLE public.artist OWNER TO myuser;

-- ============================================================================
-- 价格数据表 - AKShare数据源
-- ============================================================================

-- 股票日K线数据（原始价格）
CREATE TABLE public.stock_history (
    symbol VARCHAR(20) NOT NULL,
    date DATE,
    open DOUBLE PRECISION,
    high DOUBLE PRECISION,
    low DOUBLE PRECISION,
    close DOUBLE PRECISION,
    vol DOUBLE PRECISION,
    amount DOUBLE PRECISION
);
COMMENT ON TABLE public.stock_history IS '股票日K线数据（原始价格）- AKShare数据源';
COMMENT ON COLUMN public.stock_history.symbol IS '股票代码（格式：000001.SZ）';
COMMENT ON COLUMN public.stock_history.date IS '交易日期';
COMMENT ON COLUMN public.stock_history.open IS '开盘价（元）';
COMMENT ON COLUMN public.stock_history.high IS '最高价（元）';
COMMENT ON COLUMN public.stock_history.low IS '最低价（元）';
COMMENT ON COLUMN public.stock_history.close IS '收盘价（元）';
COMMENT ON COLUMN public.stock_history.vol IS '成交量（手）';
COMMENT ON COLUMN public.stock_history.amount IS '成交额（元）';
ALTER TABLE public.stock_history OWNER TO myuser;
CREATE INDEX ix_stock_history_date ON public.stock_history (date);
CREATE INDEX ix_stock_history_symbol ON public.stock_history (symbol);

-- 股票日K线数据（前复权）
CREATE TABLE public.stock_history_qfq (
    symbol VARCHAR(20) NOT NULL,
    date DATE,
    open DOUBLE PRECISION,
    high DOUBLE PRECISION,
    low DOUBLE PRECISION,
    close DOUBLE PRECISION,
    vol DOUBLE PRECISION,
    amount DOUBLE PRECISION
);
COMMENT ON TABLE public.stock_history_qfq IS '股票日K线数据（前复权）- 向前复权处理，适合长期回测';
COMMENT ON COLUMN public.stock_history_qfq.symbol IS '股票代码';
ALTER TABLE public.stock_history_qfq OWNER TO myuser;
CREATE INDEX ix_stock_history_qfq_date ON public.stock_history_qfq (date);

-- 股票日K线数据（后复权）
CREATE TABLE public.stock_history_hfq (
    symbol VARCHAR(20) NOT NULL,
    date DATE,
    open DOUBLE PRECISION,
    high DOUBLE PRECISION,
    low DOUBLE PRECISION,
    close DOUBLE PRECISION,
    vol DOUBLE PRECISION,
    amount DOUBLE PRECISION
);
COMMENT ON TABLE public.stock_history_hfq IS '股票日K线数据（后复权）- 向后复权处理，保留最近价格原始值';
COMMENT ON COLUMN public.stock_history_hfq.symbol IS '股票代码';
ALTER TABLE public.stock_history_hfq OWNER TO myuser;

-- ============================================================================
-- 价格数据表 - BaoStock数据源
-- ============================================================================

-- BaoStock K线数据（原始价格）
CREATE TABLE public.stock_history_bao_k (
    code VARCHAR(20) NOT NULL,
    date DATE,
    open DOUBLE PRECISION,
    high DOUBLE PRECISION,
    low DOUBLE PRECISION,
    close DOUBLE PRECISION,
    vol DOUBLE PRECISION,
    amount DOUBLE PRECISION
);
COMMENT ON TABLE public.stock_history_bao_k IS 'BaoStock K线数据（原始价格）';
COMMENT ON COLUMN public.stock_history_bao_k.code IS '股票代码（BaoStock格式：sh.600000）';
ALTER TABLE public.stock_history_bao_k OWNER TO myuser;
CREATE INDEX ix_stock_history_bao_k_date ON public.stock_history_bao_k (date);
CREATE INDEX ix_stock_history_bao_k_code ON public.stock_history_bao_k (code);

-- BaoStock K线数据（前复权）
CREATE TABLE public.stock_history_bao_k_qfq (
    code VARCHAR(20) NOT NULL,
    date DATE
);
COMMENT ON TABLE public.stock_history_bao_k_qfq IS 'BaoStock K线数据（前复权）';
ALTER TABLE public.stock_history_bao_k_qfq OWNER TO myuser;
CREATE INDEX ix_stock_history_bao_k_qfq_date ON public.stock_history_bao_k_qfq (date);
CREATE INDEX ix_stock_history_bao_k_qfq_code ON public.stock_history_bao_k_qfq (code);

-- BaoStock K线数据（后复权）
CREATE TABLE public.stock_history_bao_k_hfq (
    code VARCHAR(20) NOT NULL,
    date DATE
);
COMMENT ON TABLE public.stock_history_bao_k_hfq IS 'BaoStock K线数据（后复权）';
ALTER TABLE public.stock_history_bao_k_hfq OWNER TO myuser;
CREATE INDEX ix_stock_history_bao_k_hfq_date ON public.stock_history_bao_k_hfq (date);
CREATE INDEX ix_stock_history_bao_k_hfq_code ON public.stock_history_bao_k_hfq (code);

-- ============================================================================
-- 实时行情表
-- ============================================================================

-- 实时行情数据（东财）
CREATE TABLE public.stock_zh_a_spot_em_realtime (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_zh_a_spot_em_realtime IS '实时行情数据（东财）- 交易时段实时更新';
COMMENT ON COLUMN public.stock_zh_a_spot_em_realtime.symbol IS '股票代码';
COMMENT ON COLUMN public.stock_zh_a_spot_em_realtime.trade_date IS '交易日期';
ALTER TABLE public.stock_zh_a_spot_em_realtime OWNER TO myuser;
CREATE INDEX ix_stock_zh_a_spot_em_realtime_symbol ON public.stock_zh_a_spot_em_realtime (symbol);
CREATE INDEX ix_stock_zh_a_spot_em_realtime_trade_date ON public.stock_zh_a_spot_em_realtime (trade_date);

-- 东财实时行情快照
CREATE TABLE public.stock_zh_a_spot_em (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_zh_a_spot_em IS '东财行情快照 - 日度或定点汇总';
ALTER TABLE public.stock_zh_a_spot_em OWNER TO myuser;
CREATE INDEX ix_stock_zh_a_spot_em_symbol ON public.stock_zh_a_spot_em (symbol);
CREATE INDEX ix_stock_zh_a_spot_em_trade_date ON public.stock_zh_a_spot_em (trade_date);

-- 新浪实时行情
CREATE TABLE public.stock_zh_a_spot_sina_realtime (
    symbol VARCHAR(20),
    code VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_zh_a_spot_sina_realtime IS '新浪实时行情数据 - 作为东财数据补充';
COMMENT ON COLUMN public.stock_zh_a_spot_sina_realtime.symbol IS '标准股票代码';
COMMENT ON COLUMN public.stock_zh_a_spot_sina_realtime.code IS '新浪股票代码';
ALTER TABLE public.stock_zh_a_spot_sina_realtime OWNER TO myuser;
CREATE INDEX ix_stock_zh_a_spot_sina_realtime_symbol ON public.stock_zh_a_spot_sina_realtime (symbol);
CREATE INDEX ix_stock_zh_a_spot_sina_realtime_code ON public.stock_zh_a_spot_sina_realtime (code);

-- ============================================================================
-- 交易日历表
-- ============================================================================

-- 交易日期日历
CREATE TABLE public.stock_trade_date (
    trade_date DATE NOT NULL
);
COMMENT ON TABLE public.stock_trade_date IS '交易日期日历 - 仅包含实际交易日（排除周末和假期）';
COMMENT ON COLUMN public.stock_trade_date.trade_date IS '交易日期';
ALTER TABLE public.stock_trade_date OWNER TO myuser;
CREATE INDEX ix_stock_trade_date_trade_date ON public.stock_trade_date (trade_date);

-- ============================================================================
-- 异常波动表
-- ============================================================================

-- 异常波动监控
CREATE TABLE public.stock_change_abnormal (
    symbol VARCHAR(20) NOT NULL,
    date DATE,
    event_time TIMESTAMP
);
COMMENT ON TABLE public.stock_change_abnormal IS '异常波动监控 - 追踪异常价格波动事件';
COMMENT ON COLUMN public.stock_change_abnormal.symbol IS '股票代码';
COMMENT ON COLUMN public.stock_change_abnormal.date IS '异常发生日期';
COMMENT ON COLUMN public.stock_change_abnormal.event_time IS '异常发生时间';
ALTER TABLE public.stock_change_abnormal OWNER TO myuser;
CREATE INDEX ix_stock_change_abnormal_symbol ON public.stock_change_abnormal (symbol);
CREATE INDEX ix_stock_change_abnormal_date ON public.stock_change_abnormal (date);
CREATE INDEX ix_stock_change_abnormal_event_time ON public.stock_change_abnormal (event_time);

-- ============================================================================
-- 热点数据表
-- ============================================================================

-- 股票相关新闻
CREATE TABLE public.stock_news (
    symbol VARCHAR(20) NOT NULL,
    pub_time TIMESTAMP
);
COMMENT ON TABLE public.stock_news IS '股票相关新闻 - 用于舆情分析和事件追踪';
COMMENT ON COLUMN public.stock_news.symbol IS '相关股票代码';
COMMENT ON COLUMN public.stock_news.pub_time IS '新闻发布时间';
ALTER TABLE public.stock_news OWNER TO myuser;
CREATE INDEX ix_stock_news_symbol ON public.stock_news (symbol);
CREATE INDEX ix_stock_news_pub_time ON public.stock_news (pub_time);

-- 股票评论数据
CREATE TABLE public.stock_comment (
    symbol VARCHAR(20) NOT NULL,
    trade_date DATE
);
COMMENT ON TABLE public.stock_comment IS '股票评论数据 - 分析投资者情绪';
COMMENT ON COLUMN public.stock_comment.symbol IS '股票代码';
COMMENT ON COLUMN public.stock_comment.trade_date IS '交易日期';
ALTER TABLE public.stock_comment OWNER TO myuser;
CREATE INDEX ix_stock_comment_symbol ON public.stock_comment (symbol);
CREATE INDEX ix_stock_comment_trade_date ON public.stock_comment (trade_date);

-- 上市公司事件
CREATE TABLE public.stock_company_event (
    symbol VARCHAR(20) NOT NULL,
    event_date DATE
);
COMMENT ON TABLE public.stock_company_event IS '上市公司事件 - 捕捉公司基本面事件';
COMMENT ON COLUMN public.stock_company_event.symbol IS '股票代码';
COMMENT ON COLUMN public.stock_company_event.event_date IS '事件发生日期';
ALTER TABLE public.stock_company_event OWNER TO myuser;
CREATE INDEX ix_stock_company_event_symbol ON public.stock_company_event (symbol);
CREATE INDEX ix_stock_company_event_event_date ON public.stock_company_event (event_date);

-- 龙虎榜详情
CREATE TABLE public.stock_lhb_detail_em (
    trade_date DATE,
    insight VARCHAR
);
COMMENT ON TABLE public.stock_lhb_detail_em IS '龙虎榜详情 - 追踪游资和机构动向';
COMMENT ON COLUMN public.stock_lhb_detail_em.trade_date IS '交易日期';
COMMENT ON COLUMN public.stock_lhb_detail_em.insight IS '龙虎榜分析';
ALTER TABLE public.stock_lhb_detail_em OWNER TO myuser;
CREATE INDEX ix_stock_lhb_detail_em_trade_date ON public.stock_lhb_detail_em (trade_date);
CREATE INDEX ix_stock_lhb_detail_em_insight ON public.stock_lhb_detail_em (insight);

-- 龙虎榜营业部汇总
CREATE TABLE public.stock_lhb_hyyyb_em (
    yyb_symbol VARCHAR(20) NOT NULL,
    trade_date DATE
);
COMMENT ON TABLE public.stock_lhb_hyyyb_em IS '龙虎榜营业部汇总 - 统计营业部出现频率';
ALTER TABLE public.stock_lhb_hyyyb_em OWNER TO myuser;
CREATE INDEX ix_stock_lhb_hyyyb_em_trade_date ON public.stock_lhb_hyyyb_em (trade_date);

-- 龙虎榜营业部详情
CREATE TABLE public.stock_lhb_yyb_detail_em (
    yyb_symbol VARCHAR(20) NOT NULL,
    trade_date DATE
);
COMMENT ON TABLE public.stock_lhb_yyb_detail_em IS '龙虎榜营业部详情 - 营业部交易明细';
ALTER TABLE public.stock_lhb_yyb_detail_em OWNER TO myuser;
CREATE INDEX ix_stock_lhb_yyb_detail_em_trade_date ON public.stock_lhb_yyb_detail_em (trade_date);

-- ============================================================================
-- 股票排名表
-- ============================================================================

-- 换手率排名（股数）
CREATE TABLE public.stock_rank_cxg (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_rank_cxg IS '换手率排名（股数） - 按range_type区分时间范围（日/周/月）';
ALTER TABLE public.stock_rank_cxg OWNER TO myuser;
CREATE INDEX ix_stock_rank_cxg_symbol ON public.stock_rank_cxg (symbol);
CREATE INDEX ix_stock_rank_cxg_trade_date ON public.stock_rank_cxg (trade_date);
CREATE INDEX ix_stock_rank_cxg_range_type ON public.stock_rank_cxg (range_type);

-- 换手率排名（百分比）
CREATE TABLE public.stock_rank_cxd (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_rank_cxd IS '换手率排名（百分比）';
ALTER TABLE public.stock_rank_cxd OWNER TO myuser;
CREATE INDEX ix_stock_rank_cxd_symbol ON public.stock_rank_cxd (symbol);
CREATE INDEX ix_stock_rank_cxd_trade_date ON public.stock_rank_cxd (trade_date);
CREATE INDEX ix_stock_rank_cxd_range_type ON public.stock_rank_cxd (range_type);

-- 连续上升周数排名
CREATE TABLE public.stock_rank_lxsz (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_rank_lxsz IS '连续上升周数排名';
ALTER TABLE public.stock_rank_lxsz OWNER TO myuser;
CREATE INDEX ix_stock_rank_lxsz_symbol ON public.stock_rank_lxsz (symbol);
CREATE INDEX ix_stock_rank_lxsz_trade_date ON public.stock_rank_lxsz (trade_date);

-- 连续下降周数排名
CREATE TABLE public.stock_rank_lxxd (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_rank_lxxd IS '连续下降周数排名';
ALTER TABLE public.stock_rank_lxxd OWNER TO myuser;
CREATE INDEX ix_stock_rank_lxxd_symbol ON public.stock_rank_lxxd (symbol);
CREATE INDEX ix_stock_rank_lxxd_trade_date ON public.stock_rank_lxxd (trade_date);

-- 涨幅排名
CREATE TABLE public.stock_rank_cxfl (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_rank_cxfl IS '涨幅排名';
ALTER TABLE public.stock_rank_cxfl OWNER TO myuser;
CREATE INDEX ix_stock_rank_cxfl_symbol ON public.stock_rank_cxfl (symbol);
CREATE INDEX ix_stock_rank_cxfl_trade_date ON public.stock_rank_cxfl (trade_date);
CREATE INDEX ix_stock_rank_cxfl_range_type ON public.stock_rank_cxfl (range_type);

-- 跌幅排名
CREATE TABLE public.stock_rank_cxsl (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_rank_cxsl IS '跌幅排名';
ALTER TABLE public.stock_rank_cxsl OWNER TO myuser;
CREATE INDEX ix_stock_rank_cxsl_symbol ON public.stock_rank_cxsl (symbol);
CREATE INDEX ix_stock_rank_cxsl_trade_date ON public.stock_rank_cxsl (trade_date);
CREATE INDEX ix_stock_rank_cxsl_range_type ON public.stock_rank_cxsl (range_type);

-- 新股高点排名
CREATE TABLE public.stock_rank_xstp (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_rank_xstp IS '新股高点排名';
ALTER TABLE public.stock_rank_xstp OWNER TO myuser;
CREATE INDEX ix_stock_rank_xstp_symbol ON public.stock_rank_xstp (symbol);
CREATE INDEX ix_stock_rank_xstp_trade_date ON public.stock_rank_xstp (trade_date);
CREATE INDEX ix_stock_rank_xstp_range_type ON public.stock_rank_xstp (range_type);

-- 新股低点排名
CREATE TABLE public.stock_rank_xxtp (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_rank_xxtp IS '新股低点排名';
ALTER TABLE public.stock_rank_xxtp OWNER TO myuser;
CREATE INDEX ix_stock_rank_xxtp_symbol ON public.stock_rank_xxtp (symbol);
CREATE INDEX ix_stock_rank_xxtp_trade_date ON public.stock_rank_xxtp (trade_date);
CREATE INDEX ix_stock_rank_xxtp_range_type ON public.stock_rank_xxtp (range_type);

-- 连续上升成交额排名
CREATE TABLE public.stock_rank_ljqs (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_rank_ljqs IS '连续上升成交额排名';
ALTER TABLE public.stock_rank_ljqs OWNER TO myuser;
CREATE INDEX ix_stock_rank_ljqs_symbol ON public.stock_rank_ljqs (symbol);
CREATE INDEX ix_stock_rank_ljqs_trade_date ON public.stock_rank_ljqs (trade_date);

-- 连续下降成交额排名
CREATE TABLE public.stock_rank_ljqd (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_rank_ljqd IS '连续下降成交额排名';
ALTER TABLE public.stock_rank_ljqd OWNER TO myuser;
CREATE INDEX ix_stock_rank_ljqd_symbol ON public.stock_rank_ljqd (symbol);
CREATE INDEX ix_stock_rank_ljqd_trade_date ON public.stock_rank_ljqd (trade_date);

-- 限制涨停排名
CREATE TABLE public.stock_rank_xzjp (
    symbol VARCHAR(20),
    pub_date DATE
);
COMMENT ON TABLE public.stock_rank_xzjp IS '涨停板股票排名';
ALTER TABLE public.stock_rank_xzjp OWNER TO myuser;
CREATE INDEX ix_stock_rank_xzjp_symbol ON public.stock_rank_xzjp (symbol);
CREATE INDEX ix_stock_rank_xzjp_pub_date ON public.stock_rank_xzjp (pub_date);

-- ============================================================================
-- 基金流向表
-- ============================================================================

-- 概念板块日内基金流
CREATE TABLE public.stock_fund_concept_intraday (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_fund_concept_intraday IS '概念板块日内基金流向';
ALTER TABLE public.stock_fund_concept_intraday OWNER TO myuser;
CREATE INDEX ix_stock_fund_concept_intraday_trade_date ON public.stock_fund_concept_intraday (trade_date);

-- 概念板块基金流排名
CREATE TABLE public.stock_fund_concept_rank (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_fund_concept_rank IS '概念板块基金流排名';
ALTER TABLE public.stock_fund_concept_rank OWNER TO myuser;
CREATE INDEX ix_stock_fund_concept_rank_trade_date ON public.stock_fund_concept_rank (trade_date);
CREATE INDEX ix_stock_fund_concept_rank_range_type ON public.stock_fund_concept_rank (range_type);

-- 行业板块日内基金流
CREATE TABLE public.stock_fund_industry_intraday (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_fund_industry_intraday IS '行业板块日内基金流向';
ALTER TABLE public.stock_fund_industry_intraday OWNER TO myuser;
CREATE INDEX ix_stock_fund_industry_intraday_trade_date ON public.stock_fund_industry_intraday (trade_date);

-- 行业板块基金流排名
CREATE TABLE public.stock_fund_industry_rank (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_fund_industry_rank IS '行业板块基金流排名';
ALTER TABLE public.stock_fund_industry_rank OWNER TO myuser;
CREATE INDEX ix_stock_fund_industry_rank_trade_date ON public.stock_fund_industry_rank (trade_date);
CREATE INDEX ix_stock_fund_industry_rank_range_type ON public.stock_fund_industry_rank (range_type);

-- 大宗交易
CREATE TABLE public.stock_fund_big_deal (
    symbol VARCHAR(20),
    trade_date DATE,
    trade_time TIMESTAMP
);
COMMENT ON TABLE public.stock_fund_big_deal IS '大宗交易 - 监控大宗交易，识别机构动向';
ALTER TABLE public.stock_fund_big_deal OWNER TO myuser;
CREATE INDEX ix_stock_fund_big_deal_symbol ON public.stock_fund_big_deal (symbol);
CREATE INDEX ix_stock_fund_big_deal_trade_date ON public.stock_fund_big_deal (trade_date);
CREATE INDEX ix_stock_fund_big_deal_trade_time ON public.stock_fund_big_deal (trade_time);

-- 个股日内基金流
CREATE TABLE public.stock_fund_single_intraday (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_fund_single_intraday IS '个股日内基金流向';
ALTER TABLE public.stock_fund_single_intraday OWNER TO myuser;
CREATE INDEX ix_stock_fund_single_intraday_symbol ON public.stock_fund_single_intraday (symbol);
CREATE INDEX ix_stock_fund_single_intraday_trade_date ON public.stock_fund_single_intraday (trade_date);

-- 个股基金流排名
CREATE TABLE public.stock_fund_single_rank (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_fund_single_rank IS '个股基金流排名';
ALTER TABLE public.stock_fund_single_rank OWNER TO myuser;
CREATE INDEX ix_stock_fund_single_rank_symbol ON public.stock_fund_single_rank (symbol);
CREATE INDEX ix_stock_fund_single_rank_trade_date ON public.stock_fund_single_rank (trade_date);
CREATE INDEX ix_stock_fund_single_rank_range_type ON public.stock_fund_single_rank (range_type);

-- 个股详细日内基金流
CREATE TABLE public.stock_fund_single_detail_intraday (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_fund_single_detail_intraday IS '个股详细日内基金流向';
ALTER TABLE public.stock_fund_single_detail_intraday OWNER TO myuser;
CREATE INDEX ix_stock_fund_single_detail_intraday_symbol ON public.stock_fund_single_detail_intraday (symbol);
CREATE INDEX ix_stock_fund_single_detail_intraday_trade_date ON public.stock_fund_single_detail_intraday (trade_date);

-- 个股详细基金流排名
CREATE TABLE public.stock_fund_single_detail_rank (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_fund_single_detail_rank IS '个股详细基金流排名';
ALTER TABLE public.stock_fund_single_detail_rank OWNER TO myuser;
CREATE INDEX ix_stock_fund_single_detail_rank_symbol ON public.stock_fund_single_detail_rank (symbol);
CREATE INDEX ix_stock_fund_single_detail_rank_trade_date ON public.stock_fund_single_detail_rank (trade_date);
CREATE INDEX ix_stock_fund_single_detail_rank_range_type ON public.stock_fund_single_detail_rank (range_type);

-- 个股实时基金流
CREATE TABLE public.stock_fund_single_detail_realtime (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_fund_single_detail_realtime IS '个股实时基金流向 - 高频更新';
ALTER TABLE public.stock_fund_single_detail_realtime OWNER TO myuser;
CREATE INDEX ix_stock_fund_single_detail_realtime_symbol ON public.stock_fund_single_detail_realtime (symbol);
CREATE INDEX ix_stock_fund_single_detail_realtime_trade_date ON public.stock_fund_single_detail_realtime (trade_date);

-- 市场资金流向详情
CREATE TABLE public.stock_fund_market_detail (
    trade_date DATE
);
COMMENT ON TABLE public.stock_fund_market_detail IS '整体市场资金流向汇总';
ALTER TABLE public.stock_fund_market_detail OWNER TO myuser;
CREATE INDEX ix_stock_fund_market_detail_trade_date ON public.stock_fund_market_detail (trade_date);

-- 概念板块详细日内基金流
CREATE TABLE public.stock_fund_concept_detail_intraday (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_fund_concept_detail_intraday IS '概念板块详细日内基金流向';
ALTER TABLE public.stock_fund_concept_detail_intraday OWNER TO myuser;
CREATE INDEX ix_stock_fund_concept_detail_intraday_trade_date ON public.stock_fund_concept_detail_intraday (trade_date);

-- 概念板块详细基金流排名
CREATE TABLE public.stock_fund_concept_detail_rank (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_fund_concept_detail_rank IS '概念板块详细基金流排名';
ALTER TABLE public.stock_fund_concept_detail_rank OWNER TO myuser;
CREATE INDEX ix_stock_fund_concept_detail_rank_trade_date ON public.stock_fund_concept_detail_rank (trade_date);
CREATE INDEX ix_stock_fund_concept_detail_rank_range_type ON public.stock_fund_concept_detail_rank (range_type);

-- 行业板块详细日内基金流
CREATE TABLE public.stock_fund_industry_detail_intraday (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_fund_industry_detail_intraday IS '行业板块详细日内基金流向';
ALTER TABLE public.stock_fund_industry_detail_intraday OWNER TO myuser;
CREATE INDEX ix_stock_fund_industry_detail_intraday_trade_date ON public.stock_fund_industry_detail_intraday (trade_date);

-- 行业板块详细基金流排名
CREATE TABLE public.stock_fund_industry_detail_rank (
    symbol VARCHAR(20),
    trade_date DATE,
    range_type VARCHAR
);
COMMENT ON TABLE public.stock_fund_industry_detail_rank IS '行业板块详细基金流排名';
ALTER TABLE public.stock_fund_industry_detail_rank OWNER TO myuser;
CREATE INDEX ix_stock_fund_industry_detail_rank_trade_date ON public.stock_fund_industry_detail_rank (trade_date);
CREATE INDEX ix_stock_fund_industry_detail_rank_range_type ON public.stock_fund_industry_detail_rank (range_type);

-- ============================================================================
-- 板块行情表
-- ============================================================================

-- 概念板块日内行情
CREATE TABLE public.stock_board_concept_em (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_board_concept_em IS '概念板块行情数据';
ALTER TABLE public.stock_board_concept_em OWNER TO myuser;
CREATE INDEX ix_stock_board_concept_em_trade_date ON public.stock_board_concept_em (trade_date);

-- 概念板块实时行情
CREATE TABLE public.stock_board_concept_em_realtime (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_board_concept_em_realtime IS '概念板块实时行情数据';
ALTER TABLE public.stock_board_concept_em_realtime OWNER TO myuser;
CREATE INDEX ix_stock_board_concept_em_realtime_trade_date ON public.stock_board_concept_em_realtime (trade_date);

-- 行业板块日内行情
CREATE TABLE public.stock_board_industry_em (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_board_industry_em IS '行业板块行情数据';
ALTER TABLE public.stock_board_industry_em OWNER TO myuser;
CREATE INDEX ix_stock_board_industry_em_trade_date ON public.stock_board_industry_em (trade_date);

-- 行业板块实时行情
CREATE TABLE public.stock_board_industry_em_realtime (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_board_industry_em_realtime IS '行业板块实时行情数据';
ALTER TABLE public.stock_board_industry_em_realtime OWNER TO myuser;
CREATE INDEX ix_stock_board_industry_em_realtime_trade_date ON public.stock_board_industry_em_realtime (trade_date);

-- 行业板块成分股
CREATE TABLE public.stock_board_industry_cons_em (
    board_name VARCHAR(40)
);
COMMENT ON TABLE public.stock_board_industry_cons_em IS '行业板块成分股 - 存储每个行业的包含股票';
ALTER TABLE public.stock_board_industry_cons_em OWNER TO myuser;

-- 概念板块成分股
CREATE TABLE public.stock_board_concept_cons_em (
    board_name VARCHAR(40)
);
COMMENT ON TABLE public.stock_board_concept_cons_em IS '概念板块成分股 - 存储每个概念的包含股票';
ALTER TABLE public.stock_board_concept_cons_em OWNER TO myuser;

-- ============================================================================
-- 筹码集中度表
-- ============================================================================

-- 筹码集中度分析
CREATE TABLE public.stock_cyq_em (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_cyq_em IS '筹码集中度分析 - 分析主力筹码集中情况';
COMMENT ON COLUMN public.stock_cyq_em.symbol IS '股票代码';
COMMENT ON COLUMN public.stock_cyq_em.trade_date IS '交易日期';
ALTER TABLE public.stock_cyq_em OWNER TO myuser;
CREATE INDEX ix_stock_cyq_em_symbol ON public.stock_cyq_em (symbol);
CREATE INDEX ix_stock_cyq_em_trade_date ON public.stock_cyq_em (trade_date);

-- ============================================================================
-- 股票池表
-- ============================================================================

-- 涨停板股票池
CREATE TABLE public.stock_pool_zt (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_pool_zt IS '涨停板股票池 - 存储当日涨停的股票';
ALTER TABLE public.stock_pool_zt OWNER TO myuser;
CREATE INDEX ix_stock_pool_zt_symbol ON public.stock_pool_zt (symbol);
CREATE INDEX ix_stock_pool_zt_trade_date ON public.stock_pool_zt (trade_date);

-- 强势股票池
CREATE TABLE public.stock_pool_strong (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_pool_strong IS '强势股票池 - 存储表现强势的股票';
ALTER TABLE public.stock_pool_strong OWNER TO myuser;
CREATE INDEX ix_stock_pool_strong_symbol ON public.stock_pool_strong (symbol);
CREATE INDEX ix_stock_pool_strong_trade_date ON public.stock_pool_strong (trade_date);

-- 次新股池
CREATE TABLE public.stock_pool_sub_new (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_pool_sub_new IS '次新股池 - 存储次新股票';
ALTER TABLE public.stock_pool_sub_new OWNER TO myuser;
CREATE INDEX ix_stock_pool_sub_new_symbol ON public.stock_pool_sub_new (symbol);
CREATE INDEX ix_stock_pool_sub_new_trade_date ON public.stock_pool_sub_new (trade_date);

-- 主板股票池
CREATE TABLE public.stock_pool_zb (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_pool_zb IS '主板股票池 - 存储主板股票';
ALTER TABLE public.stock_pool_zb OWNER TO myuser;
CREATE INDEX ix_stock_pool_zb_symbol ON public.stock_pool_zb (symbol);
CREATE INDEX ix_stock_pool_zb_trade_date ON public.stock_pool_zb (trade_date);

-- 跌停股票池
CREATE TABLE public.stock_pool_dt (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_pool_dt IS '跌停股票池 - 存储当日跌停的股票';
ALTER TABLE public.stock_pool_dt OWNER TO myuser;
CREATE INDEX ix_stock_pool_dt_symbol ON public.stock_pool_dt (symbol);
CREATE INDEX ix_stock_pool_dt_trade_date ON public.stock_pool_dt (trade_date);

-- ============================================================================
-- 市场活跃度表
-- ============================================================================

-- 市场活跃度实时数据
CREATE TABLE public.stock_market_activity_realtime (
    trade_date DATE
);
COMMENT ON TABLE public.stock_market_activity_realtime IS '市场活跃度实时数据 - 监控整体市场活跃程度';
ALTER TABLE public.stock_market_activity_realtime OWNER TO myuser;
CREATE INDEX ix_stock_market_activity_realtime_trade_date ON public.stock_market_activity_realtime (trade_date);

-- ============================================================================
-- 账户数据表
-- ============================================================================

-- 账户持仓信息
CREATE TABLE public.stock_account_position (
    symbol VARCHAR(20),
    trade_date DATE
);
COMMENT ON TABLE public.stock_account_position IS '账户持仓信息 - 跟踪实际持仓状况';
COMMENT ON COLUMN public.stock_account_position.symbol IS '股票代码';
COMMENT ON COLUMN public.stock_account_position.trade_date IS '交易日期';
ALTER TABLE public.stock_account_position OWNER TO myuser;
CREATE INDEX ix_stock_account_position_symbol ON public.stock_account_position (symbol);
CREATE INDEX ix_stock_account_position_trade_date ON public.stock_account_position (trade_date);

-- 账户操作记录
CREATE TABLE public.stock_account_action (
    symbol VARCHAR(20),
    trade_date DATE,
    type VARCHAR
);
COMMENT ON TABLE public.stock_account_action IS '账户操作记录 - 记录所有交易操作';
COMMENT ON COLUMN public.stock_account_action.symbol IS '股票代码';
COMMENT ON COLUMN public.stock_account_action.trade_date IS '交易日期';
COMMENT ON COLUMN public.stock_account_action.type IS '操作类型（买入、卖出等）';
ALTER TABLE public.stock_account_action OWNER TO myuser;
CREATE INDEX ix_stock_account_action_symbol ON public.stock_account_action (symbol);
CREATE INDEX ix_stock_account_action_trade_date ON public.stock_account_action (trade_date);
CREATE INDEX ix_stock_account_action_type ON public.stock_account_action (type);

-- ============================================================================
-- 数据库使用说明
-- ============================================================================
/*
本数据库（fin_store）用于量化交易数据存储和分析。

主要模块：
1. 价格数据 - K线数据（原始、前复权、后复权）
2. 实时行情 - 交易时段的实时报价数据
3. 热点数据 - 新闻、龙虎榜、公司事件等
4. 排名数据 - 涨跌幅、换手率等各类排名
5. 基金流向 - 主力资金动向分析
6. 板块数据 - 行业和概念板块数据
7. 账户数据 - 持仓和交易操作记录

数据来源：
- AKShare：中国股市数据，绝大多数表
- BaoStock：财经数据，表名中包含 bao_k 的K线表

建议用途：
- 策略回测：使用 stock_history_qfq 表
- 近期分析：使用 stock_history_hfq 表
- 日内交易：使用 stock_zh_a_spot_em_realtime 表
- 资金分析：使用 stock_fund_* 系列表
- 热点追踪：使用龙虎榜和新闻相关表

维护建议：
1. 定期检查数据完整性
2. 监控表大小，及时清理过期数据
3. 定期更新统计信息以优化查询性能
4. 设置自动备份策略
*/

-- ============================================================================
-- 授权设置
-- ============================================================================

-- 仅读用户访问权限已通过 create_readonly_user.sql 配置

