// file: lib/features/security/screens/security_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import 'change_password_screen.dart';
import 'two_factor_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _twoFactorEnabled = false;

  // Mock Connected Devices
  final List<Map<String, String>> _devices = [
    {
      'id': '1',
      'name': 'MacBook Pro 16"',
      'os': 'macOS Sequoia',
      'lastActive': 'نشط الآن (الجهاز الحالي)',
      'isCurrent': 'true',
    },
    {
      'id': '2',
      'name': 'iPhone 15 Pro Max',
      'os': 'iOS 17.5',
      'lastActive': 'منذ ساعتين',
      'isCurrent': 'false',
    },
    {
      'id': '3',
      'name': 'Samsung Galaxy S24 Ultra',
      'os': 'Android 14',
      'lastActive': 'منذ يومين',
      'isCurrent': 'false',
    },
  ];

  // Mock Security Log Events
  final List<Map<String, String>> _securityLogs = [
    {
      'event': 'تسجيل دخول ناجح',
      'device': 'MacBook Pro - Chrome',
      'time': 'اليوم، 10:24 ص',
      'status': 'success',
    },
    {
      'event': 'تغيير كلمة المرور',
      'device': 'من خلال المتصفح',
      'time': 'أمس، 04:15 م',
      'status': 'warning',
    },
    {
      'event': 'محاولة تسجيل دخول فاشلة',
      'device': 'IP: 192.168.1.45',
      'time': '3 يونيو 2026، 11:02 ص',
      'status': 'error',
    },
    {
      'event': 'تفعيل المصادقة الثنائية',
      'device': 'من خلال التطبيق',
      'time': '1 يونيو 2026، 09:30 ص',
      'status': 'success',
    },
  ];

  void _logoutDevice(int index) {
    final device = _devices[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تسجيل خروج من الجهاز',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد تسجيل الخروج من جهاز ${device['name']}؟ سيتعين عليك إدخال بيانات الاعتماد مجدداً للدخول.',
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
              setState(() {
                _devices.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم تسجيل الخروج من الجهاز بنجاح',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: kSuccess,
                ),
              );
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

  void _logoutAllDevices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تسجيل خروج من جميع الأجهزة',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(color: kError, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'تحذير: سيتم تسجيل الخروج من جميع أجهزتك المتصلة باستثناء هذا الجهاز الحالي. هل تريد المتابعة؟',
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
              setState(() {
                _devices.removeWhere((d) => d['isCurrent'] != 'true');
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم تسجيل الخروج من جميع الأجهزة الأخرى بنجاح',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: kSuccess,
                ),
              );
            },
            child: Text(
              'تسجيل خروج الكل',
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
          'إعدادات الأمان',
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
              // 1. Password and 2FA Navigation Cards
              _buildSectionTitle('الأمان الأساسي'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                      leading: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kTextLight),
                      title: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'تغيير كلمة المرور',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark),
                        ),
                      ),
                      subtitle: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'قم بتحديث كلمة المرور الخاصة بحسابك دورياً لحمايته.',
                          style: GoogleFonts.cairo(fontSize: 12, color: kTextMedium),
                        ),
                      ),
                      trailing: const Icon(Icons.lock_outline_rounded, color: kPrimaryTeal),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TwoFactorScreen(enabled: _twoFactorEnabled),
                          ),
                        );
                        if (result != null && result is bool) {
                          setState(() {
                            _twoFactorEnabled = result;
                          });
                        }
                      },
                      leading: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kTextLight),
                      title: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'المصادقة الثنائية (2FA)',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark),
                        ),
                      ),
                      subtitle: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _twoFactorEnabled ? 'نشطة - حسابك محمي بطبقة أمان إضافية.' : 'غير مفعلة - ننصح بتفعيلها فوراً لحماية حسابك.',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _twoFactorEnabled ? kSuccess : kError,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        _twoFactorEnabled ? Icons.security_rounded : Icons.gpp_maybe_outlined,
                        color: _twoFactorEnabled ? kSuccess : kError,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 2. Connected Devices Section
              _buildSectionTitle('الأجهزة المتصلة'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _devices.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        final isCurrent = device['isCurrent'] == 'true';
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: isCurrent
                              ? null
                              : TextButton(
                                  onPressed: () => _logoutDevice(index),
                                  style: TextButton.styleFrom(foregroundColor: kError),
                                  child: Text('تسجيل خروج', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                          title: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              device['name']!,
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark),
                            ),
                          ),
                          subtitle: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${device['os']} • ${device['lastActive']}',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: isCurrent ? kPrimaryTeal : kTextMedium,
                              ),
                            ),
                          ),
                          trailing: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCurrent ? kPrimaryTeal.withValues(alpha: 0.1) : kDivider.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              device['os']!.toLowerCase().contains('mac') || device['os']!.toLowerCase().contains('windows')
                                  ? Icons.laptop_mac_rounded
                                  : Icons.phone_iphone_rounded,
                              color: isCurrent ? kPrimaryTeal : kTextMedium,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                    if (_devices.length > 1) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _logoutAllDevices,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kError.withValues(alpha: 0.1),
                              foregroundColor: kError,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: Text(
                              'تسجيل خروج من جميع الأجهزة الأخرى',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 3. Security Log
              _buildSectionTitle('سجل النشاطات الأمنية (آخر 4 عمليات)'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _securityLogs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final log = _securityLogs[index];
                    Color statusColor = kSuccess;
                    if (log['status'] == 'error') {
                      statusColor = kError;
                    } else if (log['status'] == 'warning') {
                      statusColor = kWarning;
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          log['event']!,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: kTextDark),
                        ),
                      ),
                      subtitle: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${log['device']} • ${log['time']}',
                          style: GoogleFonts.cairo(fontSize: 11, color: kTextMedium),
                        ),
                      ),
                      trailing: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: kTextDark,
        ),
      ),
    );
  }
}
