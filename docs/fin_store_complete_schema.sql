-- ============================================================================
-- GeniusStockAIQuant 数据库完整DDL定义（带中文注释）
-- 数据库名: fin_store
-- 用途: A股市场量化交易数据存储
-- 数据来源: AKShare (主要), BaoStock (K线数据)
-- ============================================================================

create table public.artist

(

    name      varchar(120) not null,

    artist_id serial

        primary key

);


ALTER TABLE public.artist
    OWNER TO myuser;

COMMENT ON TABLE public.artist IS '艺术品相关信息表';

create table public.stock_exchange

(

    name         varchar(120) not null,

    city         varchar(120) not null,

    akshare_abb  varchar(20),

    yfinance_abb varchar(20),

    stock_count  integer,

    id           serial

        primary key

);


ALTER TABLE public.stock_exchange
    OWNER TO myuser;

COMMENT ON TABLE public.stock_exchange IS '证券交易所信息表';

create table public.stock_info

(

    market_value        double precision,

    traded_market_value double precision,

    industry            varchar(50),

    offering_date       date,

    symbol              varchar(20) not null,

    short_name          varchar(20),

    total_share_capital double precision,

    outstanding_shares  double precision,

    exchange            varchar(10),

    id                  serial

        primary key

);


ALTER TABLE public.stock_info
    OWNER TO myuser;

COMMENT ON TABLE public.stock_info IS '股票基本信息表 - 包含市值、行业等基本面数据';

create table public.stock_history

(

    symbol        varchar(20) not null,

    date          date,

    open          double precision,

    close         double precision,

    high          double precision,

    low           double precision,

    volume        integer,

    turnover      double precision,

    range         double precision,

    change_rate   double precision,

    change_amount double precision,

    turnover_rate double precision,

    id            serial

        primary key

);


ALTER TABLE public.stock_history
    OWNER TO myuser;

COMMENT ON TABLE public.stock_history IS '股票日K线数据（原始价格）- AKShare数据源';

create table public.stock_history_qfq

(

    symbol        varchar(20) not null,

    date          date,

    open          double precision,

    close         double precision,

    high          double precision,

    low           double precision,

    volume        integer,

    turnover      double precision,

    range         double precision,

    change_rate   double precision,

    change_amount double precision,

    turnover_rate double precision,

    id            serial

        primary key

);


ALTER TABLE public.stock_history_qfq
    OWNER TO myuser;

COMMENT ON TABLE public.stock_history_qfq IS '股票日K线数据（前复权）- 向前复权处理，适合长期回测';

create table public.stock_history_hfq

(

    symbol        varchar(20) not null,

    date          date,

    open          double precision,

    close         double precision,

    high          double precision,

    low           double precision,

    volume        integer,

    turnover      double precision,

    range         double precision,

    change_rate   double precision,

    change_amount double precision,

    turnover_rate double precision,

    id            serial

        primary key

);


ALTER TABLE public.stock_history_hfq
    OWNER TO myuser;

COMMENT ON TABLE public.stock_history_hfq IS '股票日K线数据（后复权）- 向后复权处理，保留最近价格原始值';

create table public.stock_news

(

    symbol     varchar(20) not null,

    pub_time   timestamp,

    title      varchar(200),

    content    varchar(1000),

    source     varchar(50),

    link       varchar(500),

    created_at timestamp,

    updated_at timestamp,

    id         serial

        primary key

);


ALTER TABLE public.stock_news
    OWNER TO myuser;

create table public.stock_trade_date

(

    trade_date date not null,

    created_at timestamp,

    updated_at timestamp,

    id         serial

        primary key

);


ALTER TABLE public.stock_trade_date
    OWNER TO myuser;

create table public.stock_change_abnormal

(

    symbol      varchar(20) not null,

    date        date,

    event_time  time,

    name        varchar(40),

    event       varchar(40),

    attach_info varchar(40),

    created_at  timestamp,

    updated_at  timestamp,

    id          serial

        primary key

);


ALTER TABLE public.stock_change_abnormal
    OWNER TO myuser;

create table public.stock_comment

(

    symbol          varchar(20) not null,

    trade_date      date,

    name            varchar(20),

    latest_price    double precision,

    change_rate     double precision,

    turnover_rate   double precision,

    pe_ratio        double precision,

    main_cost       double precision,

    inst_own_pct    double precision,

    overall_score   double precision,

    rise            integer,

    rank            integer,

    attention_index double precision,

    created_at      timestamp,

    updated_at      timestamp,

    id              serial

        primary key

);


