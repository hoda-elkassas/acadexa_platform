"""
Pydantic models for curriculum import/export JSON.
"""
from pydantic import BaseModel
from typing import List, Optional, Dict, Any

class CourseJsonSchema(BaseModel):
    code: str
    name_ar: str
    name_en: Optional[str] = None
    credit_hours: int
    category: str # Compulsory, Elective, general, college, department
    level: int = 1
    prerequisites: List[str] = [] # list of course codes

class ElectiveGroupJsonSchema(BaseModel):
    name_ar: str
    required_hours: int
    courses: List[str] = [] # course codes

class CurriculumPlanJson(BaseModel):
    plan_name: str
    department_name: str
    enrollment_year: int
    required_hours: int
    min_gpa: float = 2.0
    rules: Dict[str, Any] = {}
    courses: List[CourseJsonSchema] = []
    elective_groups: List[ElectiveGroupJsonSchema] = []

class CurriculumValidationResponse(BaseModel):
    valid: bool
    errors: List[str] = []
    warnings: List[str] = []
    stats: Dict[str, Any] = {}

class PlanCopyRequest(BaseModel):
    source_plan_id: str
    target_department_id: str
    target_enrollment_year: int
    new_name: str

class PlanImportRequest(BaseModel):
    curriculum_json: Dict[str, Any]
    target_department_id: str
    target_academic_year: int

class PlanExportResponse(BaseModel):
    plan_id: str
    plan_name: str
    data: Dict[str, Any]
