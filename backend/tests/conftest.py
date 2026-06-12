import pytest
from typing import Dict, Any, List, Optional
from dataclasses import dataclass, field

from app.services.file_parser import ParsedCourse, ParsedSemester, ParsedStudent


@pytest.fixture
def sample_student_data() -> ParsedStudent:
    courses_sem1 = [
        ParsedCourse(course_code="CS101", course_name="مقدمة في علوم الحاسب", credit_hours=3, grade_letter="A", score=90.0, passed=True, grade_points=4.0),
        ParsedCourse(course_code="MATH101", course_name="رياضيات 1", credit_hours=3, grade_letter="B+", score=82.0, passed=True, grade_points=3.4),
        ParsedCourse(course_code="ENG101", course_name="لغة إنجليزية 1", credit_hours=2, grade_letter="A-", score=88.0, passed=True, grade_points=3.7),
    ]
    sem1 = ParsedSemester(
        semester_number=1, academic_year="2023-2024", term="fall", level=1,
        courses=courses_sem1, semester_gpa=3.72, total_hours=8,
    )
    courses_sem2 = [
        ParsedCourse(course_code="CS102", course_name="برمجة 1", credit_hours=3, grade_letter="B", score=78.0, passed=True, grade_points=3.2),
        ParsedCourse(course_code="MATH102", course_name="رياضيات 2", credit_hours=3, grade_letter="C+", score=72.0, passed=True, grade_points=2.8),
        ParsedCourse(course_code="PHY101", course_name="فيزياء 1", credit_hours=3, grade_letter="B-", score=75.0, passed=True, grade_points=3.0),
    ]
    sem2 = ParsedSemester(
        semester_number=2, academic_year="2023-2024", term="spring", level=1,
        courses=courses_sem2, semester_gpa=3.00, total_hours=9,
    )
    student = ParsedStudent(
        student_code="2023001", name="أحمد محمد", study_level_str="الأول",
        cumulative_percentage=85.0, enrollment_year=2023,
        semesters=[sem1, sem2], cumulative_gpa=3.33, total_passed_hours=17,
    )
    return student


@pytest.fixture
def sample_plan_data() -> Dict[str, Any]:
    return {
        "id": "plan-001",
        "name": "خطة علوم الحاسب 2023",
        "department_id": "dept-cs",
        "total_graduation_hours": 132,
        "min_graduation_gpa": 2.0,
        "max_levels": 4,
        "max_semester_hours": 18,
        "max_summer_hours": 9,
        "field_training_required": True,
        "field_training_level": 3,
        "civic_literacy_course_code": "CIV101",
        "community_course_code": "COM101",
    }


@pytest.fixture
def mock_facts_dict() -> Dict[str, Any]:
    return {
        "student_id": "stu-001",
        "student_code": "2023001",
        "name": "أحمد محمد",
        "department_id": "dept-cs",
        "plan_id": "plan-001",
        "study_level": 1,
        "cumulative_gpa": 3.33,
        "total_passed_hours": 17,
        "total_failed_hours": 0,
        "total_attempted_hours": 17,
        "total_elective_hours": 0,
        "total_mandatory_hours": 17,
        "is_field_training_completed": False,
        "current_semester_load": 15,
        "is_summer": False,
        "graduation_hours_required": 132,
        "min_graduation_gpa": 2.0,
        "max_semester_hours": 18,
        "max_summer_hours": 9,
    }
