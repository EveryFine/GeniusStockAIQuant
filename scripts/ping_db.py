#!/usr/bin/env python3
"""Verify PostgreSQL connectivity (uses env from .env.example / shell)."""

from __future__ import annotations

import sys

from genius_stock_aiquant.data_sources.postgres import load_postgres_config_from_env, ping_postgres


def main() -> None:
    if load_postgres_config_from_env() is None:
        print(
            "PostgreSQL env not configured. Set DATABASE_URL or GSAQ_PG_* — see .env.example.",
            file=sys.stderr,
        )
        sys.exit(1)
    ok = ping_postgres()
    print("database ping: OK" if ok else "database ping: FAILED")
    sys.exit(0 if ok else 2)


if __name__ == "__main__":
    main()
