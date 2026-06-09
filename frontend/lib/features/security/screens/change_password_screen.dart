// file: lib/features/security/screens/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isUpdating = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength() {
    final password = _newPasswordController.text;
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 8) score += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 0.25;
    return score;
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.25) return kError;
    if (strength <= 0.5) return kWarning;
    if (strength <= 0.75) return kPrimaryBlue;
    return kSuccess;
  }

  String _getStrengthText(double strength) {
    if (strength == 0.0) return '';
    if (strength <= 0.25) return 'ضعيفة جداً';
    if (strength <= 0.5) return 'ضعيفة';
    if (strength <= 0.75) return 'متوسطة القوة';
    return 'قوية جداً';
  }

  void _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentPasswordController.text == '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'كلمة المرور الحالية غير صحيحة',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: kError,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    await Future.delayed(const Duration(seconds: 1500));

    if (mounted) {
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تغيير كلمة المرور بنجاح',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: kSuccess,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength();

    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: AppBar(
        backgroundColor: kDarkNavy,
        foregroundColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تغيير كلمة المرور',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Warning note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kWarning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kWarning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: kWarning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'بعد تغيير كلمة المرور بنجاح، سيظل جهازك الحالي مسجلاً للدخول، ولكن سيتعين على الأجهزة الأخرى تسجيل الدخول مجدداً.',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(fontSize: 11, color: kTextDark, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Current Password Field
                Text(
                  'كلمة المرور الحالية *',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(color: kTextDark),
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, color: kTextLight),
                      onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    filled: true,
                    fillColor: kWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'كلمة المرور الحالية مطلوبة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // New Password Field
                Text(
                  'كلمة المرور الجديدة *',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(color: kTextDark),
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: kTextLight),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    filled: true,
                    fillColor: kWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'يجب ألا تقل كلمة المرور عن 8 أحرف';
                    }
                    return null;
                  },
                ),

                // Strength indicator bar
                if (strength > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getStrengthText(strength),
                        style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: _getStrengthColor(strength)),
                      ),
                      Text(
                        'قوة كلمة المرور',
                        style: GoogleFonts.cairo(fontSize: 11, color: kTextMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: strength,
                      backgroundColor: kDivider,
                      valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor(strength)),
                      minHeight: 6,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Confirm Password Field
                Text(
                  'تأكيد كلمة المرور الجديدة *',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(color: kTextDark),
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: kTextLight),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    filled: true,
                    fillColor: kWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'تأكيد كلمة المرور غير متطابق';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      foregroundColor: kWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isUpdating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kWhite))
                        : Text('تحديث كلمة المرور', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
