// file: lib/data/models/department_model.dart

class DepartmentModel {
  const DepartmentModel({
    this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    this.shortName,
    this.programId,
    this.isProgram = false,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String code;
  final String nameAr;
  final String nameEn;
  final String? shortName;
  final String? programId;
  final bool isProgram;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as String?,
      code: json['code'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      shortName: json['short_name'] as String?,
      programId: json['program_id'] as String?,
      isProgram: (json['is_program'] as bool?) ?? false,
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
        'code': code,
        'name_ar': nameAr,
        'name_en': nameEn,
        if (shortName != null) 'short_name': shortName,
        if (programId != null) 'program_id': programId,
        'is_program': isProgram,
        'is_active': isActive,
        if (createdBy != null) 'created_by': createdBy,
      };

  Map<String, dynamic> toUpdateJson() => {
        'code': code,
        'name_ar': nameAr,
        'name_en': nameEn,
        'short_name': shortName,
        'program_id': programId,
        'is_program': isProgram,
        'is_active': isActive,
      };

  DepartmentModel copyWith({
    String? id,
    String? code,
    String? nameAr,
    String? nameEn,
    String? shortName,
    String? programId,
    bool? isProgram,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      code: code ?? this.code,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      shortName: shortName ?? this.shortName,
      programId: programId ?? this.programId,
      isProgram: isProgram ?? this.isProgram,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
