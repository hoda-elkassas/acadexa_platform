import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/study_plan_model.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';

// Import curriculum screens
import '../../features/study_plan/screens/study_plan_structure_screen.dart';
import '../../features/study_plan/screens/academic_load_rules_screen.dart';
import '../../features/study_plan/screens/grade_points_screen.dart';
import '../../features/study_plan/screens/field_training_settings_screen.dart';
import '../../features/study_plan/screens/import_curriculum_screen.dart';
import '../../features/courses/screens/manage_courses_screen.dart';
import '../../features/courses/screens/manage_prerequisites_screen.dart';
import '../../features/courses/screens/elective_groups_screen.dart';

// Import curriculum cubits
import '../../features/study_plan/cubit/plan_structure_cubit.dart';
import '../../features/study_plan/cubit/academic_rules_cubit.dart';
import '../../features/study_plan/cubit/grading_cubit.dart';
import '../../features/study_plan/cubit/field_training_cubit.dart';
import '../../features/courses/cubit/courses_cubit.dart';
import '../../features/courses/cubit/prerequisites_cubit.dart';
import '../../features/courses/cubit/elective_groups_cubit.dart';

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

  // Curriculum & Study Plan routes
  static const studyPlanStructure = '/curriculum/study-plans/structure';
  static const studyPlanCourses = '/curriculum/study-plans/courses';
  static const studyPlanPrerequisites = '/curriculum/study-plans/prerequisites';
  static const studyPlanElectiveGroups = '/curriculum/study-plans/elective-groups';
  static const studyPlanAcademicLoad = '/curriculum/study-plans/rules/academic-load';
  static const studyPlanGrading = '/curriculum/study-plans/rules/grading';
  static const studyPlanFieldTraining = '/curriculum/study-plans/rules/field-training';
  static const studyPlanImport = '/curriculum/study-plans/import';
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

  /// Helper to fetch and normalize role from database.
  /// Throws [AuthException] if the account is inactive.
  static Future<String> _fetchUserRole(String userId) async {
    final client = Supabase.instance.client;
    
    // 1. Try app_users
    try {
      final res = await client
          .from('app_users')
          .select('system_role, is_active')
          .eq('id', userId)
          .single();

      // Check if the account is active
      final isActive = res['is_active'] as bool? ?? true;
      if (!isActive) {
        await client.auth.signOut();
        throw Exception('الحساب غير نشط. يرجى التواصل مع مسؤول النظام.');
      }

      final systemRole = res['system_role'] as String?;
      return AppRole.fromString(systemRole).value;
    } catch (e) {
      // Re-throw inactive account errors
      if (e.toString().contains('غير نشط')) rethrow;
    }

    // 2. Try v_users_with_roles
    try {
      final res = await client
          .from('v_users_with_roles')
          .select('role_key, legacy_role, is_active')
          .eq('id', userId)
          .single();

      final isActive = res['is_active'] as bool? ?? true;
      if (!isActive) {
        await client.auth.signOut();
        throw Exception('الحساب غير نشط. يرجى التواصل مع مسؤول النظام.');
      }

      final roleKey = res['role_key'] as String? ?? res['legacy_role'] as String?;
      return AppRole.fromString(roleKey).value;
    } catch (e) {
      if (e.toString().contains('غير نشط')) rethrow;
    }

    // 3. Fallback to auth metadata
    final user = client.auth.currentUser;
    final metaRole = user?.userMetadata?['role']?.toString();
    return AppRole.fromString(metaRole).value;
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
                  final role = await _fetchUserRole(session.user.id);
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
                  final role = await _fetchUserRole(user.id);
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

      // ── Curriculum & Study Plan Detail Routes ───────────────────────────
      case AppRoutes.studyPlanStructure:
        final plan = settings.arguments as StudyPlanModel;
        return _slideRoute(
          BlocProvider<PlanStructureCubit>(
            create: (_) => PlanStructureCubit(),
            child: StudyPlanStructureScreen(plan: plan),
          ),
          settings,
        );

      case AppRoutes.studyPlanCourses:
        final plan = settings.arguments as StudyPlanModel;
        return _slideRoute(
          BlocProvider<CoursesCubit>(
            create: (_) => CoursesCubit(),
            child: ManageCoursesScreen(plan: plan),
          ),
          settings,
        );

      case AppRoutes.studyPlanPrerequisites:
        final plan = settings.arguments as StudyPlanModel;
        return _slideRoute(
          BlocProvider<PrerequisitesCubit>(
            create: (_) => PrerequisitesCubit(),
            child: ManagePrerequisitesScreen(plan: plan),
          ),
          settings,
        );

      case AppRoutes.studyPlanElectiveGroups:
        final plan = settings.arguments as StudyPlanModel;
        return _slideRoute(
          BlocProvider<ElectiveGroupsCubit>(
            create: (_) => ElectiveGroupsCubit(),
            child: ElectiveGroupsScreen(plan: plan),
          ),
          settings,
        );

      case AppRoutes.studyPlanAcademicLoad:
        final plan = settings.arguments as StudyPlanModel;
        return _slideRoute(
          BlocProvider<AcademicRulesCubit>(
            create: (_) => AcademicRulesCubit(),
            child: AcademicLoadRulesScreen(plan: plan),
          ),
          settings,
        );

      case AppRoutes.studyPlanGrading:
        final plan = settings.arguments as StudyPlanModel;
        return _slideRoute(
          BlocProvider<GradingCubit>(
            create: (_) => GradingCubit(),
            child: GradePointsScreen(plan: plan),
          ),
          settings,
        );

      case AppRoutes.studyPlanFieldTraining:
        final plan = settings.arguments as StudyPlanModel;
        return _slideRoute(
          BlocProvider<FieldTrainingCubit>(
            create: (_) => FieldTrainingCubit(),
            child: FieldTrainingSettingsScreen(plan: plan),
          ),
          settings,
        );

      case AppRoutes.studyPlanImport:
        final plan = settings.arguments as StudyPlanModel;
        return _slideRoute(
          ImportCurriculumScreen(plan: plan),
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
