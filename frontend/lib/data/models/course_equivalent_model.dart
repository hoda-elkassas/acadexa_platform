// file: lib/data/models/course_equivalent_model.dart

class CourseEquivalentModel {
  const CourseEquivalentModel({
    this.id,
    required this.courseId,
    required this.equivalentCode,
    this.createdAt,
    // Joined display fields
    this.courseCode,
    this.courseName,
  });

  final String? id;
  final String courseId;
  final String equivalentCode;
  final DateTime? createdAt;
  final String? courseCode;
  final String? courseName;

  factory CourseEquivalentModel.fromJson(Map<String, dynamic> json) {
    final course = json['courses'];
    return CourseEquivalentModel(
      id: json['id'] as String?,
      courseId: json['course_id'] as String,
      equivalentCode: json['equivalent_code'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      courseCode: course is Map ? (course['code'] as String?) : null,
      courseName: course is Map ? (course['name_ar'] as String?) : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'course_id': courseId,
        'equivalent_code': equivalentCode,
      };

  Map<String, dynamic> toUpdateJson() => toInsertJson();

  CourseEquivalentModel copyWith({
    String? id,
    String? courseId,
    String? equivalentCode,
    DateTime? createdAt,
  }) {
    return CourseEquivalentModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      equivalentCode: equivalentCode ?? this.equivalentCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
