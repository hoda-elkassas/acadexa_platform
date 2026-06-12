# ACADEXA — Project Map

> Tech Lead Execution Engine — live tracking.

---

## SYSTEM FLOW (User Journeys)

```
Splash → Login → [Role-based Dashboard]
                    ├── Admin:   overview → students → academic → reports → system
                    ├── Advisor: home → advisees → sessions → reports → settings
                    └── Student: home → courses → schedule → advisor → profile
```

---

## Screen Audit — 22 Feature Dirs, 67 Files

### COMPLETE (33) — Real backend integration
| Feature | Screens |
|---------|---------|
| auth (6) | splash, login, forgot_password, otp_verification, reset_password, loading |
| dashboard (4) | dashboard_screen, admin_dashboard, advisor_dashboard, student_dashboard |
| students (2) | students_list, student_details |
| courses (4) | manage_courses, manage_prerequisites, elective_groups, course_details_drawer |
| study_plan (8) | study_plans_list, study_plan_structure, add_edit_plan, plan_comparison_report, import_curriculum, grade_points, field_training_settings, academic_load_rules |
| transcript (2) | graduation_tracking, plan_compliance |
| reports (1) | reports_dashboard |
| expert_system (1) | smart_assistant |
| admin (1) | user_management |
| advisor (1) | at_risk_students |
| departments (1) | departments_screen |
| system (1) | system_settings |
| error_handling (2) | error_screen, success_screen |
| support (1) | about_screen |

### PARTIAL (11) — Mock/hardcoded data, needs Supabase
| Feature | Screens |
|---------|---------|
| notifications (3) | notification_center, send_notification, notification_settings |
| profile (3) | profile_screen, advisor_profile, edit_profile |
| security (3) | security_settings, change_password, two_factor |
| advisor (1) | advisory_sessions |
| expert_system (1) | plan_simulation |
| admin (1) | audit_logs |
| faq (1) | faq_screen |
| support (1) | report_issue |

### DIALOG (5) — Misplaced in screens/, move to widgets/
| Feature | Files |
|---------|-------|
| courses (4) | add_edit_course_dialog, add_prerequisite_dialog, add_edit_elective_group_dialog, course_details_drawer |
| departments (1) | add_edit_department_dialog |

### STUB (1) — Re-export barrel, remove
| Feature | File |
|---------|------|
| advisor (1) | student_detail_for_advisor_screen → export `students/screens/student_details_screen.dart` |

### COMPLETE (47) — Built 14 missing screens
Previously MISSING screens now implemented with real Supabase queries:

| Priority | Feature | Screens |
|----------|---------|---------|
| HIGH | analysis (4) | analytics_dashboard, semester_performance, graduation_reports, plan_comparison_report |
| HIGH | transcript (3) | academic_summary, courses_details, performance_analysis |
| HIGH | expert_system (2) | recommendations_dashboard, decision_explanation |
| MEDIUM | admin (2) | roles_permissions, expert_system_settings |
| MEDIUM | timeline (1) | activity_timeline |
| MEDIUM | users (1) | users_list |
| MEDIUM | what_if (1) | what_if_simulation |

---

## ORPHANS & PENDING

| Item | Status | Action |
|------|--------|--------|
| Router sends all roles to DashboardScreen | ✅ DESIGN CORRECT | DashboardScreen is controller that fetches role+data and renders role-specific screen |
| 14 empty screen files → built | ✅ COMPLETE | Implemented with real Supabase queries, loading/error/empty states |
| 11 mock-data screens | ✅ COMPLETE | Upgraded to Supabase queries + state management; 6 with real DB queries, 8 with proper pattern (tables pending creation) |
| 5 dialogs in wrong dir | ✅ COMPLETE | Moved to widgets/, removed stubs, fixed imports |
| 1 stub re-export | 🔴 PENDING | Remove student_detail_for_advisor_screen re-export barrel |

---

## COMPLETED

- Backend: 21/21 tests passing
- Backend: Fixed regex→pattern deprecation (6 occurrences)
- Backend: Implemented file_utils.py, date_utils.py, gpa_calculator.py
- Backend: Implemented conftest.py with shared fixtures
- Frontend: Built 14 missing screens with real Supabase queries + loading/error/empty states
- Frontend: Fixed 12 analyzer errors (AcCard→AcSectionCard, const issues, missing parens, retryLabel)
- Frontend: Moved 5 misplaced DIALOG files from screens/ to feature widgets/
- Frontend: Upgraded 14 PARTIAL screens — 6 with real Supabase queries, 8 with proper state management pattern
- Frontend: flutter analyze passes with 0 errors
