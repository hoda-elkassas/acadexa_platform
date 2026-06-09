"""
Curriculum Service: Manages JSON export, validation, import and copying of academic study plans.
"""
from typing import Dict, Any, List
from app.core.database import supabase_admin
from app.core.exceptions import NotFoundError, SupabaseError

class CurriculumService:
    @staticmethod
    def export_curriculum(plan_id: str) -> Dict[str, Any]:
        """
        Fetches the complete study plan with all its rules and courses, returning it as a single JSON object.
        """
        plan_res = supabase_admin.table("study_plans").select("*").eq("id", plan_id).execute()
        if not plan_res.data:
            raise NotFoundError(f"Study plan {plan_id} not found.")
        plan = plan_res.data[0]

        # Fetch relations
        courses_res = supabase_admin.table("courses").select("*").eq("study_plan_id", plan_id).execute()
        grad_res = supabase_admin.table("graduation_requirements").select("*").eq("plan_id", plan_id).execute()
        load_res = supabase_admin.table("academic_load_rules").select("*").eq("plan_id", plan_id).execute()
        training_res = supabase_admin.table("field_training_rules").select("*").eq("plan_id", plan_id).execute()
        groups_res = supabase_admin.table("elective_groups").select("*").eq("plan_id", plan_id).execute()

        # Fetch prerequisites
        prereqs_res = supabase_admin.table("prerequisites").select("*").execute()
        prereq_map = {}
        if prereqs_res.data:
            for p in prereqs_res.data:
                c = p.get("course_code")
                pre = p.get("prerequisite_course_code")
                if c not in prereq_map:
                    prereq_map[c] = []
                prereq_map[c].append(pre)

        # Build elective groups map
        elective_groups_data = []
        if groups_res.data:
            g_ids = [g["id"] for g in groups_res.data]
            eg_courses_res = supabase_admin.table("elective_group_courses").select("*").in_("group_id", g_ids).execute()
            eg_map = {}
            if eg_courses_res.data:
                for row in eg_courses_res.data:
                    g_id = row.get("group_id")
                    c_code = row.get("course_code")
                    if g_id not in eg_map:
                        eg_map[g_id] = []
                    eg_map[g_id].append(c_code)
            
            for g in groups_res.data:
                elective_groups_data.append({
                    "name_ar": g.get("name_ar"),
                    "required_hours": g.get("required_hours"),
                    "courses": eg_map.get(g["id"], [])
                })

        courses_data = []
        for c in (courses_res.data or []):
            code = c.get("code")
            courses_data.append({
                "code": code,
                "name_ar": c.get("name_ar"),
                "name_en": c.get("name_en"),
                "credit_hours": c.get("credit_hours"),
                "category": c.get("category"),
                "level": c.get("level", 1),
                "prerequisites": prereq_map.get(code, [])
            })

        return {
            "plan_name": plan.get("name"),
            "department_id": plan.get("department_id"),
            "enrollment_year": plan.get("enrollment_year"),
            "required_hours": grad_res.data[0].get("required_hours", 136) if grad_res.data else 136,
            "min_gpa": grad_res.data[0].get("min_gpa", 2.0) if grad_res.data else 2.0,
            "rules": {
                "graduation": grad_res.data[0] if grad_res.data else {},
                "load": load_res.data[0] if load_res.data else {},
                "training": training_res.data[0] if training_res.data else {}
            },
            "courses": courses_data,
            "elective_groups": elective_groups_data
        }

    @staticmethod
    def validate_curriculum(curriculum_json: Dict[str, Any]) -> Dict[str, Any]:
        """
        Validates JSON schema, checking for missing prerequisites, loop dependencies, 
        non-positive credit hours, and outputting statistics.
        """
        errors = []
        warnings = []
        
        if not curriculum_json.get("plan_name"):
            errors.append("اسم خطة الدراسة مفقود (Missing 'plan_name')")
        
        courses = curriculum_json.get("courses") or []
        course_codes = {c.get("code") for c in courses if c.get("code")}

        total_courses = len(courses)
        total_hours = 0

        # Build graph for circular dependency checks
        graph = {}
        
        for c in courses:
            code = c.get("code")
            if not code:
                errors.append("كود المقرر مفقود لأحد المقررات (Missing course 'code')")
                continue
                
            hours = c.get("credit_hours", 0)
            if hours <= 0:
                errors.append(f"عدد الساعات المعتمدة للمقرر {code} يجب أن يكون أكبر من صفر (Credit hours must be > 0)")
            else:
                total_hours += hours
                
            prereqs = c.get("prerequisites") or []
            graph[code] = prereqs
            
            for pre in prereqs:
                if pre not in course_codes:
                    errors.append(f"المقرر '{code}' يتطلب المتطلب السابق '{pre}' وهو غير موجود بالخطة الدراسي.")
                if pre == code:
                    errors.append(f"المقرر '{code}' لا يمكن أن يكون متطلباً سابقاً لنفسه.")

        # Cycle detection using DFS
        visited = {}  # 0 = unvisited, 1 = visiting, 2 = visited
        
        def dfs(node):
            visited[node] = 1
            for neighbor in graph.get(node, []):
                if visited.get(neighbor, 0) == 1:
                    errors.append(f"كشف حلقة متداخلة (دائرية) في المتطلبات السابقة: {node} -> {neighbor}")
                    return True
                elif visited.get(neighbor, 0) == 0:
                    if dfs(neighbor):
                        return True
            visited[node] = 2
            return False

        for node in graph:
            if visited.get(node, 0) == 0:
                dfs(node)

        stats = {
            "total_courses": total_courses,
            "total_hours": total_hours
        }

        return {
            "valid": len(errors) == 0,
            "errors": errors,
            "warnings": warnings,
            "stats": stats
        }

    @staticmethod
    def import_curriculum(curriculum_json: Dict[str, Any], target_department_id: str, target_academic_year: int, imported_by: str) -> str:
        """
        Parses curriculum JSON and saves it into Supabase inside a simulation transaction construct.
        """
        val = CurriculumService.validate_curriculum(curriculum_json)
        if not val["valid"]:
            raise SupabaseError(f"Validation failed: {', '.join(val['errors'])}")

        # Insert study plan
        plan_payload = {
            "name": curriculum_json["plan_name"],
            "department_id": target_department_id,
            "enrollment_year": target_academic_year,
            "created_by": imported_by
        }
        plan_res = supabase_admin.table("study_plans").insert(plan_payload).execute()
        if not plan_res.data:
            raise SupabaseError("Failed to insert study plan.")
        plan_id = plan_res.data[0]["id"]

        try:
            # Save graduation requirements
            rules = curriculum_json.get("rules") or {}
            grad_req = rules.get("graduation") or {}
            grad_payload = {
                "plan_id": plan_id,
                "required_hours": curriculum_json.get("required_hours", 136),
                "min_gpa": curriculum_json.get("min_gpa", 2.0),
                "requires_field_training": grad_req.get("requires_field_training", False),
                "requires_civic_literacy": grad_req.get("requires_civic_literacy", False),
                "civic_literacy_count": grad_req.get("civic_literacy_count", 0)
            }
            supabase_admin.table("graduation_requirements").insert(grad_payload).execute()

            # Save load rules
            load_req = rules.get("load") or {}
            load_payload = {
                "plan_id": plan_id,
                "max_hours_gpa_high": load_req.get("max_hours_gpa_high", 20),
                "max_hours_gpa_normal": load_req.get("max_hours_gpa_normal", 18),
                "max_hours_gpa_low": load_req.get("max_hours_gpa_low", 12),
                "min_hours": load_req.get("min_hours", 12),
                "summer_cap": load_req.get("summer_cap", 9)
            }
            supabase_admin.table("academic_load_rules").insert(load_payload).execute()

            # Save training rules
            train_req = rules.get("training") or {}
            train_payload = {
                "plan_id": plan_id,
                "required_hours_to_start": train_req.get("required_hours_to_start", 90),
                "min_level_to_start": train_req.get("min_level_to_start", 5),
                "training_duration_weeks": train_req.get("training_duration_weeks", 8)
            }
            supabase_admin.table("field_training_rules").insert(train_payload).execute()

            # Insert courses & prerequisites
            courses = curriculum_json.get("courses") or []
            for c in courses:
                c_payload = {
                    "code": c["code"],
                    "name_ar": c["name_ar"],
                    "name_en": c.get("name_en"),
                    "credit_hours": c.get("credit_hours", 3),
                    "category": c.get("category", "Compulsory"),
                    "study_plan_id": plan_id,
                    "level": c.get("level", 1)
                }
                supabase_admin.table("courses").insert(c_payload).execute()

                # Save prerequisites
                prereqs = c.get("prerequisites") or []
                for pre in prereqs:
                    supabase_admin.table("prerequisites").insert({
                        "course_code": c["code"],
                        "prerequisite_course_code": pre
                    }).execute()

            # Save elective groups
            groups = curriculum_json.get("elective_groups") or []
            for g in groups:
                g_payload = {
                    "plan_id": plan_id,
                    "name_ar": g["name_ar"],
                    "required_hours": g["required_hours"]
                }
                g_res = supabase_admin.table("elective_groups").insert(g_payload).execute()
                if g_res.data:
                    group_id = g_res.data[0]["id"]
                    for c_code in g.get("courses") or []:
                        supabase_admin.table("elective_group_courses").insert({
                            "group_id": group_id,
                            "course_code": c_code
                        }).execute()

            return plan_id
        except Exception as e:
            # Simulated Rollback
            supabase_admin.table("study_plans").delete().eq("id", plan_id).execute()
            raise SupabaseError(f"Failed to import plan: {str(e)}")

    @staticmethod
    def copy_curriculum(source_plan_id: str, target_department_id: str, target_academic_year: int, copied_by: str) -> str:
        """
        Duplicates an existing plan configuration under a new department / year.
        """
        exported = CurriculumService.export_curriculum(source_plan_id)
        return CurriculumService.import_curriculum(
            curriculum_json=exported,
            target_department_id=target_department_id,
            target_academic_year=target_academic_year,
            imported_by=copied_by
        )

    # Legacy compatibility wrappers
    @staticmethod
    def export_plan(plan_id: str) -> Dict[str, Any]:
        return CurriculumService.export_curriculum(plan_id)

    @staticmethod
    def validate_plan_schema(plan_data: Dict[str, Any]) -> Dict[str, Any]:
        return CurriculumService.validate_curriculum(plan_data)

    @staticmethod
    def import_plan(plan_data: Dict[str, Any]) -> str:
        return CurriculumService.import_curriculum(
            curriculum_json=plan_data,
            target_department_id=plan_data.get("department_id"),
            target_academic_year=plan_data.get("enrollment_year", 2023),
            imported_by="system"
        )

    @staticmethod
    def copy_plan(plan_id: str, target_department_id: str, target_enrollment_year: int, new_name: str) -> str:
        exported = CurriculumService.export_curriculum(plan_id)
        exported["plan_name"] = new_name
        return CurriculumService.import_curriculum(
            curriculum_json=exported,
            target_department_id=target_department_id,
            target_academic_year=target_enrollment_year,
            imported_by="system"
        )
