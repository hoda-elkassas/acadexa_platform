// file: lib/data/models/special_grade_symbol_model.dart

class SpecialGradeSymbolModel {
  const SpecialGradeSymbolModel({
    this.id,
    required this.planId,
    required this.symbol,
    required this.nameAr,
    this.description,
    this.affectsGpa = false,
    this.createdAt,
  });

  final String? id;
  final String planId;
  final String symbol;
  final String nameAr;
  final String? description;
  final bool affectsGpa;
  final DateTime? createdAt;

  factory SpecialGradeSymbolModel.fromJson(Map<String, dynamic> json) {
    return SpecialGradeSymbolModel(
      id: json['id'] as String?,
      planId: json['plan_id'] as String,
      symbol: json['symbol'] as String,
      nameAr: json['name_ar'] as String,
      description: json['description'] as String?,
      affectsGpa: (json['affects_gpa'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'plan_id': planId,
        'symbol': symbol,
        'name_ar': nameAr,
        if (description != null) 'description': description,
        'affects_gpa': affectsGpa,
      };

  Map<String, dynamic> toUpdateJson() => {
        'symbol': symbol,
        'name_ar': nameAr,
        'description': description,
        'affects_gpa': affectsGpa,
      };

  SpecialGradeSymbolModel copyWith({
    String? id,
    String? planId,
    String? symbol,
    String? nameAr,
    String? description,
    bool? affectsGpa,
    DateTime? createdAt,
  }) {
    return SpecialGradeSymbolModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      symbol: symbol ?? this.symbol,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      affectsGpa: affectsGpa ?? this.affectsGpa,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
