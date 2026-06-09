import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_endpoints.dart';

class ReportsApi {
  final Dio _dio = Dio();

  Map<String, String> _getHeaders() {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Downloads the student transcript PDF and saves it to [savePath].
  Future<void> downloadStudentTranscriptPdf(String studentId, String savePath) async {
    try {
      await _dio.download(
        '${ApiEndpoints.apiV1}/reports/student/$studentId/transcript',
        savePath,
        options: Options(
          headers: _getHeaders(),
        ),
      );
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'فشل تحميل كشف الدرجات بصيغة PDF';
      throw Exception(message);
    }
  }

  /// Downloads the department summary report (PDF or Excel) and saves it to [savePath].
  Future<void> downloadDepartmentSummary({
    required String departmentId,
    required String fileFormat, // pdf | excel
    required String savePath,
  }) async {
    try {
      await _dio.download(
        '${ApiEndpoints.apiV1}/reports/department/$departmentId/summary',
        savePath,
        queryParameters: {
          'file_format': fileFormat,
        },
        options: Options(
          headers: _getHeaders(),
        ),
      );
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'فشل تحميل تقرير ملخص القسم';
      throw Exception(message);
    }
  }

  /// Downloads the at-risk student report (PDF or Excel) and saves it to [savePath].
  Future<void> downloadAtRiskReport({
    required String departmentId,
    required String fileFormat, // pdf | excel
    required String savePath,
    int limit = 50,
  }) async {
    try {
      await _dio.download(
        '${ApiEndpoints.apiV1}/reports/department/$departmentId/at-risk',
        savePath,
        queryParameters: {
          'file_format': fileFormat,
          'limit': limit,
        },
        options: Options(
          headers: _getHeaders(),
        ),
      );
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'فشل تحميل تقرير الطلاب المتعثرين';
      throw Exception(message);
    }
  }
}
