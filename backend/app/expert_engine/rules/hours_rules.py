"""
Hours Rules: Verifies student credit hours progression, semester workloads, and progress speed.
"""
from typing import Dict, Any, List

def check(facts: Any, issues: List[Dict[str, Any]], recommendations: List[Dict[str, Any]]):
    passed_hours = facts.get("total_passed_hours") or facts.get("passed_hours") or 0
    current_study_level_order = facts.get("current_study_level_order") or facts.get("study_level") or 1
    current_level_name = facts.get("current_study_level_name") or f"المستوى {current_study_level_order}"
    
    # Retrieve rules and policies
    grad_req = facts.get("graduation_req") or facts.get("graduation_requirements") or {}
    required_hours = grad_req.get("required_hours") or 136
    
    load_rules = facts.get("load_rules") or {}
    max_hours_fall_spring = load_rules.get("max_hours_gpa_normal") or 18
    
    plan_policies = facts.get("plan_policies") or {}
    progression_rules = plan_policies.get("progression_rules") or {}
    analysis_thresholds = plan_policies.get("analysis_thresholds") or {}
    
    slow_ratio = analysis_thresholds.get("slow_progress_ratio", 0.75)
    summer_max_hours = analysis_thresholds.get("summer_max_hours", 9)

    # Rule H1: Insufficient hours for graduation (error)
    if passed_hours < required_hours:
        remaining = required_hours - passed_hours
        issues.append({
            "rule_code": "INSUFFICIENT_GRADUATION_HOURS",
            "severity": "error",
            "title": "ساعات التخرج غير مكتملة",
            "description": f"أنجز الطالب {passed_hours} ساعة معتمدة من أصل {required_hours} ساعة معتمدة مطلوبة للتخرج.",
            "suggestion": f"متبقي {remaining} ساعة معتمدة لإكمال متطلبات التخرج."
        })

    # Rule H2: Level progression mismatch (warning)
    # Determine expected level order based on passed hours
    study_levels = facts.get("study_levels") or []
    expected_level_order = current_study_level_order
    expected_level_name = current_level_name

    # Check via progression_rules first, e.g. level_1_min_hours, level_2_min_hours etc.
    # Otherwise check study_levels min_hours / max_hours
    if progression_rules:
        # Find highest level X where passed_hours >= level_X_min_hours
        highest_order = 1
        for sl in study_levels:
            order = sl.get("level_order") or 1
            key = f"level_{order}_min_hours"
            min_h = progression_rules.get(key)
            if min_h is not None and passed_hours >= min_h:
                if order > highest_order:
                    highest_order = order
        expected_level_order = highest_order
    else:
        # Check via study_levels min_hours / max_hours
        if study_levels:
            for sl in study_levels:
                min_h = sl.get("min_hours") or 0
                max_h = sl.get("max_hours") or 999
                if min_h <= passed_hours <= max_h:
                    expected_level_order = sl.get("level_order") or 1
                    break
        else:
            expected_level_order = int(passed_hours / 30) + 1

    # Get expected level name
    expected_level_name = f"المستوى {expected_level_order}"
    for sl in study_levels:
        if sl.get("level_order") == expected_level_order:
            expected_level_name = sl.get("level_name")
            break

    if expected_level_order != current_study_level_order:
        issues.append({
            "rule_code": "LEVEL_MISMATCH",
            "severity": "warning",
            "title": "عدم مطابقة المستوى الدراسي الفعلي مع المنجز",
            "description": f"المستوى الدراسي المسجل للطالب حالياً هو '{current_level_name}' (الترتيب: {current_study_level_order})، بينما تشير الساعات المنجزة ({passed_hours} ساعة) إلى أن المستوى المتوقع هو '{expected_level_name}' (الترتيب: {expected_level_order}).",
            "suggestion": "يُنصح بتحديث المستوى الدراسي للطالب في نظام شؤون الطلاب ليتوافق مع الساعات المنجزة الفعلية."
        })

    # Rule H3: Overload risk (warning)
    # Check if student registered > max_hours_fall_spring in any semester
    semesters = facts.get("semesters") or []
    for sem in semesters:
        sem_name = sem.get("semester_name") or sem.get("term") or ""
        is_summer = "summer" in sem_name.lower() or "صيفي" in sem_name
        registered = sem.get("registered_hours") or sem.get("total_hours") or 0
        
        if not is_summer and registered > max_hours_fall_spring:
            issues.append({
                "rule_code": "SEMESTER_OVERLOAD_RISK",
                "severity": "warning",
                "title": f"خطر تجاوز العبء الدراسي في {sem_name}",
                "description": f"عدد الساعات المسجلة للطالب في الفصل الدراسي ({registered} ساعة) يتجاوز العبء القياسي المسموح به لخطته الدراسية ({max_hours_fall_spring} ساعة).",
                "suggestion": "تجنب تسجيل ساعات زائدة في الفصول القادمة لمنع الضغط الدراسي والحفاظ على استقرار المعدل الأكاديمي."
            })

    # Rule H4: Summer cap exceeded (error)
    for sem in semesters:
        sem_name = sem.get("semester_name") or sem.get("term") or ""
        is_summer = "summer" in sem_name.lower() or "صيفي" in sem_name
        registered = sem.get("registered_hours") or sem.get("total_hours") or 0
        
        if is_summer and registered > summer_max_hours:
            issues.append({
                "rule_code": "SUMMER_CAP_EXCEEDED",
                "severity": "error",
                "title": f"تجاوز الحد الأقصى للفصل الصيفي في {sem_name}",
                "description": f"عدد الساعات المسجلة للطالب ({registered} ساعة) يتجاوز الحد الأقصى المسموح به للفصل الصيفي بموجب السياسات وهو ({summer_max_hours} ساعة).",
                "suggestion": f"يجب تعديل الجدول الأكاديمي وسحب المقررات الزائدة للالتزام بالحد الأقصى ({summer_max_hours} ساعة)."
            })

    # Rule H5: Very slow progress (info)
    # Retrieve expected hours for current study level
    current_level_min_hours = 0
    for sl in study_levels:
        if sl.get("level_order") == current_study_level_order:
            current_level_min_hours = sl.get("min_hours") or 0
            break
            
    if current_level_min_hours == 0:
        # Fallback approximation
        current_level_min_hours = (current_study_level_order - 1) * 15

    if passed_hours < (current_level_min_hours * slow_ratio):
        issues.append({
            "rule_code": "SLOW_PROGRESS_WARNING",
            "severity": "info",
            "title": "تقدم أكاديمي بطيء",
            "description": f"الساعات المنجزة الحالية للطالب ({passed_hours} ساعة) تقل بشكل ملحوظ عن الحد المتوقع لمستواه الأكاديمي الحالي وهو ({current_level_min_hours} ساعة) بمعدل تقدم يقل عن ({slow_ratio * 100:.0f}%).",
            "suggestion": "يُنصح بالتخطيط لتسجيل عبء دراسي كامل أو الاستعانة بالفصول الصيفية لتعويض النقص وتسريع التخرج."
        })
