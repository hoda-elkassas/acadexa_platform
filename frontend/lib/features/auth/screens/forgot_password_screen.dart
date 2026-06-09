// file: lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final Future<void> Function(String email) onSendCode;
  final VoidCallback onBack;

  const ForgotPasswordScreen({
    super.key,
    required this.onSendCode,
    required this.onBack,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _sent = false;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'io.supabase.acadexa://reset-callback',
      );

      setState(() {
        _sent = true;
      });

      // التوجيه لشاشة الـ OTP بعد ثانيتين مع تمرير الإيميل
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        widget.onSendCode(_emailController.text.trim());
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _mapAuthError(e.message);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
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
    if (message.contains('User not found') || message.contains('user_not_found')) {
      return 'المستخدم غير مسجل بالنظام';
    }
    if (message.contains('rate limit') || message.contains('Too many requests')) {
      return 'محاولات كثيرة جداً. يرجى المحاولة لاحقاً بعد قليل';
    }
    return 'حدث خطأ أثناء إرسال رمز التحقق. يرجى المحاولة مرة أخرى';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: kPrimaryBlue,
          onPressed: widget.onBack,
        ),
        title: Text(
          'استعادة كلمة المرور',
          style: GoogleFonts.cairo(
            color: kTextDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ① أيقونة توضيحية
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: kLightBlue.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: kPrimaryBlue,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ② عنوان وشرح
                Text(
                  'أدخل بريدك الإلكتروني',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سنرسل إليك رمز التحقق (OTP) على بريدك الإلكتروني لإعادة تعيين كلمة المرور.',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: kTextMedium,
                    height: 1.5,
                  ),
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

                const SizedBox(height: 24),

                // ④ زر إرسال OTP
                PrimaryButton(
                  label: 'إرسال رمز التحقق',
                  isLoading: _isLoading,
                  onPressed: _sendOtp,
                ),

                const SizedBox(height: 24),

                // ⑤ رسالة نجاح (تظهر بعد الإرسال)
                if (_sent) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kSuccess.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kSuccess.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: kSuccess, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تم إرسال رمز التحقق بنجاح إلى بريدك الإلكتروني',
                            style: GoogleFonts.cairo(
                              color: kSuccess,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ⑥ رسالة الخطأ (تظهر فقط لو في error)
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
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
