class ImportJobStatus {
  final String id;
  final String filename;
  final String? departmentId;
  final String status;
  final int totalStudents;
  final int successful;
  final int failed;
  final double progressPercentage;
  final List<String> errorLog;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ImportJobStatus({
    required this.id,
    required this.filename,
    this.departmentId,
    required this.status,
    required this.totalStudents,
    required this.successful,
    required this.failed,
    required this.progressPercentage,
    required this.errorLog,
    this.createdAt,
    this.updatedAt,
  });

  factory ImportJobStatus.fromJson(Map<String, dynamic> json) {
    return ImportJobStatus(
      id: json['id'] as String,
      filename: json['filename'] as String,
      departmentId: json['department_id'] as String?,
      status: json['status'] as String,
      totalStudents: json['total_students'] as int? ?? 0,
      successful: json['successful'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      errorLog: (json['error_log'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'department_id': departmentId,
        'status': status,
        'total_students': totalStudents,
        'successful': successful,
        'failed': failed,
        'progress_percentage': progressPercentage,
        'error_log': errorLog,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  ImportJobStatus copyWith({
    String? id,
    String? filename,
    String? departmentId,
    String? status,
    int? totalStudents,
    int? successful,
    int? failed,
    double? progressPercentage,
    List<String>? errorLog,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ImportJobStatus(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      departmentId: departmentId ?? this.departmentId,
      status: status ?? this.status,
      totalStudents: totalStudents ?? this.totalStudents,
      successful: successful ?? this.successful,
      failed: failed ?? this.failed,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      errorLog: errorLog ?? this.errorLog,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
