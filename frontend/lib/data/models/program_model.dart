// file: lib/data/models/program_model.dart

class ProgramModel {
  const ProgramModel({
    this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    this.programType = 'regular',
    this.departmentId,
    this.isActive = true,
    this.description,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String code;
  final String nameAr;
  final String nameEn;
  final String programType;
  final String? departmentId;
  final bool isActive;
  final String? description;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] as String?,
      code: json['code'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      programType: (json['program_type'] as String?) ?? 'regular',
      departmentId: json['department_id'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      description: json['description'] as String?,
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
        'code': code,
        'name_ar': nameAr,
        'name_en': nameEn,
        'program_type': programType,
        if (departmentId != null) 'department_id': departmentId,
        'is_active': isActive,
        if (description != null) 'description': description,
        if (createdBy != null) 'created_by': createdBy,
      };

  Map<String, dynamic> toUpdateJson() => {
        'code': code,
        'name_ar': nameAr,
        'name_en': nameEn,
        'program_type': programType,
        'department_id': departmentId,
        'is_active': isActive,
        'description': description,
      };

  ProgramModel copyWith({
    String? id,
    String? code,
    String? nameAr,
    String? nameEn,
    String? programType,
    String? departmentId,
    bool? isActive,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      code: code ?? this.code,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      programType: programType ?? this.programType,
      departmentId: departmentId ?? this.departmentId,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
