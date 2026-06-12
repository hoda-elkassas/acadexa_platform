import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;
import 'environment.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException ($statusCode): $message';
    }
    return 'ApiException: $message';
  }
}

class ApiClient {
  static final ApiClient instance = ApiClient();

  final String baseUrl;
  final SupabaseClient supabase;
  final Dio _dio;

  ApiClient({
    String? baseUrl,
    SupabaseClient? supabaseClient,
    Dio? dio,
  })  : baseUrl = _normalizeBaseUrl(baseUrl ?? Environment.apiBaseUrl),
        supabase = supabaseClient ?? Supabase.instance.client,
        _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.endsWith('/')
        ? value.substring(0, value.length - 1)
        : value;
    return trimmed.endsWith('/api/v1') ? trimmed : '$trimmed/api/v1';
  }

  String _url(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return path.startsWith('/') ? '$baseUrl$path' : '$baseUrl/$path';
  }

  /// Helper to get or refresh Supabase Auth Token
  Future<String> _getAuthToken() async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      throw ApiException(
        'لا توجد جلسة نشطة. يرجى تسجيل الدخول أولاً.',
        statusCode: 401,
      );
    }

    if (session.isExpired) {
      try {
        final response = await supabase.auth.refreshSession();
        final refreshedToken = response.session?.accessToken;
        if (refreshedToken == null) {
          throw ApiException(
            'انتهت صلاحية الجلسة وفشل تجديدها تلقائياً.',
            statusCode: 401,
          );
        }
        return refreshedToken;
      } catch (e) {
        throw ApiException(
          'فشل تجديد الجلسة: ${e.toString()}',
          statusCode: 401,
        );
      }
    }

    return session.accessToken;
  }

  /// Universal request wrapper with 3 retries and exponential backoff
  Future<Response<T>> _requestWithRetry<T>(
    Future<Response<T>> Function(Map<String, String> headers) requestFn,
  ) async {
    int retries = 3;
    int delayMs = 1000;

    while (true) {
      try {
        final token = await _getAuthToken();
        final headers = {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        };
        return await requestFn(headers);
      } on DioException catch (e) {
        final isNetworkError = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError;

        if (isNetworkError && retries > 0) {
          retries--;
          await Future.delayed(Duration(milliseconds: delayMs));
          delayMs *= 2;
          continue;
        }

        if (e.response != null) {
          _handleError(e.response!);
        }

        throw ApiException(
          'فشل الاتصال بالخادم. يرجى التحقق من الاتصال بالشبكة.',
          details: e.message,
        );
      } catch (e) {
        if (e is ApiException) {
          rethrow;
        }
        throw ApiException('حدث خطأ غير متوقع: ${e.toString()}');
      }
    }
  }

  /// Parses error responses to retrieve the detailed error message in Arabic
  void _handleError(Response response) {
    final data = response.data;
    String message = 'حدث خطأ غير متوقع أثناء معالجة الطلب.';
    dynamic details;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) {
          message = detail;
        } else if (detail is List) {
          // Parse validation errors
          message = detail
              .map((e) => '${e['loc']?.last ?? ''}: ${e['msg'] ?? ''}')
              .join('\n');
          details = detail;
        } else if (detail is Map) {
          message = detail['message']?.toString() ?? detail.toString();
          details = detail;
        }
      } else if (data.containsKey('message')) {
        message = data['message'].toString();
      }
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
      details: details,
    );
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final response = await _requestWithRetry(
      (headers) => _dio.get(
        _url(path),
        queryParameters: queryParams,
        options: Options(headers: headers),
      ),
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'data': response.data};
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _requestWithRetry(
      (headers) => _dio.post(
        _url(path),
        data: body,
        options: Options(headers: headers),
      ),
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'data': response.data};
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _requestWithRetry(
      (headers) => _dio.delete(
        _url(path),
        data: body,
        options: Options(headers: headers),
      ),
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'data': response.data};
  }

  /// Download file as Uint8List
  Future<Uint8List> download(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final response = await _requestWithRetry(
      (headers) => _dio.get<List<int>>(
        _url(path),
        queryParameters: queryParams,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
      ),
    );
    final bytes = response.data;
    if (bytes == null) {
      throw ApiException('الملف الذي تم تنزيله فارغ أو غير موجود.');
    }
    return Uint8List.fromList(bytes);
  }

  /// Upload file using multipart/form-data
  Future<Map<String, dynamic>> uploadFile(
    String path,
    File file,
    Map<String, String> fields,
  ) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      ...fields,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _requestWithRetry(
      (headers) => _dio.post(
        _url(path),
        data: formData,
        options: Options(
          headers: {
            ...headers,
            'Content-Type': 'multipart/form-data',
          },
        ),
      ),
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'data': response.data};
  }
}
