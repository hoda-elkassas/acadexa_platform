from fastapi import APIRouter, HTTPException, Query, Depends
from typing import Optional
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from core.security.roles import AppRole, require_role, require_auth

router = APIRouter(prefix="/students", tags=["Students"])


@router.get("/", summary="Get all students")
async def get_all_students(
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    department_code: Optional[str] = None,
    user=Depends(require_role(AppRole.admin, AppRole.academic_advisor, AppRole.dashboard_viewer)),
):
    """
    Get list of all students from database.
    Requires: admin | academic_advisor | dashboard_viewer
    """
    try:
        from core.db.supabase_client import supabase
        query = supabase.table("students").select("*", count="exact")
        if department_code:
            query = query.eq("department_code", department_code)
        result = query.range(offset, offset + limit - 1).order("created_at", desc=True).execute()
        return {
            "students": result.data,
            "total": result.count,
            "limit": limit,
            "offset": offset,
        }
    except Exception as e:
        return {"students": [], "total": 0, "limit": limit, "offset": offset, "error": str(e)}


@router.get("/me", summary="Get my student record (for user role)")
async def get_my_student(
    user=Depends(require_role(AppRole.user)),
):
    """
    Get the student record linked to the currently logged-in user.
    Requires: user
    """
    student_id = user.get("student_id")
    if not student_id:
        raise HTTPException(
            status_code=404,
            detail="لم يتم ربط حسابك بسجل طالب. تواصل مع المرشد الأكاديمي",
        )
    try:
        from core.db.supabase_client import supabase
        result = supabase.table("students").select("*").eq("id", student_id).execute()
        if not result.data:
            raise HTTPException(status_code=404, detail="سجل الطالب غير موجود")
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{student_id}", summary="Get student by ID")
async def get_student_by_id(
    student_id: str,
    user=Depends(require_auth),
):
    """
    Get a single student by UUID.
    - admin / advisor: can access any student
    - user: can only access their own student record
    """
    # Restrict 'user' role to their own record only
    if user["role"] == AppRole.user:
        if user.get("student_id") != student_id:
            raise HTTPException(status_code=403, detail="لا يمكنك الوصول لبيانات طالب آخر")

    try:
        from core.db.supabase_client import supabase
        result = supabase.table("students").select("*").eq("id", student_id).execute()
        if not result.data:
            raise HTTPException(status_code=404, detail="Student not found")
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        return {"id": student_id, "error": str(e)}


@router.get("/code/{student_code}", summary="Get student by code")
async def get_student_by_code(
    student_code: str,
    user=Depends(require_role(AppRole.admin, AppRole.academic_advisor)),
):
    """
    Get student by student_code.
    Requires: admin | academic_advisor
    """
    try:
        from core.db.supabase_client import supabase
        result = supabase.table("students").select("*").eq("student_code", student_code).execute()
        if not result.data:
            raise HTTPException(status_code=404, detail="Student not found")
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        return {"student_code": student_code, "error": str(e)}


@router.get("/{student_id}/full", summary="Get student with all semesters + courses")
async def get_student_full(
    student_id: str,
    user=Depends(require_auth),
):
    """
    Get complete student record with all semesters and courses.
    - admin / advisor: can access any student
    - user: can only access their own record
    """
    if user["role"] == AppRole.user:
        if user.get("student_id") != student_id:
            raise HTTPException(status_code=403, detail="لا يمكنك الوصول لبيانات طالب آخر")

    try:
        from core.db.supabase_client import supabase
        student = supabase.table("students").select("*").eq("id", student_id).execute()
        if not student.data:
            raise HTTPException(status_code=404, detail="Student not found")

        semesters = (
            supabase.table("student_semesters")
            .select("*")
            .eq("student_id", student_id)
            .order("semester_number")
            .execute()
        )
        for sem in semesters.data:
            courses = (
                supabase.table("student_courses")
                .select("*")
                .eq("semester_id", sem["id"])
                .order("created_at")
                .execute()
            )
            sem["courses"] = courses.data

        analysis = (
            supabase.table("analysis_results")
            .select("*")
            .eq("student_id", student_id)
            .eq("is_latest", True)
            .execute()
        )
        return {
            "student": student.data[0],
            "semesters": semesters.data,
            "latest_analysis": analysis.data[0] if analysis.data else None,
        }
    except HTTPException:
        raise
    except Exception as e:
        return {"student": {"id": student_id}, "error": str(e)}