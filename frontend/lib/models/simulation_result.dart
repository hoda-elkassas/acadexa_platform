class PlannedCourse {
  final String code;
  final int creditHours;
  final String grade;

  const PlannedCourse({
    required this.code,
    required this.creditHours,
    this.grade = 'A',
  });

  factory PlannedCourse.fromJson(Map<String, dynamic> json) {
    return PlannedCourse(
      code: json['code'] as String? ?? '',
      creditHours: json['credit_hours'] as int? ?? 3,
      grade: json['grade'] as String? ?? 'A',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'credit_hours': creditHours,
        'grade': grade,
      };

  PlannedCourse copyWith({
    String? code,
    int? creditHours,
    String? grade,
  }) {
    return PlannedCourse(
      code: code ?? this.code,
      creditHours: creditHours ?? this.creditHours,
      grade: grade ?? this.grade,
    );
  }
}

class SimulationResult {
  final double currentGpa;
  final double simulatedGpa;
  final int currentPassedHours;
  final int simulatedPassedHours;
  final String? statusChange;
  final List<String> warnings;

  const SimulationResult({
    required this.currentGpa,
    required this.simulatedGpa,
    required this.currentPassedHours,
    required this.simulatedPassedHours,
    this.statusChange,
    this.warnings = const [],
  });

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      currentGpa: (json['current_gpa'] as num?)?.toDouble() ?? 0.0,
      simulatedGpa: (json['simulated_gpa'] as num?)?.toDouble() ?? 0.0,
      currentPassedHours: json['current_passed_hours'] as int? ?? 0,
      simulatedPassedHours: json['simulated_passed_hours'] as int? ?? 0,
      statusChange: json['status_change'] as String?,
      warnings: (json['warnings'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'current_gpa': currentGpa,
        'simulated_gpa': simulatedGpa,
        'current_passed_hours': currentPassedHours,
        'simulated_passed_hours': simulatedPassedHours,
        if (statusChange != null) 'status_change': statusChange,
        'warnings': warnings,
      };

  SimulationResult copyWith({
    double? currentGpa,
    double? simulatedGpa,
    int? currentPassedHours,
    int? simulatedPassedHours,
    String? statusChange,
    List<String>? warnings,
  }) {
    return SimulationResult(
      currentGpa: currentGpa ?? this.currentGpa,
      simulatedGpa: simulatedGpa ?? this.simulatedGpa,
      currentPassedHours: currentPassedHours ?? this.currentPassedHours,
      simulatedPassedHours: simulatedPassedHours ?? this.simulatedPassedHours,
      statusChange: statusChange ?? this.statusChange,
      warnings: warnings ?? this.warnings,
    );
  }
}