ALTER TABLE public.stock_comment
    OWNER TO myuser;

create table public.stock_company_event

(

    symbol     varchar(20) not null,

    event_date date,

    date_index integer,

    name       varchar(20),

    event_type varchar(20),

    event      varchar(5000),

    created_at timestamp,

    updated_at timestamp,

    id         serial

        primary key

);


ALTER TABLE public.stock_company_event
    OWNER TO myuser;

create table public.stock_rank_cxg

(

    trade_date    date,

    range_type    varchar(20) not null,

    symbol        varchar(20) not null,

    name          varchar(40),

    change_rate   double precision,

    turnover_rate double precision,

    latest_price  double precision,

    pre_high      double precision,

    pre_high_date date,

    created_at    timestamp,

    updated_at    timestamp,

    id            serial

        primary key

);


ALTER TABLE public.stock_rank_cxg
    OWNER TO myuser;

create table public.stock_rank_cxd

(

    trade_date    date,

    range_type    varchar(20) not null,

    symbol        varchar(20) not null,

    name          varchar(40),

    change_rate   double precision,

    turnover_rate double precision,

    latest_price  double precision,

    pre_low       double precision,

    pre_low_date  date,

    created_at    timestamp,

    updated_at    timestamp,

    id            serial

        primary key

);


ALTER TABLE public.stock_rank_cxd
    OWNER TO myuser;

create table public.stock_rank_lxsz

(

    trade_date     date,

    symbol         varchar(20) not null,

    name           varchar(40),

    close          double precision,

    high           double precision,

    low            double precision,

    lz_days        integer,

    lz_change_rate double precision,

    turnover_rate  double precision,

    industry       varchar(50),

    created_at     timestamp,

    updated_at     timestamp,

    id             serial

        primary key

);


ALTER TABLE public.stock_rank_lxsz
    OWNER TO myuser;

create table public.stock_rank_lxxd

(

    trade_date     date,

    symbol         varchar(20) not null,

    name           varchar(40),

    close          double precision,

    high           double precision,

    low            double precision,

    lz_days        integer,

    lz_change_rate double precision,

    turnover_rate  double precision,

    industry       varchar(50),

    created_at     timestamp,

    updated_at     timestamp,

    id             serial

        primary key

);


ALTER TABLE public.stock_rank_lxxd
    OWNER TO myuser;

create table public.stock_rank_cxfl

(

    trade_date       date,

    symbol           varchar(20) not null,

    name             varchar(40),

    change_rate      double precision,

    latest_price     double precision,

    base_date        date,

    fl_days          integer,

    days_change_rate double precision,

    industry         varchar(50),

    created_at       timestamp,

    updated_at       timestamp,

    id               serial

        primary key

);


ALTER TABLE public.stock_rank_cxfl
    OWNER TO myuser;

create table public.stock_rank_cxsl

(

    trade_date       date,

    symbol           varchar(20) not null,

    name             varchar(40),

    change_rate      double precision,

    latest_price     double precision,

    base_date        date,

    sl_days          integer,

    days_change_rate double precision,

    industry         varchar(50),

    created_at       timestamp,

    updated_at       timestamp,

    id               serial

        primary key

);


ALTER TABLE public.stock_rank_cxsl
    OWNER TO myuser;

create table public.stock_rank_xstp

(

    trade_date    date,

    range_type    varchar(20) not null,

    symbol        varchar(20) not null,

    name          varchar(40),

    latest_price  double precision,

    change_rate   double precision,

    turnover_rate double precision,

    created_at    timestamp,

    updated_at    timestamp,

    id            serial

        primary key

);


ALTER TABLE public.stock_rank_xstp
    OWNER TO myuser;

create table public.stock_rank_xxtp

(

    trade_date    date,

    range_type    varchar(20) not null,

    symbol        varchar(20) not null,

    name          varchar(40),

    latest_price  double precision,

    change_rate   double precision,

    turnover_rate double precision,

    created_at    timestamp,

    updated_at    timestamp,

    id            serial

        primary key

);


ALTER TABLE public.stock_rank_xxtp
    OWNER TO myuser;

create table public.stock_rank_ljqs

(

    trade_date       date,

    symbol           varchar(20) not null,

    name             varchar(40),

    latest_price     double precision,

    qs_days          integer,

    days_change_rate double precision,

    turnover_rate    double precision,

    industry         varchar(50),

    created_at       timestamp,

    updated_at       timestamp,

    id               serial

        primary key

);


