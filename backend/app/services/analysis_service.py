"""
Analysis Service: Handles simulation of planned schedules and department-wide batch runs,
as well as analysis history queries and graduation readiness calculations.
"""
import asyncio
import uuid
import logging
from typing import Dict, Any, List

from app.core.database import supabase_admin
from app.services.expert_system import ExpertSystemService
from app.expert_engine.fact_loader import FactLoader
from app.expert_engine.rule_engine import RuleEngine
from app.core.exceptions import NotFoundError, SupabaseError

logger = logging.getLogger("acadexa.analysis_service")

class AnalysisService:
    @staticmethod
    async def simulate_plan(student_id: str, planned_courses: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Simulates GPA and passed hours, and runs validation rules on the planned sequence.
        """
        # 1. Load the raw data for the student
        loader = FactLoader()
        raw_data = await loader.load_raw_data(student_id)
        
        # 2. Extract next semester number
        semesters = raw_data.get("semesters") or []
        next_sem_num = max([s.get("semester_number") or 0 for s in semesters]) + 1 if semesters else 1
        
        # 3. Term details
        simulated_term_name = "الفصل الدراسي المحاكى"
        
        # 4. Map plan courses and grading scale
        plan_id = raw_data["student"].get("study_plan_id")
        try:
            scale = loader._get_grading_scale_sync(plan_id)
        except Exception:
            scale = {
                "A+": 4.0, "A": 4.0, "A-": 3.7,
                "B+": 3.3, "B": 3.0, "B-": 2.7,
                "C+": 2.3, "C": 2.0, "C-": 1.7,
                "D+": 1.3, "D": 1.0, "D-": 0.7,
                "F": 0.0
            }
            
        # 5. Add planned courses to raw_data["all_courses"]
        simulated_semester_id = "simulated_sem_1"
        sim_courses = [dict(c) for c in raw_data["all_courses"]]
        
        total_planned_hours = 0
        for pc in planned_courses:
            code = pc.get("code")
            hrs = pc.get("credit_hours") or 3
            grade = pc.get("grade") or "A"
            pts = scale.get(grade, 4.0)
            is_passed = grade not in {"F", "FA"} and pts > 0.0
            
            sim_courses.append({
                "course_code": code,
                "credit_hours": hrs,
                "grade_letter": grade,
                "status": "passed" if is_passed else "failed",
                "semester_id": simulated_semester_id,
                "semester_number": next_sem_num
            })
            total_planned_hours += hrs
            
        # 6. Add simulated semester to raw_data["semesters"]
        sim_semesters = [dict(s) for s in semesters]
        sim_semesters.append({
            "id": simulated_semester_id,
            "semester_name": simulated_term_name,
            "semester_number": next_sem_num,
            "registered_hours": total_planned_hours,
            "gpa": 0.0,
            "gpa_cumulative": 0.0
        })
        
        # 7. Update raw_data with simulated lists
        raw_data_sim = dict(raw_data)
        raw_data_sim["all_courses"] = sim_courses
        raw_data_sim["semesters"] = sim_semesters
        
        # 8. Compute simulated facts
        sim_facts = loader._compute_derived_facts(raw_data_sim)
        
        # 9. Compute current facts (unsimulated) for comparison
        current_facts = loader._compute_derived_facts(raw_data)
        
        # 10. Run rule engine on simulated facts to detect warnings/errors
        engine = RuleEngine(sim_facts)
        issues, _ = engine.run_all_rules()
        
        # 11. Extract warning descriptions to return
        warnings_list = []
        for issue in issues:
            severity_str = "خطأ" if issue["severity"] == "error" else "تحذير" if issue["severity"] == "warning" else "معلومة"
            warnings_list.append(f"[{severity_str}] {issue['title']}: {issue['description']}")
            
        # 12. Calculate status change message
        current_gpa = current_facts.calculated_gpa
        simulated_gpa = sim_facts.calculated_gpa
        
        status_change = None
        if current_gpa < 2.0 and simulated_gpa >= 2.0:
            status_change = "رفع الإنذار الأكاديمي (وضع آمن)"
        elif simulated_gpa < 2.0:
            status_change = "وضع تحت الإنذار الأكاديمي"
            
        return {
            "current_gpa": round(current_gpa, 2),
            "simulated_gpa": round(simulated_gpa, 2),
            "current_passed_hours": current_facts.total_passed_hours,
            "simulated_passed_hours": sim_facts.total_passed_hours,
            "status_change": status_change,
            "warnings": warnings_list
        }

    @staticmethod
    async def run_batch_analysis(department_id: str = None, plan_id: str = None, student_ids: List[str] = None) -> str:
        """
        Runs analysis for multiple students asynchronously. Capped at 10 concurrent requests.
        """
        logger.info(f"بدء المعالجة الدفعية للطلاب - القسم: {department_id}, الخطة: {plan_id}, قائمة الطلاب: {student_ids}")
        
        query = supabase_admin.table("students").select("id")
        if student_ids:
            query = query.in_("id", student_ids)
        elif department_id:
            query = query.eq("department_id", department_id)
        elif plan_id:
            query = query.eq("study_plan_id", plan_id)

        def _fetch():
            res = query.execute()
            return res.data or []
            
        students_to_analyze = await asyncio.to_thread(_fetch)
        job_id = str(uuid.uuid4())
        
        if not students_to_analyze:
            logger.info("لا يوجد طلاب لمعالجتهم في الدفعة.")
            return job_id
            
        # Concurrency capped at 10 requests using asyncio.Semaphore
        semaphore = asyncio.Semaphore(10)
        
        async def analyze_with_semaphore(s_id: str):
            async with semaphore:
                try:
                    await ExpertSystemService.analyze_student(s_id)
                    logger.info(f"تمت معالجة الطالب {s_id} بنجاح.")
                except Exception as e:
                    logger.error(f"خطأ أثناء معالجة الطالب {s_id} في الدفعة: {str(e)}")

        tasks = [analyze_with_semaphore(std["id"]) for std in students_to_analyze]
        await asyncio.gather(*tasks)
        
        logger.info(f"اكتملت المعالجة الدفعية للمعرف {job_id}.")
        return job_id

    @staticmethod
    async def get_latest_analysis(student_id: str) -> Dict[str, Any]:
        """
        Retrieves the latest analysis results with issues and recommendations.
        """
        def _query():
            res = supabase_admin.table("analysis_results").select("*").eq("student_id", student_id).eq("is_latest", True).execute()
            if not res.data:
                return None, [], []
            result_row = res.data[0]
            analysis_id = result_row["id"]
            
            issues_res = supabase_admin.table("analysis_issues").select("*").eq("analysis_id", analysis_id).execute()
            recs_res = supabase_admin.table("analysis_recommendations").select("*").eq("analysis_id", analysis_id).execute()
            
            return result_row, issues_res.data or [], recs_res.data or []
            
        result_row, issues_rows, recs_rows = await asyncio.to_thread(_query)
        if not result_row:
            raise NotFoundError(f"No analysis results found for student {student_id}")
            
        return AnalysisService._map_db_result(result_row, issues_rows, recs_rows)

    @staticmethod
    async def get_analysis_history(student_id: str) -> List[Dict[str, Any]]:
        """
        Retrieves complete analysis history with detailed results.
        """
        def _query():
            res = supabase_admin.table("analysis_results").select("*").eq("student_id", student_id).order("analysis_version", desc=True).execute()
            return res.data or []
        results = await asyncio.to_thread(_query)
        
        async def get_full_result(res_row):
            def _query_details():
                issues_res = supabase_admin.table("analysis_issues").select("*").eq("analysis_id", res_row["id"]).execute()
                recs_res = supabase_admin.table("analysis_recommendations").select("*").eq("analysis_id", res_row["id"]).execute()
                return issues_res.data or [], recs_res.data or []
            issues_rows, recs_rows = await asyncio.to_thread(_query_details)
            return AnalysisService._map_db_result(res_row, issues_rows, recs_rows)
            
        tasks = [get_full_result(r) for r in results]
        return await asyncio.gather(*tasks)

    @staticmethod
    async def get_analysis_issues(analysis_id: str) -> List[Dict[str, Any]]:
        """
        Retrieves all issues associated with a specific analysis run.
        """
        def _query():
            res = supabase_admin.table("analysis_issues").select("*").eq("analysis_id", analysis_id).execute()
            return res.data or []
        issues_rows = await asyncio.to_thread(_query)
        return [
            {
                "id": iss.get("id"),
                "analysis_id": iss["analysis_id"],
                "rule_code": iss["rule_code"],
                "severity": iss["severity"],
                "title": iss["title"],
                "description": iss["description"],
                "suggestion": iss.get("suggestion")
            } for iss in issues_rows
        ]

    @staticmethod
    async def get_analysis_recommendations(analysis_id: str) -> List[Dict[str, Any]]:
        """
        Retrieves all course recommendations associated with a specific analysis run.
        """
        def _query():
            res = supabase_admin.table("analysis_recommendations").select("*").eq("analysis_id", analysis_id).execute()
            return res.data or []
        recs_rows = await asyncio.to_thread(_query)
        
        mapped_recs = []
        for rec in recs_rows:
            text = rec.get("recommendation", "")
            course_code = "SUGGESTED"
            course_name = text
            reason = ""
            if text.startswith("مقرر مقترح: "):
                parts = text[len("مقرر مقترح: "):].split(" (", 1)
                if len(parts) == 2:
                    course_code = parts[0]
                    subparts = parts[1].split(") - ", 1)
                    if len(subparts) == 2:
                        course_name = subparts[0]
                        reason = subparts[1]
                    else:
                        course_name = subparts[0].rstrip(")")
                else:
                    course_code = parts[0]
            mapped_recs.append({
                "id": rec.get("id"),
                "analysis_id": rec["analysis_id"],
                "course_code": course_code,
                "course_name": course_name,
                "priority": rec.get("priority", 3),
                "reason": reason
            })
        return mapped_recs

    @staticmethod
    async def delete_analysis_history(analysis_id: str) -> bool:
        """
        Deletes a specific analysis history record and cascading details. Re-points latest flag if needed.
        """
        def _delete():
            res_check = supabase_admin.table("analysis_results").select("student_id", "is_latest").eq("id", analysis_id).execute()
            if not res_check.data:
                return False
            student_id = res_check.data[0]["student_id"]
            was_latest = res_check.data[0]["is_latest"]
            
            # Delete details
            supabase_admin.table("analysis_recommendations").delete().eq("analysis_id", analysis_id).execute()
            supabase_admin.table("analysis_issues").delete().eq("analysis_id", analysis_id).execute()
            
            # Delete result
            supabase_admin.table("analysis_results").delete().eq("id", analysis_id).execute()
            
            # If it was the latest, update the new latest
            if was_latest:
                next_latest = supabase_admin.table("analysis_results")\
                    .select("id")\
                    .eq("student_id", student_id)\
                    .order("analysis_version", desc=True)\
                    .limit(1)\
                    .execute()
                if next_latest.data:
                    supabase_admin.table("analysis_results")\
                        .update({"is_latest": True})\
                        .eq("id", next_latest.data[0]["id"])\
                        .execute()
            return True
        return await asyncio.to_thread(_delete)

    @staticmethod
    async def get_graduation_readiness(student_id: str) -> Dict[str, Any]:
        """
        Loads facts for student_id and builds a graduation readiness report checklist.
        """
        facts = await FactLoader().load_facts(student_id)
        
        report = facts.get("graduation_readiness_report") or {}
        reqs = report.get("requirements") or {}
        
        checklist = []
        # 1. Total hours
        hours_req = reqs.get("total_hours") or {}
        checklist.append({
            "rule_name": "ساعات التخرج المطلوبة",
            "status": hours_req.get("met", False),
            "details": f"أنجز {hours_req.get('completed', 0)} من أصل {hours_req.get('required', 0)} ساعة"
        })
        
        # 2. GPA
        gpa_req = reqs.get("gpa") or {}
        checklist.append({
            "rule_name": "الحد الأدنى للمعدل التراكمي",
            "status": gpa_req.get("met", False),
            "details": f"المعدل التراكمي الحالي {gpa_req.get('completed', 0.0):.2f} (المطلوب {gpa_req.get('required', 0.0):.2f})"
        })
        
        # 3. Field training
        tr_req = reqs.get("field_training") or {}
        if tr_req.get("required"):
            checklist.append({
                "rule_name": "التدريب الميداني",
                "status": tr_req.get("met", False),
                "details": "تم إكمال متطلب التدريب الميداني" if tr_req.get("met") else "متطلب التدريب الميداني غير مكتمل"
            })
            
        # 4. Civic literacy
        civ_req = reqs.get("civic_literacy") or {}
        if civ_req.get("required", 0) > 0:
            checklist.append({
                "rule_name": "مقررات الثقافة المدنية",
                "status": civ_req.get("met", False),
                "details": f"أنجز {civ_req.get('completed', 0)} من أصل {civ_req.get('required', 0)} مقرر"
            })
            
        # 5. Community issues
        comm_req = reqs.get("community_issues") or {}
        if comm_req.get("required"):
            checklist.append({
                "rule_name": "مقرر القضايا المجتمعية",
                "status": comm_req.get("met", False),
                "details": "تم اجتياز مقرر القضايا المجتمعية" if comm_req.get("met") else "لم يتم اجتياز مقرر القضايا المجتمعية"
            })
            
        return {
            "student_id": student_id,
            "is_ready": report.get("is_eligible", False),
            "passed_hours": facts.get("total_passed_hours") or 0,
            "required_hours": hours_req.get("required", 136),
            "gpa": facts.get("calculated_gpa") or 0.0,
            "required_gpa": gpa_req.get("required", 2.0),
            "checklist": checklist
        }

    @staticmethod
    def _map_db_result(res_row: Dict[str, Any], issues_rows: List[Dict[str, Any]], recs_rows: List[Dict[str, Any]]) -> Dict[str, Any]:
        created_at = res_row.get("created_at") or res_row.get("analyzed_at") or ""
        if hasattr(created_at, "isoformat"):
            created_at = created_at.isoformat()
        else:
            created_at = str(created_at)
            
        mapped_recs = []
        for rec in recs_rows:
            text = rec.get("recommendation", "")
            course_code = "SUGGESTED"
            course_name = text
            reason = ""
            if text.startswith("مقرر مقترح: "):
                parts = text[len("مقرر مقترح: "):].split(" (", 1)
                if len(parts) == 2:
                    course_code = parts[0]
                    subparts = parts[1].split(") - ", 1)
                    if len(subparts) == 2:
                        course_name = subparts[0]
                        reason = subparts[1]
                    else:
                        course_name = subparts[0].rstrip(")")
                else:
                    course_code = parts[0]
            mapped_recs.append({
                "id": rec.get("id"),
                "analysis_id": rec["analysis_id"],
                "course_code": course_code,
                "course_name": course_name,
                "priority": rec.get("priority", 3),
                "reason": reason
            })
            
        return {
            "id": res_row["id"],
            "student_id": res_row["student_id"],
            "gpa": res_row.get("calculated_gpa") or 0.0,
            "passed_hours": res_row.get("total_passed_hours") or 0,
            "attempted_hours": res_row.get("total_attempted_hours") or 0,
            "graduation_percentage": res_row.get("graduation_percentage") or 0.0,
            "is_latest": res_row.get("is_latest") or False,
            "created_at": created_at,
            "issues": [
                {
                    "id": iss.get("id"),
                    "analysis_id": iss["analysis_id"],
                    "rule_code": iss["rule_code"],
                    "severity": iss["severity"],
                    "title": iss["title"],
                    "description": iss["description"],
                    "suggestion": iss.get("suggestion")
                } for iss in issues_rows
            ],
            "recommendations": mapped_recs
        }
