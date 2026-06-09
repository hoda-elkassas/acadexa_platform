// file: lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class LoginScreen extends StatefulWidget {
  final Future<void> Function({
    required String email,
    required String password,
    required bool rememberMe,
  }) onLogin;
  final VoidCallback onForgotPassword;
  final Future<void> Function()? onGoogleLogin;
  final Future<void> Function()? onAppleLogin;
  final dynamic strings;
  final Widget? logoWidget;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onForgotPassword,
    this.onGoogleLogin,
    this.onAppleLogin,
    this.strings,
    this.logoWidget,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onLogin(
        email: _emailController.text.trim(),
        password: _passController.text,
        rememberMe: _rememberMe,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _mapAuthError(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials') || message.contains('invalid_credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (message.contains('Email not confirmed') || message.contains('email_not_confirmed')) {
      return 'يرجى تأكيد بريدك الإلكتروني أولاً';
    }
    if (message.contains('لم يتم تفعيل الحساب بعد')) {
      return 'لم يتم تفعيل الحساب بعد. تواصل مع مسؤول النظام';
    }
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    return 'حدث خطأ، يرجى المحاولة مرة أخرى';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // ① اللوجو + اسم التطبيق (نفس الـ Splash بس أصغر)
                  Image.asset(
                    'assets/images/Acadexa_Logo.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: kPrimaryGradient,
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Acadexa',
                    style: GoogleFonts.cairo(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ② subtitle
                  Text(
                    'مرحباً بك، سجّل دخولك للمتابعة',
                    style: GoogleFonts.cairo(
                      color: kTextMedium,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // ③ حقل الإيميل
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: AppTextField(
                      labelText: 'البريد الإلكتروني',
                      hintText: 'example@university.edu',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      controller: _emailController,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'أدخل البريد الإلكتروني';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                          return 'أدخل بريد إلكتروني صالح';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ④ حقل كلمة السر
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: AppTextField(
                      labelText: 'كلمة المرور',
                      hintText: '••••••••',
                      obscureText: _obscure,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      controller: _passController,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'أدخل كلمة المرور';
                        }
                        if (v.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ⑤ تذكرني و نسيت كلمة المرور
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: kPrimaryTeal,
                            onChanged: (v) {
                              setState(() {
                                _rememberMe = v ?? false;
                              });
                            },
                          ),
                          Text(
                            'تذكرني',
                            style: GoogleFonts.cairo(
                              color: kTextMedium,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: widget.onForgotPassword,
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: GoogleFonts.cairo(
                            color: kPrimaryTeal,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ⑥ زر تسجيل الدخول
                  PrimaryButton(
                    label: 'تسجيل الدخول',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),

                  const SizedBox(height: 24),

                  // ⑦ رسالة الخطأ (تظهر فقط لو في error)
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kError.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kError.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: kError, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.cairo(
                                color: kError,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
