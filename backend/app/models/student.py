"""
Pydantic models for student schema.
"""
from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, Dict, Any

class StudentBase(BaseModel):
    name_ar: str
    student_id_external: str
    national_id: Optional[str] = None
    level: int = 1
    gpa: float = 0.0
    passed_hours: int = 0
    study_plan_id: Optional[str] = None
    department_id: Optional[str] = None
    enrollment_year: int
    status: str = "active"

class StudentCreate(StudentBase):
    pass

class StudentUpdate(BaseModel):
    name_ar: Optional[str] = None
    level: Optional[int] = None
    gpa: Optional[float] = None
    passed_hours: Optional[int] = None
    study_plan_id: Optional[str] = None
    status: Optional[str] = None

class StudentResponse(StudentBase):
    id: str
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

class StudentCourseResponse(BaseModel):
    id: str
    student_id: str
    course_code: str
    course_name: str
    credit_hours: int
    grade_letter: Optional[str] = None
    grade_numeric: Optional[float] = None
    semester_id: Optional[str] = None
    status: str # passed | failed | in_progress

class StudentSemesterResponse(BaseModel):
    id: str
    student_id: str
    semester_name: str
    gpa: float
    gpa_cumulative: float
    registered_hours: int
    passed_hours: int

class SemesterWithCourses(BaseModel):
    semester: Dict[str, Any]
    courses: List[Dict[str, Any]]
    semester_gpa: Optional[float] = None

class StudentFullProfile(BaseModel):
    student: Dict[str, Any]
    semesters: List[SemesterWithCourses]
    latest_analysis: Optional[Dict[str, Any]] = None
    issues: List[Dict[str, Any]] = []
    recommendations: List[Dict[str, Any]] = []
    advisor_notes: List[Dict[str, Any]] = []

class LevelUpdateRequest(BaseModel):
    department_id: str
    academic_year: int
