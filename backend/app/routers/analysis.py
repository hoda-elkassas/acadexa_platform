"""
Analysis Router: Handles triggering of the expert rules engine, simulations,
graduation readiness, and analysis history/records retrieval.
"""
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from typing import Dict, Any, List
from app.core.dependencies import get_current_user, check_role
from app.services.expert_system import ExpertSystemService
from app.services.analysis_service import AnalysisService
from app.models.analysis import (
    SimulationRequest,
    SimulationResponse,
    BatchAnalysisRequest,
    AnalysisResultResponse,
    AnalysisIssueResponse,
    AnalysisRecommendationResponse,
    GraduationReadinessResponse
)

router = APIRouter(prefix="/analysis", tags=["Expert Engine & Analysis"])

@router.post("/run/{student_id}", response_model=Dict[str, Any])
async def run_student_analysis(
    student_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Triggers academic rules evaluation on a specific student.
    Bypasses RLS to write to analysis tables.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    
    try:
        result = await ExpertSystemService.analyze_student(student_id)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Expert analysis failed: {str(e)}")

@router.post("/simulate", response_model=SimulationResponse)
async def simulate_plan_registration(
    req: SimulationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Simulates GPA changes and warning flags based on a proposed future course plan.
    """
    try:
        sim_data = await AnalysisService.simulate_plan(req.student_id, [c.dict() for c in req.planned_courses])
        return SimulationResponse(**sim_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/batch", response_model=Dict[str, Any])
async def run_batch_analysis(
    req: BatchAnalysisRequest,
    background_tasks: BackgroundTasks,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Triggers batch evaluations for an entire department or list of students.
    Runs asynchronously in the background.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    
    background_tasks.add_task(
        AnalysisService.run_batch_analysis,
        department_id=req.department_id,
        plan_id=req.plan_id,
        student_ids=req.student_ids
    )

    return {
        "status": "processing",
        "message": "Batch academic analysis scheduled successfully in the background."
    }

@router.get("/latest/{student_id}", response_model=AnalysisResultResponse)
async def get_latest_analysis(
    student_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Retrieves the latest academic analysis for a student.
    """
    is_advisor = current_user.get("role") in ["advisor", "college_admin", "department_head", "super_admin"]
    if not is_advisor:
        pass  # Verify student matches student_id if integrated
        
    try:
        data = await AnalysisService.get_latest_analysis(student_id)
        return AnalysisResultResponse(**data)
    except NotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/history/{student_id}", response_model=List[AnalysisResultResponse])
async def get_analysis_history(
    student_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Retrieves analysis run history for a student.
    """
    is_advisor = current_user.get("role") in ["advisor", "college_admin", "department_head", "super_admin"]
    if not is_advisor:
        pass
        
    try:
        history = await AnalysisService.get_analysis_history(student_id)
        return [AnalysisResultResponse(**h) for h in history]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/issues/{analysis_id}", response_model=List[AnalysisIssueResponse])
async def get_analysis_issues(
    analysis_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Retrieves all issues associated with a specific academic analysis run.
    """
    try:
        issues = await AnalysisService.get_analysis_issues(analysis_id)
        return [AnalysisIssueResponse(**iss) for iss in issues]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/recommendations/{analysis_id}", response_model=List[AnalysisRecommendationResponse])
async def get_analysis_recommendations(
    analysis_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Retrieves all course recommendations associated with a specific analysis run.
    """
    try:
        recs = await AnalysisService.get_analysis_recommendations(analysis_id)
        return [AnalysisRecommendationResponse(**rec) for rec in recs]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/graduation-readiness/{student_id}", response_model=GraduationReadinessResponse)
async def get_graduation_readiness(
    student_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Retrieves a structured check of graduation requirements for a student.
    """
    is_advisor = current_user.get("role") in ["advisor", "college_admin", "department_head", "super_admin"]
    if not is_advisor:
        pass
        
    try:
        report = await AnalysisService.get_graduation_readiness(student_id)
        return GraduationReadinessResponse(**report)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/history/{analysis_id}", response_model=Dict[str, Any])
async def delete_analysis_record(
    analysis_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Deletes an analysis history run.
    """
    check_role(current_user, ["advisor", "college_admin", "department_head", "super_admin"])
    
    try:
        deleted = await AnalysisService.delete_analysis_history(analysis_id)
        if not deleted:
            raise HTTPException(status_code=404, detail="Analysis record not found.")
        return {"status": "success", "message": "Analysis record deleted successfully."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
