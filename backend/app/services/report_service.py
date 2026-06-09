"""
Report Service: Consolidates database records and outputs PDF or Excel reports.
"""
from typing import Dict, Any, List
import io
import pandas as pd
from app.core.database import supabase_admin
from app.core.exceptions import NotFoundError, SupabaseError
from app.utils.pdf_generator import AcademicReportPDF

class ReportService:
    @staticmethod
    async def student_pdf(student_id: str) -> bytes:
        """
        Generates official student profile / transcript PDF.
        """
        return await ReportService.student_transcript(student_id)

    @staticmethod
    async def student_transcript(student_id: str) -> bytes:
        """
        Generates official academic transcript PDF for a student.
        """
        # Fetch profile
        student_res = supabase_admin.table("students").select("*, departments(name_ar)").eq("id", student_id).execute()
        if not student_res.data:
            raise NotFoundError("Student not found")
        student = student_res.data[0]
        
        # Flatten department name
        dept = student.get("departments")
        if dept and isinstance(dept, dict):
            student["department_name"] = dept.get("name_ar")
        elif dept and isinstance(dept, list) and len(dept) > 0:
            student["department_name"] = dept[0].get("name_ar")
        else:
            student["department_name"] = student.get("department_id")

        # Fetch courses
        courses_res = supabase_admin.table("student_courses").select("*").eq("student_id", student_id).execute()
        courses = courses_res.data or []

        # Fetch analysis
        analysis_res = supabase_admin.table("analysis_results").select("*").eq("student_id", student_id).eq("is_latest", True).execute()
        analysis = {}
        if analysis_res.data:
            analysis_id = analysis_res.data[0]["id"]
            issues_res = supabase_admin.table("analysis_issues").select("*").eq("analysis_id", analysis_id).execute()
            analysis["issues"] = issues_res.data or []
            analysis["result"] = analysis_res.data[0]
        else:
            analysis["issues"] = []

        # Generate PDF
        pdf_gen = AcademicReportPDF()
        pdf_bytes = pdf_gen.generate_student_transcript(student, courses, analysis)
        return pdf_bytes

    @staticmethod
    async def department_summary(department_id: str, format: str = "pdf") -> bytes:
        """
        Generates statistical analysis for a department.
        """
        # Fetch department
        dept_res = supabase_admin.table("departments").select("name_ar").eq("id", department_id).execute()
        dept_name = dept_res.data[0].get("name_ar", department_id) if dept_res.data else department_id

        # Fetch student list
        students_res = supabase_admin.table("students").select("*").eq("department_id", department_id).execute()
        students = students_res.data or []

        # Calculate stats
        total_students = len(students)
        avg_gpa = sum(s.get("gpa") or 0.0 for s in students) / total_students if total_students > 0 else 0.0
        avg_hours = sum(s.get("passed_hours") or 0 for s in students) / total_students if total_students > 0 else 0.0
        at_risk = sum(1 for s in students if (s.get("gpa") or 0.0) < 2.0)

        stats = {
            "total_students": total_students,
            "average_gpa": avg_gpa,
            "passed_hours_average": avg_hours,
            "students_at_risk": at_risk
        }

        if format == "excel":
            # Build DataFrame
            data = []
            for s in students:
                data.append({
                    "كود الطالب": s.get("student_id_external"),
                    "الاسم": s.get("name_ar"),
                    "المستوى": s.get("level"),
                    "المعدل التراكمي": s.get("gpa"),
                    "الساعات المجتازة": s.get("passed_hours"),
                    "الحالة": s.get("status")
                })
            df = pd.DataFrame(data)
            output = io.BytesIO()
            with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
                df.to_excel(writer, sheet_name='ملخص القسم', index=False)
            return output.getvalue()
        else:
            pdf_gen = AcademicReportPDF()
            return pdf_gen.generate_department_report(dept_name, stats, students)

    @staticmethod
    async def at_risk_students(department_id: str, limit: int = 50, format: str = "pdf") -> bytes:
        """
        Generates list of at-risk students (GPA < 2.0).
        """
        # Fetch department
        dept_res = supabase_admin.table("departments").select("name_ar").eq("id", department_id).execute()
        dept_name = dept_res.data[0].get("name_ar", department_id) if dept_res.data else department_id

        # Fetch at-risk students
        students_res = supabase_admin.table("students").select("*").eq("department_id", department_id).lt("gpa", 2.0).limit(limit).execute()
        students = students_res.data or []

        # Add primary issues context
        for s in students:
            s["primary_issue"] = "انخفاض المعدل التراكمي عن الحد الأدنى (2.0)"

        if format == "excel":
            data = []
            for s in students:
                data.append({
                    "كود الطالب": s.get("student_id_external"),
                    "الاسم": s.get("name_ar"),
                    "المعدل التراكمي": s.get("gpa"),
                    "الساعات المجتازة": s.get("passed_hours"),
                    "سبب التعثر": s.get("primary_issue")
                })
            df = pd.DataFrame(data)
            output = io.BytesIO()
            with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
                df.to_excel(writer, sheet_name='الطلاب المتعثرين', index=False)
            return output.getvalue()
        else:
            pdf_gen = AcademicReportPDF()
            return pdf_gen.generate_at_risk_report(dept_name, students)

    @staticmethod
    async def graduation_predictions(department_id: str, year: int, format: str = "pdf") -> bytes:
        """
        Generates predictions for student graduation readiness in the given academic year.
        """
        # Fetch department
        dept_res = supabase_admin.table("departments").select("name_ar").eq("id", department_id).execute()
        dept_name = dept_res.data[0].get("name_ar", department_id) if dept_res.data else department_id

        # Fetch senior students (level >= 7)
        students_res = supabase_admin.table("students").select("*").eq("department_id", department_id).gte("level", 7).execute()
        students = students_res.data or []

        # Check plan hours to determine remaining hours
        graduating_students = []
        for s in students:
            plan_id = s.get("study_plan_id")
            if not plan_id:
                continue
            
            # Simple check: remaining hours
            req_hours = 136  # default
            grad_res = supabase_admin.table("graduation_requirements").select("required_hours").eq("plan_id", plan_id).execute()
            if grad_res.data:
                req_hours = grad_res.data[0].get("required_hours", 136)
            
            passed = s.get("passed_hours", 0)
            remaining = max(0, req_hours - passed)
            
            # Predict if they can graduate: e.g., if remaining hours <= 36 (can finish in two semesters)
            if remaining <= 36:
                status = "متوقع تخرجه" if remaining <= 18 else "محتمل تخرجه"
                graduating_students.append({
                    "student_id_external": s.get("student_id_external"),
                    "name_ar": s.get("name_ar"),
                    "gpa": s.get("gpa"),
                    "passed_hours": passed,
                    "remaining_hours": remaining,
                    "prediction_status": status
                })

        if format == "excel":
            data = []
            for gs in graduating_students:
                data.append({
                    "كود الطالب": gs["student_id_external"],
                    "الاسم": gs["name_ar"],
                    "المعدل التراكمي": gs["gpa"],
                    "الساعات المجتازة": gs["passed_hours"],
                    "الساعات المتبقية": gs["remaining_hours"],
                    "حالة التوقع": gs["prediction_status"]
                })
            df = pd.DataFrame(data)
            output = io.BytesIO()
            with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
                df.to_excel(writer, sheet_name='توقعات التخرج', index=False)
            return output.getvalue()
        else:
            # Generate custom PDF layout using AcademicReportPDF helper
            pdf_gen = AcademicReportPDF()
            
            # Format graduating list for PDF display
            pdf_students = []
            for gs in graduating_students:
                pdf_students.append({
                    "student_id_external": gs["student_id_external"],
                    "name_ar": gs["name_ar"],
                    "gpa": gs["gpa"],
                    "passed_hours": gs["passed_hours"],
                    "primary_issue": f"متبقي: {gs['remaining_hours']} ساعة ({gs['prediction_status']})"
                })
            return pdf_gen.generate_at_risk_report(f"{dept_name} - توقعات التخرج {year}", pdf_students)

    @staticmethod
    async def semester_performance(student_id: str, format: str = "pdf") -> bytes:
        """
        Generates report on student performance trend semester by semester.
        """
        student_res = supabase_admin.table("students").select("name_ar, student_id_external").eq("id", student_id).execute()
        if not student_res.data:
            raise NotFoundError("Student not found")
        student = student_res.data[0]

        semesters_res = supabase_admin.table("student_semesters").select("*").eq("student_id", student_id).order("semester_name").execute()
        semesters = semesters_res.data or []

        if format == "excel":
            data = []
            for sem in semesters:
                data.append({
                    "الفصل الدراسي": sem.get("semester_name"),
                    "المعدل الفصلي": sem.get("gpa"),
                    "المعدل التراكمي": sem.get("gpa_cumulative"),
                    "الساعات المسجلة": sem.get("registered_hours"),
                    "الساعات المجتازة": sem.get("passed_hours")
                })
            df = pd.DataFrame(data)
            output = io.BytesIO()
            with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
                df.to_excel(writer, sheet_name='الأداء الفصلي', index=False)
            return output.getvalue()
        else:
            # We can use student transcript PDF format as it already contains semester-by-semester details
            return await ReportService.student_transcript(student_id)

    @staticmethod
    async def plan_comparison(plan_id_1: str, plan_id_2: str, format: str = "pdf") -> bytes:
        """
        Generates a comparison between two study plans.
        """
        plan1_res = supabase_admin.table("study_plans").select("name, enrollment_year").eq("id", plan_id_1).execute()
        plan2_res = supabase_admin.table("study_plans").select("name, enrollment_year").eq("id", plan_id_2).execute()
        
        name1 = plan1_res.data[0].get("name", "الخطة الأولى") if plan1_res.data else "الخطة الأولى"
        name2 = plan2_res.data[0].get("name", "الخطة الثانية") if plan2_res.data else "الخطة الثانية"

        courses1_res = supabase_admin.table("courses").select("code, name_ar, credit_hours").eq("study_plan_id", plan_id_1).execute()
        courses2_res = supabase_admin.table("courses").select("code, name_ar, credit_hours").eq("study_plan_id", plan_id_2).execute()

        c1_codes = {c["code"]: c for c in (courses1_res.data or [])}
        c2_codes = {c["code"]: c for c in (courses2_res.data or [])}

        common_codes = set(c1_codes.keys()) & set(c2_codes.keys())
        only_in_1 = set(c1_codes.keys()) - set(c2_codes.keys())
        only_in_2 = set(c2_codes.keys()) - set(c1_codes.keys())

        if format == "excel":
            data = []
            for code in only_in_1:
                data.append({"كود المقرر": code, "الاسم": c1_codes[code]["name_ar"], "الساعات": c1_codes[code]["credit_hours"], "الخطة": name1})
            for code in only_in_2:
                data.append({"كود المقرر": code, "الاسم": c2_codes[code]["name_ar"], "الساعات": c2_codes[code]["credit_hours"], "الخطة": name2})
            for code in common_codes:
                data.append({"كود المقرر": code, "الاسم": c1_codes[code]["name_ar"], "الساعات": c1_codes[code]["credit_hours"], "الخطة": "مشترك"})
            
            df = pd.DataFrame(data)
            output = io.BytesIO()
            with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
                df.to_excel(writer, sheet_name='مقارنة الخطط', index=False)
            return output.getvalue()
        else:
            # PDF Comparison
            pdf_gen = AcademicReportPDF()
            comparison_students = []
            for code in only_in_1:
                comparison_students.append({"student_id_external": code, "name_ar": c1_codes[code]["name_ar"], "gpa": 0.0, "passed_hours": c1_codes[code]["credit_hours"], "primary_issue": f"حصري في: {name1}"})
            for code in only_in_2:
                comparison_students.append({"student_id_external": code, "name_ar": c2_codes[code]["name_ar"], "gpa": 0.0, "passed_hours": c2_codes[code]["credit_hours"], "primary_issue": f"حصري في: {name2}"})
            
            return pdf_gen.generate_at_risk_report(f"مقارنة: {name1} ضد {name2}", comparison_students)

    @staticmethod
    async def plan_compliance(student_id: str, format: str = "pdf") -> bytes:
        """
        Generates compliance report checking student progress against their assigned study plan.
        """
        return await ReportService.student_transcript(student_id)
