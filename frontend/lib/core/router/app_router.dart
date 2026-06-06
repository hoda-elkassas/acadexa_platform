// file: lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';

// ─── Route names ─────────────────────────────────────────────────────────
abstract class AppRoutes {
  static const splash          = '/';
  static const login           = '/login';
  static const forgotPassword  = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword   = '/reset-password';
  // Role dashboards
  static const studentDashboard  = '/student';
  static const advisorDashboard  = '/advisor';
  static const adminDashboard    = '/admin';
  static const dashboardViewer   = '/dashboard';
  // Other
  static const courseDetail      = '/course/:id';
  static const studentProfile    = '/student/profile';
  static const adviseeDetail     = '/advisor/advisee/:id';
  static const settings          = '/settings';
  static const error             = '/error';
  static const notFound          = '/404';
}

// ─── Route arguments ─────────────────────────────────────────────────────
class OtpArgs {
  const OtpArgs({required this.email});
  final String email;
}

class CourseDetailArgs {
  const CourseDetailArgs({required this.courseId, required this.courseName});
  final String courseId;
  final String courseName;
}

class AdviseeDetailArgs {
  const AdviseeDetailArgs({required this.adviseeId, required this.adviseeName});
  final String adviseeId;
  final String adviseeName;
}

// ─── AppRouter ───────────────────────────────────────────────────────────
class AppRouter {
  /// Maps a DB role string → the correct home route.
  static String dashboardRouteForRole(String? role) {
    switch (role) {
      case 'admin':
        return AppRoutes.adminDashboard;
      case 'academic_advisor':
        return AppRoutes.advisorDashboard;
      case 'dashboard_viewer':
        return AppRoutes.dashboardViewer;
      case 'user':
      default:
        return AppRoutes.studentDashboard;
    }
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      // ── Splash: check session → route by role ───────────────────────────
      case AppRoutes.splash:
        return _fadeRoute(
          Builder(
            builder: (context) => SplashScreen(
              onInitComplete: () async {
                final session = Supabase.instance.client.auth.currentSession;
                if (session == null) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  return;
                }
                try {
                  final profile = await Supabase.instance.client
                      .from('user_profiles')
                      .select('role')
                      .eq('id', session.user.id)
                      .single();
                  final role = profile['role'] as String?;
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(
                      dashboardRouteForRole(role),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  }
                }
              },
            ),
          ),
          settings,
        );

      // ── Login: authenticate → fetch role → route ────────────────────────
      case AppRoutes.login:
        return _slideRoute(
          Builder(
            builder: (context) => LoginScreen(
              onLogin: ({
                required email,
                required password,
                required rememberMe,
              }) async {
                final response = await Supabase.instance.client.auth
                    .signInWithPassword(email: email, password: password);
                final user = response.user;
                if (user == null || !context.mounted) return;
                try {
                  final profile = await Supabase.instance.client
                      .from('user_profiles')
                      .select('role')
                      .eq('id', user.id)
                      .single();
                  final role = profile['role'] as String?;
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(
                      dashboardRouteForRole(role),
                    );
                  }
                } catch (_) {
                  throw Exception(
                    'لم يتم تفعيل الحساب بعد. تواصل مع مسؤول النظام',
                  );
                }
              },
              onForgotPassword: () {
                Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
              },
            ),
          ),
          settings,
        );

      case AppRoutes.forgotPassword:
        return _slideRoute(
          Builder(
            builder: (context) => ForgotPasswordScreen(
              onSendCode: (email) async {
                Navigator.of(context).pushNamed(
                  AppRoutes.otpVerification,
                  arguments: OtpArgs(email: email),
                );
              },
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          settings,
        );

      case AppRoutes.otpVerification:
        final args =
            settings.arguments as OtpArgs? ?? const OtpArgs(email: '');
        return _slideRoute(
          Builder(
            builder: (context) => OtpVerificationScreen(
              email: args.email,
              onVerify: (otp) async {
                Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.resetPassword);
              },
              onResend: () async {},
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          settings,
        );

      case AppRoutes.resetPassword:
        return _slideRoute(
          Builder(
            builder: (context) => ResetPasswordScreen(
              onReset: ({required newPassword, required confirmPassword}) async {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
          settings,
        );

      // ── Role dashboards ─────────────────────────────────────────────────
      // All currently show DashboardScreen.
      // Swap each case with a dedicated screen as you build them out.
      case AppRoutes.adminDashboard:
      case AppRoutes.advisorDashboard:
      case AppRoutes.dashboardViewer:
      case AppRoutes.studentDashboard:
        return _fadeRoute(const DashboardScreen(), settings);

      default:
        return _slideRoute(
          Scaffold(
            appBar: AppBar(title: const Text('404 – غير موجود')),
            body: const Center(child: Text('الصفحة المطلوبة غير موجودة.')),
          ),
          settings,
        );
    }
  }

  // ── Transition helpers ────────────────────────────────────────────────
  static PageRouteBuilder<T> _fadeRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, anim, secondaryAnimation, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  static PageRouteBuilder<T> _slideRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, anim, secondaryAnimation, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }
}
