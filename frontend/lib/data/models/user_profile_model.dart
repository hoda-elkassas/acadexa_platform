// file: lib/data/models/user_profile_model.dart

/// Application roles — must match both the legacy schema and new app_users system_role.
enum AppRole {
  admin,
  academicAdvisor,
  dashboardViewer,
  user;

  /// Parse from DB string value (case-insensitive, handles upper and lower snake case).
  static AppRole fromString(String? value) {
    if (value == null) return AppRole.user;
    final normalized = value.toUpperCase();
    switch (normalized) {
      case 'ADMIN':
      case 'SYSTEM_MANAGEMENT':
      case 'DEVELOPER':
        return AppRole.admin;
      case 'ACADEMIC_ADVISOR':
      case 'ACADEMIC_ADVISING':
      case 'ACADEMIC_OPERATIONS':
        return AppRole.academicAdvisor;
      case 'DASHBOARD_VIEWER':
      case 'ANALYTICS_AND_REPORTING':
      case 'VIEWER':
        return AppRole.dashboardViewer;
      case 'AUTHENTICATED':
      case 'USER':
      default:
        return AppRole.user;
    }
  }

  /// DB string value (legacy format).
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

  /// New system role string value (UPPER_SNAKE_CASE).
  String get systemRoleValue {
    switch (this) {
      case AppRole.admin:
        return 'SYSTEM_MANAGEMENT';
      case AppRole.academicAdvisor:
        return 'ACADEMIC_ADVISING';
      case AppRole.dashboardViewer:
        return 'DASHBOARD_VIEWER';
      case AppRole.user:
        return 'authenticated';
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


/// Represents a user profile in the application.
/// Maps to either the `app_users` table or the `v_users_with_roles` view.
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.role,
    this.fullName,
    this.departmentId,
    this.departmentName,
    this.studentId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final AppRole role;
  final String? fullName;
  final String? departmentId;
  final String? departmentName;
  final String? studentId;   // only set for student role
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Check key for role in new schema (system_role or role)
    final roleStr = json['system_role'] as String? ?? json['role'] as String?;
    
    return UserProfileModel(
      id: json['id'] as String,
      role: AppRole.fromString(roleStr),
      fullName: json['full_name'] as String?,
      departmentId: json['department_id'] as String?,
      departmentName: json['department_name'] as String?,
      studentId: json['student_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.value,
    'system_role': role.systemRoleValue,
    'full_name': fullName,
    'department_id': departmentId,
    'student_id': studentId,
  };

  UserProfileModel copyWith({
    String? fullName,
    String? departmentId,
    String? departmentName,
    String? studentId,
    AppRole? role,
  }) {
    return UserProfileModel(
      id: id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() =>
      'UserProfileModel(id: $id, role: ${role.value}, name: $fullName)';
}
