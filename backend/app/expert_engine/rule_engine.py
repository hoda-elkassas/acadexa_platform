"""
Rule Engine: Orchestrates execution of all academic rules against loaded student facts.
Implements error isolation to prevent rule crashes from halting the pipeline.
"""
import logging
from typing import Dict, Any, List, Tuple
from app.expert_engine.rules import (
    gpa_rules,
    hours_rules,
    prerequisite_rules,
    load_rules,
    training_rules,
    elective_rules,
    graduation_rules,
)

logger = logging.getLogger("acadexa.rule_engine")

class RuleEngine:
    def __init__(self, facts: Any):
        self.facts = facts
        self.issues: List[Dict[str, Any]] = []
        self.recommendations: List[Dict[str, Any]] = []

    def run_all_rules(self) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
        """
        Executes all rule modules sequentially with safe exception handling.
        Returns a tuple of (issues list, recommendations list).
        """
        modules = [
            ("gpa_rules", gpa_rules),
            ("hours_rules", hours_rules),
            ("prerequisite_rules", prerequisite_rules),
            ("load_rules", load_rules),
            ("training_rules", training_rules),
            ("elective_rules", elective_rules),
            ("graduation_rules", graduation_rules),
        ]

        for name, mod in modules:
            self._run_rule_safe(name, mod)

        return self.issues, self.recommendations

    def _run_rule_safe(self, name: str, module: Any):
        """Executes a single check module safely, isolating any exceptions."""
        try:
            module.check(self.facts, self.issues, self.recommendations)
        except Exception as e:
            logger.exception(f"Rule module {name} crashed during evaluation.")
            self.issues.append({
                "rule_code": "SYSTEM_RULE_CRASH",
                "severity": "warning",
                "title": f"فشل في تقييم وحدة القواعد: {name}",
                "description": f"حدث خطأ غير متوقع أثناء معالجة القواعد الخاصة بـ {name}: {str(e)}",
                "suggestion": "يرجى مراجعة إدارة النظام للتحقق من سلامة البيانات والتهيئة."
            })
