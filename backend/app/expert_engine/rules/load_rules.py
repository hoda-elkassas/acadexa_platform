"""
Load Rules: Verifies student registered credit hours limits (overload/underload/summer caps) 
based on cumulative GPA and semester types.
"""
from typing import Dict, Any, List

def check(facts: Dict[str, Any], issues: List[Dict[str, Any]], recommendations: List[Dict[str, Any]]):
    semesters = facts.get("student_semesters") or facts.get("semesters") or []
    load_rules = facts.get("academic_load_rules") or facts.get("load_rules") or {}
    
    # Load limits
    max_high = load_rules.get("max_hours_gpa_high", 20)
    max_normal = load_rules.get("max_hours_gpa_normal", 18)
    max_low = load_rules.get("max_hours_gpa_low", 12)
    min_hours = load_rules.get("min_hours", 12)
    summer_cap = load_rules.get("summer_cap", 9)

    for sem in semesters:
        sem_name = sem.get("semester_name", "").lower()
        registered = sem.get("registered_hours") or 0
        sem_gpa = sem.get("gpa") or 0.0
        gpa_cum = sem.get("gpa_cumulative") or sem_gpa
        
        is_summer = "summer" in sem_name or "صيفي" in sem_name
        
        if is_summer:
            if registered > summer_cap:
                issues.append({
                    "rule_code": "SUMMER_CAP_EXCEEDED",
                    "severity": "error",
                    "title": f"تجاوز عبء الفصل الصيفي في {sem.get('semester_name')}",
                    "description": f"عدد الساعات المسجلة ({registered}) يتجاوز الحد الأقصى للفصل الصيفي وهو {summer_cap} ساعات.",
                    "suggestion": "قم بسحب بعض المواد لتتوافق مع الحد الأقصى للفصل الصيفي."
                })
        else:
            # Regular semester load checking
            allowed_max = max_normal
            if gpa_cum >= 3.0:
                allowed_max = max_high
            elif gpa_cum < 2.0:
                allowed_max = max_low

            if registered > allowed_max:
                issues.append({
                    "rule_code": "SEMESTER_OVERLOAD",
                    "severity": "error",
                    "title": f"تجاوز عبء الفصل الدراسي في {sem.get('semester_name')}",
                    "description": f"عدد الساعات المسجلة ({registered}) يتجاوز الحد الأقصى المسموح به لمعدلك الأكاديمي ({allowed_max} ساعة).",
                    "suggestion": f"يجب تعديل الجدول الأكاديمي وسحب ساعات إضافية لتصل إلى الحد الأقصى {allowed_max}."
                })
            elif registered < min_hours and registered > 0:
                issues.append({
                    "rule_code": "SEMESTER_UNDERLOAD",
                    "severity": "warning",
                    "title": f"نقص عبء الفصل الدراسي في {sem.get('semester_name')}",
                    "description": f"عدد الساعات المسجلة ({registered}) أقل من الحد الأدنى المسموح للتسجيل وهو {min_hours} ساعات.",
                    "suggestion": f"يُنصح بإضافة مواد أخرى للوصول للحد الأدنى للتسجيل وهو {min_hours} ساعات، إلا في حالات التخرج."
                })
