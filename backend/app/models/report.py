"""
Pydantic models for reporting configurations.
"""
from pydantic import BaseModel, Field
from typing import Optional

class ReportRequest(BaseModel):
    department_id: Optional[str] = None
    plan_id: Optional[str] = None
    format: str = "pdf" # pdf | excel

class ReportResponse(BaseModel):
    success: bool
    report_url: str
    filename: str

class DepartmentSummaryRequest(BaseModel):
    format: str = Field("pdf", pattern="^(pdf|excel)$")

class AtRiskReportRequest(BaseModel):
    limit: int = Field(50, ge=1, le=500)
    format: str = Field("pdf", pattern="^(pdf|excel)$")

class GraduationPredictionRequest(BaseModel):
    year: int
    format: str = Field("pdf", pattern="^(pdf|excel)$")

class PlanComparisonRequest(BaseModel):
    plan_id_1: str
    plan_id_2: str
    format: str = Field("pdf", pattern="^(pdf|excel)$")
