// file: lib/data/models/graduation_requirements_model.dart

class GraduationRequirementsModel {
  const GraduationRequirementsModel({
    this.id,
    required this.planId,
    this.requiredHours = 150,
    this.minGpa = 0.70,
    this.requiresFieldTraining = true,
    this.requiresCivicLiteracy = true,
    this.civicLiteracyCount = 2,
    this.requiresCommunityCourse = true,
    this.requiresCommunityIssuesCourse,
    this.communityIssuesCourseCode,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String planId;
  final int requiredHours;
  final double minGpa;
  final bool? requiresFieldTraining;
  final bool? requiresCivicLiteracy;
  final int? civicLiteracyCount;
  final bool? requiresCommunityCourse;
  final bool? requiresCommunityIssuesCourse;
  final String? communityIssuesCourseCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory GraduationRequirementsModel.fromJson(Map<String, dynamic> json) {
    return GraduationRequirementsModel(
      id: json['id'] as String?,
      planId: json['plan_id'] as String,
      requiredHours: (json['required_hours'] as int?) ?? 150,
      minGpa: (json['min_gpa'] as num?)?.toDouble() ?? 0.70,
      requiresFieldTraining: json['requires_field_training'] as bool?,
      requiresCivicLiteracy: json['requires_civic_literacy'] as bool?,
      civicLiteracyCount: json['civic_literacy_count'] as int?,
      requiresCommunityCourse: json['requires_community_course'] as bool?,
      requiresCommunityIssuesCourse: json['requires_community_issues_course'] as bool?,
      communityIssuesCourseCode: json['community_issues_course_code'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'plan_id': planId,
        'required_hours': requiredHours,
        'min_gpa': minGpa,
        'requires_field_training': requiresFieldTraining,
        'requires_civic_literacy': requiresCivicLiteracy,
        'civic_literacy_count': civicLiteracyCount,
        'requires_community_course': requiresCommunityCourse,
        if (requiresCommunityIssuesCourse != null)
          'requires_community_issues_course': requiresCommunityIssuesCourse,
        if (communityIssuesCourseCode != null)
          'community_issues_course_code': communityIssuesCourseCode,
      };

  Map<String, dynamic> toUpdateJson() => {
        'required_hours': requiredHours,
        'min_gpa': minGpa,
        'requires_field_training': requiresFieldTraining,
        'requires_civic_literacy': requiresCivicLiteracy,
        'civic_literacy_count': civicLiteracyCount,
        'requires_community_course': requiresCommunityCourse,
        'requires_community_issues_course': requiresCommunityIssuesCourse,
        'community_issues_course_code': communityIssuesCourseCode,
      };

  GraduationRequirementsModel copyWith({
    String? id,
    String? planId,
    int? requiredHours,
    double? minGpa,
    bool? requiresFieldTraining,
    bool? requiresCivicLiteracy,
    int? civicLiteracyCount,
    bool? requiresCommunityCourse,
    bool? requiresCommunityIssuesCourse,
    String? communityIssuesCourseCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GraduationRequirementsModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      requiredHours: requiredHours ?? this.requiredHours,
      minGpa: minGpa ?? this.minGpa,
      requiresFieldTraining:
          requiresFieldTraining ?? this.requiresFieldTraining,
      requiresCivicLiteracy:
          requiresCivicLiteracy ?? this.requiresCivicLiteracy,
      civicLiteracyCount: civicLiteracyCount ?? this.civicLiteracyCount,
      requiresCommunityCourse:
          requiresCommunityCourse ?? this.requiresCommunityCourse,
      requiresCommunityIssuesCourse:
          requiresCommunityIssuesCourse ?? this.requiresCommunityIssuesCourse,
      communityIssuesCourseCode:
          communityIssuesCourseCode ?? this.communityIssuesCourseCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
