import 'dart:io';
import '../core/api_client.dart';
import '../models/import_job.dart';
import '../models/import_job_status.dart';

class UploadService {
  final ApiClient apiClient;

  UploadService({ApiClient? client}) : apiClient = client ?? ApiClient();

  /// Upload an academic record Excel file and return the initial job status
  Future<ImportJobStatus> uploadAcademicRecord(File file, String departmentId) async {
    final response = await apiClient.uploadFile(
      '/upload/academic-record',
      file,
      {'department_id': departmentId},
    );

    final jobId = response['import_job_id'] as String;
    return getImportJobStatus(jobId);
  }

  /// Fetch the detailed status of a specific import job
  Future<ImportJobStatus> getImportJobStatus(String jobId) async {
    final response = await apiClient.get('/upload/status/$jobId');
    return ImportJobStatus.fromJson(response);
  }

  /// Exposes a stream that polls the import job status every 2 seconds
  /// until it completes or fails
  Stream<ImportJobStatus> pollImportStatus(String jobId) async* {
    while (true) {
      try {
        final status = await getImportJobStatus(jobId);
        yield status;
        if (status.status == 'completed' || status.status == 'failed') {
          break;
        }
      } catch (e) {
        yield* Stream.error(e);
        break;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /// Retrieves the history list of upload/import jobs
  Future<List<ImportJob>> getUploadHistory() async {
    final response = await apiClient.get('/upload/history');
    final dataList = response['data'] as List<dynamic>? ?? const [];
    return dataList.map((e) => ImportJob.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Deletes a completed/failed import job record
  Future<bool> deleteImportJob(String jobId) async {
    try {
      await apiClient.delete('/upload/$jobId');
      return true;
    } catch (e) {
      return false;
    }
  }
}
