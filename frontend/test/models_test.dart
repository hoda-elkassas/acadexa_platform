import 'package:flutter_test/flutter_test.dart';
import 'package:acadexa/data/models/user_profile_model.dart';
import 'package:acadexa/data/models/course_model.dart';

void main() {
  group('AppRole Tests', () {
    test('AppRole.fromString should parse roles correctly', () {
      expect(AppRole.fromString('ADMIN'), AppRole.admin);
      expect(AppRole.fromString('SYSTEM_MANAGEMENT'), AppRole.admin);
      expect(AppRole.fromString('DEVELOPER'), AppRole.admin);
      
      expect(AppRole.fromString('ACADEMIC_ADVISOR'), AppRole.academicAdvisor);
      expect(AppRole.fromString('ACADEMIC_ADVISING'), AppRole.academicAdvisor);
      expect(AppRole.fromString('ACADEMIC_OPERATIONS'), AppRole.academicAdvisor);

      expect(AppRole.fromString('DASHBOARD_VIEWER'), AppRole.dashboardViewer);
      expect(AppRole.fromString('VIEWER'), AppRole.dashboardViewer);

      expect(AppRole.fromString('USER'), AppRole.user);
      expect(AppRole.fromString('AUTHENTICATED'), AppRole.user);
      expect(AppRole.fromString(null), AppRole.user);
      expect(AppRole.fromString('UNKNOWN_ROLE'), AppRole.user);
    });

    test('AppRole permissions should work correctly', () {
      expect(AppRole.admin.canSeeAllStudents, true);
      expect(AppRole.academicAdvisor.canSeeAllStudents, true);
      expect(AppRole.dashboardViewer.canSeeAllStudents, true);
      expect(AppRole.user.canSeeAllStudents, false);

      expect(AppRole.admin.canWriteAnalysis, true);
      expect(AppRole.academicAdvisor.canWriteAnalysis, true);
      expect(AppRole.dashboardViewer.canWriteAnalysis, false);

      expect(AppRole.admin.canManageCurriculum, true);
      expect(AppRole.academicAdvisor.canManageCurriculum, false);
    });
  });

  group('UserProfileModel Tests', () {
    test('UserProfileModel.fromJson parses correctly', () {
      final json = {
        'id': 'user-123',
        'system_role': 'DEVELOPER',
        'full_name': 'Test Admin',
        'department_id': 'dept-456',
        'created_at': '2026-06-12T00:00:00Z',
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.id, 'user-123');
      expect(model.role, AppRole.admin);
      expect(model.fullName, 'Test Admin');
      expect(model.departmentId, 'dept-456');
    });

    test('UserProfileModel.toJson serializes correctly', () {
      final model = UserProfileModel(
        id: 'user-123',
        role: AppRole.academicAdvisor,
        fullName: 'Advisor Name',
        departmentId: 'dept-789',
      );

      final json = model.toJson();

      expect(json['id'], 'user-123');
      expect(json['role'], 'academic_advisor');
      expect(json['system_role'], 'ACADEMIC_ADVISING');
      expect(json['full_name'], 'Advisor Name');
      expect(json['department_id'], 'dept-789');
    });
  });

  group('CourseModel Tests', () {
    test('CourseModel.fromJson and toInsertJson mapping', () {
      final json = {
        'id': 'course-abc',
        'plan_id': 'plan-xyz',
        'code': 'CS102',
        'name_ar': 'برمجة 1',
        'credit_hours': 3,
        'theory_hours': 2,
        'lab_hours': 2,
        'level': 2,
        'term': 'spring',
        'course_type': 'compulsory',
      };

      final model = CourseModel.fromJson(json);

      expect(model.id, 'course-abc');
      expect(model.code, 'CS102');
      expect(model.courseType, CourseType.mandatory);

      final insertJson = model.toInsertJson();
      expect(insertJson['code'], 'CS102');
      expect(insertJson['course_type'], 'mandatory');
    });
  });
}
