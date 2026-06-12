"""
Reports Router: Serves generated PDF transcripts and statistical Excel summaries.
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import StreamingResponse
from typing import Dict, Any
import io
from slugify import slugify
from app.core.dependencies import get_current_user, check_role
from app.services.report_service import ReportService

router = APIRouter(prefix="/reports", tags=["Reports & Analytics"])

def get_safe_filename(prefix: str, identifier: str, ext: str) -> str:
    slug = slugify(f"{prefix}_{identifier}")
    if not slug:
        slug = "report"
    return f"{slug}.{ext}"

def get_media_type(file_format: str) -> str:
    if file_format == "excel":
        return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    return "application/pdf"

@router.get("/student/{student_id}")
async def get_student_report(
    student_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Downloads the student academic report PDF.
    """
    # Allowed for student themselves or advisors
    is_advisor = current_user.get("role") in ["advisor", "college_admin", "department_head", "super_admin"]
    if not is_advisor:
        # In production check: current_user["user_id"] matches student_id
        pass

    try:
        pdf_bytes = await ReportService.student_pdf(student_id)
        filename = get_safe_filename("student_report", student_id, "pdf")
        return StreamingResponse(
            io.BytesIO(pdf_bytes),
            media_type="application/pdf",
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/student/{student_id}/transcript")
async def get_student_transcript(
    student_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Downloads the official academic transcript PDF for a student.
    """
    is_advisor = current_user.get("role") in ["advisor", "college_admin", "department_head", "super_admin"]
    if not is_advisor:
        pass

    try:
        pdf_bytes = await ReportService.student_transcript(student_id)
        filename = get_safe_filename("transcript", student_id, "pdf")
        return StreamingResponse(
            io.BytesIO(pdf_bytes),
            media_type="application/pdf",
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/department/{department_id}/summary")
async def get_department_summary(
    department_id: str,
    file_format: str = Query("pdf", pattern="^(pdf|excel)$"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Downloads department summary report in PDF or Excel format.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    try:
        ext = "xlsx" if file_format == "excel" else "pdf"
        report_bytes = await ReportService.department_summary(department_id, file_format)
        filename = get_safe_filename("dept_summary", department_id, ext)
        return StreamingResponse(
            io.BytesIO(report_bytes),
            media_type=get_media_type(file_format),
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/department/{department_id}/at-risk")
async def get_at_risk_report(
    department_id: str,
    file_format: str = Query("pdf", pattern="^(pdf|excel)$"),
    limit: int = Query(50, ge=1, le=500),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Downloads list of at-risk students in PDF or Excel format.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    try:
        ext = "xlsx" if file_format == "excel" else "pdf"
        report_bytes = await ReportService.at_risk_students(department_id, limit, file_format)
        filename = get_safe_filename("at_risk", department_id, ext)
        return StreamingResponse(
            io.BytesIO(report_bytes),
            media_type=get_media_type(file_format),
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/department/{department_id}/graduation-predictions")
async def get_graduation_predictions(
    department_id: str,
    year: int = Query(...),
    file_format: str = Query("pdf", pattern="^(pdf|excel)$"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Downloads graduation predictions report in PDF or Excel format.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    try:
        ext = "xlsx" if file_format == "excel" else "pdf"
        report_bytes = await ReportService.graduation_predictions(department_id, year, file_format)
        filename = get_safe_filename(f"grad_predictions_{year}", department_id, ext)
        return StreamingResponse(
            io.BytesIO(report_bytes),
            media_type=get_media_type(file_format),
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/student/{student_id}/semester-performance")
async def get_semester_performance(
    student_id: str,
    file_format: str = Query("pdf", pattern="^(pdf|excel)$"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Downloads semester-by-semester student performance trend.
    """
    is_advisor = current_user.get("role") in ["advisor", "college_admin", "department_head", "super_admin"]
    if not is_advisor:
        pass
    try:
        ext = "xlsx" if file_format == "excel" else "pdf"
        report_bytes = await ReportService.semester_performance(student_id, file_format)
        filename = get_safe_filename("perf_trend", student_id, ext)
        return StreamingResponse(
            io.BytesIO(report_bytes),
            media_type=get_media_type(file_format),
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/plan/comparison")
async def get_plan_comparison(
    plan_id_1: str = Query(...),
    plan_id_2: str = Query(...),
    file_format: str = Query("pdf", pattern="^(pdf|excel)$"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Downloads study plan comparison report in PDF or Excel format.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    try:
        ext = "xlsx" if file_format == "excel" else "pdf"
        report_bytes = await ReportService.plan_comparison(plan_id_1, plan_id_2, file_format)
        filename = get_safe_filename("plan_comparison", f"{plan_id_1}_vs_{plan_id_2}", ext)
        return StreamingResponse(
            io.BytesIO(report_bytes),
            media_type=get_media_type(file_format),
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/student/{student_id}/plan-compliance")
async def get_plan_compliance(
    student_id: str,
    file_format: str = Query("pdf", pattern="^(pdf|excel)$"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Downloads study plan compliance status report.
    """
    is_advisor = current_user.get("role") in ["advisor", "college_admin", "department_head", "super_admin"]
    if not is_advisor:
        pass
    try:
        ext = "xlsx" if file_format == "excel" else "pdf"
        report_bytes = await ReportService.plan_compliance(student_id, file_format)
        filename = get_safe_filename("plan_compliance", student_id, ext)
        return StreamingResponse(
            io.BytesIO(report_bytes),
            media_type=get_media_type(file_format),
            headers={"Content-Disposition": f"attachment; filename={filename}"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
