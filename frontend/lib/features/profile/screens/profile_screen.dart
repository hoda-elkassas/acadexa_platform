// file: lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/router/app_router.dart';
import 'edit_profile_screen.dart';
import '../../notifications/screens/notification_settings_screen.dart';
import '../../security/screens/security_settings_screen.dart';
import '../../support/screens/about_screen.dart';
import '../../faq/screens/faq_screen.dart';
import '../../support/screens/report_issue_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';
  bool _isUploadingPhoto = false;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) { setState(() { _isLoading = false; }); return; }
      setState(() {
        _userName = user.userMetadata?['full_name'] as String? ?? user.email?.split('@').first ?? 'مستخدم';
        _userEmail = user.email ?? '';
        _userRole = user.userMetadata?['role'] as String? ?? '';
      });

      // Try to get more profile data from app_users
      try {
        final res = await _supabase
            .from('app_users')
            .select('full_name, email, system_role')
            .eq('id', user.id)
            .single();
        setState(() {
          _userName = res['full_name'] as String? ?? _userName;
          _userEmail = res['email'] as String? ?? _userEmail;
          final roleKey = res['system_role'] as String? ?? '';
          if (roleKey.isNotEmpty) {
            final roleLabels = {
              'SYSTEM_MANAGEMENT': 'مدير النظام',
              'DEVELOPER': 'مطور',
              'ACADEMIC_OPERATIONS': 'عمليات أكاديمية',
              'ACADEMIC_ADVISING': 'مرشد أكاديمي',
              'DASHBOARD_VIEWER': 'مشاهد لوحة البيانات',
              'ANALYTICS_AND_REPORTING': 'تحليل وتقارير',
              'AUTHENTICATED': 'مستخدم',
            };
            _userRole = roleLabels[roleKey] ?? roleKey;
          }
        });
      } catch (_) {}
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل البيانات: ${e.toString()}'; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _zoomProfilePhoto() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
            child: const Hero(
              tag: 'profile_avatar',
              child: CircleAvatar(
                radius: 150,
                backgroundColor: kPrimaryTeal,
                child: Icon(Icons.person, size: 180, color: kWhite),
              ),
            ),
        ),
      ),
    );
  }

  void _uploadPhoto() async {
    setState(() {
      _isUploadingPhoto = true;
    });

    // Simulated picker & upload
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isUploadingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تحديث الصورة الشخصية بنجاح',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: kSuccess,
        ),
      );
    }
  }

  void _copyEmail() {
    Clipboard.setData(ClipboardData(text: _userEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ البريد الإلكتروني',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: kSuccess,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'اختر اللغة / Select Language',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('العربية', style: GoogleFonts.cairo(), textAlign: TextAlign.right),
              trailing: const Icon(Icons.check, color: kPrimaryTeal),
              onTap: () => Navigator.of(context).pop(),
            ),
            const Divider(),
            ListTile(
              title: Text('English', style: GoogleFonts.inter(), textAlign: TextAlign.right),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تسجيل الخروج',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج؟ سيتعين عليك تسجيل الدخول مرة أخرى للوصول إلى حسابك.',
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
              final navigator = Navigator.of(context);
              navigator.pop();
              await _supabase.auth.signOut();
              if (mounted) {
                navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
            child: Text(
              'تسجيل خروج',
              style: GoogleFonts.cairo(color: kError, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف الحساب نهائياً',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(color: kError, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'تحذير: هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك نهائياً من قاعدة البيانات الأكاديمية. هل أنت متأكد؟',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: kTextMedium)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم إرسال طلب حذف الحساب للإدارة للمراجعة',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: kError,
                ),
              );
            },
            child: Text(
              'تأكيد الحذف',
              style: GoogleFonts.cairo(color: kError, fontWeight: FontWeight.bold),
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
          'الملف الشخصي',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage,
                          style: GoogleFonts.cairo(color: kError),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            foregroundColor: kWhite,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              color: kDarkNavy,
              child: Column(
                children: [
                  // Photo Avatar
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      GestureDetector(
                        onTap: _zoomProfilePhoto,
                        child: Hero(
                          tag: 'profile_avatar',
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: kPrimaryTeal.withValues(alpha: 0.2),
                            child: const CircleAvatar(
                              radius: 52,
                              backgroundColor: kPrimaryTeal,
                              child: Icon(Icons.person, size: 64, color: kWhite),
                            ),
                          ),
                        ),
                      ),
                      if (_isUploadingPhoto)
                        const Positioned.fill(
                          child: CircleAvatar(
                            backgroundColor: Colors.black45,
                            child: CircularProgressIndicator(color: kWhite),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: _uploadPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: kPrimaryTeal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_outlined, size: 16, color: kWhite),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name and Role
                  Text(
                    _userName,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: kWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: kWhite.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _userRole,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: kWhite.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email with Copy Button
                  GestureDetector(
                    onTap: _copyEmail,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.copy_rounded, size: 14, color: kWhite),
                        const SizedBox(width: 8),
                        Text(
                          _userEmail,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: kWhite.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),



            const SizedBox(height: 16),

            // Main Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSectionLabel('معلومات الحساب'),
                  const SizedBox(height: 8),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'تعديل الملف الشخصي',
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(name: _userName, email: _userEmail),
                          ),
                        );
                        if (result != null && result is Map<String, String>) {
                          setState(() {
                            _userName = result['name'] ?? _userName;
                            _userEmail = result['email'] ?? _userEmail;
                          });
                        }
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'الإشعارات والتنبيهات',
                      badge: '3',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.security_rounded,
                      title: 'الأمان والخصوصية',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SecuritySettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildSectionLabel('التفضيلات'),
                  const SizedBox(height: 8),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.language_rounded,
                      title: 'لغة التطبيق',
                      subtitle: 'العربية',
                      onTap: _changeLanguage,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildSectionLabel('الدعم والمساعدة'),
                  const SizedBox(height: 8),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'الأسئلة الشائعة',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FaqScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.feedback_outlined,
                      title: 'الإبلاغ عن مشكلة',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ReportIssueScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'حول التطبيق',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kError.withValues(alpha: 0.1),
                        foregroundColor: kError,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: kError, width: 1),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        'تسجيل الخروج',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: _deleteAccount,
                      style: TextButton.styleFrom(foregroundColor: kError),
                      child: Text(
                        'مسح حسابي نهائياً',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: kTextDark,
        ),
      ),
    );
  }



  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kTextDark.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: kTextLight),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: kPrimaryTeal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: GoogleFonts.inter(color: kWhite, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Text(
              subtitle,
              style: GoogleFonts.cairo(fontSize: 12, color: kTextMedium),
            ),
          ],
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
          ),
        ],
      ),
      trailing: Icon(icon, color: kPrimaryTeal, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
