// file: lib/data/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  // ── Sign in ─────────────────────────────────────────────────────────────
  /// Signs in with email/password and returns the user's profile (with role).
  /// Throws [AuthException] or [PostgrestException] on failure.
  Future<UserProfileModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.');
    }

    return _fetchProfile(user.id);
  }

  // ── Sign out ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Current session ──────────────────────────────────────────────────────
  /// Returns the profile of the currently logged-in user, or null.
  Future<UserProfileModel?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      return await _fetchProfile(user.id);
    } catch (_) {
      return null;
    }
  }

  /// Whether there is an active session right now.
  bool get isLoggedIn => _client.auth.currentSession != null;

  /// The raw Supabase JWT access token (for sending to FastAPI backend).
  String? get accessToken => _client.auth.currentSession?.accessToken;

  // ── Internal ─────────────────────────────────────────────────────────────
  Future<UserProfileModel> _fetchProfile(String userId) async {
    // Try app_users table first (primary source of truth)
    try {
      final data = await _client
          .from('app_users')
          .select('id, email, full_name, role, department_id, is_active, system_role, is_system_user, created_at, updated_at')
          .eq('id', userId)
          .single();

      // Check if the account is active
      final isActive = data['is_active'] as bool? ?? true;
      if (!isActive) {
        // Sign out the inactive user
        await _client.auth.signOut();
        throw const AuthException(
          'الحساب غير نشط. يرجى التواصل مع مسؤول النظام.',
        );
      }

      return UserProfileModel.fromJson(data);
    } catch (e) {
      // Re-throw AuthException (inactive account) immediately
      if (e is AuthException) rethrow;

      // Fallback: try v_users_with_roles view
      try {
        final data = await _client
            .from('v_users_with_roles')
            .select('*')
            .eq('id', userId)
            .single();

        // Check is_active from view as well
        final isActive = data['is_active'] as bool? ?? true;
        if (!isActive) {
          await _client.auth.signOut();
          throw const AuthException(
            'الحساب غير نشط. يرجى التواصل مع مسؤول النظام.',
          );
        }

        return UserProfileModel.fromJson(data);
      } catch (e2) {
        if (e2 is AuthException) rethrow;

        // Last resort: create a minimal model from auth metadata
        final user = _client.auth.currentUser;
        final role = user?.userMetadata?['role']?.toString();
        return UserProfileModel(
          id: userId,
          role: AppRole.fromString(role),
          fullName: user?.userMetadata?['full_name']?.toString() ?? user?.email,
        );
      }
    }
  }
}
