// file: lib/features/security/screens/security_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _isLoading = true;
  String _errorMessage = '';
  final _supabase = Supabase.instance.client;

  // Connected Devices
  final List<Map<String, String>> _devices = [];

  // Security Log Events
  final List<Map<String, String>> _securityLogs = [];


  Future<void> _deleteDeviceFromDb(String id) async {
    if (id == 'current') return;
    try {
      await _supabase
          .from('student_devices')
          .delete()
          .eq('id', id);
    } catch (_) {}
  }

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
            onPressed: () async {
              final deviceId = device['id'];
              setState(() {
                _devices.removeAt(index);
              });
              if (deviceId != null && deviceId != 'current') {
                await _deleteDeviceFromDb(deviceId);
              }
              if (context.mounted) {
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
            onPressed: () async {
              final user = _supabase.auth.currentUser;
              setState(() {
                _devices.removeWhere((d) => d['isCurrent'] != 'true');
              });
              if (user != null) {
                try {
                  await _supabase
                      .from('student_devices')
                      .delete()
                      .eq('student_id', user.id);
                } catch (_) {}
              }
              if (context.mounted) {
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
              }
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
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        _devices.clear();
        _securityLogs.clear();

        _twoFactorEnabled = user.userMetadata?['two_factor_enabled'] == true;

        _devices.add({
          'id': 'current',
          'name': 'الجهاز الحالي',
          'os': 'نشط الآن',
          'lastActive': 'نشط الآن',
          'isCurrent': 'true',
        });

        try {
          final sessionsRes = await _supabase
              .from('student_devices')
              .select('id, device_platform, created_at')
              .eq('student_id', user.id);
          if (sessionsRes.isNotEmpty) {
            for (final d in sessionsRes as List) {
              _devices.add({
                'id': d['id']?.toString() ?? '',
                'name': d['device_platform'] == 'android' ? 'جهاز أندرويد' : 'جهاز iOS',
                'os': d['device_platform'] ?? 'غير معروف',
                'lastActive': d['created_at']?.toString().split('T')[0] ?? 'غير معروف',
                'isCurrent': 'false',
              });
            }
          }
        } catch (_) {}

        if (user.lastSignInAt != null) {
          _securityLogs.add({
            'event': 'تسجيل دخول ناجح',
            'device': 'تطبيق الهاتف',
            'time': user.lastSignInAt!.split('T')[0],
            'status': 'success',
          });
        }
        _securityLogs.add({
          'event': 'تحديث إعدادات الحساب',
          'device': 'تطبيق الهاتف',
          'time': user.updatedAt?.split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
          'status': 'info',
        });
      }
    } catch (e) {
      setState(() { _errorMessage = 'فشل تحميل بيانات الأمان'; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
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
          'إعدادات الأمان',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryTeal))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(_errorMessage, textAlign: TextAlign.center, style: GoogleFonts.cairo(color: kError, fontSize: 14)),
                  ),
                )
              : SingleChildScrollView(
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
