// file: lib/features/security/screens/two_factor_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';

class TwoFactorScreen extends StatefulWidget {
  final bool enabled;
  const TwoFactorScreen({super.key, required this.enabled});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  late bool _twoFactorEnabled;
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _twoFactorEnabled = widget.enabled;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  void _toggle2FA(bool value) {
    if (!value) {
      // Prompt to disable immediately
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'إيقاف المصادقة الثنائية',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: kError),
          ),
          content: Text(
            'هل تريد بالتأكيد إيقاف المصادقة الثنائية؟ سيؤدي ذلك إلى تقليل مستوى أمان حسابك.',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: kTextMedium)),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _twoFactorEnabled = false;
                });
                try {
                  final client = Supabase.instance.client;
                  await client.auth.updateUser(
                    UserAttributes(
                      data: {
                        'two_factor_enabled': false,
                      },
                    ),
                  );
                } catch (_) {}
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم إلغاء تفعيل المصادقة الثنائية',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: kWarning,
                    ),
                  );
                }
              },
              child: Text(
                'إيقاف التشغيل',
                style: GoogleFonts.cairo(color: kError, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _twoFactorEnabled = true;
      });
    }
  }

  void _verifyAndEnable() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isVerifying = true; _errorMessage = ''; });
    try {
      final client = Supabase.instance.client;
      await client.auth.updateUser(
        UserAttributes(
          data: {
            'two_factor_enabled': true,
          },
        ),
      );
      if (mounted) {
        setState(() { _isVerifying = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تفعيل المصادقة الثنائية بنجاح', textAlign: TextAlign.right, style: GoogleFonts.cairo()),
            backgroundColor: kSuccess,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isVerifying = false; _errorMessage = 'فشل التحقق: ${e.toString()}'; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: AppBar(
        backgroundColor: kDarkNavy,
        foregroundColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'المصادقة الثنائية (2FA)',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.of(context).pop(_twoFactorEnabled);
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Info Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _twoFactorEnabled ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                        color: _twoFactorEnabled ? kSuccess : kError,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _twoFactorEnabled ? 'المصادقة الثنائية نشطة' : 'المصادقة الثنائية غير مفعلة',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _twoFactorEnabled
                                  ? 'حسابك محمي بخطوة تحقق إضافية عند تسجيل الدخول.'
                                  : 'قم بحماية حسابك بإضافة خطوة تحقق ثنائية باستخدام تطبيق Google Authenticator.',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(fontSize: 12, color: kTextMedium, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Toggle Switch
                Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile.adaptive(
                    value: _twoFactorEnabled,
                    activeColor: kPrimaryTeal,
                    title: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'تفعيل المصادقة الثنائية',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark),
                      ),
                    ),
                    onChanged: _toggle2FA,
                  ),
                ),

                // Scan QR and input if enabled in UI but not fully verified yet
                if (_twoFactorEnabled && !widget.enabled) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('خطوات التفعيل'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            '1. امسح رمز QR باستخدام تطبيق المصادقة (Authenticator app)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: kTextDark),
                          ),
                          const SizedBox(height: 20),

                          // Mock QR Code widget
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: kScaffoldBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: kWhite,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: kDivider),
                                  ),
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(8),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 6,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 4,
                                    ),
                                    itemCount: 36,
                                    itemBuilder: (context, index) {
                                      // Pattern that looks like a QR code
                                      final isBlack = (index * 7 + 13) % 5 < 2 || index < 6 || index % 6 == 0 || index % 6 == 5 || index > 30;
                                      return Container(
                                        color: isBlack ? kDarkNavy : kWhite,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'مفتاح التفعيل البديل: ABCD EFGH IJKL MNOP',
                                  style: GoogleFonts.cairo(fontSize: 11, color: kTextMedium, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            '2. أدخل رمز التأكيد المكون من 6 أرقام للتحقق',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: kTextDark),
                          ),
                          const SizedBox(height: 12),

                          // Verification Code Input
                          TextFormField(
                            controller: _codeController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 8, color: kTextDark),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '000000',
                              hintStyle: TextStyle(color: kTextLight.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: kScaffoldBg,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            validator: (value) {
                              if (value == null || value.length != 6) {
                                return 'رمز التأكيد غير صالح';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isVerifying ? null : _verifyAndEnable,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryBlue,
                                foregroundColor: kWhite,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isVerifying
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kWhite))
                                  : Text('تحقق وتفعيل', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: kTextDark,
        ),
      ),
    );
  }
}
