# PostgreSQL 数据接入

[English version](database-postgres-en.md)

本文说明如何为 **GeniusStockAIQuant** 配置 PostgreSQL：包括**建议使用的只读账号**、权限说明，以及与项目环境变量的对应关系。可执行的 SQL 模板见仓库内 [`sql/create_readonly_user.sql`](../sql/create_readonly_user.sql)。

---

## 1. 为什么使用只读用户

- 策略与数据加载通常只需要 **SELECT**，不需要建表、改表或删数据。
- 使用独立只读角色可降低误操作与凭证泄露时的风险。
- 本项目的 `DataLoader` 默认通过 `psycopg2` 连接数据库，在 `.env` 中填写只读账号即可。

---

## 2. 创建只读用户（步骤概要）

在 **psql** 中以**超级用户**（或具备 `CREATEROLE` 及目标库管理权限的账号）执行。完整脚本（含占位符）见 [`sql/create_readonly_user.sql`](../sql/create_readonly_user.sql)。

将下面示例中的 `gsaq_readonly`、`你的强密码`、`你的库名` 换成实际值；若行情表不在 `public` schema，请将 `public` 改为实际 schema（如 `market`）。

```sql
-- 1) 只读登录角色
CREATE ROLE gsaq_readonly WITH LOGIN PASSWORD '你的强密码'
  NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;

-- 2) 允许连接目标库（可在任意库中执行，常见为先连到 postgres）
GRANT CONNECT ON DATABASE 你的库名 TO gsaq_readonly;

-- 3) 连接到目标库后，授权 schema 与表（以下为 psql 的切换库命令）
\c 你的库名
GRANT USAGE ON SCHEMA public TO gsaq_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO gsaq_readonly;
```

| 语句 | 含义 |
|------|------|
| `CREATE ROLE ... LOGIN` | 创建可登录用户，并关闭建库、超级用户等高风险属性 |
| `GRANT CONNECT ON DATABASE` | 允许连接该数据库 |
| `GRANT USAGE ON SCHEMA` | 允许访问该 schema（否则无法使用其中的对象） |
| `GRANT SELECT ON ALL TABLES` | 对**当前已存在**的表授予只读 |

### 2.1 非 public schema

若表在其它 schema 下，将 `public` 替换为实际名称，例如：

```sql
GRANT USAGE ON SCHEMA market TO gsaq_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA market TO gsaq_readonly;
```

### 2.2 以后新建的表

`GRANT SELECT ON ALL TABLES` 只覆盖**执行当时已存在的表**。若希望以后由某用户新建的表也自动对只读用户开放 **SELECT**，需要由**建表用户**（或超级用户）执行：

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO gsaq_readonly;
```

（将 `public` 换成你的 schema。）

---

## 3. 与项目配置对应

1. 复制仓库根目录的 [`.env.example`](../.env.example) 为 `.env`（勿提交 Git）。
2. 使用只读账号填写连接信息，例如：

   `DATABASE_URL=postgresql://gsaq_readonly:你的强密码@localhost:5432/你的库名`

   或使用离散变量：`GSAQ_PG_HOST`、`GSAQ_PG_DB`、`GSAQ_PG_USER`、`GSAQ_PG_PASSWORD` 等。
3. 表名、列名若与默认不一致，通过 `GSAQ_PG_TABLE`、`GSAQ_PG_CODE_COLUMN` 等映射，详见 `.env.example`。
4. 连通性检查：`python scripts/ping_db.py`（需已 `pip install -e .`）。

---

## 4. 安全提示

- 勿在仓库中提交 `.env` 或真实密码。
- 生产环境建议使用强密码，并限制数据库仅内网或可信网络可访问。
- 若需撤销权限，由管理员使用 `REVOKE` / `DROP ROLE`（在确认无依赖后）处理。

---

## 5. 相关文件

| 文件 | 说明 |
|------|------|
| [`sql/create_readonly_user.sql`](../sql/create_readonly_user.sql) | 带注释的可执行 SQL 模板（占位符） |
| [`.env.example`](../.env.example) | 连接与表映射环境变量示例 |