ALTER TABLE public.stock_rank_ljqs
    OWNER TO myuser;

create table public.stock_rank_ljqd

(

    trade_date       date,

    symbol           varchar(20) not null,

    name             varchar(40),

    latest_price     double precision,

    qd_days          integer,

    days_change_rate double precision,

    turnover_rate    double precision,

    industry         varchar(50),

    created_at       timestamp,

    updated_at       timestamp,

    id               serial

        primary key

);


ALTER TABLE public.stock_rank_ljqd
    OWNER TO myuser;

create table public.stock_rank_xzjp

(

    pub_date            date,

    symbol              varchar(20)  not null,

    name                varchar(40),

    current_price       double precision,

    change_rate         double precision,

    pub_owner           varchar(200) not null,

    increase_amount     varchar(20)  not null,

    increase_amount_per double precision,

    total_amount        varchar(20)  not null,

    total_amount_per    double precision,

    created_at          timestamp,

    updated_at          timestamp,

    id                  serial

        primary key

);


ALTER TABLE public.stock_rank_xzjp
    OWNER TO myuser;

create table public.stock_fund_concept_intraday

(

    trade_date        date,

    name              varchar(40),

    index             double precision,

    change_rate       double precision,

    change_rate_rank  double precision,

    fund_in           double precision,

    fund_out          double precision,

    net_amount        double precision,

    firm_number       integer,

    best_stock        varchar(40),

    best_change_rate  double precision,

    best_latest_price double precision,

    created_at        timestamp,

    updated_at        timestamp,

    id                serial

        primary key

);


ALTER TABLE public.stock_fund_concept_intraday
    OWNER TO myuser;

create table public.stock_fund_concept_rank

(

    trade_date       date,

    range_type       varchar(20) not null,

    name             varchar(40),

    firm_number      integer,

    index            double precision,

    change_rate      double precision,

    change_rate_rank double precision,

    fund_in          double precision,

    fund_out         double precision,

    net_amount       double precision,

    created_at       timestamp,

    updated_at       timestamp,

    id               serial

        primary key

);


ALTER TABLE public.stock_fund_concept_rank
    OWNER TO myuser;

create table public.stock_fund_industry_intraday

(

    trade_date        date,

    name              varchar(40),

    index             double precision,

    change_rate       double precision,

    change_rate_rank  double precision,

    fund_in           double precision,

    fund_out          double precision,

    net_amount        double precision,

    firm_number       integer,

    best_stock        varchar(40),

    best_change_rate  double precision,

    best_latest_price double precision,

    created_at        timestamp,

    updated_at        timestamp,

    id                serial

        primary key

);


ALTER TABLE public.stock_fund_industry_intraday
    OWNER TO myuser;

create table public.stock_fund_industry_rank

(

    trade_date       date,

    range_type       varchar(20) not null,

    name             varchar(40),

    firm_number      integer,

    index            double precision,

    change_rate      double precision,

    change_rate_rank double precision,

    fund_in          double precision,

    fund_out         double precision,

    net_amount       double precision,

    created_at       timestamp,

    updated_at       timestamp,

    id               serial

        primary key

);


ALTER TABLE public.stock_fund_industry_rank
    OWNER TO myuser;

create table public.stock_fund_big_deal

(

    trade_date    date,

    trade_time    timestamp,

    symbol        varchar(20) not null,

    name          varchar(40),

    price         double precision,

    volume        integer,

    turnover      double precision,

    type          varchar(20) not null,

    change_rate   double precision,

    change_amount double precision,

    created_at    timestamp,

    updated_at    timestamp,

    id            serial

        primary key

);


ALTER TABLE public.stock_fund_big_deal
    OWNER TO myuser;

create table public.stock_fund_single_detail_intraday

(

    trade_date    date,

    symbol        varchar(20) not null,

    name          varchar(40),

    latest_price  double precision,

    change_rate   double precision,

    main_in_rank  double precision,

    main_in_net   double precision,

    main_in_per   double precision,

    huge_in_net   double precision,

    huge_in_per   double precision,

    big_in_net    double precision,

    big_in_per    double precision,

    middle_in_net double precision,

    middle_in_per double precision,

    small_in_net  double precision,

    small_in_per  double precision,

    created_at    timestamp,

    updated_at    timestamp,

    id            serial

        primary key

);


