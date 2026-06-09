// file: lib/data/models/app_user_model.dart

import 'user_profile_model.dart';

class AppUserModel {
  const AppUserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.role,
    this.departmentId,
    this.isActive = true,
    this.systemRole,
    this.isSystemUser = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? role; // e.g. 'department_head', 'academic_advisor'
  final String? departmentId;
  final bool isActive;
  final String? systemRole; // e.g. 'ACADEMIC_OPERATIONS', 'ACADEMIC_ADVISING', 'SYSTEM_MANAGEMENT'
  final bool isSystemUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Helper to convert AppUserModel to AppRole enum helper.
  AppRole get appRole => AppRole.fromString(systemRole ?? role);

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      role: json['role'] as String? ?? json['legacy_role'] as String?,
      departmentId: json['department_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      systemRole: json['system_role'] as String? ?? json['role_key'] as String?,
      isSystemUser: json['is_system_user'] as bool? ?? false,
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
        'email': email,
        'full_name': fullName,
        'role': role,
        'department_id': departmentId,
        'is_active': isActive,
        'system_role': systemRole,
        'is_system_user': isSystemUser,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  AppUserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? departmentId,
    bool? isActive,
    String? systemRole,
    bool? isSystemUser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      isActive: isActive ?? this.isActive,
      systemRole: systemRole ?? this.systemRole,
      isSystemUser: isSystemUser ?? this.isSystemUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'AppUserModel(id: $id, email: $email, role: $role, systemRole: $systemRole)';
}
