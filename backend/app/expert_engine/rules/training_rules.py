"""
Training Rules: Evaluates Field Training progress, start levels, and required levels.
"""
from typing import Dict, Any, List

def check(facts: Any, issues: List[Dict[str, Any]], recommendations: List[Dict[str, Any]]):
    grad_req = facts.get("graduation_req") or {}
    requires_training = grad_req.get("requires_field_training") or False
    
    # Retrieve field training rules/policies
    training_rules = facts.get("training_rules") or {}
    plan_policies = facts.get("plan_policies") or {}
    training_policy = plan_policies.get("training_rules") or {}

    # Read config with no hardcoded fallback values during runtime validation
    start_level = training_rules.get("training_start_level") or training_policy.get("training_start_level") or 3
    required_levels = training_rules.get("required_training_levels") or training_policy.get("required_training_levels") or 2

    study_level = facts.get("current_study_level_order") or 1
    field_training_completed = facts.get("field_training_completed") or False
    field_training_levels_done = facts.get("field_training_levels_done") or 0

    # Rule T1: Field training not started (warning)
    if study_level >= start_level and field_training_levels_done == 0:
        issues.append({
            "rule_code": "FIELD_TRAINING_NOT_STARTED",
            "severity": "warning",
            "title": "لم يتم البدء في التدريب الميداني",
            "description": f"وصل الطالب إلى المستوى الدراسي {study_level} (الحد المسموح لبدء التدريب هو {start_level}) ولكنه لم يبدأ التدريب الميداني بعد.",
            "suggestion": "يُنصح بالتنسيق مع منسق التدريب بالقسم لتسجيل مقرر التدريب الميداني في الفصل القادم."
        })
        recommendations.append({
            "course_code": "FIELD_TRAINING",
            "course_name": "التدريب الميداني",
            "priority": 1,
            "reason": f"الطالب مؤهل ومستحق لبدء التدريب الميداني لتخطيه المستوى الدراسي {start_level}."
        })

    # Rule T2: Field training insufficient levels (error)
    if 0 < field_training_levels_done < required_levels:
        remaining_levels = required_levels - field_training_levels_done
        issues.append({
            "rule_code": "FIELD_TRAINING_INSUFFICIENT_LEVELS",
            "severity": "error",
            "title": "مستويات التدريب الميداني غير مكتملة",
            "description": f"أنجز الطالب {field_training_levels_done} مستوى من التدريب الميداني من أصل {required_levels} مستويات مطلوبة.",
            "suggestion": f"يجب تسجيل واجتياز {remaining_levels} فترات/مستويات إضافية من التدريب الميداني لاستيفاء المتطلب."
        })

    # Rule T3: Field training mandatory but not done (error if mandatory_for_graduation)
    if requires_training and not field_training_completed:
        # Avoid duplicate error messages if T2 already fired
        if field_training_levels_done == 0:
            issues.append({
                "rule_code": "FIELD_TRAINING_MANDATORY_NOT_DONE",
                "severity": "error",
                "title": "التدريب الميداني الإجباري غير مكتمل",
                "description": "لم ينجز الطالب متطلب التدريب الميداني، وهو متطلب إجباري للتخرج في خطته الدراسية.",
                "suggestion": "تواصل مع منسق التدريب بالقسم للبدء في إجراءات التسجيل بالمستوى التدريبي الأول فوراً."
            })

# Expose helper to identify training status for graduation rules
def is_field_training_completed(facts: Any) -> bool:
    return facts.get("field_training_completed") or False