ALTER TABLE public.stock_fund_single_detail_intraday
    OWNER TO myuser;

create table public.stock_fund_single_detail_rank

(

    trade_date    date,

    range_type    varchar(20) not null,

    symbol        varchar(20) not null,

    name          varchar(40),

    latest_price  double precision,

    change_rate   double precision,

    main_in_rank  double precision,

    main_in_net   double precision,

    main_in_per   double precision,

    huge_in_net   double precision,

    huge_in_per   double precision,

    big_in_net    double precision,

    big_in_per    double precision,

    middle_in_net double precision,

    middle_in_per double precision,

    small_in_net  double precision,

    small_in_per  double precision,

    created_at    timestamp,

    updated_at    timestamp,

    id            serial

        primary key

);


ALTER TABLE public.stock_fund_single_detail_rank
    OWNER TO myuser;

create table public.stock_fund_market_detail

(

    trade_date     date,

    sh_close       double precision,

    sh_change_rate double precision,

    sz_close       double precision,

    sz_change_rate double precision,

    main_in_net    double precision,

    main_in_per    double precision,

    huge_in_net    double precision,

    huge_in_per    double precision,

    big_in_net     double precision,

    big_in_per     double precision,

    middle_in_net  double precision,

    middle_in_per  double precision,

    small_in_net   double precision,

    small_in_per   double precision,

    created_at     timestamp,

    updated_at     timestamp,

    id             serial

        primary key

);


ALTER TABLE public.stock_fund_market_detail
    OWNER TO myuser;

create table public.stock_fund_industry_detail_intraday

(

    trade_date         date,

    name               varchar(40),

    change_rate        double precision,

    main_in_rank       double precision,

    main_in_net        double precision,

    main_in_per        double precision,

    main_in_most_stock varchar(40),

    huge_in_net        double precision,

    huge_in_per        double precision,

    big_in_net         double precision,

    big_in_per         double precision,

    middle_in_net      double precision,

    middle_in_per      double precision,

    small_in_net       double precision,

    small_in_per       double precision,

    created_at         timestamp,

    updated_at         timestamp,

    id                 serial

        primary key

);


ALTER TABLE public.stock_fund_industry_detail_intraday
    OWNER TO myuser;

create table public.stock_fund_industry_detail_rank

(

    trade_date         date,

    range_type         varchar(20) not null,

    name               varchar(40),

    change_rate        double precision,

    main_in_rank       double precision,

    main_in_net        double precision,

    main_in_per        double precision,

    main_in_most_stock varchar(40),

    huge_in_net        double precision,

    huge_in_per        double precision,

    big_in_net         double precision,

    big_in_per         double precision,

    middle_in_net      double precision,

    middle_in_per      double precision,

    small_in_net       double precision,

    small_in_per       double precision,

    created_at         timestamp,

    updated_at         timestamp,

    id                 serial

        primary key

);


ALTER TABLE public.stock_fund_industry_detail_rank
    OWNER TO myuser;

create table public.stock_fund_concept_detail_intraday

(

    trade_date         date,

    name               varchar(40),

    change_rate        double precision,

    main_in_rank       double precision,

    main_in_net        double precision,

    main_in_per        double precision,

    main_in_most_stock varchar(40),

    huge_in_net        double precision,

    huge_in_per        double precision,

    big_in_net         double precision,

    big_in_per         double precision,

    middle_in_net      double precision,

    middle_in_per      double precision,

    small_in_net       double precision,

    small_in_per       double precision,

    created_at         timestamp,

    updated_at         timestamp,

    id                 serial

        primary key

);


ALTER TABLE public.stock_fund_concept_detail_intraday
    OWNER TO myuser;

create table public.stock_fund_concept_detail_rank

(

    trade_date         date,

    range_type         varchar(20) not null,

    name               varchar(40),

    change_rate        double precision,

    main_in_rank       double precision,

    main_in_net        double precision,

    main_in_per        double precision,

    main_in_most_stock varchar(40),

    huge_in_net        double precision,

    huge_in_per        double precision,

    big_in_net         double precision,

    big_in_per         double precision,

    middle_in_net      double precision,

    middle_in_per      double precision,

    small_in_net       double precision,

    small_in_per       double precision,

    created_at         timestamp,

    updated_at         timestamp,

    id                 serial

        primary key

);


ALTER TABLE public.stock_fund_concept_detail_rank
    OWNER TO myuser;

create table public.stock_pool_zt

