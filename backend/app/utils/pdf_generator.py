import os
from io import BytesIO
import arabic_reshaper
from bidi.algorithm import get_display

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

# Register Arabic fonts with fallbacks
font_dir = os.path.dirname(os.path.abspath(__file__))
regular_font_path = os.path.join(font_dir, "fonts", "Amiri-Regular.ttf")
bold_font_path = os.path.join(font_dir, "fonts", "Amiri-Bold.ttf")

FONT_NAME = "Amiri"
FONT_BOLD_NAME = "Amiri-Bold"

# Setup font registrations
font_registered = False
try:
    if os.path.exists(regular_font_path):
        pdfmetrics.registerFont(TTFont(FONT_NAME, regular_font_path))
        font_registered = True
    else:
        sys_noto = "/usr/share/fonts/truetype/noto/NotoSansArabic-Regular.ttf"
        if os.path.exists(sys_noto):
            pdfmetrics.registerFont(TTFont(FONT_NAME, sys_noto))
            font_registered = True
except Exception:
    pass

try:
    if os.path.exists(bold_font_path):
        pdfmetrics.registerFont(TTFont(FONT_BOLD_NAME, bold_font_path))
    else:
        sys_noto_bold = "/usr/share/fonts/truetype/noto/NotoSansArabic-Bold.ttf"
        if os.path.exists(sys_noto_bold):
            pdfmetrics.registerFont(TTFont(FONT_BOLD_NAME, sys_noto_bold))
        else:
            pdfmetrics.registerFont(TTFont(FONT_BOLD_NAME, regular_font_path))
except Exception:
    pass

if not font_registered:
    # If no Arabic font is found, fallback to standard Helvetica (RTL won't display correctly, but won't crash)
    FONT_NAME = "Helvetica"
    FONT_BOLD_NAME = "Helvetica-Bold"


def ar(text: str) -> str:
    """
    Reshapes and applies BiDi algorithm to Arabic text for proper rendering.
    """
    if not text:
        return ""
    try:
        reshaped = arabic_reshaper.reshape(str(text))
        bidi_text = get_display(reshaped)
        return bidi_text
    except Exception:
        return str(text)


