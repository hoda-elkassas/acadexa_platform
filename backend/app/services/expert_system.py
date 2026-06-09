"""
Expert System Service: Coordinates individual student evaluation by chaining FactLoader,
RuleEngine, and ResultBuilder together.
"""
from typing import Dict, Any
from app.expert_engine.fact_loader import FactLoader
from app.expert_engine.rule_engine import RuleEngine
from app.expert_engine.result_builder import ResultBuilder
from app.core.exceptions import NotFoundError, SupabaseError

class ExpertSystemService:
    @staticmethod
    async def analyze_student(student_id: str) -> Dict[str, Any]:
        """
        Loads facts for student_id, runs all rules, saves results, and returns summary.
        """
        # 1. Load facts (Working Memory)
        facts = await FactLoader().load_facts(student_id)
        
        # 2. Execute rules
        engine = RuleEngine(facts)
        issues, recommendations = engine.run_all_rules()

        # 3. Persist output
        analysis_id = ResultBuilder.persist_results(
            student_id=student_id,
            facts=facts,
            issues=issues,
            recommendations=recommendations
        )

        # Count issues by severity
        errors_count = sum(1 for i in issues if i["severity"] == "error")
        warnings_count = sum(1 for i in issues if i["severity"] == "warning")
        infos_count = sum(1 for i in issues if i["severity"] == "info")

        return {
            "analysis_id": analysis_id,
            "student_id": student_id,
            "student_name": facts.get("name") or facts.get("student_name"),
            "summary": {
                "gpa": facts.get("calculated_gpa") or facts.get("gpa") or 0.0,
                "passed_hours": facts.get("total_passed_hours") or facts.get("passed_hours") or 0,
                "errors_count": errors_count,
                "warnings_count": warnings_count,
                "infos_count": infos_count,
            }
        }
