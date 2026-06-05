// file: lib/data/models/prerequisite_model.dart

class PrerequisiteModel {
  const PrerequisiteModel({
    this.id,
    required this.courseId,
    this.requiredCourseId,
    this.requiredCourseCode,
    this.logic = 'ALL',
    this.minGrade = 50,
    this.mustBePriorTerm = true,
    this.createdAt,
    // Joined display fields
    this.courseName,
    this.courseCode,
    this.requiredCourseName,
  });

  final String? id;
  final String courseId;
  final String? requiredCourseId;
  final String? requiredCourseCode;
  final String logic; // ALL, ANY
  final int minGrade;
  final bool mustBePriorTerm;
  final DateTime? createdAt;

  // Joined fields
  final String? courseName;
  final String? courseCode;
  final String? requiredCourseName;

  factory PrerequisiteModel.fromJson(Map<String, dynamic> json) {
    final course = json['courses'];
    final reqCourse = json['required_course'];
    return PrerequisiteModel(
      id: json['id'] as String?,
      courseId: json['course_id'] as String,
      requiredCourseId: json['required_course_id'] as String?,
      requiredCourseCode: json['required_course_code'] as String?,
      logic: (json['logic'] as String?) ?? 'ALL',
      minGrade: (json['min_grade'] as int?) ?? 50,
      mustBePriorTerm: (json['must_be_prior_term'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      courseName: course is Map ? (course['name_ar'] as String?) : null,
      courseCode: course is Map ? (course['code'] as String?) : null,
      requiredCourseName:
          reqCourse is Map ? (reqCourse['name_ar'] as String?) : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'course_id': courseId,
        if (requiredCourseId != null) 'required_course_id': requiredCourseId,
        if (requiredCourseCode != null)
          'required_course_code': requiredCourseCode,
        'logic': logic,
        'min_grade': minGrade,
        'must_be_prior_term': mustBePriorTerm,
      };

  Map<String, dynamic> toUpdateJson() => toInsertJson();

  PrerequisiteModel copyWith({
    String? id,
    String? courseId,
    String? requiredCourseId,
    String? requiredCourseCode,
    String? logic,
    int? minGrade,
    bool? mustBePriorTerm,
    DateTime? createdAt,
    String? courseName,
    String? courseCode,
    String? requiredCourseName,
  }) {
    return PrerequisiteModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      requiredCourseId: requiredCourseId ?? this.requiredCourseId,
      requiredCourseCode: requiredCourseCode ?? this.requiredCourseCode,
      logic: logic ?? this.logic,
      minGrade: minGrade ?? this.minGrade,
      mustBePriorTerm: mustBePriorTerm ?? this.mustBePriorTerm,
      createdAt: createdAt ?? this.createdAt,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      requiredCourseName: requiredCourseName ?? this.requiredCourseName,
    );
  }
}
