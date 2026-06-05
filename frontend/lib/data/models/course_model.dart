// file: lib/data/models/course_model.dart

class CourseModel {
  const CourseModel({
    this.id,
    required this.planId,
    required this.code,
    required this.nameAr,
    this.nameEn,
    required this.creditHours,
    this.theoryHours = 0,
    this.practicalHours = 0,
    this.labHours = 0,
    this.fieldHours = 0,
    required this.level,
    required this.term,
    this.courseType = 'mandatory',
    this.gradingConfig,
    this.gradingScaleId,
    this.notes,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String planId;
  final String code;
  final String nameAr;
  final String? nameEn;
  final int creditHours;
  final int theoryHours;
  final int practicalHours;
  final int labHours;
  final int fieldHours;
  final int level;
  final String term; // fall, spring, summer
  final String courseType; // mandatory, elective, project, training
  final Map<String, dynamic>? gradingConfig;
  final String? gradingScaleId;
  final String? notes;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static const Map<String, dynamic> defaultGradingConfig = {
    'midterm': 20,
    'coursework': 20,
    'min_passing': 30,
    'final_theory': 30,
    'final_practical': 30,
  };

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String?,
      planId: json['plan_id'] as String,
      code: json['code'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String?,
      creditHours: json['credit_hours'] as int,
      theoryHours: (json['theory_hours'] as int?) ?? 0,
      practicalHours: (json['practical_hours'] as int?) ?? 0,
      labHours: (json['lab_hours'] as int?) ?? 0,
      fieldHours: (json['field_hours'] as int?) ?? 0,
      level: json['level'] as int,
      term: json['term'] as String,
      courseType: (json['course_type'] as String?) ?? 'mandatory',
      gradingConfig: json['grading_config'] is Map
          ? Map<String, dynamic>.from(json['grading_config'] as Map)
          : null,
      gradingScaleId: json['grading_scale_id'] as String?,
      notes: json['notes'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      createdBy: json['created_by'] as String?,
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
        'code': code,
        'name_ar': nameAr,
        if (nameEn != null) 'name_en': nameEn,
        'credit_hours': creditHours,
        'theory_hours': theoryHours,
        'practical_hours': practicalHours,
        'lab_hours': labHours,
        'field_hours': fieldHours,
        'level': level,
        'term': term,
        'course_type': courseType,
        'grading_config': gradingConfig ?? defaultGradingConfig,
        if (gradingScaleId != null) 'grading_scale_id': gradingScaleId,
        if (notes != null) 'notes': notes,
        'is_active': isActive,
        if (createdBy != null) 'created_by': createdBy,
      };

  Map<String, dynamic> toUpdateJson() => {
        'plan_id': planId,
        'code': code,
        'name_ar': nameAr,
        'name_en': nameEn,
        'credit_hours': creditHours,
        'theory_hours': theoryHours,
        'practical_hours': practicalHours,
        'lab_hours': labHours,
        'field_hours': fieldHours,
        'level': level,
        'term': term,
        'course_type': courseType,
        'grading_config': gradingConfig ?? defaultGradingConfig,
        'grading_scale_id': gradingScaleId,
        'notes': notes,
        'is_active': isActive,
      };

  CourseModel copyWith({
    String? id,
    String? planId,
    String? code,
    String? nameAr,
    String? nameEn,
    int? creditHours,
    int? theoryHours,
    int? practicalHours,
    int? labHours,
    int? fieldHours,
    int? level,
    String? term,
    String? courseType,
    Map<String, dynamic>? gradingConfig,
    String? gradingScaleId,
    String? notes,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      code: code ?? this.code,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      creditHours: creditHours ?? this.creditHours,
      theoryHours: theoryHours ?? this.theoryHours,
      practicalHours: practicalHours ?? this.practicalHours,
      labHours: labHours ?? this.labHours,
      fieldHours: fieldHours ?? this.fieldHours,
      level: level ?? this.level,
      term: term ?? this.term,
      courseType: courseType ?? this.courseType,
      gradingConfig: gradingConfig ?? this.gradingConfig,
      gradingScaleId: gradingScaleId ?? this.gradingScaleId,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
