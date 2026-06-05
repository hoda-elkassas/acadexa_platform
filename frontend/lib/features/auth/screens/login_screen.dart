// file: lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_gradients.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/buttons/ac_button.dart';
import '../../../shared/widgets/inputs/ac_text_field.dart';
import '../../../shared/widgets/dialogs/ac_dialogs.dart';

// ─── Login screen data contract ───────────────────────────────────────────
abstract class LoginScreenStrings {
  String get loginTitle;
  String get welcomeBack;
  String get loginSubtitle;
  String get emailLabel;
  String get passwordLabel;
  String get rememberMeText;
  String get forgotPasswordText;
  String get loginButtonText;
  String get emptyEmailError;
  String get emptyPasswordError;
  String get invalidEmailError;
  String get invalidPasswordError;
  String get loginFailedTitle;
  String get invalidCredentialsError;
  String get networkError;
  String get serverError;
  String get accountLockedError;
  String get tooManyAttemptsError;
}

class DefaultLoginStrings implements LoginScreenStrings {
  @override
  String get loginTitle => 'تسجيل الدخول';
  @override
  String get welcomeBack => 'مرحباً بعودتك';
  @override
  String get loginSubtitle => 'قم بتسجيل الدخول للمتابعة';
  @override
  String get emailLabel => 'البريد الإلكتروني';
  @override
  String get passwordLabel => 'كلمة المرور';
  @override
  String get rememberMeText => 'تذكرني';
  @override
  String get forgotPasswordText => 'نسيت كلمة المرور؟';
  @override
  String get loginButtonText => 'تسجيل الدخول';
  @override
  String get emptyEmailError => 'البريد الإلكتروني مطلوب';
  @override
  String get emptyPasswordError => 'كلمة المرور مطلوبة';
  @override
  String get invalidEmailError => 'البريد الإلكتروني غير صالح';
  @override
  String get invalidPasswordError => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
  @override
  String get loginFailedTitle => 'فشل تسجيل الدخول';
  @override
  String get invalidCredentialsError =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';
  @override
  String get networkError => 'خطأ في الاتصال. يرجى التحقق من الإنترنت';
  @override
  String get serverError => 'خطأ في الخادم. يرجى المحاولة لاحقاً';
  @override
  String get accountLockedError => 'الحساب مقفل. يرجى التواصل مع الدعم الفني';
  @override
  String get tooManyAttemptsError => 'محاولات كثيرة جداً. يرجى المحاولة لاحقاً';
}

