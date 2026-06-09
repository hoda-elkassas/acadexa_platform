"""
Tests for academic analysis service methods and simulations.
"""
import pytest
from unittest.mock import patch, MagicMock
from app.services.analysis_service import AnalysisService

@pytest.fixture
def mock_raw_data():
    return {
        "student": {
            "id": "student-123",
            "study_plan_id": "plan-123",
            "name": "طالب تجريبي",
            "gpa": 1.8,
            "passed_hours": 30
        },
        "all_courses": [
            {"course_code": "CS101", "credit_hours": 3, "grade_letter": "C", "status": "passed", "semester_number": 1}
        ],
        "semesters": [
            {"id": "sem-1", "semester_number": 1, "semester_name": "الفصل الأول", "registered_hours": 3, "gpa": 2.0, "gpa_cumulative": 2.0}
        ],
        "graduation_req": {
            "required_hours": 136,
            "min_gpa": 2.0,
            "requires_field_training": False,
            "requires_civic_literacy": False,
            "requires_community_issues_course": False
        },
        "load_rules": {},
        "training_rules": {},
        "plan": {
            "min_gpa": 2.0
        },
        "plan_policies": {
            "gpa_rules": {
                "warning_threshold": 2.0,
                "risk_threshold": 2.2
            },
            "hours_rules": {
                "summer_max_hours": 9,
                "warning_threshold": 12
            },
            "graduation_rules": {
                "min_gpa_to_graduate": 2.0
            }
        },
        "study_levels": [
            {"id": "level-1", "level_name": "المستوى الأول", "level_order": 1, "min_hours": 0, "max_hours": 30}
        ],
        "plan_courses": [
            {"id": "c1", "code": "CS101", "credit_hours": 3, "category": "mandatory"},
            {"id": "c2", "code": "CS102", "credit_hours": 3, "category": "mandatory"},
            {"id": "c3", "code": "CS103", "credit_hours": 3, "category": "mandatory"}
        ],
        "prerequisites": [],
        "elective_groups": []
    }

@pytest.fixture
def mock_grading_scale():
    return {"A": 4.0, "B": 3.0, "C": 2.0, "F": 0.0}

@pytest.mark.asyncio
@patch("app.expert_engine.fact_loader.FactLoader.load_raw_data")
@patch("app.expert_engine.fact_loader.FactLoader._get_grading_scale_sync")
async def test_simulation_gpa_increase(mock_get_scale, mock_load_raw, mock_raw_data, mock_grading_scale):
    # Setup mock returns
    mock_load_raw.return_value = mock_raw_data
    mock_get_scale.return_value = mock_grading_scale

    planned = [
        {"code": "CS102", "credit_hours": 3, "grade": "A"},
        {"code": "CS103", "credit_hours": 3, "grade": "A"}
    ]

    res = await AnalysisService.simulate_plan("student-123", planned)
    
    assert res["current_gpa"] == 2.0  # calculated from 1 course CS101 with C (2.0)
    assert res["simulated_gpa"] > 2.0  # adding A's will increase GPA
    assert res["simulated_passed_hours"] == 9  # 3 original + 6 planned
    assert res["status_change"] == "رفع الإنذار الأكاديمي (وضع آمن)" or res["status_change"] is None

@pytest.mark.asyncio
@patch("app.expert_engine.fact_loader.FactLoader.load_raw_data")
async def test_graduation_readiness_checklist(mock_load_raw, mock_raw_data):
    mock_load_raw.return_value = mock_raw_data

    res = await AnalysisService.get_graduation_readiness("student-123")
    
    assert res["student_id"] == "student-123"
    assert res["is_ready"] is False  # hours not sufficient (3 < 136)
    assert len(res["checklist"]) >= 2
    assert res["checklist"][0]["rule_name"] == "ساعات التخرج المطلوبة"
    assert res["checklist"][0]["status"] is False
