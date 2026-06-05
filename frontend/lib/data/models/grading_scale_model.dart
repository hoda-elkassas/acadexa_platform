// file: lib/data/models/grading_scale_model.dart

class GradingScaleModel {
  const GradingScaleModel({
    this.id,
    this.planId,
    this.departmentId,
    this.programId,
    required this.nameAr,
    this.nameEn,
    this.isDefault = false,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  final String? id;
  final String? planId;
  final String? departmentId;
  final String? programId;
  final String nameAr;
  final String? nameEn;
  final bool isDefault;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<GradeScaleItemModel> items;

  factory GradingScaleModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['grade_scale_items'];
    final items = <GradeScaleItemModel>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          items.add(GradeScaleItemModel.fromJson(item));
        }
      }
    }

    return GradingScaleModel(
      id: json['id'] as String?,
      planId: json['plan_id'] as String?,
      departmentId: json['department_id'] as String?,
      programId: json['program_id'] as String?,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      isDefault: (json['is_default'] as bool?) ?? false,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      items: items,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        if (planId != null) 'plan_id': planId,
        if (departmentId != null) 'department_id': departmentId,
        if (programId != null) 'program_id': programId,
        'name_ar': nameAr,
        if (nameEn != null) 'name_en': nameEn,
        'is_default': isDefault,
        if (createdBy != null) 'created_by': createdBy,
      };

  Map<String, dynamic> toUpdateJson() => {
        'plan_id': planId,
        'department_id': departmentId,
        'program_id': programId,
        'name_ar': nameAr,
        'name_en': nameEn,
        'is_default': isDefault,
      };

  GradingScaleModel copyWith({
    String? id,
    String? planId,
    String? departmentId,
    String? programId,
    String? nameAr,
    String? nameEn,
    bool? isDefault,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<GradeScaleItemModel>? items,
  }) {
    return GradingScaleModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      departmentId: departmentId ?? this.departmentId,
      programId: programId ?? this.programId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      isDefault: isDefault ?? this.isDefault,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

// Also defined here for convenience — re-exported from grade_scale_item_model.dart
class GradeScaleItemModel {
  const GradeScaleItemModel({
    this.id,
    required this.gradeScaleId,
    required this.gradeAr,
    required this.gradeLetter,
    required this.points,
    required this.minScore,
    required this.maxScore,
    this.isPassing = true,
    this.createdAt,
  });

  final String? id;
  final String gradeScaleId;
  final String gradeAr;
  final String gradeLetter;
  final double points;
  final int minScore;
  final int maxScore;
  final bool isPassing;
  final DateTime? createdAt;

  factory GradeScaleItemModel.fromJson(Map<String, dynamic> json) {
    return GradeScaleItemModel(
      id: json['id'] as String?,
      gradeScaleId: json['grade_scale_id'] as String,
      gradeAr: json['grade_ar'] as String,
      gradeLetter: json['grade_letter'] as String,
      points: (json['points'] as num).toDouble(),
      minScore: json['min_score'] as int,
      maxScore: json['max_score'] as int,
      isPassing: (json['is_passing'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'grade_scale_id': gradeScaleId,
        'grade_ar': gradeAr,
        'grade_letter': gradeLetter,
        'points': points,
        'min_score': minScore,
        'max_score': maxScore,
        'is_passing': isPassing,
      };

  Map<String, dynamic> toUpdateJson() => toInsertJson();

  GradeScaleItemModel copyWith({
    String? id,
    String? gradeScaleId,
    String? gradeAr,
    String? gradeLetter,
    double? points,
    int? minScore,
    int? maxScore,
    bool? isPassing,
    DateTime? createdAt,
  }) {
    return GradeScaleItemModel(
      id: id ?? this.id,
      gradeScaleId: gradeScaleId ?? this.gradeScaleId,
      gradeAr: gradeAr ?? this.gradeAr,
      gradeLetter: gradeLetter ?? this.gradeLetter,
      points: points ?? this.points,
      minScore: minScore ?? this.minScore,
      maxScore: maxScore ?? this.maxScore,
      isPassing: isPassing ?? this.isPassing,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
