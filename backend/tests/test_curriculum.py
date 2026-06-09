"""
Tests for curriculum management: JSON validation, import schema structure.
"""
import pytest
from app.services.curriculum_service import CurriculumService

def test_validate_plan_schema_valid():
    plan_data = {
        "plan_name": "خطة حاسبات 2026",
        "enrollment_year": 2026,
        "courses": [
            {"code": "CS101", "name_ar": "مقدمة حاسبات", "credit_hours": 3, "prerequisites": []},
            {"code": "CS102", "name_ar": "برمجة 1", "credit_hours": 3, "prerequisites": ["CS101"]}
        ]
    }
    
    val = CurriculumService.validate_curriculum(plan_data)
    assert val["valid"] is True
    assert len(val["errors"]) == 0
    assert val["stats"]["total_courses"] == 2
    assert val["stats"]["total_hours"] == 6

def test_validate_plan_schema_invalid_prereq():
    plan_data = {
        "plan_name": "خطة حاسبات 2026",
        "enrollment_year": 2026,
        "courses": [
            {"code": "CS102", "name_ar": "برمجة 1", "credit_hours": 3, "prerequisites": ["CS999"]}
        ]
    }
    
    val = CurriculumService.validate_curriculum(plan_data)
    assert val["valid"] is False
    assert any("CS999" in err for err in val["errors"])

def test_validate_circular_dependency():
    plan_data = {
        "plan_name": "خطة حاسبات دائرية",
        "enrollment_year": 2026,
        "courses": [
            {"code": "CS101", "name_ar": "مقرر 1", "credit_hours": 3, "prerequisites": ["CS102"]},
            {"code": "CS102", "name_ar": "مقرر 2", "credit_hours": 3, "prerequisites": ["CS101"]}
        ]
    }
    val = CurriculumService.validate_curriculum(plan_data)
    assert val["valid"] is False
    assert any("دائرية" in err or "حلقة" in err for err in val["errors"])

def test_validate_non_positive_hours():
    plan_data = {
        "plan_name": "خطة ساعات خاطئة",
        "enrollment_year": 2026,
        "courses": [
            {"code": "CS101", "name_ar": "مقرر 1", "credit_hours": -1, "prerequisites": []}
        ]
    }
    val = CurriculumService.validate_curriculum(plan_data)
    assert val["valid"] is False
    assert any("أكبر من صفر" in err or "credit_hours" in err or "zero" in err.lower() for err in val["errors"])
