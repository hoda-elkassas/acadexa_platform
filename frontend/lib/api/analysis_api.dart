import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_endpoints.dart';

class AnalysisApi {
  final Dio _dio = Dio();

  Map<String, String> _getHeaders() {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Triggers rule evaluation/analysis for a specific student.
  Future<Map<String, dynamic>> runAnalysis(String studentId) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.apiV1}/analysis/run/$studentId',
        options: Options(
          headers: _getHeaders(),
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'فشل تشغيل محرك القواعد للطالب';
      throw Exception(message);
    }
  }

  /// Simulates registration of prospective courses to forecast GPA and rule warnings.
  Future<Map<String, dynamic>> simulatePlan(
    String studentId,
    List<Map<String, dynamic>> plannedCourses,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.apiV1}/analysis/simulate',
        data: {
          'student_id': studentId,
          'planned_courses': plannedCourses,
        },
        options: Options(
          headers: _getHeaders(),
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'فشل تشغيل محاكاة التسجيل الأكاديمي';
      throw Exception(message);
    }
  }

  /// Triggers a batch analysis for a department, study plan, or custom list of students.
  Future<Map<String, dynamic>> runBatchAnalysis({
    String? departmentId,
    String? planId,
    List<String>? studentIds,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.apiV1}/analysis/batch',
        data: {
          if (departmentId != null) 'department_id': departmentId,
          if (planId != null) 'plan_id': planId,
          if (studentIds != null) 'student_ids': studentIds,
        },
        options: Options(
          headers: _getHeaders(),
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'فشل جدولة التحليل الجماعي';
      throw Exception(message);
    }
  }
}
