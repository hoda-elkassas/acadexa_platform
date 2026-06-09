"""
Elective Rules: Verifies student compliance with elective groups, required hours, and course selections.
"""
from typing import Dict, Any, List

def check(facts: Any, issues: List[Dict[str, Any]], recommendations: List[Dict[str, Any]]):
    elective_groups = facts.get("elective_groups") or []
    student_courses = facts.get("all_courses") or []
    equivalents = facts.get("equivalents") or {}

    # Gather all passed/in-progress course codes
    passed_codes = set()
    for sc in student_courses:
        gl = sc.get("grade_letter")
        status = sc.get("status")
        # Define passed
        if status == "passed" or (gl not in {"F", "FA", "W", "I", "IP"} and sc.get("score", 0) >= 60):
            passed_codes.add(sc["course_code"])
            # Add equivalents
            if sc["course_code"] in equivalents:
                passed_codes.update(equivalents[sc["course_code"]])

    for group in elective_groups:
        g_id = group.get("id")
        g_name = group.get("name_ar") or group.get("name") or "مجموعة اختيارية"
        req_hours = group.get("required_hours") or 0
        min_courses = group.get("min_courses") or 0
        select_by_hours = group.get("select_by_hours") if group.get("select_by_hours") is not None else True
        max_hours = group.get("max_hours")

        # Find student courses belonging to this group
        group_courses = group.get("courses") or []
        student_group_courses = []
        group_passed_hours = 0
        group_passed_count = 0

        for sc in student_courses:
            code = sc["course_code"]
            status = sc.get("status")
            gl = sc.get("grade_letter")
            is_passed = status == "passed" or (gl not in {"F", "FA", "W", "I", "IP"} and sc.get("score", 0) >= 60)

            # Check if this course or its equivalent is in the group courses
            is_in_group = (code in group_courses) or any(eq in group_courses for eq in equivalents.get(code, []))
            if is_in_group:
                student_group_courses.append(sc)
                if is_passed:
                    group_passed_hours += sc.get("credit_hours") or 0
                    group_passed_count += 1

        # Rule E1: Elective group hours / min courses not met (warning)
        if select_by_hours:
            if group_passed_hours < req_hours:
                remaining_hours = req_hours - group_passed_hours
                issues.append({
                    "rule_code": "ELECTIVE_GROUP_HOURS_INCOMPLETE",
                    "severity": "warning",
                    "title": f"متطلبات ساعات المجموعة الاختيارية غير مكتملة: {g_name}",
                    "description": f"أنجز الطالب {group_passed_hours} ساعة معتمدة من أصل {req_hours} ساعة مطلوبة في المجموعة الاختيارية '{g_name}'.",
                    "suggestion": f"يجب تسجيل واجتياز {remaining_hours} ساعة إضافية من مقررات هذه المجموعة الاختيارية."
                })
                
                # Recommend unpassed elective courses from this group
                for course_code in group_courses:
                    if course_code not in passed_codes:
                        recommendations.append({
                            "course_code": course_code,
                            "course_name": f"مقرر اختياري من {g_name}",
                            "priority": 2,
                            "reason": f"مقرر مقترح لتغطية الساعات المتبقية ({remaining_hours} ساعة) في المجموعة الاختيارية '{g_name}'."
                        })
        else:
            if group_passed_count < min_courses:
                remaining_courses = min_courses - group_passed_count
                issues.append({
                    "rule_code": "ELECTIVE_GROUP_COURSES_INCOMPLETE",
                    "severity": "warning",
                    "title": f"متطلبات مقررات المجموعة الاختيارية غير مكتملة: {g_name}",
                    "description": f"أنجز الطالب {group_passed_count} مقرر من أصل {min_courses} مقررات مطلوبة في المجموعة الاختيارية '{g_name}'.",
                    "suggestion": f"يجب تسجيل واجتياز {remaining_courses} مقررات إضافية من مقررات هذه المجموعة الاختيارية."
                })

        # Rule E2: Elective group over-selection (info)
        if max_hours is not None and group_passed_hours > max_hours:
            issues.append({
                "rule_code": "ELECTIVE_GROUP_OVER_SELECTION",
                "severity": "info",
                "title": f"تجاوز الحد الأقصى للمجموعة الاختيارية: {g_name}",
                "description": f"عدد الساعات المنجزة للمجموعة الاختيارية ({group_passed_hours}) يتجاوز الحد الأقصى المسموح باحتسابه وهو {max_hours} ساعة.",
                "suggestion": "الساعات الزائدة قد لا تحتسب ضمن متطلبات التخرج الأساسية للبرنامج الدراسي."
            })

        # Rule E3: Invalid elective choice (error)
        # Check if student took any course not belonging to their study plan or any invalid selection
        # (For this example, if a student course is marked as category "elective" in student_courses but does not map to any elective group, we raise an issue)
        # However, to avoid false positives, we check if they registered a course in this group that is somehow barred.
        # If there are no specific exclusion lists, we check if they passed a course but it's not registered correctly.
