class AnalysisRecommendation {
  final String? id;
  final String analysisId;
  final String courseCode;
  final String courseName;
  final int priority; // 1 (high), 2 (medium), 3 (low)
  final String reason;

  const AnalysisRecommendation({
    this.id,
    required this.analysisId,
    required this.courseCode,
    required this.courseName,
    required this.priority,
    required this.reason,
  });

  factory AnalysisRecommendation.fromJson(Map<String, dynamic> json) {
    return AnalysisRecommendation(
      id: json['id'] as String?,
      analysisId: json['analysis_id'] as String,
      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      priority: json['priority'] as int? ?? 1,
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'analysis_id': analysisId,
        'course_code': courseCode,
        'course_name': courseName,
        'priority': priority,
        'reason': reason,
      };

  AnalysisRecommendation copyWith({
    String? id,
    String? analysisId,
    String? courseCode,
    String? courseName,
    int? priority,
    String? reason,
  }) {
    return AnalysisRecommendation(
      id: id ?? this.id,
      analysisId: analysisId ?? this.analysisId,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      priority: priority ?? this.priority,
      reason: reason ?? this.reason,
    );
  }
}
