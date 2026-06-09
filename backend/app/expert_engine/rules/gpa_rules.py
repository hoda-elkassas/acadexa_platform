"""
GPA Rules: Evaluates student GPA against graduation requirements and policy thresholds.
"""
from typing import Dict, Any, List

def check(facts: Any, issues: List[Dict[str, Any]], recommendations: List[Dict[str, Any]]):
    # Retrieve calculated GPA and policy details
    calculated_gpa = facts.get("calculated_gpa") or facts.get("gpa") or 0.0
    plan_policies = facts.get("plan_policies") or {}
    gpa_policy = plan_policies.get("gpa_rules") or {}
    
    warning_threshold = gpa_policy.get("warning_threshold", 2.0)
    risk_threshold = gpa_policy.get("risk_threshold", 2.0)
    declining_count = gpa_policy.get("declining_semester_count", 3)
    
    # Retrieve graduation requirements minimum GPA
    grad_req = facts.get("graduation_req") or facts.get("graduation_requirements") or {}
    plan_data = facts.get("plan") or {}
    min_gpa_to_graduate = grad_req.get("min_gpa") or plan_data.get("min_gpa") or 2.0

    # Rule: Academic Probation (from consecutive semesters low GPA)
    consecutive_low_gpa = 0
    consecutive_req = 2
    gpa_threshold = 2.0
    is_on_probation = facts.get("is_on_academic_probation")
    if is_on_probation is None:
        student_semesters = facts.get("student_semesters") or facts.get("semesters") or []
        for sem in student_semesters:
            sem_gpa = sem.get("gpa") or sem.get("gpa_cumulative") or sem.get("semester_gpa") or 0.0
            if sem_gpa < gpa_threshold:
                consecutive_low_gpa += 1
                if consecutive_low_gpa >= consecutive_req:
                    is_on_probation = True
            else:
                consecutive_low_gpa = 0

    if is_on_probation:
        issues.append({
            "rule_code": "ACADEMIC_PROBATION",
            "severity": "error",
            "title": "إنذار أكاديمي (وضع تحت الملاحظة)",
            "description": "تم وضع الطالب تحت الإنذار الأكاديمي بسبب انخفاض المعدل التراكمي عن 2.00 لفصلين متتاليين أو أكثر.",
            "suggestion": "يرجى مراجعة المرشد الأكاديمي لتسجيل حد أدنى من الساعات وتحسين الأداء."
        })

    # Rule G1: GPA below graduation minimum (error)
    if calculated_gpa < min_gpa_to_graduate:
        issues.append({
            "rule_code": "GPA_BELOW_GRAD_MINIMUM",
            "severity": "error",
            "title": "المعدل دون حد التخرج",
            "description": f"المعدل التراكمي المحتسب للعمليات ({calculated_gpa:.2f}) أقل من الحد الأدنى المطلوب للتخرج وهو ({min_gpa_to_graduate:.2f}).",
            "suggestion": "يجب التركيز على تحسين الدرجات وإعادة دراسة المواد ذات التقدير المنخفض لرفع المعدل التراكمي."
        })

    # Rule: Low GPA warning (warning)
    if calculated_gpa < warning_threshold:
        issues.append({
            "rule_code": "LOW_GPA_WARNING",
            "severity": "warning",
            "title": "تدني المعدل التراكمي عن الحد المقبول",
            "description": f"المعدل التراكمي الحالي للعمليات ({calculated_gpa:.2f}) يقل عن حد الإنذار الأكاديمي ({warning_threshold:.2f}).",
            "suggestion": "يرجى مراجعة المرشد الأكاديمي لوضع خطة تحسين أكاديمي عاجلة."
        })

    # Rule G2: GPA critically low - probation risk (warning)
    if calculated_gpa < risk_threshold and is_on_probation:
        issues.append({
            "rule_code": "LOW_GPA_PROBATION_RISK",
            "severity": "warning",
            "title": "خطر التعليق الأكاديمي بسبب تدني المعدل",
            "description": f"معدل الطالب التراكمي ({calculated_gpa:.2f}) يقل عن حد المخاطرة الأكاديمية ({risk_threshold:.2f}) مع وقوعه تحت الإنذار الأكاديمي.",
            "suggestion": "يُنصح بتقليص الساعات المسجلة في الفصل القادم والتركيز على رفع المعدل لتفادي تعليق القيد الأكاديمي."
        })

    # Rule G3: GPA declining trend (info)
    # Check if the last N semester GPAs are monotonically decreasing
    semester_gpas = facts.get("semester_gpas") or []
    if len(semester_gpas) >= declining_count:
        recent_gpas = semester_gpas[-declining_count:]
        is_declining = True
        for i in range(len(recent_gpas) - 1):
            if recent_gpas[i+1] >= recent_gpas[i]:
                is_declining = False
                break
        
        if is_declining:
            trend_str = " -> ".join(f"{g:.2f}" for g in recent_gpas)
            issues.append({
                "rule_code": "GPA_TREND_DECLINING",
                "severity": "info",
                "title": "تراجع مستمر في المعدل الفصلي",
                "description": f"يظهر تحليل الأداء تراجعاً مستمراً في المعدلات الفصلية لآخر {declining_count} فصول دراسية: ({trend_str}).",
                "suggestion": "يُنصح بمراجعة أساليب الدراسة وتعديل الخطة الدراسية بالتنسيق مع المرشد الأكاديمي لمنع استمرار التراجع."
            })

    # Rule G4: GPA near probation threshold (warning)
    if (warning_threshold - 0.2) <= calculated_gpa < warning_threshold:
        issues.append({
            "rule_code": "GPA_NEAR_PROBATION_THRESHOLD",
            "severity": "warning",
            "title": "المعدل يقترب من حد الإنذار الأكاديمي",
            "description": f"المعدل التراكمي الحالي ({calculated_gpa:.2f}) يقترب بشكل حرج من حد الإنذار الأكاديمي ({warning_threshold:.2f}).",
            "suggestion": "يجب توخي الحذر وبذل المزيد من الجهد في المقررات الحالية لضمان بقاء المعدل فوق حد الإنذار."
        })
