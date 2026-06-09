// file: lib/features/profile/screens/advisor_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class AdvisorProfileScreen extends StatefulWidget {
  const AdvisorProfileScreen({super.key});

  @override
  State<AdvisorProfileScreen> createState() => _AdvisorProfileScreenState();
}

class _AdvisorProfileScreenState extends State<AdvisorProfileScreen> {
  String _officeLocation = 'مبنى الحاسبات - الدور الثالث - مكتب 302';
  String _officeHours = 'الأحد والثلاثاء: 10:00 ص - 01:00 م';

  void _editOfficeInfo() {
    final locationController = TextEditingController(text: _officeLocation);
    final hoursController = TextEditingController(text: _officeHours);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تحديث بيانات المكتب والإرشاد',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('موقع المكتب', style: GoogleFonts.cairo(fontSize: 12, color: kTextMedium)),
              const SizedBox(height: 6),
              TextField(
                controller: locationController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kScaffoldBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Text('الساعات المكتبية والإرشادية', style: GoogleFonts.cairo(fontSize: 12, color: kTextMedium)),
              const SizedBox(height: 6),
              TextField(
                controller: hoursController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kScaffoldBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: kTextMedium)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _officeLocation = locationController.text;
                _officeHours = hoursController.text;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم تحديث البيانات بنجاح',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: kSuccess,
                ),
              );
            },
            child: Text(
              'حفظ',
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
          'ملف المرشد الأكاديمي',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              color: kDarkNavy,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: kPrimaryTeal.withValues(alpha: 0.2),
                    child: const CircleAvatar(
                      radius: 46,
                      backgroundColor: kPrimaryTeal,
                      child: Icon(Icons.school_rounded, size: 54, color: kWhite),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'د. خالد بن عبد الرحمن السليمان',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18, color: kWhite),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'قسم علوم الحاسب ومعلومات الشبكات',
                    style: GoogleFonts.cairo(fontSize: 12, color: kWhite.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'كود المرشد: ADV-40892',
                    style: GoogleFonts.inter(fontSize: 12, color: kWhite.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // KPI Statistics
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          title: 'الطلاب المسترشدين',
                          value: '45 طالب',
                          icon: Icons.people_outline_rounded,
                          color: kPrimaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'حالات تحت الإنذار',
                          value: '8 طلاب',
                          icon: Icons.warning_amber_rounded,
                          color: kError,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Office and Location info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: kPrimaryTeal),
                        onPressed: _editOfficeInfo,
                      ),
                      Text(
                        'معلومات الاتصال والمكتب',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          title: 'موقع المكتب',
                          value: _officeLocation,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.access_time_rounded,
                          title: 'الساعات الإرشادية والمكتبية',
                          value: _officeHours,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.mail_outline_rounded,
                          title: 'البريد الإلكتروني الجامعي',
                          value: 'k.sulaiman@acadexa.edu.eg',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Advisees Lists short link
                  Text(
                    'المهام الإرشادية السريعة',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {},
                          leading: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                          title: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'طلبات التسجيل المعلقة',
                              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: kTextDark),
                            ),
                          ),
                          trailing: const Icon(Icons.pending_actions_rounded, color: kWarning),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          onTap: () {},
                          leading: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                          title: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'تقارير الأداء الأكاديمي للطلاب',
                              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: kTextDark),
                            ),
                          ),
                          trailing: const Icon(Icons.analytics_outlined, color: kPrimaryTeal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark),
          ),
          Text(
            title,
            style: GoogleFonts.cairo(fontSize: 11, color: kTextMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(fontSize: 11, color: kTextMedium),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: kTextDark),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Icon(icon, color: kPrimaryTeal, size: 22),
      ],
    );
  }
}
