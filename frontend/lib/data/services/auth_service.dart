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
    final data = await _client
        .from('user_profiles')
        .select('id, role, full_name, department_id, student_id, created_at')
        .eq('id', userId)
        .single();

    return UserProfileModel.fromJson(data as Map<String, dynamic>);
  }
}
