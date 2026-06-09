// file: lib/features/notifications/screens/notification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _academicAlerts = true;
  bool _curriculumUpdates = true;
  bool _advisorMessages = true;
  bool _generalAnnouncements = false;

  bool _inAppChannel = true;
  bool _emailChannel = true;
  bool _pushChannel = false;

  bool _isSaving = false;

  void _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    // Simulated API call
    await Future.delayed(const Duration(seconds: 1500));

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ إعدادات الإشعارات بنجاح',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: kSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
          'إعدادات الإشعارات',
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Section 1: Types of Notifications
              _buildSectionTitle('أنواع التنبيهات'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kTextDark.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'التنبيهات الأكاديمية',
                      subtitle: 'إنذارات تدني المعدل، تجاوز الغياب، الخ.',
                      value: _academicAlerts,
                      icon: Icons.warning_amber_rounded,
                      onChanged: (val) => setState(() => _academicAlerts = val),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildSwitchTile(
                      title: 'تحديثات اللائحة الدراسية',
                      subtitle: 'تعديل خطط، إضافة متطلبات جديدة، الخ.',
                      value: _curriculumUpdates,
                      icon: Icons.menu_book_rounded,
                      onChanged: (val) => setState(() => _curriculumUpdates = val),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildSwitchTile(
                      title: 'رسائل المرشد الأكاديمي',
                      subtitle: 'تنبيهات مباشرة ورسائل هامة من مستشارك.',
                      value: _advisorMessages,
                      icon: Icons.chat_bubble_outline_rounded,
                      onChanged: (val) => setState(() => _advisorMessages = val),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildSwitchTile(
                      title: 'إعلانات عامة وإدارية',
                      subtitle: 'أخبار الجامعة، التسجيل، مواعيد عامة.',
                      value: _generalAnnouncements,
                      icon: Icons.campaign_outlined,
                      onChanged: (val) => setState(() => _generalAnnouncements = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Section 2: Channels / Delivery Methods
              _buildSectionTitle('وسائل استلام الإشعارات'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kTextDark.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildCheckboxTile(
                      title: 'تنبيهات داخل التطبيق (In-App)',
                      subtitle: 'عرض الإشعارات داخل المنصة عند الاستخدام.',
                      value: _inAppChannel,
                      icon: Icons.notifications_none_rounded,
                      onChanged: (val) => setState(() => _inAppChannel = val ?? false),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildCheckboxTile(
                      title: 'البريد الإلكتروني (Email)',
                      subtitle: 'إرسال ملخص التنبيهات لبريدك الجامعي.',
                      value: _emailChannel,
                      icon: Icons.mail_outline_rounded,
                      onChanged: (val) => setState(() => _emailChannel = val ?? false),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildCheckboxTile(
                      title: 'إشعارات الدفع (Push Notifications)',
                      subtitle: 'تنبيهات الهاتف المحمول المباشرة.',
                      value: _pushChannel,
                      icon: Icons.phone_android_rounded,
                      onChanged: (val) => setState(() => _pushChannel = val ?? false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kWhite,
                          ),
                        )
                      : Text(
                          'حفظ الإعدادات',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: kTextDark,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: kPrimaryTeal,
      title: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: kTextDark,
          ),
        ),
      ),
      subtitle: Align(
        alignment: Alignment.centerRight,
        child: Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: kTextMedium,
          ),
        ),
      ),
      secondary: Icon(icon, color: kPrimaryTeal),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: kPrimaryTeal,
      title: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: kTextDark,
          ),
        ),
      ),
      subtitle: Align(
        alignment: Alignment.centerRight,
        child: Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: kTextMedium,
          ),
        ),
      ),
      secondary: Icon(icon, color: kPrimaryTeal),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      controlAffinity: ListTileControlAffinity.leading, // Box on the left for RTL consistency
    );
  }
}
