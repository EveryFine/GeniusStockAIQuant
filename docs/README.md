# GeniusStockAIQuant 数据库文档索引

## 📚 文档清单

本项目已生成了完整的数据库文档，共包含**4份Markdown文档**和**2份SQL文件**。

---

## 📖 文档导航

### 1. **[database-schema-guide.md](database-schema-guide.md)** 
   **数据库架构完整指南** (16KB)
   
   📍 **适合人群**: 了解项目数据结构的初学者
   
   **包含内容**:
   - 项目概述和核心功能模块说明
   - 13个主要表类别的详细介绍
   - 每个表的用途和使用建议
   - 数据完整性检查方法
   - 性能优化建议
   
   **快速查找**:
   - 📊 基础信息表 → 第1节
   - 📈 价格数据表 → 第2节
   - 📡 实时行情表 → 第3节
   - 🔥 热点数据表 → 第5节
   - 💹 基金流向表 → 第8节
   - 🏢 板块表 → 第9节
   - 📋 账户数据 → 第13节

---

### 2. **[database-complete-column-reference.md](database-complete-column-reference.md)**
   **完整表列参考手册** (16KB)
   
   📍 **适合人群**: 需要查看具体列定义的开发者
   
   **包含内容**:
   - 所有61个表的完整列定义
   - 每个列的数据类型和中文说明
   - 索引设计原则
   - 数据量级参考
   
   **核心特性**:
   - ✅ 涵盖所有表（包括复杂的BaoStock表）
   - ✅ 每列都有详细的中文说明
   - ✅ 表格格式易于查阅
   - ✅ 包含数据类型完整说明
   
   **快速查找**:
   - 基础信息表 → 第1节
   - K线价格表 → 第2节（包含BaoStock的详细列）
   - 实时行情 → 第3节
   - 异常波动 → 第5节
   - 龙虎榜系列 → 第6.4节
   - 排名表 → 第7节
   - 基金流向 → 第8节
   - 板块表 → 第9节
   - 股票池 → 第10.2节
   - 账户数据 → 第11节

---

### 3. **[database-data-dictionary.md](database-data-dictionary.md)**
   **详细数据字典和使用指南** (13KB)
   
   📍 **适合人群**: 需要理解数据含义和使用方法的分析师
   
   **包含内容**:
   - 数据来源详解（AKShare vs BaoStock）
   - 股票代码格式说明（3种格式）
   - 复权数据的详细说明和选择指南
   - 热点数据表的实际应用案例
   - 基金流向指标详解
   - 排名表时间范围说明
   - SQL数据质量检查脚本（可直接运行）
   - 查询性能优化技巧
   - 常见问题Q&A
   - 最佳实践总结
   
   **核心亮点**:
   - 🎯 包含SQL查询示例
   - 🔧 性能优化建议
   - 📊 数据更新频率参考
   - ✅ 数据质量检查方案
   
   **快速查找**:
   - 数据源说明 → 第1节
   - 代码格式 → 第2节
   - 复权数据详解 → 第3节
   - 龙虎榜使用 → 第4节
   - 基金流向应用 → 第5节
   - 排名表用法 → 第6节
   - SQL检查脚本 → 第9节

---

### 4. **[database-postgres.md](database-postgres.md)** / **[database-postgres-en.md](database-postgres-en.md)**
   **PostgreSQL配置文档** (3-4KB)
   
   📍 **适合人群**: 需要配置和管理数据库的DBA/DevOps
   
   **包含内容**:
   - PostgreSQL连接配置
   - 只读用户设置
   - 数据库初始化说明

---

## 🔧 SQL文件

### 5. **[fin_store_complete_schema.sql](fin_store_complete_schema.sql)**
   **完整的DDL定义文件** (42KB)
   
   📍 **用途**: 重新创建或初始化数据库
   
   **特点**:
   - ✅ 包含所有61个表的完整定义
   - ✅ 包含所有223个索引定义
   - ✅ 包含中文注释（表和部分列）
   - ✅ 可直接导入PostgreSQL
   
   **使用方法**:
   ```bash
   psql -U myuser -d fin_store < fin_store_complete_schema.sql
   ```

---

### 6. **[fin_store_schema_with_comments.sql](fin_store_schema_with_comments.sql)**
   **注释版DDL文件** (33KB)
   
   📍 **用途**: 参考文档，包含详细的中文注释
   
   **特点**:
   - ✅ 每个表都有详细的中文注释
   - ✅ 关键列都有中文说明
   - ✅ 包含表的用途和数据来源标注

---

## 🎯 按使用场景快速查找

### "我想了解数据库有哪些表"
→ 阅读 **database-schema-guide.md** 第1-11节