// ─── LoginScreen ──────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onForgotPassword,
    this.onGoogleLogin,
    this.onAppleLogin,
    this.strings,
    this.logoWidget,
  });

  final Future<void> Function({
    required String email,
    required String password,
    required bool rememberMe,
  })
  onLogin;
  final VoidCallback onForgotPassword;
  final Future<void> Function()? onGoogleLogin;
  final Future<void> Function()? onAppleLogin;
  final LoginScreenStrings? strings;
  final Widget? logoWidget;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _googleLoading = false;
  bool _appleLoading = false;

  String? _emailError;
  String? _passwordError;

  late final AnimationController _slideCtrl;
  late final Animation<double> _slideAnim;

  LoginScreenStrings get _s => widget.strings ?? DefaultLoginStrings();

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _slideAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  bool _validateEmail(String v) {
    if (v.isEmpty) {
      setState(() => _emailError = _s.emptyEmailError);
      return false;
    }
    final regex = RegExp(r'^[\w\-.+]+@[\w\-]+\.\w{2,}$');
    if (!regex.hasMatch(v)) {
      setState(() => _emailError = _s.invalidEmailError);
      return false;
    }
    setState(() => _emailError = null);
    return true;
  }

  bool _validatePassword(String v) {
    if (v.isEmpty) {
      setState(() => _passwordError = _s.emptyPasswordError);
      return false;
    }
    if (v.length < 8) {
      setState(() => _passwordError = _s.invalidPasswordError);
      return false;
    }
    setState(() => _passwordError = null);
    return true;
  }

  Future<void> _handleLogin() async {
    final emailOk = _validateEmail(_emailCtrl.text.trim());
    final passOk = _validatePassword(_passwordCtrl.text);
    if (!emailOk || !passOk) return;

    setState(() => _isLoading = true);
    try {
      await widget.onLogin(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        rememberMe: _rememberMe,
      );
    } catch (e) {
      if (!mounted) return;
      AcToast.show(context, message: e.toString(), type: AcToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogle() async {
    if (widget.onGoogleLogin == null) return;
    setState(() => _googleLoading = true);
    try {
      await widget.onGoogleLogin!();
    } catch (e) {
      if (mounted) {
        AcToast.show(context, message: e.toString(), type: AcToastType.error);
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _handleApple() async {
    if (widget.onAppleLogin == null) return;
    setState(() => _appleLoading = true);
    try {
      await widget.onAppleLogin!();
    } catch (e) {
      if (mounted) {
        AcToast.show(context, message: e.toString(), type: AcToastType.error);
      }
    } finally {
      if (mounted) setState(() => _appleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            //final isWide = constraints.maxWidth > 600;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: FadeTransition(
                    opacity: _slideAnim,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(_slideAnim),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Logo ────────────────────────────
                            Center(
                              child:
                                  widget.logoWidget ??
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: const BoxDecoration(
                                      gradient: AppGradients.primaryDiagonal,
                                      borderRadius: AppRadius.brMd,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'A',
                                        style: TextStyle(
                                          color: AppColors.neutral0,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // ── Title ───────────────────────────
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    _s.welcomeBack,
                                    style: AppTypography.h2,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    _s.loginSubtitle,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // ── Email ───────────────────────────
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: AcTextField(
                                controller: _emailCtrl,
                                label: _s.emailLabel,
                                hint: 'example@university.edu',
                                errorText: _emailError,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                textDirection: TextDirection.ltr,
                                prefixIcon: const Icon(Icons.email_outlined),
                                onChanged: (_) {
                                  if (_emailError != null) {
                                    setState(() => _emailError = null);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // ── Password ────────────────────────
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: AcPasswordField(
                                controller: _passwordCtrl,
                                label: _s.passwordLabel,
                                hint: '••••••••',
                                errorText: _passwordError,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleLogin(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // ── Remember me + Forgot ─────────────
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _rememberMe = !_rememberMe,
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (v) => setState(
                                            () => _rememberMe = v ?? false,
                                          ),
                                        ),
                                        Text(
                                          _s.rememberMeText,
                                          style: AppTypography.labelMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: widget.onForgotPassword,
                                    child: Text(
                                      _s.forgotPasswordText,
                                      style: AppTypography.labelMedium.copyWith(
                                        color: AppColors.primary500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // ── Login Button ─────────────────────
                            AcButton(
                              label: _isLoading
                                  ? 'جاري الدخول...'
                                  : _s.loginButtonText,
                              onPressed: _isLoading ? null : _handleLogin,
                              isLoading: _isLoading,
                              isFullWidth: true,
                              useGradient: true,
                              size: AcButtonSize.large,
                            ),

                            // ── Social login ─────────────────────
                            if (widget.onGoogleLogin != null ||
                                widget.onAppleLogin != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(color: AppColors.border),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                    child: Text(
                                      'أو',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(color: AppColors.border),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  if (widget.onGoogleLogin != null)
                                    Expanded(
                                      child: _SocialButton(
                                        label: 'Google',
                                        icon: Icons.g_mobiledata_rounded,
                                        isLoading: _googleLoading,
                                        onTap: _handleGoogle,
                                      ),
                                    ),
                                  if (widget.onGoogleLogin != null &&
                                      widget.onAppleLogin != null)
                                    const SizedBox(width: AppSpacing.sm),
                                  if (widget.onAppleLogin != null)
                                    Expanded(
                                      child: _SocialButton(
                                        label: 'Apple',
                                        icon: Icons.apple_rounded,
                                        isLoading: _appleLoading,
                                        onTap: _handleApple,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: AppRadius.brButton,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: AppRadius.brButton,
          border: Border.all(color: AppColors.border, width: 1.5),
          color: AppColors.surface,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 22, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(label, style: AppTypography.labelMedium),
                  ],
                ),
        ),
      ),
    );
  }
}
