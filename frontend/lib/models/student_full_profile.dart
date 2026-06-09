import 'analysis_result.dart';
import 'analysis_issue.dart';
import 'analysis_recommendation.dart';

class SemesterWithCourses {
  final Map<String, dynamic> semester;
  final List<Map<String, dynamic>> courses;
  final double? semesterGpa;

  const SemesterWithCourses({
    required this.semester,
    this.courses = const [],
    this.semesterGpa,
  });

  factory SemesterWithCourses.fromJson(Map<String, dynamic> json) {
    return SemesterWithCourses(
      semester: json['semester'] as Map<String, dynamic>? ?? const {},
      courses: (json['courses'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      semesterGpa: (json['semester_gpa'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'semester': semester,
        'courses': courses,
        if (semesterGpa != null) 'semester_gpa': semesterGpa,
      };

  SemesterWithCourses copyWith({
    Map<String, dynamic>? semester,
    List<Map<String, dynamic>>? courses,
    double? semesterGpa,
  }) {
    return SemesterWithCourses(
      semester: semester ?? this.semester,
      courses: courses ?? this.courses,
      semesterGpa: semesterGpa ?? this.semesterGpa,
    );
  }
}

class StudentFullProfile {
  final Map<String, dynamic> student;
  final List<SemesterWithCourses> semesters;
  final AnalysisResult? latestAnalysis;
  final List<AnalysisIssue> issues;
  final List<AnalysisRecommendation> recommendations;
  final List<Map<String, dynamic>> advisorNotes;

  const StudentFullProfile({
    required this.student,
    this.semesters = const [],
    this.latestAnalysis,
    this.issues = const [],
    this.recommendations = const [],
    this.advisorNotes = const [],
  });

  factory StudentFullProfile.fromJson(Map<String, dynamic> json) {
    return StudentFullProfile(
      student: json['student'] as Map<String, dynamic>? ?? const {},
      semesters: (json['semesters'] as List<dynamic>?)
              ?.map((e) => SemesterWithCourses.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      latestAnalysis: json['latest_analysis'] != null
          ? AnalysisResult.fromJson(json['latest_analysis'] as Map<String, dynamic>)
          : null,
      issues: (json['issues'] as List<dynamic>?)
              ?.map((e) => AnalysisIssue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => AnalysisRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      advisorNotes: (json['advisor_notes'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'student': student,
        'semesters': semesters.map((e) => e.toJson()).toList(),
        if (latestAnalysis != null) 'latest_analysis': latestAnalysis!.toJson(),
        'issues': issues.map((e) => e.toJson()).toList(),
        'recommendations': recommendations.map((e) => e.toJson()).toList(),
        'advisor_notes': advisorNotes,
      };

  StudentFullProfile copyWith({
    Map<String, dynamic>? student,
    List<SemesterWithCourses>? semesters,
    AnalysisResult? latestAnalysis,
    List<AnalysisIssue>? issues,
    List<AnalysisRecommendation>? recommendations,
    List<Map<String, dynamic>>? advisorNotes,
  }) {
    return StudentFullProfile(
      student: student ?? this.student,
      semesters: semesters ?? this.semesters,
      latestAnalysis: latestAnalysis ?? this.latestAnalysis,
      issues: issues ?? this.issues,
      recommendations: recommendations ?? this.recommendations,
      advisorNotes: advisorNotes ?? this.advisorNotes,
    );
  }
}
