// file: lib/data/models/study_plan_model.dart

class StudyPlanModel {
  const StudyPlanModel({
    this.id,
    required this.departmentId,
    this.programId,
    required this.academicYear,
    this.version = 1,
    this.isCurrent = false,
    required this.name,
    this.totalCreditHours = 150,
    this.minGpaToGraduate = 0.70,
    this.description,
    this.status = 'draft',
    this.effectiveFrom,
    this.effectiveTo,
    this.defaultGradingScaleId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    // Joined fields (not in table, populated via select)
    this.departmentName,
    this.programName,
  });

  final String? id;
  final String departmentId;
  final String? programId;
  final int academicYear;
  final int version;
  final bool isCurrent;
  final String name;
  final int totalCreditHours;
  final double minGpaToGraduate;
  final String? description;
  final String status; // draft, active, archived
  final String? effectiveFrom;
  final String? effectiveTo;
  final String? defaultGradingScaleId;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined display fields
  final String? departmentName;
  final String? programName;

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    final dept = json['departments'];
    final prog = json['programs'];
    return StudyPlanModel(
      id: json['id'] as String?,
      departmentId: json['department_id'] as String,
      programId: json['program_id'] as String?,
      academicYear: json['academic_year'] as int,
      version: (json['version'] as int?) ?? 1,
      isCurrent: (json['is_current'] as bool?) ?? false,
      name: json['name'] as String,
      totalCreditHours: (json['total_credit_hours'] as int?) ?? 150,
      minGpaToGraduate: (json['min_gpa_to_graduate'] as num?)?.toDouble() ?? 0.70,
      description: json['description'] as String?,
      status: (json['status'] as String?) ?? 'draft',
      effectiveFrom: json['effective_from'] as String?,
      effectiveTo: json['effective_to'] as String?,
      defaultGradingScaleId: json['default_grading_scale_id'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      departmentName: dept is Map ? (dept['name_ar'] as String?) : null,
      programName: prog is Map ? (prog['name_ar'] as String?) : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'department_id': departmentId,
        if (programId != null) 'program_id': programId,
        'academic_year': academicYear,
        'version': version,
        'is_current': isCurrent,
        'name': name,
        'total_credit_hours': totalCreditHours,
        'min_gpa_to_graduate': minGpaToGraduate,
        if (description != null) 'description': description,
        'status': status,
        if (effectiveFrom != null) 'effective_from': effectiveFrom,
        if (effectiveTo != null) 'effective_to': effectiveTo,
        if (defaultGradingScaleId != null)
          'default_grading_scale_id': defaultGradingScaleId,
        if (createdBy != null) 'created_by': createdBy,
      };

  Map<String, dynamic> toUpdateJson() => {
        'department_id': departmentId,
        'program_id': programId,
        'academic_year': academicYear,
        'version': version,
        'is_current': isCurrent,
        'name': name,
        'total_credit_hours': totalCreditHours,
        'min_gpa_to_graduate': minGpaToGraduate,
        'description': description,
        'status': status,
        'effective_from': effectiveFrom,
        'effective_to': effectiveTo,
        'default_grading_scale_id': defaultGradingScaleId,
      };

  StudyPlanModel copyWith({
    String? id,
    String? departmentId,
    String? programId,
    int? academicYear,
    int? version,
    bool? isCurrent,
    String? name,
    int? totalCreditHours,
    double? minGpaToGraduate,
    String? description,
    String? status,
    String? effectiveFrom,
    String? effectiveTo,
    String? defaultGradingScaleId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? departmentName,
    String? programName,
  }) {
    return StudyPlanModel(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      programId: programId ?? this.programId,
      academicYear: academicYear ?? this.academicYear,
      version: version ?? this.version,
      isCurrent: isCurrent ?? this.isCurrent,
      name: name ?? this.name,
      totalCreditHours: totalCreditHours ?? this.totalCreditHours,
      minGpaToGraduate: minGpaToGraduate ?? this.minGpaToGraduate,
      description: description ?? this.description,
      status: status ?? this.status,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      defaultGradingScaleId:
          defaultGradingScaleId ?? this.defaultGradingScaleId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      departmentName: departmentName ?? this.departmentName,
      programName: programName ?? this.programName,
    );
  }
}
