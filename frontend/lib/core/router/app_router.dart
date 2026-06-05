// file: lib/core/router/app_router.dart
import 'package:flutter/material.dart';

// ─── Route names ─────────────────────────────────────────────────────────
abstract class AppRoutes {
  static const splash          = '/';
  static const login           = '/login';
  static const forgotPassword  = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword   = '/reset-password';
  static const studentDashboard  = '/student';
  static const advisorDashboard  = '/advisor';
  static const adminDashboard    = '/admin';
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

// ─── AppRouter (Navigator 1.0 – swap for GoRouter as preferred) ──────────
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(
          const _PlaceholderScreen(title: 'Splash'),
          settings,
        );

      case AppRoutes.login:
        return _slideRoute(
          const _PlaceholderScreen(title: 'Login'),
          settings,
        );

      case AppRoutes.forgotPassword:
        return _slideRoute(
          const _PlaceholderScreen(title: 'Forgot Password'),
          settings,
        );

      case AppRoutes.otpVerification:
        return _slideRoute(
          const _PlaceholderScreen(title: 'OTP'),
          settings,
        );

      case AppRoutes.resetPassword:
        return _slideRoute(
          const _PlaceholderScreen(title: 'Reset Password'),
          settings,
        );

      case AppRoutes.studentDashboard:
        return _fadeRoute(
          const _PlaceholderScreen(title: 'Student Dashboard'),
          settings,
        );

      case AppRoutes.advisorDashboard:
        return _fadeRoute(
          const _PlaceholderScreen(title: 'Advisor Dashboard'),
          settings,
        );

      case AppRoutes.adminDashboard:
        return _fadeRoute(
          const _PlaceholderScreen(title: 'Admin Dashboard'),
          settings,
        );

      default:
        return _slideRoute(
          const _PlaceholderScreen(title: '404 – Not Found'),
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

// ─── Placeholder (replace with real screens) ─────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
