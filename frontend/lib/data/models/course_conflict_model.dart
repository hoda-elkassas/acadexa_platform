// file: lib/data/models/course_conflict_model.dart

class CourseConflictModel {
  const CourseConflictModel({
    this.id,
    required this.courseId,
    required this.conflictingCourseId,
    this.createdAt,
    // Joined display fields
    this.courseCode,
    this.courseName,
    this.conflictingCourseCode,
    this.conflictingCourseName,
  });

  final String? id;
  final String courseId;
  final String conflictingCourseId;
  final DateTime? createdAt;
  final String? courseCode;
  final String? courseName;
  final String? conflictingCourseCode;
  final String? conflictingCourseName;

  factory CourseConflictModel.fromJson(Map<String, dynamic> json) {
    final course = json['course'];
    final conflict = json['conflicting_course'];
    return CourseConflictModel(
      id: json['id'] as String?,
      courseId: json['course_id'] as String,
      conflictingCourseId: json['conflicting_course_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      courseCode: course is Map ? (course['code'] as String?) : null,
      courseName: course is Map ? (course['name_ar'] as String?) : null,
      conflictingCourseCode:
          conflict is Map ? (conflict['code'] as String?) : null,
      conflictingCourseName:
          conflict is Map ? (conflict['name_ar'] as String?) : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'course_id': courseId,
        'conflicting_course_id': conflictingCourseId,
      };

  Map<String, dynamic> toUpdateJson() => toInsertJson();

  CourseConflictModel copyWith({
    String? id,
    String? courseId,
    String? conflictingCourseId,
    DateTime? createdAt,
  }) {
    return CourseConflictModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      conflictingCourseId: conflictingCourseId ?? this.conflictingCourseId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
