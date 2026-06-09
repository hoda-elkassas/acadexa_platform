// file: lib/core/constants/api_endpoints.dart
import '../environment.dart';

/// Base URL for the Python FastAPI backend.
/// Change this if your backend is running on a different host/port.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = Environment.apiBaseUrl;
  static const String apiV1   = '$baseUrl/api/v1';

  // ── Health ──────────────────────────────────────────────────────────
  static const String health = '$baseUrl/health';

  // ── Upload ──────────────────────────────────────────────────────────
  static const String uploadExcel  = '$apiV1/upload';
  static const String uploadToDB   = '$apiV1/upload-to-db';
  static String uploadStatus(String jobId) => '$apiV1/upload/status/$jobId';

  // ── Students ────────────────────────────────────────────────────────
  static const String students           = '$apiV1/students/';
  static String studentById(String id)   => '$apiV1/students/$id';
  static String studentByCode(String c)  => '$apiV1/students/code/$c';
  static String studentFull(String id)   => '$apiV1/students/$id/full';

  // ── Curriculum ──────────────────────────────────────────────────────
  static const String plans                       = '$apiV1/curriculum/plans';
  static String planById(String id)               => '$apiV1/curriculum/plans/$id';
  static String planCourses(String id)            => '$apiV1/curriculum/plans/$id/courses';
  static String coursePrerequisites(String id)    => '$apiV1/curriculum/courses/$id/prerequisites';
  static const String electiveGroups              = '$apiV1/curriculum/elective-groups';
  static const String gradingScales               = '$apiV1/curriculum/grading-scales';

  // ── Departments ─────────────────────────────────────────────────────
  static const String departments                 = '$apiV1/departments/';
  static String departmentById(String id)         => '$apiV1/departments/$id';
}
