// file: lib/features/auth/screens/otp_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final Future<void> Function(String otp) onVerify;
  final Future<void> Function() onResend;
  final VoidCallback onBack;
  final int countdownSeconds;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
    this.countdownSeconds = 60,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  String _otp = '';
  bool _isLoading = false;
  String? _errorMessage;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = widget.countdownSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp(String token) async {
    if (token.length < 6) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await widget.onVerify(token);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'الرمز غير صحيح أو انتهت صلاحيته';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    try {
      await widget.onResend();
      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال رمز جديد إلى بريدك الإلكتروني',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: kSuccess,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء إعادة إرسال الرمز',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: kError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pin themes
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: kTextDark,
      ),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      textStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: kPrimaryBlue,
      ),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryBlue, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kError, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: kPrimaryBlue,
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // ① أيقونة
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: kPrimaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: kWhite,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // ② عنوان
              Text(
                'رمز التحقق',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: kTextMedium,
                  ),
                  children: [
                    const TextSpan(text: 'أُرسل رمز مكوّن من 6 أرقام إلى '),
                    TextSpan(
                      text: widget.email,
                      style: GoogleFonts.cairo(
                        color: kPrimaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // ③ حقول OTP (6 خانات) — Pinput
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  length: 6,
                  controller: _otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  errorPinTheme: errorPinTheme,
                  forceErrorState: _errorMessage != null,
                  onCompleted: (pin) {
                    setState(() => _otp = pin);
                    _verifyOtp(pin);
                  },
                  onChanged: (v) {
                    setState(() {
                      _otp = v;
                      _errorMessage = null;
                    });
                  },
                ),
              ),

              const SizedBox(height: 32),

              // ④ زر التحقق
              PrimaryButton(
                label: 'تحقق',
                isLoading: _isLoading,
                onPressed: _otp.length == 6 ? () => _verifyOtp(_otp) : null,
              ),

              const SizedBox(height: 24),

              // ⑤ إعادة الإرسال مع countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لم تستلم الرمز؟ ',
                    style: GoogleFonts.cairo(
                      color: kTextMedium,
                      fontSize: 14,
                    ),
                  ),
                  if (_countdown > 0)
                    Text(
                      'إعادة الإرسال بعد $_countdown ثانية',
                      style: GoogleFonts.cairo(
                        color: kTextLight,
                        fontSize: 14,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _resendOtp,
                      child: Text(
                        'إعادة الإرسال',
                        style: GoogleFonts.cairo(
                          color: kPrimaryTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),

              // ⑥ رسالة خطأ
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.cairo(
                    color: kError,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
