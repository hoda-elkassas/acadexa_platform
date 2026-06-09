"""
Pydantic models for upload/import job schemas.
"""
from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


class UploadResponse(BaseModel):
    import_job_id: str
    status: str = "pending"
    message: str


class ImportJobStatus(BaseModel):
    id: str
    filename: str
    department_id: Optional[str] = None
    status: str  # pending | processing | completed | partial_success | failed
    total_students: int = 0
    successful: int = 0
    failed: int = 0
    progress_percentage: float = 0.0
    error_log: List[dict] = []
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class ImportHistoryResponse(BaseModel):
    data: List[ImportJobStatus]
    total: int
    page: int
    limit: int
