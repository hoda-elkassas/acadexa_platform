"""
Graduation Rules: Evaluates student eligibility to graduate against curriculum requirements.
"""
from typing import Dict, Any, List

def check(facts: Any, issues: List[Dict[str, Any]], recommendations: List[Dict[str, Any]]):
    grad_req = facts.get("graduation_req") or {}
    plan_data = facts.get("plan") or {}
    plan_policies = facts.get("plan_policies") or {}
    grad_policy = plan_policies.get("graduation_rules") or {}

    # Read config values
    required_hours = grad_req.get("required_hours") or 136
    min_gpa = grad_req.get("min_gpa") or plan_data.get("min_gpa") or 2.0
    requires_training = grad_req.get("requires_field_training") or False
    requires_civic = grad_req.get("requires_civic_literacy") or False
    civic_count_req = grad_policy.get("civic_literacy_count", 0)
    comm_code = grad_policy.get("community_issues_course_code", "UNIV201")
    requires_community_issues = grad_req.get("requires_community_issues_course") if grad_req.get("requires_community_issues_course") is not None else True

    # Student achievements
    passed_hours = facts.get("total_passed_hours") or facts.get("passed_hours") or 0
    calculated_gpa = facts.get("calculated_gpa") or facts.get("gpa") or 0.0
    field_training_completed = facts.get("field_training_completed") or False
    civic_passed_count = facts.get("civic_literacy_courses_passed") or 0
    community_issues_passed = facts.get("community_issues_passed")
    if community_issues_passed is None:
        student_courses = facts.get("student_courses") or facts.get("all_courses") or []
        community_issues_passed = any(c.get("course_code") == comm_code and c.get("status") == "passed" for c in student_courses)

    # Check metrics
    hours_met = passed_hours >= required_hours
    gpa_met = calculated_gpa >= min_gpa
    training_met = not requires_training or field_training_completed
    civic_met = not requires_civic or civic_passed_count >= civic_count_req
    comm_met = not requires_community_issues or community_issues_passed

    all_met = hours_met and gpa_met and training_met and civic_met and comm_met

    # Rule GR1: Graduation hours check (error)
    if not hours_met:
        issues.append({
            "rule_code": "GR1_HOURS_INSUFFICIENT",
            "severity": "error",
            "title": "ساعات التخرج غير كافية",
            "description": f"لم ينجز الطالب الساعات المطلوبة للتخرج ({passed_hours}/{required_hours} ساعة).",
            "suggestion": "سجل المقررات المتبقية في الخطة الدراسية لإكمال الساعات."
        })

    # Rule GR2: GPA check (error)
    if not gpa_met:
        issues.append({
            "rule_code": "GR2_GPA_INSUFFICIENT",
            "severity": "error",
            "title": "المعدل التراكمي للتخرج غير كافٍ",
            "description": f"المعدل التراكمي الحالي ({calculated_gpa:.2f}) أقل من الحد الأدنى للتخرج ({min_gpa:.2f}).",
            "suggestion": "أعد دراسة بعض المقررات ذات التقديرات المنخفضة لرفع المعدل."
        })

    # Rule GR3: Field training check (error)
    if requires_training and not field_training_completed:
        issues.append({
            "rule_code": "GR3_FIELD_TRAINING_INCOMPLETE",
            "severity": "error",
            "title": "التدريب الميداني للتخرج غير مكتمل",
            "description": "لم يتم إكمال جميع مستويات/فترات التدريب الميداني المطلوبة للتخرج.",
            "suggestion": "تواصل مع منسق التدريب بالقسم لتسجيل الساعات المتبقية."
        })

    # Rule GR4: Civic literacy check (error)
    if requires_civic and civic_passed_count < civic_count_req:
        issues.append({
            "rule_code": "GR4_CIVIC_LITERACY_INCOMPLETE",
            "severity": "error",
            "title": "متطلب الثقافة المدنية غير مكتمل",
            "description": f"أنجز الطالب {civic_passed_count} مقررات ثقافة مدنية من أصل {civic_count_req} مقررات مطلوبة.",
            "suggestion": "سجل المقررات العامة (UNIV) المتبقية لتلبية متطلب الثقافة المدنية."
        })

    # Rule GR5: Community issues course check (error)
    if requires_community_issues and not community_issues_passed:
        issues.append({
            "rule_code": "GR5_COMMUNITY_ISSUES_INCOMPLETE",
            "severity": "error",
            "title": "مقرر القضايا المجتمعية غير مجتاز",
            "description": f"لم يتم اجتياز مقرر القضايا المجتمعية ({comm_code}) وهو متطلب إجباري للجامعة.",
            "suggestion": f"سجل مقرر القضايا المجتمعية ({comm_code}) واجتزه في الفصل الدراسي القادم."
        })

    # Rule GR6: Eligible to graduate (info)
    # Stored on facts.graduation_readiness_report rather than appending to issues list

    # Construct the graduation readiness report
    report = {
        "is_eligible": all_met,
        "requirements": {
            "total_hours": {
                "required": required_hours,
                "completed": passed_hours,
                "met": hours_met
            },
            "gpa": {
                "required": min_gpa,
                "completed": calculated_gpa,
                "met": gpa_met
            },
            "field_training": {
                "required": requires_training,
                "completed": field_training_completed if requires_training else True,
                "met": training_met
            },
            "civic_literacy": {
                "required": civic_count_req if requires_civic else 0,
                "completed": civic_passed_count,
                "met": civic_met
            },
            "community_issues": {
                "required": requires_community_issues,
                "completed": community_issues_passed if requires_community_issues else True,
                "met": comm_met
            }
        }
    }
    
    # Store the report on the facts object
    if hasattr(facts, "get"):
        try:
            facts.graduation_readiness_report = report
        except AttributeError:
            pass
        if isinstance(facts, dict):
            facts["graduation_readiness_report"] = report
