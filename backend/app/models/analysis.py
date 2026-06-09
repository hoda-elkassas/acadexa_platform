"""
Pydantic models for academic analysis and simulation.
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any

class AnalysisRequest(BaseModel):
    force_refresh: bool = False

class BatchAnalysisRequest(BaseModel):
    department_id: Optional[str] = None
    plan_id: Optional[str] = None
    student_ids: Optional[List[str]] = None

class AnalysisIssueResponse(BaseModel):
    id: Optional[str] = None
    analysis_id: str
    rule_code: str
    severity: str # error | warning | info
    title: str
    description: str
    suggestion: Optional[str] = None

class AnalysisRecommendationResponse(BaseModel):
    id: Optional[str] = None
    analysis_id: str
    course_code: str
    course_name: str
    priority: int # 1 (high), 2 (medium), 3 (low)
    reason: str

class AnalysisResultResponse(BaseModel):
    id: str
    student_id: str
    gpa: float
    passed_hours: int
    attempted_hours: int
    graduation_percentage: float
    is_latest: bool
    created_at: str
    issues: List[AnalysisIssueResponse] = []
    recommendations: List[AnalysisRecommendationResponse] = []

class SimulationPlannedCourse(BaseModel):
    code: str
    credit_hours: int
    grade: str = "A"

class SimulationRequest(BaseModel):
    student_id: str
    planned_courses: List[SimulationPlannedCourse]

class SimulationResponse(BaseModel):
    current_gpa: float
    simulated_gpa: float
    current_passed_hours: int
    simulated_passed_hours: int
    status_change: Optional[str] = None
    warnings: List[str] = []

class GraduationCheckItem(BaseModel):
    rule_name: str
    status: bool # True (met), False (unmet)
    details: str

class GraduationReadinessResponse(BaseModel):
    student_id: str
    is_ready: bool
    passed_hours: int
    required_hours: int
    gpa: float
    required_gpa: float
    checklist: List[GraduationCheckItem]

class ChatRequest(BaseModel):
    question: str

class ChatResponse(BaseModel):
    answer: str
    data: Optional[Dict[str, Any]] = None
