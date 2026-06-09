import 'analysis_issue.dart';
import 'analysis_recommendation.dart';

class AnalysisResult {
  final String id;
  final String studentId;
  final double gpa;
  final int passedHours;
  final int attemptedHours;
  final double graduationPercentage;
  final bool isLatest;
  final DateTime createdAt;
  final List<AnalysisIssue> issues;
  final List<AnalysisRecommendation> recommendations;

  const AnalysisResult({
    required this.id,
    required this.studentId,
    required this.gpa,
    required this.passedHours,
    required this.attemptedHours,
    required this.graduationPercentage,
    required this.isLatest,
    required this.createdAt,
    this.issues = const [],
    this.recommendations = const [],
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0.0,
      passedHours: json['passed_hours'] as int? ?? 0,
      attemptedHours: json['attempted_hours'] as int? ?? 0,
      graduationPercentage: (json['graduation_percentage'] as num?)?.toDouble() ?? 0.0,
      isLatest: json['is_latest'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      issues: (json['issues'] as List<dynamic>?)
              ?.map((e) => AnalysisIssue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => AnalysisRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'gpa': gpa,
        'passed_hours': passedHours,
        'attempted_hours': attemptedHours,
        'graduation_percentage': graduationPercentage,
        'is_latest': isLatest,
        'created_at': createdAt.toIso8601String(),
        'issues': issues.map((e) => e.toJson()).toList(),
        'recommendations': recommendations.map((e) => e.toJson()).toList(),
      };

  AnalysisResult copyWith({
    String? id,
    String? studentId,
    double? gpa,
    int? passedHours,
    int? attemptedHours,
    double? graduationPercentage,
    bool? isLatest,
    DateTime? createdAt,
    List<AnalysisIssue>? issues,
    List<AnalysisRecommendation>? recommendations,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      gpa: gpa ?? this.gpa,
      passedHours: passedHours ?? this.passedHours,
      attemptedHours: attemptedHours ?? this.attemptedHours,
      graduationPercentage: graduationPercentage ?? this.graduationPercentage,
      isLatest: isLatest ?? this.isLatest,
      createdAt: createdAt ?? this.createdAt,
      issues: issues ?? this.issues,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}
