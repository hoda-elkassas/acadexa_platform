// file: lib/features/auth/screens/otp_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_gradients.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/buttons/ac_button.dart';
import '../../../shared/widgets/inputs/ac_text_field.dart';
import '../../../shared/widgets/dialogs/ac_dialogs.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
    this.countdownSeconds = 60,
  });

  final String email;
  final Future<void> Function(String otp) onVerify;
  final Future<void> Function() onResend;
  final VoidCallback onBack;
  final int countdownSeconds;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otp = '';
  bool _isLoading = false;
  bool _otpError = false;
  String? _otpErrorText;
  int _remaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _remaining = widget.countdownSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _remaining--);
      if (_remaining <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length < 6) return;
    setState(() {
      _isLoading = true;
      _otpError = false;
      _otpErrorText = null;
    });
    try {
      await widget.onVerify(_otp);
    } catch (e) {
      if (mounted) {
        setState(() {
          _otpError = true;
          _otpErrorText = 'الرمز غير صحيح. يرجى المحاولة مرة أخرى';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await widget.onResend();
      _startCountdown();
      if (mounted) {
        AcToast.show(
          context,
          message: 'تم إرسال رمز جديد إلى بريدك الإلكتروني',
          type: AcToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AcToast.show(
          context,
          message: 'حدث خطأ أثناء إعادة إرسال الرمز',
          type: AcToastType.error,
        );
      }
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
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.primaryDiagonal,
                      borderRadius: AppRadius.brMd,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 32,
                      color: AppColors.neutral0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'تحقق من حسابك',
                    style: AppTypography.h2,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text.rich(
                    TextSpan(
                      text: 'أدخل الرمز المرسل إلى ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: widget.email,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AcOtpField(
                    length: 6,
                    onCompleted: (v) => setState(() => _otp = v),
                    onChanged: (v) {
                      setState(() {
                        _otp = v;
                        _otpError = false;
                        _otpErrorText = null;
                      });
                    },
                    hasError: _otpError,
                    errorText: _otpErrorText,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  AcButton(
                    label: 'تحقق',
                    onPressed: _otp.length == 6 && !_isLoading ? _verify : null,
                    isLoading: _isLoading,
                    isDisabled: _otp.length < 6,
                    isFullWidth: true,
                    size: AcButtonSize.large,
                    useGradient: true,
                  ),

                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لم يصلك رمز؟',
                        style: AppTypography.bodySmall,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _remaining > 0
                          ? Text(
                              'يمكنك إعادة الإرسال بعد $_remaining ث',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                              textDirection: TextDirection.rtl,
                            )
                          : GestureDetector(
                              onTap: _resend,
                              child: Text(
                                'إعادة إرسال الرمز',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primary500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary500,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                    ],
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
