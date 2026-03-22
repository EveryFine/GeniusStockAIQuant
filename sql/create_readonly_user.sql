-- =============================================================================
-- 创建只读数据库用户（供 GeniusStockAIQuant 等客户端使用）
--
-- 使用前请替换占位符：
--   <readonly_user>   例如 gsaq_readonly
--   <strong_password> 强密码
--   <your_database>   实际库名
--
-- 在 psql 中以超级用户执行；含 \c 的为 psql 元命令，若用其它客户端请改为
-- 先连接到 <your_database> 再执行对应 GRANT。
-- =============================================================================

-- 1) 登录角色（无建库、复制等权限）
CREATE ROLE <readonly_user> WITH LOGIN PASSWORD '<strong_password>'
  NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;

-- 2) 允许连接指定数据库（在任意库中执行均可，常用：先连到 postgres）
GRANT CONNECT ON DATABASE <your_database> TO <readonly_user>;

-- 3) 切换到存放行情表的数据库，再授权 schema / 表
\c <your_database>

GRANT USAGE ON SCHEMA public TO <readonly_user>;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO <readonly_user>;

-- 4) 若表不在 public，把 public 改成实际 schema，例如 market：
-- GRANT USAGE ON SCHEMA market TO <readonly_user>;
-- GRANT SELECT ON ALL TABLES IN SCHEMA market TO <readonly_user>;

-- 5) 以后新建表时，希望只读用户自动可读，需由「建表用户」执行（或由超级用户指定角色）：
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO <readonly_user>;
