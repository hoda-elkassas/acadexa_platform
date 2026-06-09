"""
Prerequisite Rules: Verifies course prerequisite completions, prior semester requirements, and min grades.
Supports both list-of-dicts and dict-of-lists input formats for testing compatibility.
"""
from typing import Dict, Any, List

def check(facts: Any, issues: List[Dict[str, Any]], recommendations: List[Dict[str, Any]]):
    student_courses = facts.get("all_courses") or facts.get("student_courses") or []
    raw_prereqs = facts.get("prerequisites") or []
    equivalents = facts.get("equivalents") or {}
    semesters = facts.get("semesters") or facts.get("student_semesters") or []

    # Map semester_id to semester_number
    sem_num_map = {}
    for i, sem in enumerate(semesters):
        s_id = sem.get("id") or sem.get("semester_name") or f"sem_{i}"
        sem_num_map[s_id] = sem.get("semester_number") or i

    # Fetch plan_id and grading scale to compare min grades
    plan_id = facts.get("study_plan_id")
    scale = {}
    if plan_id:
        try:
            from app.expert_engine.fact_loader import FactLoader
            scale = FactLoader()._get_grading_scale_sync(plan_id)
        except Exception:
            pass
    if not scale:
        # Fallback default scale
        scale = {
            "A+": 4.0, "A": 4.0, "A-": 3.7,
            "B+": 3.3, "B": 3.0, "B-": 2.7,
            "C+": 2.3, "C": 2.0, "C-": 1.7,
            "D+": 1.3, "D": 1.0, "D-": 0.7,
            "F": 0.0
        }

    # Normalize prerequisites input
    prereqs = []
    if isinstance(raw_prereqs, dict):
        for c_code, p_codes in raw_prereqs.items():
            for p_code in p_codes:
                prereqs.append({
                    "course_code": c_code,
                    "prerequisite_code": p_code,
                    "must_be_prior_term": True,
                    "min_grade": None
                })
    else:
        prereqs = raw_prereqs

    # Helper: Check if a student course passed the prerequisite course (or its equivalents)
    # in or before a specific semester number.
    def get_prereq_status(req_code: str, before_sem_num: int) -> tuple[bool, str, int]:
        """
        Returns (is_passed, grade_letter, semester_number).
        """
        best_grade_points = -1.0
        best_grade_letter = "F"
        best_sem_num = 9999
        found_pass = False

        # Gather target codes (prereq code + equivalents)
        target_codes = {req_code}
        if req_code in equivalents:
            target_codes.update(equivalents[req_code])

        for sc in student_courses:
            if sc.get("course_code") in target_codes:
                status = sc.get("status")
                gl = sc.get("grade_letter") or "F"
                sem_id = sc.get("semester_id") or sc.get("semester_name")
                sem_num = sem_num_map.get(sem_id, 9999)

                if sem_num <= before_sem_num:
                    pts = scale.get(gl, 0.0)
                    # Consider passed if status is "passed" or points > 0
                    is_passed = status == "passed" or (gl not in {"F", "FA"} and pts > 0.0)
                    if is_passed:
                        found_pass = True
                        if pts > best_grade_points:
                            best_grade_points = pts
                            best_grade_letter = gl
                            best_sem_num = sem_num

        return found_pass, best_grade_letter, best_sem_num

    # Verify each registered/in-progress student course
    for sc in student_courses:
        code = sc.get("course_code")
        status = sc.get("status")
        sem_id = sc.get("semester_id") or sc.get("semester_name")
        sem_num = sem_num_map.get(sem_id, 9999)

        # Check prerequisites for this course code
        course_prereqs = [p for p in prereqs if p["course_code"] == code]
        for p in course_prereqs:
            req_code = p["prerequisite_code"]
            must_prior = p.get("must_be_prior_term") or False
            min_grade = p.get("min_grade")

            is_passed, prereq_grade, prereq_sem_num = get_prereq_status(req_code, sem_num)

            # Rule P1: Prerequisite not completed / min grade not met (error)
            if not is_passed:
                # If course is in_progress/planned, we flag it as missing prerequisite
                if status in {"in_progress", "planned"}:
                    issues.append({
                        "rule_code": "MISSING_PREREQUISITE",
                        "severity": "error",
                        "title": "متطلب سابق غير مكتمل",
                        "description": f"المقرر '{code}' يتطلب اجتياز المقرر '{req_code}' أولاً كمتطلب سابق.",
                        "suggestion": f"يجب تسجيل واجتياز مقرر '{req_code}' قبل التقدم لتسجيل مقرر '{code}'."
                    })
                else:
                    # Course is already passed/failed but prerequisite was not met at the time
                    issues.append({
                        "rule_code": "MISSING_PREREQUISITE_HISTORICAL",
                        "severity": "error",
                        "title": "مخالفة متطلب سابق",
                        "description": f"تم تسجيل المقرر '{code}' دون اجتياز متطلبه السابق '{req_code}'.",
                        "suggestion": "تأكد من تسوية وضع هذا المقرر إدارياً مع القسم المعني."
                    })
            else:
                # Prerequisite is passed, check min grade constraint
                if min_grade:
                    min_pts = scale.get(min_grade, 0.0)
                    prereq_pts = scale.get(prereq_grade, 0.0)
                    if prereq_pts < min_pts:
                        issues.append({
                            "rule_code": "PREREQ_MIN_GRADE_NOT_MET",
                            "severity": "error",
                            "title": "درجة متطلب سابق غير كافية",
                            "description": f"المقرر '{code}' يتطلب اجتياز '{req_code}' بتقدير لا يقل عن '{min_grade}'، بينما حصل الطالب على تقدير '{prereq_grade}'.",
                            "suggestion": f"يجب إعادة دراسة مقرر '{req_code}' لتحسين التقدير وتلبية متطلبات المقررات اللاحقة."
                        })

                # Rule P2: Prerequisite taken in the same semester (warning)
                if must_prior and prereq_sem_num == sem_num:
                    issues.append({
                        "rule_code": "PREREQ_SAME_SEMESTER_WARNING",
                        "severity": "warning",
                        "title": "تسجيل متزامن لمتطلب سابق إجباري",
                        "description": f"تم تسجيل المقرر '{code}' ومتمتلبه السابق '{req_code}' في نفس الفصل الدراسي، على الرغم من أن المتطلب يجب أن يكون في فصل سابق.",
                        "suggestion": "تأكد من الحصول على موافقة استثنائية من مجلس القسم/الكلية للتسجيل المتزامن."
                    })

    # Rule P3: Missing prerequisite chain (info)
    # Check planned courses or courses student hasn't taken yet that are in the plan but prerequisites are not met
    plan_courses = facts.get("plan_courses") or []
    passed_codes = {c["course_code"] for c in facts.get("passed_courses") or []}
    taken_codes = {c["course_code"] for c in student_courses}

    for pc in plan_courses:
        pc_code = pc.get("code")
        if pc_code and pc_code not in taken_codes:
            pc_prereqs = [p for p in prereqs if p["course_code"] == pc_code]
            for p in pc_prereqs:
                req_code = p["prerequisite_code"]
                if req_code not in passed_codes:
                    recommendations.append({
                        "course_code": req_code,
                        "course_name": f"متطلب لـ {pc_code}",
                        "priority": 3,
                        "reason": f"مقرر '{req_code}' متطلب إجباري لمقرر '{pc_code}' المقترح في خطتك الأكاديمية."
                    })
