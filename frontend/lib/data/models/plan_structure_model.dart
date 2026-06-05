// file: lib/data/models/plan_structure_model.dart

class PlanStructureModel {
  const PlanStructureModel({
    this.id,
    required this.planId,
    required this.level,
    required this.term,
    this.prescribedHours = 0,
    this.minHours = 12,
    this.maxHours = 20,
  });

  final String? id;
  final String planId;
  final int level;
  final String term; // fall, spring, summer
  final int prescribedHours;
  final int minHours;
  final int maxHours;

  factory PlanStructureModel.fromJson(Map<String, dynamic> json) {
    return PlanStructureModel(
      id: json['id'] as String?,
      planId: json['plan_id'] as String,
      level: json['level'] as int,
      term: json['term'] as String,
      prescribedHours: (json['prescribed_hours'] as int?) ?? 0,
      minHours: (json['min_hours'] as int?) ?? 12,
      maxHours: (json['max_hours'] as int?) ?? 20,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'plan_id': planId,
        'level': level,
        'term': term,
        'prescribed_hours': prescribedHours,
        'min_hours': minHours,
        'max_hours': maxHours,
      };

  Map<String, dynamic> toUpdateJson() => {
        'level': level,
        'term': term,
        'prescribed_hours': prescribedHours,
        'min_hours': minHours,
        'max_hours': maxHours,
      };

  PlanStructureModel copyWith({
    String? id,
    String? planId,
    int? level,
    String? term,
    int? prescribedHours,
    int? minHours,
    int? maxHours,
  }) {
    return PlanStructureModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      level: level ?? this.level,
      term: term ?? this.term,
      prescribedHours: prescribedHours ?? this.prescribedHours,
      minHours: minHours ?? this.minHours,
      maxHours: maxHours ?? this.maxHours,
    );
  }
}
