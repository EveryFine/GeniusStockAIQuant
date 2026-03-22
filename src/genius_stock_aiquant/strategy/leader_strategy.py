"""Industry leader / relative-strength style strategy."""

from __future__ import annotations

from .base import BaseStrategy


class LeaderStrategy(BaseStrategy):
    def name(self) -> str:
        return "leader"
