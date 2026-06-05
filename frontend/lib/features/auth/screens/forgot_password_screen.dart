// file: lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
//import '../../../core/themes/app_gradients.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/buttons/ac_button.dart';
import '../../../shared/widgets/inputs/ac_text_field.dart';
import '../../../shared/widgets/dialogs/ac_dialogs.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.onSendCode,
    required this.onBack,
  });

  final Future<void> Function(String email) onSendCode;
  final VoidCallback onBack;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final v = _emailCtrl.text.trim();
    if (v.isEmpty) {
      setState(() => _emailError = 'البريد الإلكتروني مطلوب');
      return false;
    }
    if (!RegExp(r'^[\w\-.+]+@[\w\-]+\.\w{2,}$').hasMatch(v)) {
      setState(() => _emailError = 'البريد الإلكتروني غير صالح');
      return false;
    }
    setState(() => _emailError = null);
    return true;
  }

  Future<void> _send() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.onSendCode(_emailCtrl.text.trim());
    } catch (e) {
      if (mounted) {
        AcToast.show(context, message: e.toString(), type: AcToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: AppRadius.brMd,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 32,
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'نسيت كلمة المرور',
                          style: AppTypography.h2,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'لا تقلق! سنرسل لك رمز التحقق',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: AcTextField(
                      controller: _emailCtrl,
                      label: 'البريد الإلكتروني',
                      hint: 'example@university.edu',
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      prefixIcon: const Icon(Icons.email_outlined),
                      onChanged: (_) => setState(() => _emailError = null),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'سنرسل رمز التحقق إلى بريدك الإلكتروني',
                    style: AppTypography.bodySmall,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AcButton(
                    label: 'إرسال رمز التحقق',
                    onPressed: _isLoading ? null : _send,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    size: AcButtonSize.large,
                    useGradient: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: TextButton(
                      onPressed: widget.onBack,
                      child: Text(
                        'رجوع إلى تسجيل الدخول',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