class AcademicReportPDF:
    """
    Generates professional PDF reports in Arabic (RTL) using ReportLab.
    """

    def __init__(self):
        self.styles = getSampleStyleSheet()
        
        # Define base Arabic styles
        self.title_style = ParagraphStyle(
            'ArabicTitle',
            parent=self.styles['Normal'],
            fontName=FONT_BOLD_NAME,
            fontSize=18,
            leading=22,
            textColor=colors.HexColor("#1A365D"),  # Deep navy
            alignment=1,  # Center
            spaceAfter=15
        )
        
        self.header_style = ParagraphStyle(
            'ArabicHeader',
            parent=self.styles['Normal'],
            fontName=FONT_BOLD_NAME,
            fontSize=12,
            leading=16,
            textColor=colors.HexColor("#2C5282"),
            alignment=2,  # Right
            spaceAfter=10
        )
        
        self.body_style = ParagraphStyle(
            'ArabicBody',
            parent=self.styles['Normal'],
            fontName=FONT_NAME,
            fontSize=10,
            leading=14,
            textColor=colors.HexColor("#2D3748"),
            alignment=2,  # Right
            spaceAfter=5
        )

        self.body_center_style = ParagraphStyle(
            'ArabicBodyCenter',
            parent=self.styles['Normal'],
            fontName=FONT_NAME,
            fontSize=10,
            leading=14,
            textColor=colors.HexColor("#2D3748"),
            alignment=1,  # Center
            spaceAfter=5
        )

        self.table_header_style = ParagraphStyle(
            'TableHeader',
            parent=self.styles['Normal'],
            fontName=FONT_BOLD_NAME,
            fontSize=9,
            leading=12,
            textColor=colors.white,
            alignment=1  # Center
        )

        self.table_cell_style = ParagraphStyle(
            'TableCell',
            parent=self.styles['Normal'],
            fontName=FONT_NAME,
            fontSize=9,
            leading=12,
            textColor=colors.HexColor("#2D3748"),
            alignment=1  # Center
        )

    def _add_page_number(self, canvas, doc):
        canvas.saveState()
        canvas.setFont(FONT_NAME, 9)
        # Add thin header line
        canvas.setStrokeColor(colors.HexColor("#E2E8F0"))
        canvas.setLineWidth(0.5)
        canvas.line(54, doc.pagesize[1] - 40, doc.pagesize[0] - 54, doc.pagesize[1] - 40)
        
        # Header text
        canvas.drawRightString(doc.pagesize[0] - 54, doc.pagesize[1] - 35, ar("نظام الإرشاد الأكاديمي الذكي - جامعة كفر الشيخ"))
        
        # Footer text & page number
        canvas.line(54, 50, doc.pagesize[0] - 54, 50)
        canvas.drawString(54, 38, ar(f"الصفحة {doc.page}"))
        canvas.drawRightString(doc.pagesize[0] - 54, 38, ar("سري للغاية - للاستخدام الأكاديمي فقط"))
        canvas.restoreState()

    def generate_student_transcript(self, student_data: dict, courses: list, analysis: dict) -> bytes:
        """
        Generates official student academic transcript in PDF format.
        """
        buffer = BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=A4,
            leftMargin=54,
            rightMargin=54,
            topMargin=54,
            bottomMargin=54
        )

        story = []

        # 1. Header
        story.append(Paragraph(ar("جامعة كفر الشيخ"), self.header_style))
        story.append(Paragraph(ar("كلية التربية النوعية"), self.header_style))
        story.append(Spacer(1, 10))
        story.append(Paragraph(ar("سجل الدرجات الأكاديمي للجمهورية"), self.title_style))
        story.append(Spacer(1, 15))

        # 2. Student Info Box (RTL Table)
        info_data = [
            [
                ar(student_data.get("student_id_external", "")), ar("الرقم الأكاديمي:"),
                ar(student_data.get("name_ar", "")), ar("اسم الطالب:")
            ],
            [
                ar(str(student_data.get("level", 1))), ar("المستوى الدراسي:"),
                ar(student_data.get("department_name", student_data.get("department_id", ""))), ar("القسم والشعبة:")
            ],
            [
                ar(f"{student_data.get('passed_hours', 0)} / {student_data.get('total_attempted_hours', 0)}"), ar("الساعات (مجتازة/مسجلة):"),
                ar(f"{student_data.get('gpa', 0.0):.2f}"), ar("المعدل التراكمي (GPA):")
            ],
            [
                ar(str(student_data.get("enrollment_year", ""))), ar("سنة الالتحاق:"),
                ar(student_data.get("status", "نشط")), ar("حالة الطالب:")
            ]
        ]
        
        info_table = Table(info_data, colWidths=[130, 110, 150, 90])
        info_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F7FAFC")),
            ('TEXTCOLOR', (0, 0), (-1, -1), colors.HexColor("#2D3748")),
            ('FONTNAME', (0, 0), (-1, -1), FONT_NAME),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('ALIGN', (0, 0), (-1, -1), 'RIGHT'),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
            ('BACKGROUND', (1, 0), (1, -1), colors.HexColor("#EDF2F7")),
            ('BACKGROUND', (3, 0), (3, -1), colors.HexColor("#EDF2F7")),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
        ]))
        story.append(info_table)
        story.append(Spacer(1, 20))

        # 3. Semester-by-semester details
        # Group courses by semester_name
        semesters = {}
        for c in courses:
            sem_name = c.get("semester_name", "الفصل الدراسي غير المحدد")
            if sem_name not in semesters:
                semesters[sem_name] = []
            semesters[sem_name].append(c)

        # Sort semesters chronologically or alphabetically
        sorted_sem_names = sorted(list(semesters.keys()))
        for sem_name in sorted_sem_names:
            sem_courses = semesters[sem_name]
            
            # Semester Title
            story.append(Paragraph(ar(sem_name), self.header_style))
            
            # Semester Course Table Header (RTL: Status, Grade, Hours, Course Name, Code)
            table_header = [
                Paragraph(ar("الحالة"), self.table_header_style),
                Paragraph(ar("التقدير"), self.table_header_style),
                Paragraph(ar("الساعات"), self.table_header_style),
                Paragraph(ar("اسم المقرر"), self.table_header_style),
                Paragraph(ar("كود المقرر"), self.table_header_style)
            ]
            
            table_rows = [table_header]
            for sc in sem_courses:
                status_map = {"passed": "ناجح", "failed": "راسب", "in_progress": "مسجل"}
                status_ar = status_map.get(sc.get("status", ""), sc.get("status", ""))
                
                table_rows.append([
                    Paragraph(ar(status_ar), self.table_cell_style),
                    Paragraph(ar(sc.get("grade_letter", "-") or "-"), self.table_cell_style),
                    Paragraph(ar(str(sc.get("credit_hours", 3))), self.table_cell_style),
                    Paragraph(ar(sc.get("course_name", "")), self.table_cell_style),
                    Paragraph(ar(sc.get("course_code", "")), self.table_cell_style)
                ])

            sem_table = Table(table_rows, colWidths=[80, 70, 60, 200, 70])
            sem_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#2B6CB0")),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E0")),
                ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#F7FAFC")]),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
                ('TOPPADDING', (0, 0), (-1, -1), 5),
            ]))
            story.append(sem_table)
            story.append(Spacer(1, 15))

        # 4. Warnings and Academic Alerts
        issues = analysis.get("issues", [])
        if issues:
            story.append(Spacer(1, 10))
            story.append(Paragraph(ar("تنبيهات وملاحظات الإرشاد الأكاديمي:"), self.header_style))
            
            issues_data = []
            for issue in issues:
                severity = issue.get("severity", "info")
                severity_ar = "خطأ حرج" if severity == "error" else "تحذير" if severity == "warning" else "تنبيه"
                desc = issue.get("description", "") or issue.get("title", "")
                suggestion = issue.get("suggestion", "")
                if suggestion:
                    desc += f" (التوجيه: {suggestion})"
                
                issues_data.append([
                    Paragraph(ar(desc), self.table_cell_style),
                    Paragraph(ar(severity_ar), self.table_header_style)
                ])

            issues_table = Table(issues_data, colWidths=[400, 80])
            issues_table.setStyle(TableStyle([
                ('BACKGROUND', (1, 0), (1, -1), colors.HexColor("#C53030")), # Red alert label
                ('ALIGN', (0, 0), (-1, -1), 'RIGHT'),
                ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#FEB2B2")),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
                ('TOPPADDING', (0, 0), (-1, -1), 6),
            ]))
            story.append(issues_table)
            story.append(Spacer(1, 25))

        # 5. Signatures area
        sig_data = [
            [ar("عميد الكلية"), ar("رئيس الكنترول/التسجيل"), ar("المرشد الأكاديمي")],
            ["", "", ""],
            [ar("التوقيع: ........................"), ar("التوقيع: ........................"), ar("التوقيع: ........................")]
        ]
        sig_table = Table(sig_data, colWidths=[160, 160, 160])
        sig_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, -1), FONT_BOLD_NAME),
            ('BOTTOMPADDING', (0, 1), (-1, 1), 30), # spacing for signature
        ]))
        story.append(KeepTogether([sig_table]))

        # Build PDF
        doc.build(story, onFirstPage=self._add_page_number, onLaterPages=self._add_page_number)
        pdf_bytes = buffer.getvalue()
        buffer.close()
        return pdf_bytes

    def generate_department_report(self, department_name: str, stats: dict, students: list) -> bytes:
        """
        Generates statistical analysis for a department.
        """
        buffer = BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=A4,
            leftMargin=54,
            rightMargin=54,
            topMargin=54,
            bottomMargin=54
        )

        story = []

        # 1. Header
        story.append(Paragraph(ar("جامعة كفر الشيخ - كلية التربية النوعية"), self.header_style))
        story.append(Spacer(1, 10))
        story.append(Paragraph(ar(f"تقرير الأداء الأكاديمي لقسم: {department_name}"), self.title_style))
        story.append(Spacer(1, 15))

        # 2. Stats grid
        stats_data = [
            [
                ar(f"{stats.get('average_gpa', 0.0):.2f}"), ar("متوسط المعدل التراكمي:"),
                ar(str(stats.get('total_students', 0))), ar("إجمالي الطلاب:")
            ],
            [
                ar(str(stats.get('students_at_risk', 0))), ar("الطلاب المتعثرين (تحت الإنذار):"),
                ar(str(stats.get('passed_hours_average', 0))), ar("متوسط الساعات المنجزة:")
            ]
        ]
        stats_table = Table(stats_data, colWidths=[120, 120, 120, 120])
        stats_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#EBF8FF")),
            ('TEXTCOLOR', (0, 0), (-1, -1), colors.HexColor("#2B6CB0")),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#BEE3F8")),
            ('ALIGN', (0, 0), (-1, -1), 'RIGHT'),
            ('FONTNAME', (0, 0), (-1, -1), FONT_NAME),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
            ('TOPPADDING', (0, 0), (-1, -1), 8),
        ]))
        story.append(stats_table)
        story.append(Spacer(1, 20))

        # 3. Student list
        story.append(Paragraph(ar("قائمة الطلاب ومعدلاتهم الدراسية:"), self.header_style))
        
        table_header = [
            Paragraph(ar("عدد الإنذارات"), self.table_header_style),
            Paragraph(ar("الساعات المنجزة"), self.table_header_style),
            Paragraph(ar("المعدل (GPA)"), self.table_header_style),
            Paragraph(ar("اسم الطالب"), self.table_header_style),
            Paragraph(ar("الترتيب"), self.table_header_style)
        ]
        
        table_rows = [table_header]
        for idx, student in enumerate(students, 1):
            table_rows.append([
                Paragraph(ar(str(student.get("warnings_count", 0))), self.table_cell_style),
                Paragraph(ar(str(student.get("passed_hours", 0))), self.table_cell_style),
                Paragraph(ar(f"{student.get('gpa', 0.0):.2f}"), self.table_cell_style),
                Paragraph(ar(student.get("name_ar", "")), self.table_cell_style),
                Paragraph(ar(str(idx)), self.table_cell_style)
            ])

        students_table = Table(table_rows, colWidths=[80, 80, 80, 200, 40])
        students_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#2C5282")),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E0")),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#F7FAFC")]),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
        ]))
        story.append(students_table)

        # Build PDF
        doc.build(story, onFirstPage=self._add_page_number, onLaterPages=self._add_page_number)
        pdf_bytes = buffer.getvalue()
        buffer.close()
        return pdf_bytes

    def generate_at_risk_report(self, department_name: str, students: list) -> bytes:
        """
        Generates list of at-risk students.
        """
        buffer = BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=A4,
            leftMargin=54,
            rightMargin=54,
            topMargin=54,
            bottomMargin=54
        )

        story = []

        # 1. Header
        story.append(Paragraph(ar("جامعة كفر الشيخ - كلية التربية النوعية"), self.header_style))
        story.append(Spacer(1, 10))
        story.append(Paragraph(ar(f"تقرير الحالات المتعثرة أكاديمياً (تحت الإنذار) - قسم: {department_name}"), self.title_style))
        story.append(Spacer(1, 15))

        # 2. Risk description paragraph
        desc_text = (
            "يحتوي هذا التقرير على قائمة الطلاب المتعثرين أكاديمياً الذين تقل معدلاتهم التراكمية عن 2.00 "
            "أو لديهم تعثر في الساعات أو متطلبات التخرج الأساسية. يرجى توجيههم للمرشدين الأكاديميين للمتابعة الفورية."
        )
        story.append(Paragraph(ar(desc_text), self.body_style))
        story.append(Spacer(1, 15))

        # 3. Student list table
        table_header = [
            Paragraph(ar("السبب الأساسي للتعثر"), self.table_header_style),
            Paragraph(ar("المعدل الحالي"), self.table_header_style),
            Paragraph(ar("الساعات المجتازة"), self.table_header_style),
            Paragraph(ar("اسم الطالب"), self.table_header_style),
            Paragraph(ar("كود الطالب"), self.table_header_style)
        ]
        
        table_rows = [table_header]
        for s in students:
            # Determine primary failure reason
            reason = s.get("primary_issue", "") or "تدني المعدل التراكمي"
            table_rows.append([
                Paragraph(ar(reason), self.table_cell_style),
                Paragraph(ar(f"{s.get('gpa', 0.0):.2f}"), self.table_cell_style),
                Paragraph(ar(str(s.get("passed_hours", 0))), self.table_cell_style),
                Paragraph(ar(s.get("name_ar", "")), self.table_cell_style),
                Paragraph(ar(s.get("student_id_external", "")), self.table_cell_style)
            ])

        at_risk_table = Table(table_rows, colWidths=[130, 70, 70, 140, 70])
        at_risk_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#9B2C2C")),  # Deep Red header
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#FEB2B2")),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor("#FFF5F5")]),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
        ]))
        story.append(at_risk_table)

        # Build PDF
        doc.build(story, onFirstPage=self._add_page_number, onLaterPages=self._add_page_number)
        pdf_bytes = buffer.getvalue()
        buffer.close()
        return pdf_bytes
