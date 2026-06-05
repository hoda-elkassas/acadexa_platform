// file: lib/data/models/field_training_rules_model.dart

class FieldTrainingRulesModel {
  const FieldTrainingRulesModel({
    this.id,
    required this.planId,
    this.trainingLevels = 4,
    this.hoursPerLevel = 2,
    this.externalSupervisorWeight = 20.0,
    this.internalSupervisorWeight = 20.0,
    this.remoteSupervisorWeight = 20.0,
    this.finalExamWeight = 40.0,
    this.allowShiftLevel1_2 = false,
    this.allowShiftLevel3_4 = false,
    this.mandatoryForGraduation = true,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String planId;
  final int? trainingLevels;
  final int? hoursPerLevel;
  final double? externalSupervisorWeight;
  final double? internalSupervisorWeight;
  final double? remoteSupervisorWeight;
  final double? finalExamWeight;
  final bool? allowShiftLevel1_2;
  final bool? allowShiftLevel3_4;
  final bool? mandatoryForGraduation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory FieldTrainingRulesModel.fromJson(Map<String, dynamic> json) {
    return FieldTrainingRulesModel(
      id: json['id'] as String?,
      planId: json['plan_id'] as String,
      trainingLevels: json['training_levels'] as int?,
      hoursPerLevel: json['hours_per_level'] as int?,
      externalSupervisorWeight:
          (json['external_supervisor_weight'] as num?)?.toDouble(),
      internalSupervisorWeight:
          (json['internal_supervisor_weight'] as num?)?.toDouble(),
      remoteSupervisorWeight:
          (json['remote_supervisor_weight'] as num?)?.toDouble(),
      finalExamWeight: (json['final_exam_weight'] as num?)?.toDouble(),
      allowShiftLevel1_2: json['allow_shift_level_1_2'] as bool?,
      allowShiftLevel3_4: json['allow_shift_level_3_4'] as bool?,
      mandatoryForGraduation: json['mandatory_for_graduation'] as bool?,
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
        'training_levels': trainingLevels,
        'hours_per_level': hoursPerLevel,
        'external_supervisor_weight': externalSupervisorWeight,
        'internal_supervisor_weight': internalSupervisorWeight,
        'remote_supervisor_weight': remoteSupervisorWeight,
        'final_exam_weight': finalExamWeight,
        'allow_shift_level_1_2': allowShiftLevel1_2,
        'allow_shift_level_3_4': allowShiftLevel3_4,
        'mandatory_for_graduation': mandatoryForGraduation,
      };

  Map<String, dynamic> toUpdateJson() => {
        'training_levels': trainingLevels,
        'hours_per_level': hoursPerLevel,
        'external_supervisor_weight': externalSupervisorWeight,
        'internal_supervisor_weight': internalSupervisorWeight,
        'remote_supervisor_weight': remoteSupervisorWeight,
        'final_exam_weight': finalExamWeight,
        'allow_shift_level_1_2': allowShiftLevel1_2,
        'allow_shift_level_3_4': allowShiftLevel3_4,
        'mandatory_for_graduation': mandatoryForGraduation,
      };

  FieldTrainingRulesModel copyWith({
    String? id,
    String? planId,
    int? trainingLevels,
    int? hoursPerLevel,
    double? externalSupervisorWeight,
    double? internalSupervisorWeight,
    double? remoteSupervisorWeight,
    double? finalExamWeight,
    bool? allowShiftLevel1_2,
    bool? allowShiftLevel3_4,
    bool? mandatoryForGraduation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FieldTrainingRulesModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      trainingLevels: trainingLevels ?? this.trainingLevels,
      hoursPerLevel: hoursPerLevel ?? this.hoursPerLevel,
      externalSupervisorWeight:
          externalSupervisorWeight ?? this.externalSupervisorWeight,
      internalSupervisorWeight:
          internalSupervisorWeight ?? this.internalSupervisorWeight,
      remoteSupervisorWeight:
          remoteSupervisorWeight ?? this.remoteSupervisorWeight,
      finalExamWeight: finalExamWeight ?? this.finalExamWeight,
      allowShiftLevel1_2: allowShiftLevel1_2 ?? this.allowShiftLevel1_2,
      allowShiftLevel3_4: allowShiftLevel3_4 ?? this.allowShiftLevel3_4,
      mandatoryForGraduation:
          mandatoryForGraduation ?? this.mandatoryForGraduation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
