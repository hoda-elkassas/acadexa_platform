// file: lib/features/auth/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/password_strength.dart';

class ResetPasswordScreen extends StatefulWidget {
  final Future<void> Function({
    required String newPassword,
    required String confirmPassword,
  }) onReset;
  final VoidCallback onBack;

  const ResetPasswordScreen({
    super.key,
    required this.onReset,
    required this.onBack,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pass1Controller = TextEditingController();
  final _pass2Controller = TextEditingController();
  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _pass1Controller.dispose();
    _pass2Controller.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await widget.onReset(
        newPassword: _pass1Controller.text,
        confirmPassword: _pass2Controller.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تغيير كلمة المرور بنجاح ✓',
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
              'حدث خطأ أثناء تغيير كلمة المرور',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: kError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'كلمة مرور جديدة',
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

                // ① أيقونة
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: kPrimaryTeal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_open_outlined,
                      color: kPrimaryTeal,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ② عنوان وشرح
                Text(
                  'أنشئ كلمة مرور جديدة',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يجب أن تكون 8 أحرف على الأقل وتحتوي على أرقام وحروف.',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: kTextMedium,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // ③ كلمة المرور الجديدة
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: AppTextField(
                    labelText: 'كلمة المرور الجديدة',
                    hintText: '••••••••',
                    obscureText: _obscure1,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                    controller: _pass1Controller,
                    onChanged: (_) => setState(() {}), // rebuild for strength indicator
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                      if (v.length < 8) return 'كلمة المرور قصيرة جداً';
                      if (!v.contains(RegExp(r'[0-9]'))) return 'يجب أن تحتوي على أرقام';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ④ تأكيد كلمة المرور
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: AppTextField(
                    labelText: 'تأكيد كلمة المرور',
                    hintText: '••••••••',
                    obscureText: _obscure2,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                    controller: _pass2Controller,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'أدخل تأكيد كلمة المرور';
                      if (v != _pass1Controller.text) return 'كلمتا المرور غير متطابقتين';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ⑤ مؤشر قوة كلمة المرور
                PasswordStrengthIndicator(password: _pass1Controller.text),

                const SizedBox(height: 32),

                // ⑥ زر الحفظ
                PrimaryButton(
                  label: 'حفظ كلمة المرور',
                  isLoading: _isLoading,
                  onPressed: _handleReset,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