### "我需要知道某个表有哪些列"
→ 查看 **database-complete-column-reference.md** 相应部分

### "我想了解如何选择复权数据"
→ 查看 **database-data-dictionary.md** 第3节

### "我想分析龙虎榜数据"
→ 查看 **database-data-dictionary.md** 第4节

### "我想查看基金流向指标"
→ 查看 **database-data-dictionary.md** 第5节

### "我想优化查询性能"
→ 查看 **database-data-dictionary.md** 第10节

### "我想检查数据质量"
→ 查看 **database-data-dictionary.md** 第9节

### "我想了解数据来源"
→ 查看 **database-data-dictionary.md** 第1-2节

### "我需要重建数据库"
→ 使用 **fin_store_complete_schema.sql**

### "我需要查看完整的DDL定义"
→ 参考 **fin_store_schema_with_comments.sql**

---

## 📊 文档统计

| 文档 | 类型 | 大小 | 表数 | 列数 |
|------|------|------|------|------|
| database-schema-guide.md | Markdown | 16KB | 13个类别 | - |
| database-complete-column-reference.md | Markdown | 16KB | 61个 | 500+ |
| database-data-dictionary.md | Markdown | 13KB | - | 应用指南 |
| fin_store_complete_schema.sql | SQL | 42KB | 61个 | 500+ |
| fin_store_schema_with_comments.sql | SQL | 33KB | 主要表 | 中文注释 |

**总计**: 
- 📄 3份Markdown指南文档
- 🗄️ 2份SQL定义文件
- 📊 61个数据库表
- 🔑 223个索引
- 📝 500+列的完整定义

---

## 🚀 开始使用

### 第一步：了解数据结构
1. 阅读 **database-schema-guide.md** 的概述部分
2. 浏览各个表的分类和用途

### 第二步：深入学习
1. 针对你感兴趣的表，在 **database-complete-column-reference.md** 中查看完整的列定义
2. 查看 **database-data-dictionary.md** 了解该表的使用方法和最佳实践

### 第三步：实际应用
1. 使用提供的SQL模板进行查询
2. 参考"最佳实践"部分优化你的应用

### 第四步：维护优化
1. 定期运行 **数据质量检查SQL**（database-data-dictionary.md 第9节）
2. 参考 **性能优化建议**（database-data-dictionary.md 第10节）

---

## 💡 关键概念速查

### 复权类型选择表
| 场景 | 推荐表 | 原因 |
|------|--------|------|
| 长期策略回测 | stock_history_qfq | 数据连贯 |
| 近期分析 | stock_history_hfq | 最新价格准确 |
| 实盘操作 | stock_history_hfq | 与市场一致 |
| K线绘制 | stock_history_hfq | 视觉效果好 |

### 数据来源标识
| 数据来源 | 标识 | 表名特征 |
|---------|------|--------|
| AKShare | 主数据源 | 大多数表（除了bao_k） |
| BaoStock | 补充数据源 | 表名包含 `bao_k` |

### 表类别快速索引
| 类别 | 核心表 | 主要列 |
|------|--------|--------|
| 价格数据 | stock_history* | open, close, high, low |
| 实时行情 | stock_zh_a_spot_em* | symbol, trade_date |
| 热点数据 | stock_lhb*, stock_news | symbol, trade_date |
| 基金流向 | stock_fund_* | inflow, outflow, net_inflow |
| 排名数据 | stock_rank_* | symbol, range_type |
| 板块数据 | stock_board_* | board_name, symbol |
| 账户数据 | stock_account_* | symbol, quantity, price |

---

## 📞 常见问题速查

**Q: 数据更新频率是多少?**
→ 见 **database-data-dictionary.md** 第11节

**Q: 哪些表有高频实时数据?**
→ 表名包含 `realtime` 的表

**Q: 如何快速找到涨停板股票?**
→ 查询 `stock_pool_zt` 表

**Q: 龙虎榜数据在哪里?**
→ 查询 `stock_lhb_*` 系列表

**Q: 如何查询资金流向?**
→ 查询 `stock_fund_*` 系列表

---

## 🔗 相关资源

### 数据来源官方链接
- **AKShare**: https://www.akshare.xyz/
- **BaoStock**: http://baostock.com/

### 项目相关文件
- 项目根目录: [README.md](../../README.md)
- 配置文件: [config/strategy_config.json](../../config/strategy_config.json)
- 源代码: [src/genius_stock_aiquant/](../../src/genius_stock_aiquant/)

---

**文档最后更新**: 2024年3月22日  
**文档版本**: 1.0  
**维护者**: GeniusStockAIQuant项目

