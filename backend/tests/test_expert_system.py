"""
Tests for rule modules in isolation using mock facts dicts.
"""
import pytest
from app.expert_engine.rules import gpa_rules, hours_rules, prerequisite_rules, load_rules, graduation_rules

def test_gpa_rules():
    # Test low GPA warning
    facts = {
        "gpa": 1.8,
        "student_courses": []
    }
    issues = []
    recs = []
    gpa_rules.check(facts, issues, recs)
    assert any(i["rule_code"] == "LOW_GPA_WARNING" for i in issues)

    # Test probation
    facts_prob = {
        "gpa": 1.7,
        "student_semesters": [
            {"semester_name": "ترم 1", "gpa": 1.7, "gpa_cumulative": 1.7},
            {"semester_name": "ترم 2", "gpa": 1.6, "gpa_cumulative": 1.6}
        ]
    }
    issues_prob = []
    gpa_rules.check(facts_prob, issues_prob, recs)
    assert any(i["rule_code"] == "ACADEMIC_PROBATION" for i in issues_prob)

def test_hours_rules():
    facts = {
        "passed_hours": 35,
        "study_level": 1,
        "graduation_requirements": {"required_hours": 136}
    }
    issues = []
    recs = []
    hours_rules.check(facts, issues, recs)
    # Calculated level for 35 hrs is 2, but study_level is 1. Level mismatch should trigger.
    assert any(i["rule_code"] == "LEVEL_MISMATCH" for i in issues)

def test_prerequisite_rules():
    # Student registered in a course without passing prerequisite
    facts = {
        "student_courses": [
            {"course_code": "CS201", "status": "in_progress", "semester_id": "sem_1"},
            {"course_code": "CS101", "status": "failed", "semester_id": "sem_0"}
        ],
        "prerequisites": {
            "CS201": ["CS101"]
        },
        "equivalents": {}
    }
    issues = []
    recs = []
    prerequisite_rules.check(facts, issues, recs)
    assert any(i["rule_code"] == "MISSING_PREREQUISITE" for i in issues)

def test_load_rules():
    # Summer cap exceeded
    facts = {
        "student_semesters": [
            {"semester_name": "الفصل الصيفي", "registered_hours": 10, "gpa": 3.0}
        ],
        "academic_load_rules": {
            "summer_cap": 9
        }
    }
    issues = []
    recs = []
    load_rules.check(facts, issues, recs)
    assert any(i["rule_code"] == "SUMMER_CAP_EXCEEDED" for i in issues)

def test_graduation_rules():
    facts = {
        "passed_hours": 136,
        "gpa": 2.5,
        "student_courses": [
            {"course_code": "UNIV201", "status": "passed"}
        ],
        "graduation_requirements": {
            "required_hours": 136,
            "min_gpa": 2.0,
            "requires_field_training": False,
            "requires_civic_literacy": False
        }
    }
    issues = []
    recs = []
    graduation_rules.check(facts, issues, recs)
    # No issues because student passed everything and met all reqs
    assert len(issues) == 0
