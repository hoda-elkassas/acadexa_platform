"""
Import Service: Consumes parser output and populates Supabase database.
Bypasses RLS using the supabase_admin client.
Logs events in Arabic and technical errors in English.
"""
import asyncio
import logging
import os
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from app.core.database import (
    supabase_admin,
    execute_rpc,
    fetch_one,
    fetch_many,
    insert_one,
    update_one,
)
from app.services.file_parser import ExcelFileParser, ParsedSemester, SPECIAL_SYMBOLS

logger = logging.getLogger("acadexa.import_service")

# Cache for study plan grading scales
_grade_scale_cache: Dict[str, Dict[str, float]] = {}


def calculate_semester_gpa(courses: List[Any], scale: Dict[str, float]) -> Optional[float]:
    """Calculate semester GPA from courses using a specific grade scale."""
    total_points = 0.0
    total_hours = 0
    for c in courses:
        if c.grade_letter in SPECIAL_SYMBOLS:
            continue
        if c.credit_hours <= 0:
            continue
        pts = scale.get(c.grade_letter)
        if pts is None:
            continue
        total_points += pts * c.credit_hours
        total_hours += c.credit_hours
    if total_hours == 0:
        return None
    return round(total_points / total_hours, 4)


def calculate_cumulative_gpa(semesters: List[ParsedSemester], scale: Dict[str, float]) -> Optional[float]:
    """Calculate cumulative GPA across all semesters from course-level data using a specific grade scale."""
    total_points = 0.0
    total_hours = 0
    for sem in semesters:
        for c in sem.courses:
            if c.grade_letter in SPECIAL_SYMBOLS:
                continue
            if c.credit_hours <= 0:
                continue
            pts = scale.get(c.grade_letter)
            if pts is None:
                continue
            total_points += pts * c.credit_hours
            total_hours += c.credit_hours
    if total_hours == 0:
        return None
    return round(total_points / total_hours, 4)


async def _get_grade_scale(plan_id: str) -> Dict[str, float]:
    """Fetch and cache grade scale items for a given study plan."""
    if plan_id in _grade_scale_cache:
        return _grade_scale_cache[plan_id]

    scale_id = None
    try:
        # First check the study plan's default_grading_scale_id
        plan = await fetch_one("study_plans", {"id": plan_id})
        if plan and plan.get("default_grading_scale_id"):
            scale_id = plan["default_grading_scale_id"]
        else:
            # Fallback to fetching scale from grading_scales table
            scale = await fetch_one("grading_scales", {"plan_id": plan_id})
            if scale:
                scale_id = scale["id"]

        if scale_id:
            items = await fetch_many("grade_scale_items", {"grade_scale_id": scale_id})
            scale_dict = {item["grade_letter"]: float(item["points"]) for item in items}
            _grade_scale_cache[plan_id] = scale_dict
            return scale_dict
    except Exception as e:
        logger.warning(f"Failed to fetch grade scale for study plan {plan_id}: {e}")

    return {}


async def _upsert_student(student: Any, department_id: str, plan_id: Optional[str], import_job_id: str, level_num: int) -> str:
    """Upsert student profile record and return student UUID."""
    student_payload = {
        "student_code": student.student_code,
        "name": student.name,
        "department_id": department_id,
        "study_plan_id": plan_id,
        "enrollment_year": student.enrollment_year,
        "study_level": level_num,
        "cumulative_gpa": student.cumulative_gpa,
        "cumulative_percentage": student.cumulative_percentage,
        "is_active": True,
        "import_job_id": import_job_id,
    }

    def _call():
        res = supabase_admin.table("students").upsert(student_payload, on_conflict="student_code").execute()
        if not res.data:
            raise RuntimeError(f"Upsert student {student.student_code} returned no data.")
        return res.data[0]["id"]

    return await asyncio.to_thread(_call)


async def _upsert_semesters(student_id: str, semesters: List[ParsedSemester]) -> Dict[int, str]:
    """Upsert student semesters and return a mapping of semester_number -> semester UUID."""
    if not semesters:
        return {}

    semester_payloads = []
    for sem in semesters:
        semester_payloads.append({
            "student_id": student_id,
            "semester_number": sem.semester_number,
            "academic_year": sem.academic_year,
            "term": sem.term,
            "total_hours": sem.total_hours,
            "semester_gpa": sem.semester_gpa,
        })

    def _call():
        res = supabase_admin.table("student_semesters").upsert(semester_payloads, on_conflict="student_id,semester_number").execute()
        if not res.data:
            raise RuntimeError("Upsert semesters returned no data.")
        return {row["semester_number"]: row["id"] for row in res.data}

    return await asyncio.to_thread(_call)


