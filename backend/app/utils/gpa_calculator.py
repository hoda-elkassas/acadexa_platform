from typing import Dict, List, Optional

FALLBACK_GRADE_POINTS: Dict[str, float] = {
    "A+": 4.0, "A": 4.0, "A-": 3.7,
    "B+": 3.4, "B": 3.2, "B-": 3.0,
    "C+": 2.8, "C": 2.5, "C-": 2.2,
    "D+": 1.8, "D": 1.5, "D-": 1.2,
    "F": 0.0,
}

SPECIAL_SYMBOLS = {"W", "FW", "IC", "MW", "AU", "S", "TC", "Ex", "IP", "NP", "I"}


def grade_letter_to_points(letter: str, scale: Optional[Dict[str, float]] = None) -> float:
    """Convert a grade letter to numeric points using the provided scale or fallback."""
    if scale is None:
        scale = FALLBACK_GRADE_POINTS
    return scale.get(letter, FALLBACK_GRADE_POINTS.get(letter, 0.0))


def is_passing_grade(points: float) -> bool:
    """Return True if the grade points indicate a passing grade."""
    return points > 0.0


def calculate_semester_gpa(
    courses: List[Dict],
    grade_scale: Optional[Dict[str, float]] = None,
) -> Optional[float]:
    """Calculate semester GPA from a list of course dicts with 'grade_letter' and 'credit_hours'."""
    if grade_scale is None:
        grade_scale = FALLBACK_GRADE_POINTS
    total_points = 0.0
    total_hours = 0
    for c in courses:
        letter = c.get("grade_letter", "")
        hours = c.get("credit_hours", 0)
        if letter in SPECIAL_SYMBOLS or hours <= 0:
            continue
        pts = grade_scale.get(letter, FALLBACK_GRADE_POINTS.get(letter))
        if pts is None:
            continue
        total_points += pts * hours
        total_hours += hours
    if total_hours == 0:
        return None
    return round(total_points / total_hours, 4)


def calculate_gpa_from_courses(
    all_courses: List[Dict],
    grade_scale: Optional[Dict[str, float]] = None,
) -> Optional[float]:
    """Calculate cumulative GPA from all courses across all semesters."""
    if grade_scale is None:
        grade_scale = FALLBACK_GRADE_POINTS
    total_points = 0.0
    total_hours = 0
    for c in all_courses:
        letter = c.get("grade_letter", "")
        hours = c.get("credit_hours", 0)
        if letter in SPECIAL_SYMBOLS or hours <= 0:
            continue
        pts = grade_scale.get(letter, FALLBACK_GRADE_POINTS.get(letter))
        if pts is None:
            continue
        total_points += pts * hours
        total_hours += hours
    if total_hours == 0:
        return None
    return round(total_points / total_hours, 4)
