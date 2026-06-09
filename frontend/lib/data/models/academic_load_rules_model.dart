// file: lib/data/models/academic_load_rules_model.dart

class AcademicLoadRulesModel {
  const AcademicLoadRulesModel({
    this.id,
    required this.planId,
    this.maxHoursFallSpring = 20,
    this.minHoursFallSpring = 12,
    this.maxHoursSummer = 9,
    this.allowOverload = false,
    this.overloadMaxHours,
    this.overloadMinGpa,
    this.level1To2MinHours = 32,
    this.level2To3MinHours = 70,
    this.level3To4MinHours = 110,
    this.requiresCivicLiteracy = true,
    this.civicLiteracyCount = 2,
    this.requiresCommunityCourse = true,
    this.probationMinGpa,
    this.probationAfterSemesters,
    this.probationMaxHours,
    this.suspensionConsecutiveSemesters,
    this.suspensionMinGpa,
  });

  final String? id;
  final String planId;
  final int maxHoursFallSpring;
  final int minHoursFallSpring;
  final int maxHoursSummer;
  final bool allowOverload;
  final int? overloadMaxHours;
  final double? overloadMinGpa;
  final int? level1To2MinHours;
  final int? level2To3MinHours;
  final int? level3To4MinHours;
  final bool requiresCivicLiteracy;
  final int? civicLiteracyCount;
  final bool requiresCommunityCourse;
  final double? probationMinGpa;
  final int? probationAfterSemesters;
  final int? probationMaxHours;
  final int? suspensionConsecutiveSemesters;
  final double? suspensionMinGpa;

