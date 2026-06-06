// file: lib/data/models/user_profile_model.dart

/// Application roles — must match the CHECK constraint in user_profiles table.
enum AppRole {
  admin,
  academicAdvisor,
  dashboardViewer,
  user;

  /// Parse from DB string value.
  static AppRole fromString(String value) {
    switch (value) {
      case 'admin':
        return AppRole.admin;
      case 'academic_advisor':
        return AppRole.academicAdvisor;
      case 'dashboard_viewer':
        return AppRole.dashboardViewer;
      default:
        return AppRole.user;
    }
  }

  /// DB string value.
  String get value {
    switch (this) {
      case AppRole.admin:
        return 'admin';
      case AppRole.academicAdvisor:
        return 'academic_advisor';
      case AppRole.dashboardViewer:
        return 'dashboard_viewer';
      case AppRole.user:
        return 'user';
    }
  }

  /// Arabic display label.
  String get labelAr {
    switch (this) {
      case AppRole.admin:
        return 'مدير النظام';
      case AppRole.academicAdvisor:
        return 'المرشد الأكاديمي';
      case AppRole.dashboardViewer:
        return 'عارض اللوحة';
      case AppRole.user:
        return 'طالب';
    }
  }

  bool get canSeeAllStudents =>
      this == AppRole.admin ||
      this == AppRole.academicAdvisor ||
      this == AppRole.dashboardViewer;

  bool get canWriteAnalysis =>
      this == AppRole.admin || this == AppRole.academicAdvisor;

  bool get canManageCurriculum => this == AppRole.admin;

  bool get canImportData =>
      this == AppRole.admin || this == AppRole.academicAdvisor;
}


/// Represents a row in the `user_profiles` table.
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.role,
    this.fullName,
    this.departmentId,
    this.studentId,
    this.createdAt,
  });

  final String  id;
  final AppRole role;
  final String? fullName;
  final String? departmentId;
  final String? studentId;   // only set for 'user' role
  final DateTime? createdAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id:           json['id'] as String,
      role:         AppRole.fromString(json['role'] as String? ?? 'user'),
      fullName:     json['full_name']     as String?,
      departmentId: json['department_id'] as String?,
      studentId:    json['student_id']    as String?,
      createdAt:    json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'role':          role.value,
    'full_name':     fullName,
    'department_id': departmentId,
    'student_id':    studentId,
  };

  UserProfileModel copyWith({
    String?  fullName,
    String?  departmentId,
    String?  studentId,
  }) {
    return UserProfileModel(
      id:           id,
      role:         role,
      fullName:     fullName     ?? this.fullName,
      departmentId: departmentId ?? this.departmentId,
      studentId:    studentId    ?? this.studentId,
      createdAt:    createdAt,
    );
  }

  @override
  String toString() =>
      'UserProfileModel(id: $id, role: ${role.value}, name: $fullName)';
}
