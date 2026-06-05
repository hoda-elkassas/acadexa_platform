// file: lib/data/models/elective_group_model.dart

class ElectiveGroupModel {
  const ElectiveGroupModel({
    this.id,
    required this.planId,
    required this.name,
    required this.code,
    this.selectByHours = true,
    this.minHours,
    this.maxHours,
    this.minCourses,
    this.maxCourses,
    this.validFromYear,
    this.validToYear,
    this.createdAt,
    this.courseIds = const [],
    this.rules,
  });

  final String? id;
  final String planId;
  final String name;
  final String code;
  final bool selectByHours;
  final int? minHours;
  final int? maxHours;
  final int? minCourses;
  final int? maxCourses;
  final int? validFromYear;
  final int? validToYear;
  final DateTime? createdAt;

  // Related data
  final List<String> courseIds;
  final ElectiveGroupRulesModel? rules;

  factory ElectiveGroupModel.fromJson(Map<String, dynamic> json) {
    final rawCourses = json['elective_group_courses'];
    final courseIds = <String>[];
    if (rawCourses is List) {
      for (final c in rawCourses) {
        if (c is Map && c['course_id'] != null) {
          courseIds.add(c['course_id'] as String);
        }
      }
    }

    final rawRules = json['elective_group_rules'];
    ElectiveGroupRulesModel? rules;
    if (rawRules is List && rawRules.isNotEmpty) {
      rules = ElectiveGroupRulesModel.fromJson(
          rawRules.first as Map<String, dynamic>);
    } else if (rawRules is Map) {
      rules = ElectiveGroupRulesModel.fromJson(
          rawRules as Map<String, dynamic>);
    }

    return ElectiveGroupModel(
      id: json['id'] as String?,
      planId: json['plan_id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      selectByHours: (json['select_by_hours'] as bool?) ?? true,
      minHours: json['min_hours'] as int?,
      maxHours: json['max_hours'] as int?,
      minCourses: json['min_courses'] as int?,
      maxCourses: json['max_courses'] as int?,
      validFromYear: json['valid_from_year'] as int?,
      validToYear: json['valid_to_year'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      courseIds: courseIds,
      rules: rules,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'plan_id': planId,
        'name': name,
        'code': code,
        'select_by_hours': selectByHours,
        if (minHours != null) 'min_hours': minHours,
        if (maxHours != null) 'max_hours': maxHours,
        if (minCourses != null) 'min_courses': minCourses,
        if (maxCourses != null) 'max_courses': maxCourses,
        if (validFromYear != null) 'valid_from_year': validFromYear,
        if (validToYear != null) 'valid_to_year': validToYear,
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'code': code,
        'select_by_hours': selectByHours,
        'min_hours': minHours,
        'max_hours': maxHours,
        'min_courses': minCourses,
        'max_courses': maxCourses,
        'valid_from_year': validFromYear,
        'valid_to_year': validToYear,
      };

  ElectiveGroupModel copyWith({
    String? id,
    String? planId,
    String? name,
    String? code,
    bool? selectByHours,
    int? minHours,
    int? maxHours,
    int? minCourses,
    int? maxCourses,
    int? validFromYear,
    int? validToYear,
    DateTime? createdAt,
    List<String>? courseIds,
    ElectiveGroupRulesModel? rules,
  }) {
    return ElectiveGroupModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      name: name ?? this.name,
      code: code ?? this.code,
      selectByHours: selectByHours ?? this.selectByHours,
      minHours: minHours ?? this.minHours,
      maxHours: maxHours ?? this.maxHours,
      minCourses: minCourses ?? this.minCourses,
      maxCourses: maxCourses ?? this.maxCourses,
      validFromYear: validFromYear ?? this.validFromYear,
      validToYear: validToYear ?? this.validToYear,
      createdAt: createdAt ?? this.createdAt,
      courseIds: courseIds ?? this.courseIds,
      rules: rules ?? this.rules,
    );
  }
}

class ElectiveGroupRulesModel {
  const ElectiveGroupRulesModel({
    this.id,
    required this.groupId,
    this.allowRetake = false,
    this.allowAlternativeAfterFail = false,
    this.maxRetakeAttempts = 2,
    this.createdAt,
  });

  final String? id;
  final String groupId;
  final bool allowRetake;
  final bool allowAlternativeAfterFail;
  final int maxRetakeAttempts;
  final DateTime? createdAt;

  factory ElectiveGroupRulesModel.fromJson(Map<String, dynamic> json) {
    return ElectiveGroupRulesModel(
      id: json['id'] as String?,
      groupId: json['group_id'] as String,
      allowRetake: (json['allow_retake'] as bool?) ?? false,
      allowAlternativeAfterFail:
          (json['allow_alternative_after_fail'] as bool?) ?? false,
      maxRetakeAttempts: (json['max_retake_attempts'] as int?) ?? 2,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'group_id': groupId,
        'allow_retake': allowRetake,
        'allow_alternative_after_fail': allowAlternativeAfterFail,
        'max_retake_attempts': maxRetakeAttempts,
      };

  Map<String, dynamic> toUpdateJson() => toInsertJson();
}
