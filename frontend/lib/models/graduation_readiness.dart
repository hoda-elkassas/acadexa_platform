class GraduationCheckItem {
  final String ruleName;
  final bool status; // true (met), false (unmet)
  final String details;

  const GraduationCheckItem({
    required this.ruleName,
    required this.status,
    required this.details,
  });

  factory GraduationCheckItem.fromJson(Map<String, dynamic> json) {
    return GraduationCheckItem(
      ruleName: json['rule_name'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      details: json['details'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'rule_name': ruleName,
        'status': status,
        'details': details,
      };

  GraduationCheckItem copyWith({
    String? ruleName,
    bool? status,
    String? details,
  }) {
    return GraduationCheckItem(
      ruleName: ruleName ?? this.ruleName,
      status: status ?? this.status,
      details: details ?? this.details,
    );
  }
}

class GraduationReadiness {
  final String studentId;
  final bool isReady;
  final int passedHours;
  final int requiredHours;
  final double gpa;
  final double requiredGpa;
  final List<GraduationCheckItem> checklist;

  const GraduationReadiness({
    required this.studentId,
    required this.isReady,
    required this.passedHours,
    required this.requiredHours,
    required this.gpa,
    required this.requiredGpa,
    this.checklist = const [],
  });

  factory GraduationReadiness.fromJson(Map<String, dynamic> json) {
    return GraduationReadiness(
      studentId: json['student_id'] as String? ?? '',
      isReady: json['is_ready'] as bool? ?? false,
      passedHours: json['passed_hours'] as int? ?? 0,
      requiredHours: json['required_hours'] as int? ?? 0,
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0.0,
      requiredGpa: (json['required_gpa'] as num?)?.toDouble() ?? 0.0,
      checklist: (json['checklist'] as List<dynamic>?)
              ?.map((e) => GraduationCheckItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'is_ready': isReady,
        'passed_hours': passedHours,
        'required_hours': requiredHours,
        'gpa': gpa,
        'required_gpa': requiredGpa,
        'checklist': checklist.map((e) => e.toJson()).toList(),
      };

  GraduationReadiness copyWith({
    String? studentId,
    bool? isReady,
    int? passedHours,
    int? requiredHours,
    double? gpa,
    double? requiredGpa,
    List<GraduationCheckItem>? checklist,
  }) {
    return GraduationReadiness(
      studentId: studentId ?? this.studentId,
      isReady: isReady ?? this.isReady,
      passedHours: passedHours ?? this.passedHours,
      requiredHours: requiredHours ?? this.requiredHours,
      gpa: gpa ?? this.gpa,
      requiredGpa: requiredGpa ?? this.requiredGpa,
      checklist: checklist ?? this.checklist,
    );
  }
}
