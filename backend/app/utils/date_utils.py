from datetime import date, datetime

TERM_MAP = {1: "fall", 2: "spring", 3: "summer"}
TERM_LABEL = {"fall": "الأول", "spring": "الثاني", "summer": "الصيفي"}


def get_current_semester() -> tuple[int, str]:
    """Return (semester_number, term) based on current month."""
    month = datetime.now().month
    if 8 <= month <= 12:
        return (1, "fall")
    elif 1 <= month <= 4:
        return (2, "spring")
    else:
        return (3, "summer")


def academic_year_from_date(d: date | None = None) -> str:
    """Return academic year string like '2023-2024'."""
    if d is None:
        d = date.today()
    if d.month >= 8:
        return f"{d.year}-{d.year + 1}"
    return f"{d.year - 1}-{d.year}"


def semester_number_to_label(semester_number: int, academic_year: str = "") -> str:
    """Return Arabic label e.g. 'الفصل الأول 2023/2024'."""
    term = TERM_LABEL.get({1: "fall", 2: "spring", 3: "summer"}.get(semester_number, 1), "")
    year_part = f" {academic_year.replace('-', '/')}" if academic_year else ""
    return f"الفصل {term}{year_part}"


def days_until_graduation_estimate(enrollment_year: int, program_years: int = 4) -> int:
    """Estimate days from now until expected graduation date."""
    graduation_year = enrollment_year + program_years
    grad_date = date(graduation_year, 6, 30)
    delta = grad_date - date.today()
    return max(delta.days, 0)


def semester_start_date(year: int, semester_number: int) -> date:
    """Approximate start date for a given semester."""
    if semester_number == 1:
        return date(year, 9, 1)
    elif semester_number == 2:
        return date(year + 1, 2, 1)
    else:
        return date(year + 1, 6, 1)
