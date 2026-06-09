"""
Tests for report generation services.
"""
import pytest
from unittest.mock import patch, MagicMock
from app.services.report_service import ReportService

@pytest.mark.asyncio
async def test_student_pdf_generation():
    with patch("app.services.report_service.supabase_admin") as mock_supabase:
        # Mock student
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [
            {
                "id": "student-1",
                "name_ar": "مصطفى أحمد",
                "student_id_external": "1001",
                "department_id": "dept-1",
                "enrollment_year": 2022,
                "gpa": 3.4,
                "passed_hours": 95,
                "level": 3,
                "status": "active"
            }
        ]
        # Mock courses
        mock_supabase.table.return_value.select.return_value.eq.return_value.order.return_value.execute.return_value.data = [
            {"semester_name": "الترم الأول 2022", "gpa": 3.4}
        ]
        
        # Mock other dependencies inside student_pdf
        # Since student_pdf calls:
        # - student_res = select
        # - semesters_res = select
        # - courses_res = select
        # - analysis_res = select
        # Let's mock a sequence of returns or general responses:
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.side_effect = [
            MagicMock(data=[{"id": "student-1", "name_ar": "مصطفى أحمد", "student_id_external": "1001", "department_id": "dept-1", "enrollment_year": 2022}]), # student
            MagicMock(data=[{"semester_name": "الترم الأول 2022", "gpa": 3.4}]), # semesters
            MagicMock(data=[{"course_code": "CS101", "course_name_ar": "مقدمة", "grade_ar": "A", "credit_hours": 3, "semester_name": "الترم الأول 2022", "status": "passed"}]), # courses
            MagicMock(data=[{"calculated_gpa": 3.4, "total_passed_hours": 95, "errors_count": 0, "warnings_count": 0}]), # analysis
        ]
        
        pdf_bytes = await ReportService.student_pdf("student-1")
        assert len(pdf_bytes) > 0
        assert pdf_bytes.startswith(b"%PDF")

@pytest.mark.asyncio
async def test_department_summary_excel():
    with patch("app.services.report_service.supabase_admin") as mock_supabase:
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value.data = [
            {"id": "s1", "name_ar": "طالب 1", "gpa": 3.2, "passed_hours": 80, "level": 3, "status": "active"}
        ]
        
        excel_bytes = await ReportService.department_summary("dept-1", "excel")
        assert len(excel_bytes) > 0
        # Excel zip format signature: PK
        assert excel_bytes.startswith(b"PK")