(

    trade_date          date,

    symbol              varchar(20) not null,

    name                varchar(40),

    change_rate         double precision,

    latest_price        double precision,

    turnover            double precision,

    traded_market_value double precision,

    market_value        double precision,

    turnover_rate       double precision,

    fb_fund             double precision,

    fb_first_time       time,

    fb_last_time        time,

    zb_count            integer,

    zt_status           varchar(20),

    lb_count            integer,

    industry            varchar(50),

    created_at          timestamp,

    updated_at          timestamp,

    id                  serial

        primary key

);


ALTER TABLE public.stock_pool_zt
    OWNER TO myuser;

create table public.stock_pool_strong

(

    trade_date          date,

    symbol              varchar(20) not null,

    name                varchar(40),

    change_rate         double precision,

    latest_price        double precision,

    zt_price            double precision,

    turnover            double precision,

    traded_market_value double precision,

    market_value        double precision,

    turnover_rate       double precision,

    up_speed            double precision,

    is_new_high         varchar(20),

    volume_ratio        double precision,

    zt_status           varchar(20),

    reason              varchar(20),

    industry            varchar(50),

    created_at          timestamp,

    updated_at          timestamp,

    id                  serial

        primary key

);


ALTER TABLE public.stock_pool_strong
    OWNER TO myuser;

create table public.stock_pool_sub_new

(

    trade_date          date,

    symbol              varchar(20) not null,

    name                varchar(40),

    change_rate         double precision,

    latest_price        double precision,

    zt_price            double precision,

    turnover            double precision,

    traded_market_value double precision,

    market_value        double precision,

    turnover_rate       double precision,

    kb_days             integer,

    kb_date             date,

    offering_date       date,

    is_new_high         varchar(20),

    zt_status           varchar(20),

    industry            varchar(50),

    created_at          timestamp,

    updated_at          timestamp,

    id                  serial

        primary key

);


ALTER TABLE public.stock_pool_sub_new
    OWNER TO myuser;

create table public.stock_pool_zb

(

    trade_date          date,

    symbol              varchar(20) not null,

    name                varchar(40),

    change_rate         double precision,

    latest_price        double precision,

    zt_price            double precision,

    turnover            double precision,

    traded_market_value double precision,

    market_value        double precision,

    turnover_rate       double precision,

    up_speed            double precision,

    fb_first_time       time,

    zb_count            integer,

    zt_status           varchar(20),

    range               double precision,

    industry            varchar(50),

    created_at          timestamp,

    updated_at          timestamp,

    id                  serial

        primary key

);


ALTER TABLE public.stock_pool_zb
    OWNER TO myuser;

create table public.stock_pool_dt

(

    trade_date          date,

    symbol              varchar(20) not null,

    name                varchar(40),

    change_rate         double precision,

    latest_price        double precision,

    turnover            double precision,

    traded_market_value double precision,

    market_value        double precision,

    forward_pe_ratio    double precision,

    turnover_rate       double precision,

    fd_fund             double precision,

    fb_last_time        time,

    bs_turnover         double precision,

    lb_count            integer,

    kb_count            integer,

    industry            varchar(50),

    created_at          timestamp,

    updated_at          timestamp,

    id                  serial

        primary key

);


ALTER TABLE public.stock_pool_dt
    OWNER TO myuser;

create table public.stock_fund_single_intraday

(

    trade_date       date,

    symbol           varchar(20) not null,

    name             varchar(40),

    latest_price     double precision,

    change_rate      double precision,

    change_rate_rank double precision,

    turnover_rate    double precision,

    fund_in          double precision,

    fund_out         double precision,

    net_amount       double precision,

    turnover         double precision,

    created_at       timestamp,

    updated_at       timestamp,

    id               serial

        primary key

);


ALTER TABLE public.stock_fund_single_intraday
    OWNER TO myuser;

create table public.stock_fund_single_rank

(

    trade_date       date,

    range_type       varchar(20) not null,

    symbol           varchar(20) not null,

    name             varchar(40),

    latest_price     double precision,

    change_rate      double precision,

    change_rate_rank double precision,

    turnover_rate    double precision,

    fund_in_net      double precision,

    created_at       timestamp,

    updated_at       timestamp,

    id               serial

        primary key

);


ALTER TABLE public.stock_fund_single_rank
    OWNER TO myuser;

create table public.stock_history_bao_k

