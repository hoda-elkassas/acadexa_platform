// file: lib/data/services/base_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base service providing shared Supabase client and helpers.
abstract class BaseService {
  SupabaseClient get client => Supabase.instance.client;

  /// Paginated select helper.
  /// Returns [from, to] range for Supabase .range() call.
  ({int from, int to}) pageRange(int page, int pageSize) {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;
    return (from: from, to: to);
  }

  /// Wraps Supabase calls with consistent error handling.
  Future<T> safeCall<T>(Future<T> Function() fn, {String? context}) async {
    try {
      return await fn();
    } on PostgrestException catch (e) {
      throw ServiceException(
        message: e.message,
        code: e.code,
        context: context,
      );
    } on AuthException catch (e) {
      throw ServiceException(
        message: e.message,
        code: 'AUTH_ERROR',
        context: context,
      );
    } catch (e) {
      throw ServiceException(
        message: e.toString(),
        code: 'UNKNOWN',
        context: context,
      );
    }
  }
}

/// Structured exception for service layer errors.
class ServiceException implements Exception {
  const ServiceException({
    required this.message,
    this.code,
    this.context,
  });

  final String message;
  final String? code;
  final String? context;

  @override
  String toString() =>
      'ServiceException(${context ?? ""}): [$code] $message';
}
