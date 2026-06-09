class ImportJob {
  final String id;
  final String filename;
  final String? departmentId;
  final String status;
  final int? totalStudents;
  final int? successful;
  final int? failed;
  final List<dynamic>? errorLog;
  final String? uploadedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ImportJob({
    required this.id,
    required this.filename,
    this.departmentId,
    required this.status,
    this.totalStudents,
    this.successful,
    this.failed,
    this.errorLog,
    this.uploadedBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory ImportJob.fromJson(Map<String, dynamic> json) {
    return ImportJob(
      id: json['id'] as String,
      filename: json['filename'] as String,
      departmentId: json['department_id'] as String?,
      status: json['status'] as String,
      totalStudents: json['total_students'] as int?,
      successful: json['successful'] as int?,
      failed: json['failed'] as int?,
      errorLog: json['error_log'] as List<dynamic>?,
      uploadedBy: json['uploaded_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
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
        'error_log': errorLog,
        'uploaded_by': uploadedBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  ImportJob copyWith({
    String? id,
    String? filename,
    String? departmentId,
    String? status,
    int? totalStudents,
    int? successful,
    int? failed,
    List<dynamic>? errorLog,
    String? uploadedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ImportJob(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      departmentId: departmentId ?? this.departmentId,
      status: status ?? this.status,
      totalStudents: totalStudents ?? this.totalStudents,
      successful: successful ?? this.successful,
      failed: failed ?? this.failed,
      errorLog: errorLog ?? this.errorLog,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
