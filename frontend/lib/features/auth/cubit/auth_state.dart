// file: lib/features/auth/cubit/auth_state.dart
part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// App just launched, haven't checked session yet.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Checking session / signing in / signing out.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is logged in with a verified role profile.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.profile});
  final UserProfileModel profile;

  @override
  List<Object?> get props => [profile.id, profile.role];
}

/// No active session.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Sign-in failed or profile fetch failed.
final class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