(

    code         varchar(20) not null,

    symbol       varchar(20) not null,

    name         varchar(40),

    date         date,

    open         double precision,

    close        double precision,

    high         double precision,

    low          double precision,

    volume       bigint,

    pre_close    double precision,

    amount       double precision,

    adjust_flag  integer,

    turn         double precision,

    trade_status integer,

    change_rate  double precision,

    pe_ttm       double precision,

    pb_mrq       double precision,

    ps_ttm       double precision,

    pcf_ncf_ttm  double precision,

    is_st        integer,

    created_at   timestamp,

    updated_at   timestamp,

    id           serial

        primary key

);


ALTER TABLE public.stock_history_bao_k
    OWNER TO myuser;

COMMENT ON TABLE public.stock_history_bao_k IS 'BaoStock K线数据（原始价格）';

create table public.stock_history_bao_k_qfq

(

    code         varchar(20) not null,

    symbol       varchar(20) not null,

    name         varchar(40),

    date         date,

    open         double precision,

    close        double precision,

    high         double precision,

    low          double precision,

    volume       bigint,

    pre_close    double precision,

    amount       double precision,

    adjust_flag  integer,

    turn         double precision,

    trade_status integer,

    change_rate  double precision,

    pe_ttm       double precision,

    pb_mrq       double precision,

    ps_ttm       double precision,

    pcf_ncf_ttm  double precision,

    is_st        integer,

    created_at   timestamp,

    updated_at   timestamp,

    id           serial

        primary key

);


ALTER TABLE public.stock_history_bao_k_qfq
    OWNER TO myuser;

COMMENT ON TABLE public.stock_history_bao_k_qfq IS 'BaoStock K线数据（前复权）';

create table public.stock_history_bao_k_hfq

(

    code         varchar(20) not null,

    symbol       varchar(20) not null,

    name         varchar(40),

    date         date,

    open         double precision,

    close        double precision,

    high         double precision,

    low          double precision,

    volume       bigint,

    pre_close    double precision,

    amount       double precision,

    adjust_flag  integer,

    turn         double precision,

    trade_status integer,

    change_rate  double precision,

    pe_ttm       double precision,

    pb_mrq       double precision,

    ps_ttm       double precision,

    pcf_ncf_ttm  double precision,

    is_st        integer,

    created_at   timestamp,

    updated_at   timestamp,

    id           serial

        primary key

);


ALTER TABLE public.stock_history_bao_k_hfq
    OWNER TO myuser;

COMMENT ON TABLE public.stock_history_bao_k_hfq IS 'BaoStock K线数据（后复权）';

create table public.stock_cyq_em

(

    trade_date       date,

    symbol           varchar(20) not null,

    name             varchar(40),

    profit_ratio     double precision,

    avg_cost         double precision,

    cost_90_low      double precision,

    cost_90_high     double precision,

    concentration_90 double precision,

    cost_70_low      double precision,

    cost_70_high     double precision,

    concentration_70 double precision,

    created_at       timestamp,

    updated_at       timestamp,

    id               serial

        primary key

);


ALTER TABLE public.stock_cyq_em
    OWNER TO myuser;

create table public.stock_lhb_detail_em

(

    trade_date          date,

    name                varchar(40),

    symbol              varchar(20),

    insight             varchar(300),

    close               double precision,

    change_rate         double precision,

    lhb_in_net          double precision,

    lhb_in_amount       double precision,

    lhb_out_amount      double precision,

    lhb_amount          double precision,

    total_amount        double precision,

    in_net_per          double precision,

    in_amount_per       double precision,

    turnover_rate       double precision,

    traded_market_value double precision,

    reason              varchar(400),

    created_at          timestamp,

    updated_at          timestamp,

    id                  serial

        primary key

);


ALTER TABLE public.stock_lhb_detail_em
    OWNER TO myuser;

create table public.stock_lhb_hyyyb_em

(

    yyb_symbol        varchar(20) not null,

    yyb_name          varchar(40),

    trade_date        date,

    buy_stock_count   integer,

    sell_stock_count  integer,

    buy_amount_total  double precision,

    sell_amount_total double precision,

    net_amount_total  double precision,

    buy_stocks        varchar(5000),

    created_at        timestamp,

    updated_at        timestamp,

    id                serial

        primary key

);


ALTER TABLE public.stock_lhb_hyyyb_em
    OWNER TO myuser;

create table public.stock_lhb_yyb_detail_em

