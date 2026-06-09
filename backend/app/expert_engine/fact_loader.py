"""
Fact Loader: Loads all required facts for the expert system from Supabase.
All queries run concurrently using asyncio.gather where possible.
"""
import asyncio
import logging
from dataclasses import dataclass, field
from typing import Dict, Any, List, Optional, Tuple
from pydantic import BaseModel, Field, ValidationError

from app.core.database import supabase_admin
from app.core.exceptions import NotFoundError, ValidationException, SupabaseError

logger = logging.getLogger("acadexa.fact_loader")

SPECIAL_SYMBOLS = {"W", "I", "WP", "WF", "IP", "FA", "NP"}

# --- Pydantic Schemas for Policy Validation ---

class GpaRulesSchema(BaseModel):
    warning_threshold: float = Field(..., gt=0)
    risk_threshold: float = Field(..., gt=0)
    declining_semester_count: int = Field(..., gt=0)

class ProgressionRulesSchema(BaseModel):
    pass

class AcademicStatusRulesSchema(BaseModel):
    consecutive_semesters_for_probation: int = Field(..., gt=0)
    gpa_threshold_for_probation: float = Field(..., gt=0)

class AnalysisThresholdsSchema(BaseModel):
    slow_progress_ratio: float = Field(..., gt=0, lt=1)
    summer_max_hours: int = Field(..., gt=0)

class GraduationRulesSchema(BaseModel):
    civic_literacy_count: int = Field(..., ge=0)
    community_issues_course_code: str = Field(..., min_length=1)


@dataclass
class StudentFacts:
    # Student basics
    student_id: str
    student_code: str
    name: str
    department_id: str
    program_id: Optional[str]
    study_plan_id: str
    enrollment_year: int
    
    # Dynamic study level
    current_study_level_id: str
    current_study_level_name: str
    current_study_level_order: int
    
    # Computed academic metrics
    calculated_gpa: float
    total_attempted_hours: int
    total_passed_hours: int
    
    # Plan rules (from Supabase)
    graduation_req: dict
    load_rules: dict
    training_rules: dict
    plan: dict
    
    # Dynamic policies loaded from plan_policies
    plan_policies: dict  # { 'gpa_rules': {...}, 'progression_rules': {...}, ... }
    
    # Course data
    all_courses: list[dict]
    passed_courses: list[dict]
    failed_courses: list[dict]
    courses_by_code: dict[str, list]
    
    # Plan courses and requirements
    plan_courses: list[dict]
    prerequisites: list[dict]
    elective_groups: list[dict]
    
    # Study levels for this plan
    study_levels: list[dict]
    
    # Computed categorized hours
    mandatory_hours_passed: int
    elective_hours_passed: int
    university_hours_passed: int
    college_hours_passed: int
    field_training_hours_passed: int
    civic_literacy_courses_passed: int
    community_issues_passed: bool
    
    # Semester data
    semesters: list[dict]
    semester_gpas: list[float]
    
    # Academic status history
    status_rule_matches: list[dict]
    
    # Field training
    field_training_completed: bool
    field_training_levels_done: int
    
    # Flags
    is_on_academic_probation: bool

    # Backwards compatibility: allow dictionary-like attribute access
    def get(self, key: str, default: Any = None) -> Any:
        return getattr(self, key, default)

    def __getitem__(self, key: str) -> Any:
        if hasattr(self, key):
            return getattr(self, key)
        raise KeyError(key)