async def _insert_courses(student_id: str, semester_id_map: Dict[int, str], semesters: List[ParsedSemester]):
    """Insert student courses if they do not already exist, using the DB RPC function."""
    # 1. Fetch existing student courses to avoid duplicate insertions
    def _fetch_existing():
        res = supabase_admin.table("student_courses").select("id, semester_id, course_code").eq("student_id", student_id).execute()
        return res.data or []

    existing_courses = await asyncio.to_thread(_fetch_existing)
    existing_set = {
        (c["semester_id"], c["course_code"]) for c in existing_courses
    }

    # 2. Fetch official curriculum courses to map course codes to catalog IDs
    def _fetch_official():
        res = supabase_admin.table("courses").select("id, code").execute()
        return {row["code"]: row["id"] for row in res.data or []}

    course_code_to_id = await asyncio.to_thread(_fetch_official)

    for sem in semesters:
        semester_id = semester_id_map.get(sem.semester_number)
        if not semester_id:
            continue

        for course in sem.courses:
            if (semester_id, course.course_code) in existing_set:
                # Course already imported for this semester, skip
                continue

            # Call RPC to insert with grade lookup validation
            def _insert():
                res = supabase_admin.rpc("insert_student_course", {
                    "p_student_id": student_id,
                    "p_semester_id": semester_id,
                    "p_course_code": course.course_code,
                    "p_course_name": course.course_name,
                    "p_credit_hours": course.credit_hours,
                    "p_grade_letter": course.grade_letter,
                }).execute()
                if not res.data:
                    raise RuntimeError(f"insert_student_course RPC failed to return record ID for {course.course_code}")
                return res.data

            course_row_id = await asyncio.to_thread(_insert)

            # Update additional properties (score, is_retake, retake_count, course_id)
            course_db_id = course_code_to_id.get(course.course_code)
            update_payload = {}
            if course_db_id:
                update_payload["course_id"] = course_db_id
            if course.score is not None:
                update_payload["score"] = course.score
            if course.is_retake:
                update_payload["is_retake"] = True
                update_payload["retake_count"] = course.retake_count

            if update_payload:
                def _update():
                    supabase_admin.table("student_courses").update(update_payload).eq("id", course_row_id).execute()

                await asyncio.to_thread(_update)


async def _process_student(student: Any, department_id: str, import_job_id: str) -> Tuple[bool, Optional[str]]:
    """Process a single parsed student: resolve plan, recalculate GPA, and upsert records."""
    logger.info(f"بدء معالجة الطالب ذو الكود: {student.student_code}")

    # 1. Resolve student plan ID
    plan_id = None
    try:
        plan_id = await execute_rpc("resolve_student_plan", {
            "p_department_id": department_id,
            "p_enrollment_year": student.enrollment_year or 2023,
        })
    except Exception as e:
        logger.warning(f"Could not resolve study plan for student {student.student_code}: {e}")

    # 2. Fetch grade scale and recalculate GPAs if plan exists
    grade_scale = {}
    if plan_id:
        grade_scale = await _get_grade_scale(plan_id)

    if grade_scale:
        for semester in student.semesters:
            for course in semester.courses:
                pts = grade_scale.get(course.grade_letter)
                if pts is not None:
                    course.grade_points = pts
                    course.passed = pts > 0 and course.grade_letter != "F"
            semester.semester_gpa = calculate_semester_gpa(semester.courses, grade_scale)
            semester.total_hours = sum(c.credit_hours for c in semester.courses if c.passed and c.credit_hours > 0)

        student.cumulative_gpa = calculate_cumulative_gpa(student.semesters, grade_scale)
        student.total_passed_hours = sum(s.total_hours for s in student.semesters)

    # Map level string to integer
    level_num = 1
    from app.services.file_parser import LEVEL_MAP
    for k, v in LEVEL_MAP.items():
        if k in (student.study_level_str or ""):
            level_num = v
            break

    # 3. Upsert student
    try:
        student_id = await _upsert_student(student, department_id, plan_id, import_job_id, level_num)
    except Exception as e:
        return False, f"فشل استيراد الملف الشخصي للطالب: {e}"

    # 4. Upsert semesters
    try:
        semester_id_map = await _upsert_semesters(student_id, student.semesters)
    except Exception as e:
        return False, f"فشل استيراد الفصول الدراسية للطالب: {e}"

    # 5. Insert courses
    try:
        await _insert_courses(student_id, semester_id_map, student.semesters)
    except Exception as e:
        return False, f"فشل استيراد مساقات الطالب: {e}"

    logger.info(f"تم استيراد بيانات الطالب {student.student_code} بنجاح.")
    return True, None


