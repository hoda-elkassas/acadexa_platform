import 'dart:io';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;
import '../core/constants/api_endpoints.dart';

class TranscriptApi {
  final Dio _dio = Dio();

  Map<String, String> _getHeaders() {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Uploads an academic transcript Excel file to the FastAPI backend.
  Future<Map<String, dynamic>> uploadTranscript(String filePath, String departmentId) async {
    try {
      final file = File(filePath);
      final filename = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: filename,
        ),
        'department_id': departmentId,
      });

      final response = await _dio.post(
        '${ApiEndpoints.apiV1}/upload/transcript',
        data: formData,
        options: Options(
          headers: _getHeaders(),
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'فشل رفع الملف الأكاديمي';
      throw Exception(message);
    }
  }

  /// Gets the status and progress of a background transcript import job.
  Future<Map<String, dynamic>> getJobStatus(String jobId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.apiV1}/upload/job/$jobId',
        options: Options(
          headers: _getHeaders(),
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'فشل جلب حالة مهمة الرفع';
      throw Exception(message);
    }
  }
}
