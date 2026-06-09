"""
Result Builder: Consolidates execution results and persists them into the Supabase database.
"""
from typing import Dict, Any, List
from app.core.database import supabase_admin
from app.core.exceptions import SupabaseError

class ResultBuilder:
    @staticmethod
    def persist_results(
        student_id: str,
        facts: Any,
        issues: List[Dict[str, Any]],
        recommendations: List[Dict[str, Any]],
        analyzed_by: str = "system"
    ) -> str:
        """
        Saves the analysis results to Supabase and marks previous ones as not latest.
        """
        try:
            # 1. Query the latest version to increment it
            version = 1
            ver_res = supabase_admin.table("analysis_results")\
                .select("analysis_version")\
                .eq("student_id", student_id)\
                .order("analysis_version", desc=True)\
                .limit(1)\
                .execute()
            if ver_res.data and ver_res.data[0].get("analysis_version") is not None:
                version = ver_res.data[0]["analysis_version"] + 1

            # 2. Update previous student analysis results to set is_latest = False
            supabase_admin.table("analysis_results")\
                .update({"is_latest": False})\
                .eq("student_id", student_id)\
                .execute()

            # 3. Extract metrics from facts
            plan_id = facts.get("study_plan_id")
            calculated_gpa = facts.get("calculated_gpa") or 0.0
            total_attempted_hours = facts.get("total_attempted_hours") or 0
            total_passed_hours = facts.get("total_passed_hours") or 0

            # Count severities in issues
            errors_count = sum(1 for iss in issues if iss.get("severity") == "error")
            warnings_count = sum(1 for iss in issues if iss.get("severity") == "warning")
            info_count = sum(1 for iss in issues if iss.get("severity") == "info")

            # Check eligibility to graduate
            report = None
            if hasattr(facts, "get"):
                try:
                    report = facts.get("graduation_readiness_report")
                except Exception:
                    pass
            if not report:
                report = getattr(facts, "graduation_readiness_report", None)
            
            is_eligible = False
            if isinstance(report, dict):
                is_eligible = report.get("is_eligible", False)

            # Compute graduation percentage
            grad_req = facts.get("graduation_req") or {}
            req_hours = grad_req.get("required_hours") or 136
            graduation_percentage = min(100.0, (total_passed_hours / req_hours) * 100.0) if req_hours > 0 else 0.0

            # 4. Create analysis_result record
            result_payload = {
                "student_id": student_id,
                "plan_id": plan_id,
                "calculated_gpa": calculated_gpa,
                "total_attempted_hours": total_attempted_hours,
                "total_passed_hours": total_passed_hours,
                "graduation_percentage": round(graduation_percentage, 2),
                "is_eligible_to_graduate": is_eligible,
                "errors_count": errors_count,
                "warnings_count": warnings_count,
                "info_count": info_count,
                "analyzed_by": analyzed_by,
                "is_latest": True,
                "analysis_version": version
            }
            
            res_insert = supabase_admin.table("analysis_results").insert(result_payload).execute()
            if not res_insert.data:
                raise SupabaseError("Failed to insert analysis result record.")
            
            analysis_id = res_insert.data[0]["id"]

            # 5. Insert issues
            if issues:
                issue_records = []
                for iss in issues:
                    issue_records.append({
                        "analysis_id": analysis_id,
                        "student_id": student_id,
                        "rule_code": iss["rule_code"],
                        "severity": iss["severity"],
                        "title": iss["title"],
                        "description": iss["description"],
                        "suggestion": iss.get("suggestion")
                    })
                supabase_admin.table("analysis_issues").insert(issue_records).execute()

            # 6. Insert recommendations (sorted by priority)
            if recommendations:
                rec_records = []
                # Deduplicate by course_code
                seen = set()
                # Sort by priority ascending (1 = highest priority)
                sorted_recs = sorted(recommendations, key=lambda r: r.get("priority", 3))

                for rec in sorted_recs:
                    c_code = rec["course_code"]
                    if c_code not in seen:
                        seen.add(c_code)
                        # Format the recommendation text nicely in Arabic
                        name = rec.get("course_name") or "مقرر مقترح"
                        reason = rec.get("reason") or ""
                        rec_text = f"مقرر مقترح: {c_code} ({name}) - {reason}"
                        rec_records.append({
                            "analysis_id": analysis_id,
                            "student_id": student_id,
                            "recommendation": rec_text,
                            "priority": rec.get("priority", 3)
                        })
                if rec_records:
                    supabase_admin.table("analysis_recommendations").insert(rec_records).execute()

            return analysis_id

        except Exception as e:
            raise SupabaseError(f"Failed to persist analysis results: {str(e)}")