class FactLoader:
    """Loads all required facts for the expert system from Supabase."""

    async def load_raw_data(self, student_id: str) -> Dict[str, Any]:
        """
        Loads all raw database records for a student and their assigned study plan.
        """
        # 1. Load Student base info (required first to get plan_id)
        student = await self._load_student_base(student_id)
        plan_id = student.get("study_plan_id")
        if not plan_id:
            raise ValidationException(f"Student {student_id} does not have an assigned study plan.")

        # 2. Concurrently load all other student-specific and plan-specific data
        (
            all_courses,
            semesters,
            (grad_req, load_rules, training_rules, plan_data),
            plan_policies,
            study_levels,
            plan_courses,
            prerequisites,
            elective_groups,
        ) = await asyncio.gather(
            self._load_academic_history(student_id),
            self._load_semesters(student_id),
            self._load_plan_rules(plan_id),
            self._load_plan_policies(plan_id),
            self._load_study_levels(plan_id),
            self._load_plan_courses(plan_id),
            self._load_prerequisites(plan_id),
            self._load_elective_groups(plan_id),
        )

        # 3. Validate curriculum policies - NO DEFAULTS ALLOWED
        self._validate_all_policies(plan_policies, grad_req, training_rules, plan_data)

        # 4. Construct raw_data dictionary
        return {
            "student": student,
            "all_courses": all_courses,
            "semesters": semesters,
            "graduation_req": grad_req,
            "load_rules": load_rules,
            "training_rules": training_rules,
            "plan": plan_data,
            "plan_policies": plan_policies,
            "study_levels": study_levels,
            "plan_courses": plan_courses,
            "prerequisites": prerequisites,
            "elective_groups": elective_groups,
        }

    async def load_facts(self, student_id: str) -> StudentFacts:
        """
        Main method. Makes necessary Supabase queries and returns StudentFacts.
        All queries run concurrently using asyncio.gather where possible.
        """
        raw_data = await self.load_raw_data(student_id)
        # 5. Compute derived facts
        return self._compute_derived_facts(raw_data)

    async def _load_student_base(self, student_id: str) -> dict:
        """Query students table."""
        def _call():
            res = supabase_admin.table("students").select("*").eq("id", student_id).execute()
            if not res.data:
                raise NotFoundError(f"Student with ID {student_id} not found.")
            return res.data[0]
        return await asyncio.to_thread(_call)

    async def _load_academic_history(self, student_id: str) -> list[dict]:
        """Query student_courses with all fields."""
        def _call():
            res = supabase_admin.table("student_courses").select("*").eq("student_id", student_id).execute()
            return res.data or []
        return await asyncio.to_thread(_call)

    async def _load_semesters(self, student_id: str) -> list[dict]:
        """Query student_semesters ordered by semester_number."""
        def _call():
            res = supabase_admin.table("student_semesters").select("*").eq("student_id", student_id).order("semester_number").execute()
            return res.data or []
        return await asyncio.to_thread(_call)

    async def _load_plan_rules(self, plan_id: str) -> tuple[dict, dict, dict, dict]:
        """
        Load graduation_requirements, academic_load_rules,
        field_training_rules, study_plans for this plan_id.
        Returns all four as a tuple.
        """
        def _call():
            grad_res = supabase_admin.table("graduation_requirements").select("*").eq("plan_id", plan_id).execute()
            load_res = supabase_admin.table("academic_load_rules").select("*").eq("plan_id", plan_id).execute()
            train_res = supabase_admin.table("field_training_rules").select("*").eq("plan_id", plan_id).execute()
            plan_res = supabase_admin.table("study_plans").select("*").eq("id", plan_id).execute()

            grad_req = grad_res.data[0] if grad_res.data else {}
            load_rules = load_res.data[0] if load_res.data else {}
            training_rules = train_res.data[0] if train_res.data else {}
            plan_data = plan_res.data[0] if plan_res.data else {}

            return grad_req, load_rules, training_rules, plan_data

        return await asyncio.to_thread(_call)

    async def _load_plan_policies(self, plan_id: str) -> dict:
        """
        Load ALL policies from plan_policies table.
        Returns a dict: { 'gpa_rules': {...}, 'progression_rules': {...}, ... }
        """
        def _call():
            res = supabase_admin.table("plan_policies").select("*").eq("plan_id", plan_id).execute()
            policies = {}
            for row in (res.data or []):
                policies[row["policy_type"]] = row["policy_data"]
            return policies
        return await asyncio.to_thread(_call)

    async def _load_study_levels(self, plan_id: str) -> list[dict]:
        """
        Load study levels from study_levels table ordered by level_order.
        """
        def _call():
            res = supabase_admin.table("study_levels").select("*").eq("plan_id", plan_id).order("level_order").execute()
            return res.data or []
        return await asyncio.to_thread(_call)

    async def _load_plan_courses(self, plan_id: str) -> list[dict]:
        """Load all courses for this plan from courses table."""
        def _call():
            res = supabase_admin.table("courses").select("*").eq("study_plan_id", plan_id).execute()
            return res.data or []
        return await asyncio.to_thread(_call)

    async def _load_prerequisites(self, plan_id: str) -> list[dict]:
        """Load prerequisites."""
        def _call():
            res = supabase_admin.table("prerequisites").select("*").execute()
            return res.data or []
        return await asyncio.to_thread(_call)

    async def _load_elective_groups(self, plan_id: str) -> list[dict]:
        """Load elective_groups with their courses (elective_group_courses)."""
        def _call():
            # Get elective groups
            groups_res = supabase_admin.table("elective_groups").select("*").eq("plan_id", plan_id).execute()
            groups = groups_res.data or []
            if not groups:
                return []

            # Get linked courses for these groups
            group_ids = [g["id"] for g in groups]
            eg_courses_res = supabase_admin.table("elective_group_courses").select("*").in_("group_id", group_ids).execute()
            eg_courses = eg_courses_res.data or []

            # Structure courses inside elective groups
            for group in groups:
                group["courses"] = [
                    row["course_code"] for row in eg_courses if row["group_id"] == group["id"]
                ]
            return groups

        return await asyncio.to_thread(_call)

    def _validate_all_policies(self, plan_policies: dict, grad_req: dict, training_rules: dict, plan: dict):
        """
        Validates all policies against schema. Checks presence of critical keys.
        """
        # GPA rules
        gpa_rules = plan_policies.get("gpa_rules")
        if not gpa_rules:
            raise ValidationException("Missing 'gpa_rules' configuration in plan_policies.")
        try:
            GpaRulesSchema(**gpa_rules)
        except ValidationError as e:
            raise ValidationException(f"Invalid 'gpa_rules' configuration: {str(e)}")

        # Progression rules
        progression_rules = plan_policies.get("progression_rules")
        if not progression_rules:
            raise ValidationException("Missing 'progression_rules' configuration in plan_policies.")

        # Academic status rules
        academic_status_rules = plan_policies.get("academic_status_rules")
        if not academic_status_rules:
            raise ValidationException("Missing 'academic_status_rules' configuration in plan_policies.")
        try:
            AcademicStatusRulesSchema(**academic_status_rules)
        except ValidationError as e:
            raise ValidationException(f"Invalid 'academic_status_rules' configuration: {str(e)}")

        # Analysis thresholds
        analysis_thresholds = plan_policies.get("analysis_thresholds")
        if not analysis_thresholds:
            raise ValidationException("Missing 'analysis_thresholds' configuration in plan_policies.")
        try:
            AnalysisThresholdsSchema(**analysis_thresholds)
        except ValidationError as e:
            raise ValidationException(f"Invalid 'analysis_thresholds' configuration: {str(e)}")

        # Graduation rules
        graduation_rules = plan_policies.get("graduation_rules")
        if not graduation_rules:
            raise ValidationException("Missing 'graduation_rules' configuration in plan_policies.")
        try:
            GraduationRulesSchema(**graduation_rules)
        except ValidationError as e:
            raise ValidationException(f"Invalid 'graduation_rules' configuration: {str(e)}")

        # Check explicit critical values
        warning_threshold = gpa_rules.get("warning_threshold")
        risk_threshold = gpa_rules.get("risk_threshold")
        declining_semester_count = gpa_rules.get("declining_semester_count")
        slow_progress_ratio = analysis_thresholds.get("slow_progress_ratio")
        summer_max_hours = analysis_thresholds.get("summer_max_hours")
        community_issues_course_code = graduation_rules.get("community_issues_course_code")
        civic_literacy_count = graduation_rules.get("civic_literacy_count")

        required_training_levels = training_rules.get("required_training_levels") or plan_policies.get("training_rules", {}).get("required_training_levels")
        training_start_level = training_rules.get("training_start_level") or plan_policies.get("training_rules", {}).get("training_start_level")
        min_gpa_to_graduate = grad_req.get("min_gpa") or plan.get("min_gpa")

        missing_vars = []
        if warning_threshold is None: missing_vars.append("warning_threshold")
        if risk_threshold is None: missing_vars.append("risk_threshold")
        if declining_semester_count is None: missing_vars.append("declining_semester_count")
        if slow_progress_ratio is None: missing_vars.append("slow_progress_ratio")
        if summer_max_hours is None: missing_vars.append("summer_max_hours")
        if community_issues_course_code is None: missing_vars.append("community_issues_course_code")
        if civic_literacy_count is None: missing_vars.append("civic_literacy_count")
        if required_training_levels is None: missing_vars.append("required_training_levels")
        if training_start_level is None: missing_vars.append("training_start_level")
        if min_gpa_to_graduate is None: missing_vars.append("min_gpa_to_graduate")

        if missing_vars:
            raise ValidationException(f"Missing required policy values in database: {', '.join(missing_vars)}")

    def _compute_derived_facts(self, raw_data: dict) -> StudentFacts:
        """
        Compute all derived fields.
        """
        student = raw_data["student"]
        all_courses = raw_data["all_courses"]
        semesters = raw_data["semesters"]
        plan = raw_data["plan"]
        plan_policies = raw_data["plan_policies"]
        study_levels = raw_data["study_levels"]
        plan_courses = raw_data["plan_courses"]
        prerequisites = raw_data["prerequisites"]
        elective_groups = raw_data["elective_groups"]
        graduation_req = raw_data["graduation_req"]
        load_rules = raw_data["load_rules"]
        training_rules = raw_data["training_rules"]

        # Fetch grading scale dynamically from DB for plan_id
        # We can run synchronously or use standard scale if not cached
        plan_id = student["study_plan_id"]
        scale = self._get_grading_scale_sync(plan_id)

        # 1. Categorize courses taken
        passed_courses = []
        failed_courses = []
        courses_by_code = {}

        for sc in all_courses:
            code = sc["course_code"]
            if code not in courses_by_code:
                courses_by_code[code] = []
            courses_by_code[code].append(sc)

            grade_letter = sc.get("grade_letter") or "F"
            # Define passed if grade points > 0 or status == passed (non-failing)
            pts = scale.get(grade_letter, 0.0)
            is_passed = sc.get("status") == "passed" or (grade_letter not in SPECIAL_SYMBOLS and grade_letter != "F" and pts > 0.0)
            
            if is_passed:
                passed_courses.append(sc)
            elif grade_letter in {"F", "FA"}:
                failed_courses.append(sc)

        # 2. Dynamic study level matching
        current_level_num = student.get("study_level") or 1
        current_study_level_id = ""
        current_study_level_name = f"Level {current_level_num}"
        current_study_level_order = current_level_num

        for sl in study_levels:
            if sl["level_order"] == current_level_num or sl["level_name"].lower() == str(current_level_num).lower():
                current_study_level_id = sl["id"]
                current_study_level_name = sl["level_name"]
                current_study_level_order = sl["level_order"]
                break

        # 3. Calculate Academic Metrics
        # Attempted hours (excluding special grade symbols)
        total_attempted_hours = sum(
            c["credit_hours"] for c in all_courses if c.get("grade_letter") not in SPECIAL_SYMBOLS
        )
        # Passed hours
        passed_codes_set = {c["course_code"] for c in passed_courses}
        total_passed_hours = sum(c["credit_hours"] for c in passed_courses)

        # GPA calculation
        total_grade_points = 0.0
        total_gpa_hours = 0
        for sc in all_courses:
            grade_letter = sc.get("grade_letter")
            if grade_letter in SPECIAL_SYMBOLS or grade_letter is None:
                continue
            pts = scale.get(grade_letter)
            if pts is None:
                continue
            total_grade_points += pts * sc["credit_hours"]
            total_gpa_hours += sc["credit_hours"]

        calculated_gpa = round(total_grade_points / total_gpa_hours, 2) if total_gpa_hours > 0 else 0.0

        # 4. Categorized passed hours
        mandatory_hours_passed = 0
        elective_hours_passed = 0
        university_hours_passed = 0
        college_hours_passed = 0
        field_training_hours_passed = 0
        civic_literacy_courses_passed = 0

        # Map plan course categories
        plan_course_map = {c["code"]: c for c in plan_courses}

        for sc in passed_courses:
            code = sc["course_code"]
            hrs = sc["credit_hours"]
            plan_c = plan_course_map.get(code)
            
            category = ""
            if plan_c:
                category = (plan_c.get("category") or "").lower()

            if "compulsory" in category or "mandatory" in category or "required" in category:
                mandatory_hours_passed += hrs
            elif "elective" in category:
                elective_hours_passed += hrs

            if "university" in category:
                university_hours_passed += hrs
                # General education / general general university elective is civic literacy
                if "elective" in category:
                    civic_literacy_courses_passed += 1
            elif "college" in category:
                college_hours_passed += hrs

            if "training" in code.lower() or "تدريب" in sc.get("course_name", "").lower() or "field" in code.lower():
                field_training_hours_passed += hrs

        # Community issues course check
        grad_rules_policy = plan_policies.get("graduation_rules", {})
        comm_code = grad_rules_policy.get("community_issues_course_code", "UNIV201")
        community_issues_passed = comm_code in passed_codes_set

        # Semester GPAs list
        semester_gpas = []
        for sem in semesters:
            sem_courses = [
                c for c in all_courses if c.get("semester_id") == sem["id"]
            ]
            sem_pts = 0.0
            sem_hrs = 0
            for c in sem_courses:
                gl = c.get("grade_letter")
                if gl in SPECIAL_SYMBOLS or gl is None:
                    continue
                pts = scale.get(gl)
                if pts is None:
                    continue
                sem_pts += pts * c["credit_hours"]
                sem_hrs += c["credit_hours"]
            sem_gpa = round(sem_pts / sem_hrs, 2) if sem_hrs > 0 else 0.0
            semester_gpas.append(sem_gpa)

        # 5. Evaluate academic status dynamically
        status_rule_matches, is_on_academic_probation = self._evaluate_academic_status(
            semesters, plan_policies.get("academic_status_rules", {})
        )

        # 6. Field training completed detection
        # Check if student completed required training levels
        req_training_levels = training_rules.get("required_training_levels") or plan_policies.get("training_rules", {}).get("required_training_levels", 2)
        
        # Determine training levels done by counting distinct field training course codes passed
        training_courses_passed = set()
        for sc in passed_courses:
            code = sc["course_code"].lower()
            name = sc.get("course_name", "").lower()
            if "training" in code or "تدريب" in name or "field" in code:
                training_courses_passed.add(sc["course_code"])
        
        field_training_levels_done = len(training_courses_passed)
        field_training_completed = field_training_levels_done >= req_training_levels
        # Map prerequisites to have course_code and prerequisite_code instead of IDs
        course_id_to_code = {c["id"]: c["code"] for c in plan_courses}
        mapped_prerequisites = []
        for p in prerequisites:
            c_code = course_id_to_code.get(p.get("course_id"))
            p_code = course_id_to_code.get(p.get("prerequisite_course_id"))
            if c_code and p_code:
                mapped_prerequisites.append({
                    "course_code": c_code,
                    "prerequisite_code": p_code,
                    "must_be_prior_term": p.get("must_be_prior_term") or False,
                    "min_grade": p.get("min_grade"),
                })

        return StudentFacts(
            student_id=student["id"],
            student_code=student.get("student_code") or student.get("student_id_external") or "",
            name=student.get("name") or student.get("name_ar") or "",
            department_id=student.get("department_id"),
            program_id=student.get("program_id"),
            study_plan_id=plan_id,
            enrollment_year=student.get("enrollment_year") or 2020,
            current_study_level_id=current_study_level_id,
            current_study_level_name=current_study_level_name,
            current_study_level_order=current_study_level_order,
            calculated_gpa=calculated_gpa,
            total_attempted_hours=total_attempted_hours,
            total_passed_hours=total_passed_hours,
            graduation_req=graduation_req,
            load_rules=load_rules,
            training_rules=training_rules,
            plan=plan,
            plan_policies=plan_policies,
            all_courses=all_courses,
            passed_courses=passed_courses,
            failed_courses=failed_courses,
            courses_by_code=courses_by_code,
            plan_courses=plan_courses,
            prerequisites=mapped_prerequisites,
            elective_groups=elective_groups,
            study_levels=study_levels,
            mandatory_hours_passed=mandatory_hours_passed,
            elective_hours_passed=elective_hours_passed,
            university_hours_passed=university_hours_passed,
            college_hours_passed=college_hours_passed,
            field_training_hours_passed=field_training_hours_passed,
            civic_literacy_courses_passed=civic_literacy_courses_passed,
            community_issues_passed=community_issues_passed,
            semesters=semesters,
            semester_gpas=semester_gpas,
            status_rule_matches=status_rule_matches,
            field_training_completed=field_training_completed,
            field_training_levels_done=field_training_levels_done,
            is_on_academic_probation=is_on_academic_probation,
        )

    def _evaluate_academic_status(
        self, semesters: list[dict], academic_status_rules: dict
    ) -> tuple[list[dict], bool]:
        """
        Dynamically evaluate academic status rules against semester history.
        """
        consecutive_req = academic_status_rules.get("consecutive_semesters_for_probation", 2)
        gpa_threshold = academic_status_rules.get("gpa_threshold_for_probation", 2.0)

        consecutive_low_gpa = 0
        matches = []
        is_on_probation = False

        # Sort semesters sequentially
        sorted_semesters = sorted(semesters, key=lambda s: s.get("semester_number") or 0)

        for sem in sorted_semesters:
            sem_gpa = sem.get("semester_gpa") or sem.get("gpa_cumulative") or sem.get("gpa") or 0.0
            if sem_gpa < gpa_threshold:
                consecutive_low_gpa += 1
                if consecutive_low_gpa >= consecutive_req:
                    is_on_probation = True
                    matches.append({
                        "rule_name": "ACADEMIC_PROBATION",
                        "matched_at_semester": sem.get("id"),
                        "gpa": sem_gpa,
                        "semester_number": sem.get("semester_number"),
                    })
            else:
                consecutive_low_gpa = 0

        return matches, is_on_probation

    def _get_grading_scale_sync(self, plan_id: str) -> Dict[str, float]:
        """Fetch grading scale synchronously (with safety fallback)."""
        try:
            # Check for scale in plan first
            plan_res = supabase_admin.table("study_plans").select("default_grading_scale_id").eq("id", plan_id).execute()
            scale_id = None
            if plan_res.data and plan_res.data[0].get("default_grading_scale_id"):
                scale_id = plan_res.data[0]["default_grading_scale_id"]
            else:
                scale_res = supabase_admin.table("grading_scales").select("id").eq("plan_id", plan_id).execute()
                if scale_res.data:
                    scale_id = scale_res.data[0]["id"]

            if scale_id:
                items_res = supabase_admin.table("grade_scale_items").select("grade_letter,points").eq("grade_scale_id", scale_id).execute()
                if items_res.data:
                    return {item["grade_letter"]: float(item["points"]) for item in items_res.data}
        except Exception as e:
            logger.warning(f"Failed to fetch scale for plan {plan_id}: {e}")

        # Sensible standard fallback grading scale
        return {
            "A+": 4.00, "A": 3.75, "B+": 3.50, "B": 3.00,
            "C+": 2.50, "C": 2.00, "D+": 1.50, "D": 1.00, "F": 0.00
        }