(

    yyb_symbol     varchar(20) not null,

    yyb_name       varchar(100),

    yyb_short_name varchar(100),

    trade_date     date,

    stock_symbol   varchar(40),

    stock_name     varchar(40),

    change_rate    double precision,

    buy_amount     double precision,

    sell_amount    double precision,

    net_amount     double precision,

    reason         varchar(400),

    created_at     timestamp,

    updated_at     timestamp,

    id             serial

        primary key

);


ALTER TABLE public.stock_lhb_yyb_detail_em
    OWNER TO myuser;

create table public.stock_fund_single_detail_realtime

(

    trade_date    date,

    collect_time  time,

    symbol        varchar(20) not null,

    name          varchar(40),

    latest_price  double precision,

    change_rate   double precision,

    main_in_rank  double precision,

    main_in_net   double precision,

    main_in_per   double precision,

    huge_in_net   double precision,

    huge_in_per   double precision,

    big_in_net    double precision,

    big_in_per    double precision,

    middle_in_net double precision,

    middle_in_per double precision,

    small_in_net  double precision,

    small_in_per  double precision,

    created_at    timestamp,

    updated_at    timestamp,

    id            serial

        primary key

);


ALTER TABLE public.stock_fund_single_detail_realtime
    OWNER TO myuser;

create table public.stock_zh_a_spot_em_realtime

(

    trade_date          date,

    collect_time        time,

    symbol              varchar(20) not null,

    name                varchar(40),

    latest_price        double precision,

    change_rate         double precision,

    change_amount       double precision,

    volume              integer,

    turnover            double precision,

    range               double precision,

    high                double precision,

    low                 double precision,

    open                double precision,

    pre_close           double precision,

    volume_ratio        double precision,

    turnover_rate       double precision,

    forward_pe_ratio    double precision,

    pb_mrq              double precision,

    market_value        double precision,

    traded_market_value double precision,

    up_speed            double precision,

    change_rate_5min    double precision,

    change_rate_60d     double precision,

    change_rate_ytd     double precision,

    created_at          timestamp,

    updated_at          timestamp,

    id                  serial

        primary key

);


ALTER TABLE public.stock_zh_a_spot_em_realtime
    OWNER TO myuser;

create table public.stock_account_position

(

    trade_date                  date,

    "current_time"              timestamp,

    detail                      varchar(20) not null,

    sequence                    integer,

    symbol                      varchar(20) not null,

    name                        varchar(20),

    stock_balance               integer,

    available_balance           integer,

    frozen_quantity             integer,

    reference_cost_price        double precision,

    market_price                double precision,

    reference_profit_loss       double precision,

    reference_profit_loss_ratio double precision,

    daily_profit_loss           double precision,

    daily_profit_loss_ratio     double precision,

    market_value                double precision,

    position_ratio              double precision,

    daily_buy                   integer,

    daily_sell                  integer,

    trading_market              varchar(20),

    unnamed_18                  varchar(20),

    created_at                  timestamp,

    updated_at                  timestamp,

    id                          serial

        primary key

);


ALTER TABLE public.stock_account_position
    OWNER TO myuser;

create table public.stock_account_action

(

    trade_date     date,

    "current_time" timestamp,

    type           varchar(20) not null,

    strategy       varchar(50) not null,

    symbol         varchar(20) not null,

    name           varchar(20),

    price          double precision,

    amount         integer,

    entrust_no     varchar(50) not null,

    created_at     timestamp,

    updated_at     timestamp,

    id             serial

        primary key

);


ALTER TABLE public.stock_account_action
    OWNER TO myuser;

create table public.stock_board_concept_em

(

    trade_date            date,

    collect_time          timestamp,

    rank                  integer,

    name                  varchar(40),

    symbol                varchar(40),

    latest_price          double precision,

    change_amount         double precision,

    change_rate           double precision,

    market_value          double precision,

    turnover_rate         double precision,

    sz_count              integer,

    xd_count              integer,

    lz_symbol             varchar(40),

    lz_symbol_change_rate double precision,

    created_at            timestamp,

    updated_at            timestamp,

    id                    serial

        primary key

);


ALTER TABLE public.stock_board_concept_em
    OWNER TO myuser;

create table public.stock_board_industry_em

(

    trade_date            date,

    collect_time          timestamp,

    rank                  integer,

    name                  varchar(40),

    symbol                varchar(40),

    latest_price          double precision,

    change_amount         double precision,

    change_rate           double precision,

    market_value          double precision,

    turnover_rate         double precision,

    sz_count              integer,

    xd_count              integer,

    lz_symbol             varchar(40),

    lz_symbol_change_rate double precision,

    created_at            timestamp,

    updated_at            timestamp,

    id                    serial

        primary key

);