class ImportService:
    @staticmethod
    async def create_import_job(filename: str, department_id: str, uploaded_by: Optional[str]) -> str:
        """Create an import job record in the database with status 'pending'."""
        job_id = str(uuid.uuid4())
        payload = {
            "id": job_id,
            "filename": filename,
            "department_id": department_id,
            "status": "pending",
            "total_students": 0,
            "successful": 0,
            "failed": 0,
            "error_log": [],
            "uploaded_by": uploaded_by,
        }
        await insert_one("import_jobs", payload)
        return job_id

    @staticmethod
    async def process_import_job(import_job_id: str, file_path: str, department_id: str):
        """Asynchronously process the import job in the background."""
        logger.info(f"بدء عملية استيراد السجل الأكاديمي للملف: {os.path.basename(file_path)}")

        # Update job status to processing
        await update_one("import_jobs", {"id": import_job_id}, {"status": "processing"})

        try:
            # Parse the workbook
            parser = ExcelFileParser()
            parsed_data = await asyncio.to_thread(parser.parse_workbook, Path(file_path))

            if parsed_data.errors and not parsed_data.students:
                logger.error(f"Failed parsing workbook entirely: {parsed_data.errors}")
                await update_one("import_jobs", {"id": import_job_id}, {
                    "status": "failed",
                    "error_log": [{"error": err} for err in parsed_data.errors],
                })
                return

            total_students = len(parsed_data.students)
            await update_one("import_jobs", {"id": import_job_id}, {"total_students": total_students})

            # Process students concurrently with a limit of 10
            semaphore = asyncio.Semaphore(10)
            successful_count = 0
            failed_count = 0
            error_log = [{"error": err} for err in parsed_data.errors]

            async def process_task(student: Any):
                nonlocal successful_count, failed_count
                async with semaphore:
                    try:
                        success, err_msg = await _process_student(student, department_id, import_job_id)
                        if success:
                            successful_count += 1
                        else:
                            failed_count += 1
                            error_log.append({"student_code": student.student_code, "error": err_msg})
                    except Exception as e:
                        failed_count += 1
                        error_log.append({"student_code": student.student_code, "error": str(e)})

                    # Periodically update progress
                    await update_one("import_jobs", {"id": import_job_id}, {
                        "successful": successful_count,
                        "failed": failed_count,
                        "error_log": error_log,
                    })

            # Run all tasks
            tasks = [process_task(s) for s in parsed_data.students]
            await asyncio.gather(*tasks)

            # Determine final job status
            if successful_count > 0 and failed_count > 0:
                final_status = "partial_success"
            elif successful_count > 0:
                final_status = "completed"
            else:
                final_status = "failed"

            await update_one("import_jobs", {"id": import_job_id}, {
                "status": final_status,
                "successful": successful_count,
                "failed": failed_count,
                "error_log": error_log,
            })
            logger.info(f"اكتملت عملية الاستيراد بنجاح. إجمالي المقبولين: {successful_count}، إجمالي الفاشلين: {failed_count}.")

        except Exception as e:
            logger.error(f"Unhandled error in import job {import_job_id}: {e}", exc_info=True)
            await update_one("import_jobs", {"id": import_job_id}, {
                "status": "failed",
                "error_log": [{"error": f"Internal process error: {str(e)}"}],
            })
        finally:
            # Guarantee file deletion
            if os.path.exists(file_path):
                try:
                    os.remove(file_path)
                    logger.info(f"Cleaned up temporary upload file: {file_path}")
                except Exception as e:
                    logger.error(f"Failed to delete temp file {file_path}: {e}")
