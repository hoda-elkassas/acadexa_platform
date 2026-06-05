// file: lib/core/router/app_router.dart
import 'package:flutter/material.dart';
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

// ─── AppRouter ───────────────────────────────────────────────────────────
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fadeRoute(
          Builder(
            builder: (context) => SplashScreen(
              onInitComplete: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
            ),
          ),
          settings,
        );

      case AppRoutes.login:
        return _slideRoute(
          Builder(
            builder: (context) => LoginScreen(
              onLogin: ({required email, required password, required rememberMe}) async {
                Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
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
              onBack: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          settings,
        );

      case AppRoutes.otpVerification:
        final args = settings.arguments as OtpArgs? ?? const OtpArgs(email: '');
        return _slideRoute(
          Builder(
            builder: (context) => OtpVerificationScreen(
              email: args.email,
              onVerify: (otp) async {
                Navigator.of(context).pushReplacementNamed(AppRoutes.resetPassword);
              },
              onResend: () async {},
              onBack: () {
                Navigator.of(context).pop();
              },
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
              onBack: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          settings,
        );

      case AppRoutes.studentDashboard:
      case AppRoutes.advisorDashboard:
      case AppRoutes.adminDashboard:
        return _fadeRoute(
          const DashboardScreen(),
          settings,
        );

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

