class AnalysisIssue {
  final String? id;
  final String analysisId;
  final String ruleCode;
  final String severity; // error | warning | info
  final String title;
  final String description;
  final String? suggestion;

  const AnalysisIssue({
    this.id,
    required this.analysisId,
    required this.ruleCode,
    required this.severity,
    required this.title,
    required this.description,
    this.suggestion,
  });

  factory AnalysisIssue.fromJson(Map<String, dynamic> json) {
    return AnalysisIssue(
      id: json['id'] as String?,
      analysisId: json['analysis_id'] as String,
      ruleCode: json['rule_code'] as String,
      severity: json['severity'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      suggestion: json['suggestion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'analysis_id': analysisId,
        'rule_code': ruleCode,
        'severity': severity,
        'title': title,
        'description': description,
        if (suggestion != null) 'suggestion': suggestion,
      };

  AnalysisIssue copyWith({
    String? id,
    String? analysisId,
    String? ruleCode,
    String? severity,
    String? title,
    String? description,
    String? suggestion,
  }) {
    return AnalysisIssue(
      id: id ?? this.id,
      analysisId: analysisId ?? this.analysisId,
      ruleCode: ruleCode ?? this.ruleCode,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      suggestion: suggestion ?? this.suggestion,
    );
  }
}
