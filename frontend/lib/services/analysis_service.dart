import '../core/api_client.dart';
import '../models/analysis_result.dart';
import '../models/analysis_recommendation.dart';
import '../models/graduation_readiness.dart';
import '../models/simulation_result.dart';

class AnalysisService {
  final ApiClient apiClient;

  AnalysisService({ApiClient? client}) : apiClient = client ?? ApiClient();

  /// Trigger academic rule analysis for a student.
  /// If forceRefresh is false, it tries to fetch the latest result first.
  Future<AnalysisResult> analyzeStudent(String studentId, {bool forceRefresh = false}) async {
    if (forceRefresh) {
      await apiClient.post('/analysis/run/$studentId');
    } else {
      try {
        final response = await apiClient.get('/analysis/latest/$studentId');
        return AnalysisResult.fromJson(response);
      } catch (_) {
        // Trigger run if it fails or 404s
        await apiClient.post('/analysis/run/$studentId');
      }
    }
    final response = await apiClient.get('/analysis/latest/$studentId');
    return AnalysisResult.fromJson(response);
  }

  /// Triggers batch analysis for an entire department
  Future<String> analyzeBatch(String departmentId) async {
    final response = await apiClient.post(
      '/analysis/batch',
      body: {'department_id': departmentId},
    );
    return response['message'] as String? ?? 'تمت جدولة التحليل الجماعي بنجاح في الخلفية.';
  }

  /// Fetch the latest analysis result from Supabase view directly
  Future<AnalysisResult> getAnalysisResult(String studentId) async {
    final response = await apiClient.supabase
        .from('analysis_results')
        .select('*, issues:analysis_issues(*), recommendations:analysis_recommendations(*)')
        .eq('student_id', studentId)
        .eq('is_latest', true)
        .maybeSingle();

    if (response == null) {
      throw ApiException('لم يتم العثور على تحليل أكاديمي للمستخدم. يرجى تشغيل التحليل أولاً.');
    }
    return AnalysisResult.fromJson(response);
  }

  /// Get graduation requirements completion checks
  Future<GraduationReadiness> getGraduationReadiness(String studentId) async {
    final response = await apiClient.get('/analysis/graduation-readiness/$studentId');
    return GraduationReadiness.fromJson(response);
  }

  /// Simulates GPA and warnings for registering a list of planned courses
  Future<SimulationResult> simulatePlan(String studentId, List<PlannedCourse> courses) async {
    final body = {
      'student_id': studentId,
      'planned_courses': courses.map((c) => c.toJson()).toList(),
    };
    final response = await apiClient.post('/analysis/simulate', body: body);
    return SimulationResult.fromJson(response);
  }

  /// Retrieves recommendations directly from Supabase
  Future<List<AnalysisRecommendation>> getSmartRecommendations(String studentId) async {
    final response = await apiClient.supabase
        .from('analysis_recommendations')
        .select('*')
        .eq('student_id', studentId)
        .order('priority', ascending: true);

    final list = response as List<dynamic>? ?? const [];
    return list.map((e) => AnalysisRecommendation.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Academic advising AI chatbot assistant (context-aware mock)
  Future<String> sendChatMessage(String studentId, String question) async {
    try {
      final analysis = await getAnalysisResult(studentId);
      final gpa = analysis.gpa;
      final warningsCount = analysis.issues.where((i) => i.severity == 'warning').length;
      final errorsCount = analysis.issues.where((i) => i.severity == 'error').length;
      final passedHours = analysis.passedHours;

      if (question.contains('معدل') || question.contains('GPA') || question.contains('نقاط') || question.contains('معدلي')) {
        String advice = 'معدلك التراكمي الحالي هو **$gpa**، وقد اجتزت بنجاح **$passedHours ساعة معتمدة**.\n\n';
        if (gpa < 2.0) {
          advice += '⚠️ معدلك الحالي يقل عن الحد الأدنى المطلوب (2.0)، مما يعرضك لإنذار أكاديمي. نوصي بالتركيز على إعادة المواد الحاصل فيها على تقدير ضعيف لتحسين المعدل في أقرب فرصة.';
        } else {
          advice += '✨ وضعك الأكاديمي ممتاز ومستقر. استمر في الحفاظ على هذا المستوى الرائع!';
        }
        return advice;
      }

      if (question.contains('إنذار') || question.contains('عقوب') || question.contains('مشاكل') || question.contains('تنبيه') || question.contains('مخالفة')) {
        if (warningsCount == 0 && errorsCount == 0) {
          return 'سجلك الأكاديمي خالٍ تماماً من الإنذارات والمخالفات في الوقت الحالي. أنت تسير على الطريق الصحيح!';
        }
        return 'يحتوي سجلك حالياً على **$warningsCount إنذار** و **$errorsCount تنبيه هام**.\n\n'
            'الإنذارات تؤثر على وضعك الدراسي، لذا ننصحك بمراجعة المرشد الأكاديمي فوراً لمناقشة سبل رفع التحذيرات وتجنب تراكمها.';
      }

      if (question.contains('تخرج') || question.contains('خريج') || question.contains('متطلبات') || question.contains('أتخرج')) {
        final readyReport = await getGraduationReadiness(studentId);
        if (readyReport.isReady) {
          return '🎉 تهانينا! تشير السجلات إلى أنك استوفيت جميع شروط ومتطلبات التخرج (معدل تراكمي **$gpa**، واجتياز **$passedHours ساعة معتمدة**). يمكنك البدء في تقديم طلب التخرج.';
        } else {
          final remainingHours = readyReport.requiredHours - readyReport.passedHours;
          return 'أنت بحاجة لاجتياز **$remainingHours ساعة معتمدة** إضافية لتلبية شروط التخرج.\n\n'
              'المتطلبات المتبقية:\n'
              '${readyReport.checklist.where((item) => !item.status).map((item) => '- ${item.ruleName}: ${item.details}').join('\n')}';
        }
      }

      if (question.contains('توصي') || question.contains('تسجيل') || question.contains('مواد') || question.contains('أسجل')) {
        final recs = analysis.recommendations;
        if (recs.isEmpty) {
          return 'لا توجد توصيات تسجيل محددة مخصصة لك في هذا الفصل. يرجى اتباع الخطة الدراسية الاعتيادية لقسمك.';
        }
        final recText = recs.map((r) => '- **${r.courseName} (${r.courseCode})**: ${r.reason} (أولوية: ${r.priority})').join('\n');
        return 'بناءً على تحليل المواد المتبقية والسابقة، نوصي بتسجيل المقررات التالية:\n\n$recText';
      }
    } catch (_) {}

    return 'مرحباً بك في المساعد الأكاديمي الذكي 🎓.\n'
        'يمكنني إرشادك والإجابة على استفساراتك حول:\n'
        '1. معدلك الأكاديمي الحالي والساعات المجتازة.\n'
        '2. الإنذارات والأخطاء المسجلة في ملفك.\n'
        '3. متطلبات التخرج الحالية والساعات المتبقية.\n'
        '4. المقررات المقترحة للتسجيل في الفصل القادم.\n\n'
        'كيف يمكنني مساعدتك الآن؟';
  }
}
