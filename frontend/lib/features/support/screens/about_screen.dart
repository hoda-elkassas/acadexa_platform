// file: lib/features/support/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _isCheckingUpdates = false;

  void _checkUpdates() async {
    setState(() {
      _isCheckingUpdates = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isCheckingUpdates = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'تحديث التطبيق',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'أنت تستخدم النسخة الأحدث بالفعل (v1.2.0)',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'حسناً',
                style: GoogleFonts.cairo(color: kPrimaryBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showWebViewSimulated(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            'هذه صفحة تجريبية لـ $title. سيتم فتح الرابط الفعلي في متصفح خارجي أو WebView مدمج عند ربطه ببيئة الإنتاج.',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إغلاق',
              style: GoogleFonts.cairo(color: kPrimaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
          'حول المنصة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Logo
              Image.asset(
                'assets/images/Acadexa_Logo.png',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: kPrimaryGradient,
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // App Name
              Text(
                'Acadexa',
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
              // App Version
              Text(
                'الإصدار v1.2.0',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: kTextMedium,
                ),
              ),
              const SizedBox(height: 32),

              // Description Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kTextDark.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'أكاديكسا هي منصة إرشاد أكاديمي ذكية متكاملة، مصممة لمساعدة الطلاب والمستشارين الأكاديميين في إدارة الخطط الدراسية، متابعة التقدم، والتحقق من متطلبات التخرج وتجاوز العقبات الأكاديمية باستخدام خوارزميات ذكية متطورة.',
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    height: 1.8,
                    color: kTextDark,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Links List
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kTextDark.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => _showWebViewSimulated('سياسة الخصوصية'),
                      title: Text(
                        'سياسة الخصوصية',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      trailing: const Icon(Icons.privacy_tip_outlined, color: kPrimaryTeal),
                      leading: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      onTap: () => _showWebViewSimulated('الشروط والأحكام'),
                      title: Text(
                        'الشروط والأحكام',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      trailing: const Icon(Icons.description_outlined, color: kPrimaryTeal),
                      leading: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      onTap: () => _showWebViewSimulated('موقع الويب الرسمي'),
                      title: Text(
                        'موقع الويب الرسمي',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      trailing: const Icon(Icons.language_outlined, color: kPrimaryTeal),
                      leading: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Check for Updates Action
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isCheckingUpdates ? null : _checkUpdates,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isCheckingUpdates
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kWhite,
                          ),
                        )
                      : const Icon(Icons.system_update_rounded),
                  label: Text(
                    _isCheckingUpdates ? 'جاري التحقق...' : 'التحقق من التحديثات',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Copyright
              Text(
                '© 2026 Acadexa. جميع الحقوق محفوظة.',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: kTextLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
