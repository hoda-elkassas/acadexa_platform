// file: lib/features/auth/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_gradients.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/buttons/ac_button.dart';
import '../../../shared/widgets/inputs/ac_text_field.dart';
import '../../../shared/widgets/dialogs/ac_dialogs.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.onReset,
    required this.onBack,
  });

  final Future<void> Function({
    required String newPassword,
    required String confirmPassword,
  })
  onReset;
  final VoidCallback onBack;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  String? _passError;
  String? _confirmError;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool ok = true;
    final p = _passCtrl.text;
    final c = _confirmCtrl.text;

    if (p.isEmpty) {
      setState(() => _passError = 'كلمة المرور مطلوبة');
      ok = false;
    } else if (p.length < 8) {
      setState(() => _passError = 'يجب أن تكون 8 أحرف على الأقل');
      ok = false;
    } else if (!p.contains(RegExp(r'[A-Z]'))) {
      setState(() => _passError = 'يجب أن تحتوي على حرف كبير واحد على الأقل');
      ok = false;
    } else if (!p.contains(RegExp(r'[0-9]'))) {
      setState(() => _passError = 'يجب أن تحتوي على رقم واحد على الأقل');
      ok = false;
    } else {
      setState(() => _passError = null);
    }

    if (c.isEmpty) {
      setState(() => _confirmError = 'تأكيد كلمة المرور مطلوب');
      ok = false;
    } else if (p != c) {
      setState(() => _confirmError = 'كلمتا المرور غير متطابقتين');
      ok = false;
    } else {
      setState(() => _confirmError = null);
    }

    return ok;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.onReset(
        newPassword: _passCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );
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
                        gradient: AppGradients.primaryDiagonal,
                        borderRadius: AppRadius.brMd,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 32,
                        color: AppColors.neutral0,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'إعادة تعيين كلمة المرور',
                          style: AppTypography.h2,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'أدخل كلمة مرور جديدة قوية',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Password criteria hint
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.info50,
                      borderRadius: AppRadius.brSm,
                      border: Border.all(
                        color: AppColors.info500.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'يجب أن تحتوي كلمة المرور على:',
                          style: AppTypography.labelSmall,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        for (final c in [
                          '• حرف كبير (A-Z)',
                          '• حرف صغير (a-z)',
                          '• رقم (0-9)',
                          '• 8 أحرف على الأقل',
                        ])
                          Text(
                            c,
                            style: AppTypography.caption,
                            textDirection: TextDirection.rtl,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: AcPasswordField(
                      controller: _passCtrl,
                      label: 'كلمة المرور الجديدة',
                      errorText: _passError,
                      showStrengthIndicator: true,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: AcPasswordField(
                      controller: _confirmCtrl,
                      label: 'تأكيد كلمة المرور',
                      errorText: _confirmError,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AcButton(
                    label: 'إعادة تعيين كلمة المرور',
                    onPressed: _isLoading ? null : _submit,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    size: AcButtonSize.large,
                    useGradient: true,
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
