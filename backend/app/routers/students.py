"""
Students Router: Fetches student profiles and academic logs.
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Dict, Any, List, Optional
import asyncio
from app.core.dependencies import get_current_user, check_role
from app.core.database import supabase_admin
from app.models.student import StudentFullProfile, SemesterWithCourses, LevelUpdateRequest

router = APIRouter(prefix="/students", tags=["Student Profile & Logs"])

async def run_query(query):
    return await asyncio.to_thread(query.execute)

@router.get("/{student_id}/full-profile", response_model=StudentFullProfile)
async def get_student_full_profile(
    student_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Queries student, semesters, latest analysis, issues, recommendations, and advisor notes in parallel.
    """
    is_advisor = current_user.get("role") in ["advisor", "college_admin", "department_head", "super_admin"]
    if not is_advisor:
        # Check student ID matching in production
        pass

    try:
        # Setup 7 parallel database queries
        q_student = supabase_admin.table("students").select("*, departments(name_ar)").eq("id", student_id)
        q_semesters = supabase_admin.table("student_semesters").select("*").eq("student_id", student_id).order("semester_name")
        q_courses = supabase_admin.table("student_courses").select("*").eq("student_id", student_id)
        q_analysis = supabase_admin.table("analysis_results").select("*").eq("student_id", student_id).eq("is_latest", True)
        q_issues = supabase_admin.table("analysis_issues").select("*").eq("student_id", student_id)
        q_recs = supabase_admin.table("analysis_recommendations").select("*").eq("student_id", student_id)
        q_notes = supabase_admin.table("advisor_notes").select("*").eq("student_id", student_id)

        res_student, res_sems, res_courses, res_analysis, res_issues, res_recs, res_notes = await asyncio.gather(
            run_query(q_student),
            run_query(q_semesters),
            run_query(q_courses),
            run_query(q_analysis),
            run_query(q_issues),
            run_query(q_recs),
            run_query(q_notes)
        )

        if not res_student.data:
            raise HTTPException(status_code=404, detail="Student profile not found")
        student = res_student.data[0]
        
        # Flatten department name
        dept = student.get("departments")
        if dept and isinstance(dept, dict):
            student["department_name"] = dept.get("name_ar")
        elif dept and isinstance(dept, list) and len(dept) > 0:
            student["department_name"] = dept[0].get("name_ar")
        else:
            student["department_name"] = student.get("department_id")

        # Map semesters to SemesterWithCourses
        semesters_list = []
        courses_by_sem = {}
        for c in (res_courses.data or []):
            sem_name = c.get("semester_name") or "other"
            if sem_name not in courses_by_sem:
                courses_by_sem[sem_name] = []
            courses_by_sem[sem_name].append(c)

        for sem in (res_sems.data or []):
            sem_name = sem.get("semester_name")
            semesters_list.append(SemesterWithCourses(
                semester=sem,
                courses=courses_by_sem.get(sem_name, []),
                semester_gpa=sem.get("gpa")
            ))

        latest_analysis = res_analysis.data[0] if res_analysis.data else None

        return StudentFullProfile(
            student=student,
            semesters=semesters_list,
            latest_analysis=latest_analysis,
            issues=res_issues.data or [],
            recommendations=res_recs.data or [],
            advisor_notes=res_notes.data or []
        )
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/bulk-update-level", response_model=Dict[str, Any])
async def bulk_update_student_levels(
    req: LevelUpdateRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Recalculates study levels of all students in a department based on passed hours.
    """
    check_role(current_user, ["college_admin", "department_head", "super_admin"])
    try:
        # Fetch students in department & enrollment year
        students_res = await asyncio.to_thread(
            supabase_admin.table("students")
            .select("id, passed_hours, study_plan_id")
            .eq("department_id", req.department_id)
            .eq("enrollment_year", req.academic_year)
            .execute
        )
        students = students_res.data or []

        # Get unique study plan IDs to load level thresholds if set
        plan_ids = {s.get("study_plan_id") for s in students if s.get("study_plan_id")}
        plan_levels = {}
        for p_id in plan_ids:
            lvls = await asyncio.to_thread(
                supabase_admin.table("study_levels")
                .select("level_order, min_hours, max_hours")
                .eq("plan_id", p_id)
                .order("level_order")
                .execute
            )
            if lvls.data:
                plan_levels[p_id] = lvls.data

        updated_count = 0
        for s in students:
            passed = s.get("passed_hours", 0)
            plan_id = s.get("study_plan_id")
            
            # Determine level
            level = 1
            if plan_id in plan_levels:
                for lvl in plan_levels[plan_id]:
                    min_h = lvl.get("min_hours", 0)
                    max_h = lvl.get("max_hours", 999) or 999
                    if min_h <= passed <= max_h:
                        level = lvl.get("level_order", 1)
                        break
            else:
                # Default hours thresholds
                if passed >= 105:
                    level = 4
                elif passed >= 70:
                    level = 3
                elif passed >= 35:
                    level = 2
                else:
                    level = 1

            # Update DB
            await asyncio.to_thread(
                supabase_admin.table("students")
                .update({"level": level})
                .eq("id", s["id"])
                .execute
            )
            updated_count += 1

        return {
            "status": "success",
            "message": f"Successfully updated levels for {updated_count} students."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/search", response_model=Dict[str, Any])
async def search_students(
    query: Optional[str] = Query(None),
    department_id: Optional[str] = Query(None),
    level: Optional[int] = Query(None),
    status: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Provides fuzzy paginated search over students database.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    try:
        req_query = supabase_admin.table("students").select("*", count="exact")

        if department_id:
            req_query = req_query.eq("department_id", department_id)
        if level:
            req_query = req_query.eq("level", level)
        if status:
            req_query = req_query.eq("status", status)

        if query:
            # Fuzzy search on name or external ID
            req_query = req_query.or_(f"name_ar.ilike.%{query}%,student_id_external.ilike.%{query}%")

        offset = (page - 1) * page_size
        req_query = req_query.range(offset, offset + page_size - 1)

        res = await asyncio.to_thread(req_query.execute)
        total = res.count or 0

        return {
            "students": res.data or [],
            "total": total,
            "page": page,
            "page_size": page_size
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{student_id}/recalculate-gpa", response_model=Dict[str, Any])
async def recalculate_student_gpa(
    student_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Triggers DB function or runs manual recalculation of student's cumulative GPA.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    try:
        # Try RPC first
        try:
            rpc_res = await asyncio.to_thread(
                supabase_admin.rpc("calculate_student_gpa", {"student_uuid": student_id}).execute
            )
            if rpc_res.data:
                return {
                    "status": "success",
                    "gpa": rpc_res.data
                }
        except Exception:
            # Fallback to direct calculation
            pass

        # Fetch courses
        courses_res = await asyncio.to_thread(
            supabase_admin.table("student_courses")
            .select("grade_numeric, credit_hours, status")
            .eq("student_id", student_id)
            .execute
        )
        courses = courses_res.data or []

        total_hours = 0
        weighted_points = 0.0
        passed_hours = 0

        for c in courses:
            grade_num = c.get("grade_numeric")
            hours = c.get("credit_hours") or 3
            status = c.get("status")

            if status != "in_progress" and grade_num is not None:
                total_hours += hours
                weighted_points += grade_num * hours
            
            if status == "passed" and hours:
                passed_hours += hours

        gpa = weighted_points / total_hours if total_hours > 0 else 0.0

        # Update student record
        await asyncio.to_thread(
            supabase_admin.table("students")
            .update({
                "gpa": gpa,
                "passed_hours": passed_hours
            })
            .eq("id", student_id)
            .execute
        )

        return {
            "status": "success",
            "message": "GPA recalculated and updated successfully.",
            "gpa": gpa,
            "passed_hours": passed_hours
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
