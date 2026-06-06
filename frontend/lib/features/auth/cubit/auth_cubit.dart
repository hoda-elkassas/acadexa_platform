// file: lib/features/auth/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/services/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  final _authService = AuthService();

  // ── Initialize (called on app start / splash) ─────────────────────────
  /// Checks if there's already an active session and loads the profile.
  Future<void> initialize() async {
    emit(const AuthLoading());
    try {
      final profile = await _authService.getCurrentProfile();
      if (profile != null) {
        emit(AuthAuthenticated(profile: profile));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  // ── Sign in ──────────────────────────────────────────────────────────
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final profile = await _authService.signIn(email: email, password: password);
      emit(AuthAuthenticated(profile: profile));
    } on Exception catch (e) {
      String message = _mapError(e.toString());
      emit(AuthError(message: message));
    }
  }

  // ── Sign out ─────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _authService.signOut();
    emit(const AuthUnauthenticated());
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  AppRole? get currentRole {
    final s = state;
    if (s is AuthAuthenticated) return s.profile.role;
    return null;
  }

  bool get isLoggedIn => state is AuthAuthenticated;

  String? get accessToken => _authService.accessToken;

  String _mapError(String raw) {
    if (raw.contains('Invalid login credentials') ||
        raw.contains('invalid_credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (raw.contains('Email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني أولاً';
    }
    if (raw.contains('Too many requests') || raw.contains('rate limit')) {
      return 'محاولات كثيرة جداً. يرجى الانتظار قليلاً';
    }
    if (raw.contains('network') || raw.contains('SocketException')) {
      return 'خطأ في الاتصال. تحقق من الإنترنت';
    }
    if (raw.contains('user_profiles')) {
      return 'لم يتم تفعيل الحساب بعد. تواصل مع مسؤول النظام';
    }
    return 'حدث خطأ. يرجى المحاولة مرة أخرى';
  }
}
