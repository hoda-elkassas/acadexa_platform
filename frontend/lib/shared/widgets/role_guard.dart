// file: lib/shared/widgets/role_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_profile_model.dart';
import '../../features/auth/cubit/auth_cubit.dart';

/// Shows [child] only when the current user has one of [allowedRoles].
/// Renders [fallback] (default: empty) otherwise.
///
/// Example — show "Upload" button only for admin/advisor:
/// ```dart
/// RoleGuard(
///   allowedRoles: [AppRole.admin, AppRole.academicAdvisor],
///   child: ElevatedButton(onPressed: _upload, child: Text('رفع ملف')),
/// )
/// ```
class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  final List<AppRole> allowedRoles;
  final Widget child;

  /// Widget shown when user doesn't have the required role.
  /// Defaults to [SizedBox.shrink] (invisible).
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, AppRole?>(
      selector: (state) =>
          state is AuthAuthenticated ? state.profile.role : null,
      builder: (context, role) {
        if (role != null && allowedRoles.contains(role)) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Convenience: show only for admin.
class AdminOnly extends StatelessWidget {
  const AdminOnly({super.key, required this.child, this.fallback});
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) => RoleGuard(
        allowedRoles: const [AppRole.admin],
        fallback: fallback,
        child: child,
      );
}

/// Convenience: show for admin + academic_advisor.
class AdvisorAndAbove extends StatelessWidget {
  const AdvisorAndAbove({super.key, required this.child, this.fallback});
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) => RoleGuard(
        allowedRoles: const [AppRole.admin, AppRole.academicAdvisor],
        fallback: fallback,
        child: child,
      );
}

/// Convenience: show for all except regular user.
class StaffOnly extends StatelessWidget {
  const StaffOnly({super.key, required this.child, this.fallback});
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) => RoleGuard(
        allowedRoles: const [
          AppRole.admin,
          AppRole.academicAdvisor,
          AppRole.dashboardViewer,
        ],
        fallback: fallback,
        child: child,
      );
}
