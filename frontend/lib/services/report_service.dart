import 'dart:io';
import 'dart:typed_data';
import '../core/api_client.dart';

class ReportService {
  final ApiClient apiClient;

  ReportService({ApiClient? client}) : apiClient = client ?? ApiClient();

  /// Downloads the official transcript PDF for a student and returns the local file path.
  Future<String> downloadStudentTranscriptPDF(String studentId) async {
    final Uint8List bytes = await apiClient.download('/reports/student/$studentId/transcript');
    
    final Directory tempDir = Directory.systemTemp;
    final String path = '${tempDir.path}/transcript_$studentId.pdf';
    final File file = File(path);
    await file.writeAsBytes(bytes);
    
    return path;
  }

  /// Downloads the department summary in PDF or Excel format and returns the local file path.
  /// Format should be 'pdf' or 'excel'.
  Future<String> downloadDepartmentSummary(String departmentId, String format) async {
    final String fileFormat = format.toLowerCase() == 'excel' ? 'excel' : 'pdf';
    final String ext = fileFormat == 'excel' ? 'xlsx' : 'pdf';
    
    final Uint8List bytes = await apiClient.download(
      '/reports/department/$departmentId/summary',
      queryParams: {'file_format': fileFormat},
    );
    
    final Directory tempDir = Directory.systemTemp;
    final String path = '${tempDir.path}/dept_summary_$departmentId.$ext';
    final File file = File(path);
    await file.writeAsBytes(bytes);
    
    return path;
  }
}
