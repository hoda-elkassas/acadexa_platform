"""
Upload Router: Handles academic record file uploads (Excel) and import jobs progress/status checking.
"""
import logging
import os
import shutil
import uuid
from typing import Dict, Any

from fastapi import APIRouter, UploadFile, File, Form, Depends, BackgroundTasks, HTTPException, Query, status

from app.core.config import settings
from app.core.dependencies import get_current_user, require_role, require_advisor, CurrentUser
from app.core.database import fetch_one, delete_one, supabase_admin
from app.models.upload import ImportJobStatus, UploadResponse, ImportHistoryResponse
from app.services.import_service import ImportService

logger = logging.getLogger("acadexa.upload_router")

router = APIRouter(prefix="/upload", tags=["Upload"])


@router.post("/academic-record", response_model=UploadResponse, status_code=status.HTTP_202_ACCEPTED)
async def upload_academic_record(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    department_id: str = Form(...),
    current_user: CurrentUser = Depends(require_role("ACADEMIC_OPERATIONS", "SYSTEM_MANAGEMENT", "DEVELOPER"))
):
    """
    Upload an academic record Excel file to parse and import student data.
    Runs asynchronously in background tasks.
    """
    # 1. Validate file extension
    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in (".xlsx", ".xls"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid file type. Only Excel files (.xlsx, .xls) are allowed."
        )

    # 2. Validate file size
    max_bytes = settings.MAX_UPLOAD_SIZE_MB * 1024 * 1024
    # SpooledTemporaryFile seek/tell to find size without loading everything
    file.file.seek(0, 2)
    size = file.file.tell()
    file.file.seek(0)

    if size > max_bytes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File size exceeds the limit of {settings.MAX_UPLOAD_SIZE_MB}MB."
        )

    # 3. Create temp directory and save file
    os.makedirs(settings.UPLOAD_TEMP_DIR, exist_ok=True)
    unique_filename = f"{uuid.uuid4()}_{file.filename}"
    temp_path = os.path.join(settings.UPLOAD_TEMP_DIR, unique_filename)

    try:
        with open(temp_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        logger.error(f"Failed to write uploaded file to disk: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to save uploaded file locally."
        )

    # 4. Create import job in DB
    try:
        job_id = await ImportService.create_import_job(
            filename=file.filename,
            department_id=department_id,
            uploaded_by=current_user.id
        )
    except Exception as e:
        # Cleanup file if DB insert fails
        if os.path.exists(temp_path):
            os.remove(temp_path)
        logger.error(f"Failed to create import job: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to initialize import job: {e}"
        )

    # 5. Schedule background processing
    background_tasks.add_task(ImportService.process_import_job, job_id, temp_path, department_id)

    return UploadResponse(
        import_job_id=job_id,
        status="pending",
        message="Academic record upload started."
    )


@router.get("/status/{import_job_id}", response_model=ImportJobStatus)
async def get_job_status(
    import_job_id: str,
    current_user: CurrentUser = Depends(get_current_user)
):
    """
    Checks the status and progress of a background import job.
    """
    job = await fetch_one("import_jobs", {"id": import_job_id})
    if not job:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Import job not found"
        )

    total = job.get("total_students") or 0
    successful = job.get("successful") or 0
    failed = job.get("failed") or 0
    progress = ((successful + failed) / total) * 100.0 if total > 0 else 0.0

    return ImportJobStatus(
        id=job["id"],
        filename=job["filename"],
        department_id=job.get("department_id"),
        status=job["status"],
        total_students=total,
        successful=successful,
        failed=failed,
        progress_percentage=round(progress, 2),
        error_log=job.get("error_log") or [],
        created_at=job.get("created_at"),
        updated_at=job.get("updated_at")
    )


@router.get("/history", response_model=ImportHistoryResponse)
async def get_import_history(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    current_user: CurrentUser = Depends(require_advisor)
):
    """
    Returns a paginated history of import jobs.
    """
    start = (page - 1) * limit
    end = start + limit - 1

    def _fetch_history():
        # Get count
        count_res = supabase_admin.table("import_jobs").select("*", count="exact").execute()
        total_count = count_res.count or 0

        # Get records ordered by created_at desc
        res = supabase_admin.table("import_jobs").select("*").order("created_at", desc=True).range(start, end).execute()
        return res.data or [], total_count

    try:
        data, total = await ApiRouter_run_in_thread(_fetch_history)
    except Exception as e:
        # Fallback to run in event loop thread pool if custom helper not imported
        import asyncio
        data, total = await asyncio.to_thread(_fetch_history)

    job_statuses = []
    for job in data:
        total_students = job.get("total_students") or 0
        successful = job.get("successful") or 0
        failed = job.get("failed") or 0
        progress = ((successful + failed) / total_students) * 100.0 if total_students > 0 else 0.0

        job_statuses.append(ImportJobStatus(
            id=job["id"],
            filename=job["filename"],
            department_id=job.get("department_id"),
            status=job["status"],
            total_students=total_students,
            successful=successful,
            failed=failed,
            progress_percentage=round(progress, 2),
            error_log=job.get("error_log") or [],
            created_at=job.get("created_at"),
            updated_at=job.get("updated_at")
        ))

    return ImportHistoryResponse(
        data=job_statuses,
        total=total,
        page=page,
        limit=limit
    )


@router.delete("/{import_job_id}", status_code=status.HTTP_200_OK)
async def delete_import_job(
    import_job_id: str,
    current_user: CurrentUser = Depends(require_role("SYSTEM_MANAGEMENT", "DEVELOPER"))
):
    """
    Deletes a completed or failed import job record from the database.
    Active jobs (pending or processing) cannot be deleted.
    """
    job = await fetch_one("import_jobs", {"id": import_job_id})
    if not job:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Import job not found"
        )

    if job["status"] in ("pending", "processing"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete an active or running import job."
        )

    try:
        await delete_one("import_jobs", {"id": import_job_id})
    except Exception as e:
        logger.error(f"Failed to delete import job {import_job_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete import job record: {e}"
        )

    return {"message": "Import job record deleted successfully."}


async def ApiRouter_run_in_thread(func):
    import asyncio
    return await asyncio.to_thread(func)
