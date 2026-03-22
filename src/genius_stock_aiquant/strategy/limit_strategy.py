"""Limit-up related strategy and screening hooks."""

from __future__ import annotations

from .base import BaseStrategy


class LimitStrategy(BaseStrategy):
    def name(self) -> str:
        return "limit_up"
