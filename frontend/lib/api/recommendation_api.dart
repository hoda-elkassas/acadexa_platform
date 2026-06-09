import 'package:supabase_flutter/supabase_flutter.dart';

class RecommendationApi {
  final _supabase = Supabase.instance.client;

  /// Fetches academic advising recommendations for a specific student directly from Supabase.
  Future<List<Map<String, dynamic>>> getStudentRecommendations(String studentId) async {
    try {
      final response = await _supabase
          .from('analysis_recommendations')
          .select('*')
          .eq('student_id', studentId)
          .order('priority', ascending: true);
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('فشل جلب التوصيات الأكاديمية للطالب: ${e.toString()}');
    }
  }

  /// Adds a custom recommendation note.
  Future<Map<String, dynamic>> addRecommendation({
    required String analysisId,
    required String studentId,
    required String courseCode,
    required String courseName,
    required int priority,
    required String reason,
  }) async {
    try {
      final response = await _supabase.from('analysis_recommendations').insert({
        'analysis_id': analysisId,
        'student_id': studentId,
        'course_code': courseCode,
        'course_name': courseName,
        'priority': priority,
        'reason': reason,
      }).select().single();

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('فشل إضافة التوصية الأكاديمية: ${e.toString()}');
    }
  }
}
