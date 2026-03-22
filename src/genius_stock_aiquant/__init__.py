"""GeniusStockAIQuant — A-share quantitative trading toolkit."""

import os
from pathlib import Path

# Auto-load .env file from project root
env_file = Path(__file__).parent.parent.parent / ".env"
if env_file.exists():
    from dotenv import load_dotenv
    load_dotenv(env_file, override=False)

__version__ = "0.1.0"