  factory AcademicLoadRulesModel.fromJson(Map<String, dynamic> json) {
    return AcademicLoadRulesModel(
      id: json['id'] as String?,
      planId: json['plan_id'] as String,
      maxHoursFallSpring: (json['max_hours_fall_spring'] as int?) ?? 20,
      minHoursFallSpring: (json['min_hours_fall_spring'] as int?) ?? 12,
      maxHoursSummer: (json['max_hours_summer'] as int?) ?? 9,
      allowOverload: (json['allow_overload'] as bool?) ?? false,
      overloadMaxHours: json['overload_max_hours'] as int?,
      overloadMinGpa: (json['overload_min_gpa'] as num?)?.toDouble(),
      level1To2MinHours: json['level_1_to_2_min_hours'] as int?,
      level2To3MinHours: json['level_2_to_3_min_hours'] as int?,
      level3To4MinHours: json['level_3_to_4_min_hours'] as int?,
      requiresCivicLiteracy:
          (json['requires_civic_literacy'] as bool?) ?? true,
      civicLiteracyCount: json['civic_literacy_count'] as int?,
      requiresCommunityCourse:
          (json['requires_community_course'] as bool?) ?? true,
      probationMinGpa: (json['probation_min_gpa'] as num?)?.toDouble(),
      probationAfterSemesters: json['probation_after_semesters'] as int?,
      probationMaxHours: json['probation_max_hours'] as int?,
      suspensionConsecutiveSemesters: json['suspension_consecutive_semesters'] as int?,
      suspensionMinGpa: (json['suspension_min_gpa'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'plan_id': planId,
        'max_hours_fall_spring': maxHoursFallSpring,
        'min_hours_fall_spring': minHoursFallSpring,
        'max_hours_summer': maxHoursSummer,
        'allow_overload': allowOverload,
        if (overloadMaxHours != null) 'overload_max_hours': overloadMaxHours,
        if (overloadMinGpa != null) 'overload_min_gpa': overloadMinGpa,
        if (level1To2MinHours != null)
          'level_1_to_2_min_hours': level1To2MinHours,
        if (level2To3MinHours != null)
          'level_2_to_3_min_hours': level2To3MinHours,
        if (level3To4MinHours != null)
          'level_3_to_4_min_hours': level3To4MinHours,
        'requires_civic_literacy': requiresCivicLiteracy,
        if (civicLiteracyCount != null)
          'civic_literacy_count': civicLiteracyCount,
        'requires_community_course': requiresCommunityCourse,
        if (probationMinGpa != null) 'probation_min_gpa': probationMinGpa,
        if (probationAfterSemesters != null) 'probation_after_semesters': probationAfterSemesters,
        if (probationMaxHours != null) 'probation_max_hours': probationMaxHours,
        if (suspensionConsecutiveSemesters != null) 'suspension_consecutive_semesters': suspensionConsecutiveSemesters,
        if (suspensionMinGpa != null) 'suspension_min_gpa': suspensionMinGpa,
      };

  Map<String, dynamic> toUpdateJson() => {
        'max_hours_fall_spring': maxHoursFallSpring,
        'min_hours_fall_spring': minHoursFallSpring,
        'max_hours_summer': maxHoursSummer,
        'allow_overload': allowOverload,
        'overload_max_hours': overloadMaxHours,
        'overload_min_gpa': overloadMinGpa,
        'level_1_to_2_min_hours': level1To2MinHours,
        'level_2_to_3_min_hours': level2To3MinHours,
        'level_3_to_4_min_hours': level3To4MinHours,
        'requires_civic_literacy': requiresCivicLiteracy,
        'civic_literacy_count': civicLiteracyCount,
        'requires_community_course': requiresCommunityCourse,
        'probation_min_gpa': probationMinGpa,
        'probation_after_semesters': probationAfterSemesters,
        'probation_max_hours': probationMaxHours,
        'suspension_consecutive_semesters': suspensionConsecutiveSemesters,
        'suspension_min_gpa': suspensionMinGpa,
      };

  AcademicLoadRulesModel copyWith({
    String? id,
    String? planId,
    int? maxHoursFallSpring,
    int? minHoursFallSpring,
    int? maxHoursSummer,
    bool? allowOverload,
    int? overloadMaxHours,
    double? overloadMinGpa,
    int? level1To2MinHours,
    int? level2To3MinHours,
    int? level3To4MinHours,
    bool? requiresCivicLiteracy,
    int? civicLiteracyCount,
    bool? requiresCommunityCourse,
    double? probationMinGpa,
    int? probationAfterSemesters,
    int? probationMaxHours,
    int? suspensionConsecutiveSemesters,
    double? suspensionMinGpa,
  }) {
    return AcademicLoadRulesModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      maxHoursFallSpring: maxHoursFallSpring ?? this.maxHoursFallSpring,
      minHoursFallSpring: minHoursFallSpring ?? this.minHoursFallSpring,
      maxHoursSummer: maxHoursSummer ?? this.maxHoursSummer,
      allowOverload: allowOverload ?? this.allowOverload,
      overloadMaxHours: overloadMaxHours ?? this.overloadMaxHours,
      overloadMinGpa: overloadMinGpa ?? this.overloadMinGpa,
      level1To2MinHours: level1To2MinHours ?? this.level1To2MinHours,
      level2To3MinHours: level2To3MinHours ?? this.level2To3MinHours,
      level3To4MinHours: level3To4MinHours ?? this.level3To4MinHours,
      requiresCivicLiteracy:
          requiresCivicLiteracy ?? this.requiresCivicLiteracy,
      civicLiteracyCount: civicLiteracyCount ?? this.civicLiteracyCount,
      requiresCommunityCourse:
          requiresCommunityCourse ?? this.requiresCommunityCourse,
      probationMinGpa: probationMinGpa ?? this.probationMinGpa,
      probationAfterSemesters: probationAfterSemesters ?? this.probationAfterSemesters,
      probationMaxHours: probationMaxHours ?? this.probationMaxHours,
      suspensionConsecutiveSemesters:
          suspensionConsecutiveSemesters ?? this.suspensionConsecutiveSemesters,
      suspensionMinGpa: suspensionMinGpa ?? this.suspensionMinGpa,
    );
  }
}
