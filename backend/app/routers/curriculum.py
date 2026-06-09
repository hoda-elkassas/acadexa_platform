"""
Curriculum Router: Handles importing, exporting, and duplicating study plan configurations.
"""
from fastapi import APIRouter, Depends, HTTPException
from typing import Dict, Any
from app.core.dependencies import get_current_user, check_role
from app.services.curriculum_service import CurriculumService
from app.models.curriculum import PlanImportRequest, PlanCopyRequest, CurriculumValidationResponse

router = APIRouter(prefix="/curriculum", tags=["Curriculum Management"])

@router.get("/export/{plan_id}", response_model=Dict[str, Any])
async def export_study_plan(
    plan_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Exports a study plan with all its courses, prerequisites, and rules as a JSON object.
    """
    check_role(current_user, ["college_admin", "department_head", "super_admin"])
    try:
        plan_data = CurriculumService.export_curriculum(plan_id)
        return plan_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/validate", response_model=CurriculumValidationResponse)
async def validate_study_plan(
    req: Dict[str, Any],
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Performs dry-run validation of a curriculum JSON structure.
    """
    check_role(current_user, ["college_admin", "department_head", "super_admin"])
    try:
        res = CurriculumService.validate_curriculum(req)
        return res
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/import", response_model=Dict[str, Any])
async def import_study_plan(
    req: PlanImportRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Validates and imports a study plan JSON structure into Supabase.
    """
    check_role(current_user, ["college_admin", "department_head", "super_admin"])
    try:
        imported_by = current_user.get("email") or "system"
        plan_id = CurriculumService.import_curriculum(
            curriculum_json=req.curriculum_json,
            target_department_id=req.target_department_id,
            target_academic_year=req.target_academic_year,
            imported_by=imported_by
        )
        return {
            "status": "success",
            "message": "Curriculum imported successfully.",
            "plan_id": plan_id
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/copy", response_model=Dict[str, Any])
async def copy_study_plan(
    req: PlanCopyRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Duplicates a study plan configuration for another department or enrollment year.
    """
    check_role(current_user, ["college_admin", "department_head", "super_admin"])
    try:
        copied_by = current_user.get("email") or "system"
        new_plan_id = CurriculumService.copy_curriculum(
            source_plan_id=req.source_plan_id,
            target_department_id=req.target_department_id,
            target_academic_year=req.target_enrollment_year,
            copied_by=copied_by
        )
        return {
            "status": "success",
            "message": "Curriculum duplicated successfully.",
            "new_plan_id": new_plan_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
