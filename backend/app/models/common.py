"""
Common shared Pydantic response models.
"""
from typing import Generic, List, Optional, TypeVar
from pydantic import BaseModel

T = TypeVar("T")

class PaginatedResponse(BaseModel, Generic[T]):
    data: List[T]
    total: int
    page: int
    limit: int
    has_next: bool

class ErrorResponse(BaseModel):
    error: str
    detail: str
    field: Optional[str] = None

class SuccessResponse(BaseModel):
    success: bool
    message: str
    data: Optional[dict] = None

class JobStatus(BaseModel):
    job_id: str
    status: str  # pending | processing | completed | failed
    progress_percentage: float
    message: Optional[str] = None