ALTER TABLE public.stock_board_industry_em
    OWNER TO myuser;

create table public.stock_board_industry_cons_em

(

    board_name   varchar(40),

    board_symbol varchar(40),

    stock_name   varchar(40),

    stock_symbol varchar(40),

    created_at   timestamp,

    updated_at   timestamp,

    id           serial

        primary key

);


ALTER TABLE public.stock_board_industry_cons_em
    OWNER TO myuser;

create table public.stock_board_concept_cons_em

(

    board_name   varchar(40),

    board_symbol varchar(40),

    stock_name   varchar(40),

    stock_symbol varchar(40),

    created_at   timestamp,

    updated_at   timestamp,

    id           serial

        primary key

);


ALTER TABLE public.stock_board_concept_cons_em
    OWNER TO myuser;

create table public.stock_zh_a_spot_em

(

    trade_date          date,

    collect_time        time,

    symbol              varchar(20) not null,

    name                varchar(40),

    latest_price        double precision,

    change_rate         double precision,

    change_amount       double precision,

    volume              integer,

    turnover            double precision,

    range               double precision,

    high                double precision,

    low                 double precision,

    open                double precision,

    pre_close           double precision,

    volume_ratio        double precision,

    turnover_rate       double precision,

    forward_pe_ratio    double precision,

    pb_mrq              double precision,

    market_value        double precision,

    traded_market_value double precision,

    up_speed            double precision,

    change_rate_5min    double precision,

    change_rate_60d     double precision,

    change_rate_ytd     double precision,

    created_at          timestamp,

    updated_at          timestamp,

    id                  serial

        primary key

);


ALTER TABLE public.stock_zh_a_spot_em
    OWNER TO myuser;

create table public.stock_board_concept_em_realtime

(

    trade_date            date,

    collect_time          timestamp,

    rank                  integer,

    name                  varchar(40),

    symbol                varchar(40),

    latest_price          double precision,

    change_amount         double precision,

    change_rate           double precision,

    market_value          double precision,

    turnover_rate         double precision,

    sz_count              integer,

    xd_count              integer,

    lz_symbol             varchar(40),

    lz_symbol_change_rate double precision,

    created_at            timestamp,

    updated_at            timestamp,

    id                    serial

        primary key

);


ALTER TABLE public.stock_board_concept_em_realtime
    OWNER TO myuser;

create table public.stock_board_industry_em_realtime

(

    trade_date            date,

    collect_time          timestamp,

    rank                  integer,

    name                  varchar(40),

    symbol                varchar(40),

    latest_price          double precision,

    change_amount         double precision,

    change_rate           double precision,

    market_value          double precision,

    turnover_rate         double precision,

    sz_count              integer,

    xd_count              integer,

    lz_symbol             varchar(40),

    lz_symbol_change_rate double precision,

    created_at            timestamp,

    updated_at            timestamp,

    id                    serial

        primary key

);


ALTER TABLE public.stock_board_industry_em_realtime
    OWNER TO myuser;

create table public.stock_market_activity_realtime

(

    trade_date       date,

    collect_time     timestamp,

    advancing        integer,

    limit_up         integer,

    true_limit_up    integer,

    st_limit_up      integer,

    declining        integer,

    limit_down       integer,

    true_limit_down  integer,

    st_limit_down    integer,

    unchanged        integer,

    suspended        integer,

    activity_rate    double precision,

    statistical_date timestamp,

    created_at       timestamp,

    updated_at       timestamp,

    id               serial

        primary key

);


ALTER TABLE public.stock_market_activity_realtime
    OWNER TO myuser;

create table public.stock_zh_a_spot_sina_realtime

(

    trade_date     date,

    collect_time   timestamp,

    code           varchar(20) not null,

    symbol         varchar(20) not null,

    name           varchar(40),

    latest_price   double precision,

    change_amount  double precision,

    change_rate    double precision,

    buy_in         double precision,

    sell_out       double precision,

    pre_close      double precision,

    open           double precision,

    high           double precision,

    low            double precision,

    volume         integer,

    turnover       double precision,

    data_timestamp time,

    created_at     timestamp,

    updated_at     timestamp,

    id             serial

        primary key

);


ALTER TABLE public.stock_zh_a_spot_sina_realtime
    OWNER TO myuser;
