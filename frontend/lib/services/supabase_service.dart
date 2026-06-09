import '../data/services/base_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends BaseService {
  SupabaseService([SupabaseClient? customClient]) : super(customClient);

  // ── Students ──────────────────────────────────────────────────────────

  /// Fetch list of students with optional department and study level filters
  Future<List<Map<String, dynamic>>> getStudents({String? departmentId, int? level}) async {
    return safeCall(() async {
      var query = client.from('students').select('*, departments(name_ar)');
      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.eq('department_id', departmentId);
      }
      if (level != null) {
        query = query.eq('level', level);
      }
      final res = await query.order('name_ar');
      return List<Map<String, dynamic>>.from(res as List);
    }, context: 'SupabaseService.getStudents');
  }

  /// Fetch a single student's basic details by ID
  Future<Map<String, dynamic>> getStudentById(String id) async {
    return safeCall(() async {
      final res = await client.from('students').select('*, departments(name_ar)').eq('id', id).single();
      return res as Map<String, dynamic>;
    }, context: 'SupabaseService.getStudentById');
  }

  /// Exposes a realtime stream of student records filtered by department
  Stream<List<Map<String, dynamic>>> watchStudents(String departmentId) {
    return client
        .from('students')
        .stream(primaryKey: ['id'])
        .eq('department_id', departmentId)
        .map((list) => list.map((e) => Map<String, dynamic>.from(e)).toList());
  }

  // ── Study Plans ────────────────────────────────────────────────────────

  /// Fetch study plans with optional department filter
  Future<List<Map<String, dynamic>>> getStudyPlans({String? departmentId}) async {
    return safeCall(() async {
      var query = client.from('study_plans').select('*, departments(name_ar)');
      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.eq('department_id', departmentId);
      }
      final res = await query.order('name');
      return List<Map<String, dynamic>>.from(res as List);
    }, context: 'SupabaseService.getStudyPlans');
  }

  /// Fetch a single study plan by ID
  Future<Map<String, dynamic>> getStudyPlanById(String id) async {
    return safeCall(() async {
      final res = await client.from('study_plans').select('*').eq('id', id).single();
      return res as Map<String, dynamic>;
    }, context: 'SupabaseService.getStudyPlanById');
  }

  /// Inserts a new study plan
  Future<Map<String, dynamic>> createStudyPlan(Map<String, dynamic> data) async {
    return safeCall(() async {
      final res = await client.from('study_plans').insert(data).select().single();
      return res as Map<String, dynamic>;
    }, context: 'SupabaseService.createStudyPlan');
  }

  /// Updates an existing study plan
  Future<Map<String, dynamic>> updateStudyPlan(String id, Map<String, dynamic> data) async {
    return safeCall(() async {
      final res = await client.from('study_plans').update(data).eq('id', id).select().single();
      return res as Map<String, dynamic>;
    }, context: 'SupabaseService.updateStudyPlan');
  }

  // ── Analysis Results (READ ONLY) ──────────────────────────────────────

  /// Fetches the latest analysis run for a student
  Future<Map<String, dynamic>?> getLatestAnalysis(String studentId) async {
    return safeCall(() async {
      final res = await client
          .from('analysis_results')
          .select('*')
          .eq('student_id', studentId)
          .eq('is_latest', true)
          .maybeSingle();
      return res as Map<String, dynamic>?;
    }, context: 'SupabaseService.getLatestAnalysis');
  }

  /// Fetches issues from the latest analysis run
  Future<List<Map<String, dynamic>>> getAnalysisIssues(String studentId, {String? severity}) async {
    return safeCall(() async {
      var query = client.from('analysis_issues').select('*').eq('student_id', studentId);
      if (severity != null && severity.isNotEmpty) {
        query = query.eq('severity', severity);
      }
      final res = await query;
      return List<Map<String, dynamic>>.from(res as List);
    }, context: 'SupabaseService.getAnalysisIssues');
  }

  // ── Advisor Notes ──────────────────────────────────────────────────────

  /// Fetch notes/logs written by advisors for a student
  Future<List<Map<String, dynamic>>> getAdvisorNotes(String studentId) async {
    return safeCall(() async {
      final res = await client
          .from('advisor_notes')
          .select('*')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res as List);
    }, context: 'SupabaseService.getAdvisorNotes');
  }

  /// Adds a new advisor note for a student
  Future<Map<String, dynamic>> addAdvisorNote(String studentId, String note, bool isPrivate) async {
    return safeCall(() async {
      final currentUserId = client.auth.currentUser?.id;
      final res = await client.from('advisor_notes').insert({
        'student_id': studentId,
        'note_text': note,
        'is_private': isPrivate,
        'created_by': currentUserId,
      }).select().single();
      return res as Map<String, dynamic>;
    }, context: 'SupabaseService.addAdvisorNote');
  }

  // ── Statistics ─────────────────────────────────────────────────────────

  /// Computes general platform statistics directly from DB
  Future<Map<String, dynamic>> getGeneralStatistics() async {
    return safeCall(() async {
      final students = await client.from('students').select('id, gpa');
      final issues = await client.from('analysis_issues').select('id, severity');

      final totalStudents = (students as List).length;
      double totalGpa = 0.0;
      int gpaCount = 0;
      for (var s in students) {
        final g = s['gpa'];
        if (g != null && g is num) {
          totalGpa += g.toDouble();
          gpaCount++;
        }
      }
      final avgGpa = gpaCount > 0 ? (totalGpa / gpaCount) : 0.0;

      final totalIssues = (issues as List).length;
      final totalWarnings = issues.where((i) => i['severity'] == 'warning').length;
      final totalErrors = issues.where((i) => i['severity'] == 'error').length;

      return {
        'total_students': totalStudents,
        'average_gpa': avgGpa,
        'total_issues': totalIssues,
        'warnings_count': totalWarnings,
        'errors_count': totalErrors,
      };
    }, context: 'SupabaseService.getGeneralStatistics');
  }

  /// Computes statistics grouped per department
  Future<List<Map<String, dynamic>>> getDepartmentStatistics() async {
    return safeCall(() async {
      final departmentsRes = await client.from('departments').select('id, name_ar');
      final studentsRes = await client.from('students').select('department_id, gpa');

      final departments = departmentsRes as List<dynamic>;
      final students = studentsRes as List<dynamic>;

      final List<Map<String, dynamic>> stats = [];

      for (var dept in departments) {
        final deptId = dept['id'];
        final deptName = dept['name_ar'];

        final deptStudents = students.where((s) => s['department_id'] == deptId).toList();
        final count = deptStudents.length;

        double totalGpa = 0.0;
        int gpaCount = 0;
        for (var s in deptStudents) {
          final g = s['gpa'];
          if (g != null && g is num) {
            totalGpa += g.toDouble();
            gpaCount++;
          }
        }
        final avgGpa = gpaCount > 0 ? (totalGpa / gpaCount) : 0.0;

        stats.add({
          'department_id': deptId,
          'department_name': deptName,
          'student_count': count,
          'average_gpa': avgGpa,
        });
      }

      return stats;
    }, context: 'SupabaseService.getDepartmentStatistics');
  }
}
