// file: lib/features/support/screens/report_issue_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../error_handling/screens/success_screen.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _issueType;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isSending = false;
  bool _hasAttachment = false;

  final List<String> _issueTypes = [
    'مشكلة تقنية',
    'خطأ في البيانات',
    'اقتراح تحسين',
    'أخرى',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_issueType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار نوع المشكلة', textAlign: TextAlign.right, style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() { _isSending = true; });
    try {
      // Simulate API call - would insert into support_tickets table when it exists
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              title: 'تم إرسال البلاغ بنجاح!',
              subtitle: 'شكراً لتواصلك معنا. سيقوم فريق الدعم بمراجعة البلاغ والتواصل معك في أقرب وقت.',
              primaryButtonLabel: 'العودة للرئيسية',
              onPrimaryPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isSending = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال البلاغ: ${e.toString()}', textAlign: TextAlign.right, style: GoogleFonts.cairo()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _pickAttachment() {
    // Simulated attachment picking
    setState(() {
      _hasAttachment = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرفاق لقطة الشاشة بنجاح',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: kSuccess,
      ),
    );
  }

  void _removeAttachment() {
    setState(() {
      _hasAttachment = false;
    });
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
          'الإبلاغ عن مشكلة',
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
                // Title Help
                Text(
                  'هل واجهت مشكلة أو لديك اقتراح؟',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                Text(
                  'يسعدنا سماع ملاحظاتك لتحسين المنصة باستمرار.',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: kTextMedium,
                  ),
                ),
                const SizedBox(height: 24),

                // Dropdown selection
                Text(
                  'نوع المشكلة *',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kDivider),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      value: _issueType,
                      hint: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'اختر نوع البلاغ',
                          style: GoogleFonts.cairo(color: kTextLight),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_drop_down, color: kPrimaryTeal),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      isExpanded: true,
                      dropdownColor: kWhite,
                      alignment: Alignment.centerRight,
                      items: _issueTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              type,
                              style: GoogleFonts.cairo(color: kTextDark),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _issueType = val;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title input field
                Text(
                  'عنوان المشكلة *',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(color: kTextDark),
                  decoration: InputDecoration(
                    hintText: 'اكتب عنواناً مختصراً للمشكلة',
                    hintStyle: GoogleFonts.cairo(color: kTextLight),
                    filled: true,
                    fillColor: kWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kDivider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kPrimaryTeal, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال عنوان المشكلة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description input field
                Text(
                  'الوصف بالتفصيل *',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 5,
                  style: GoogleFonts.cairo(color: kTextDark),
                  decoration: InputDecoration(
                    hintText: 'اكتب شرحاً تفصيلياً للمشكلة والخطوات اللازمة لإعادة إظهارها',
                    hintStyle: GoogleFonts.cairo(color: kTextLight),
                    filled: true,
                    fillColor: kWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kDivider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kPrimaryTeal, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال وصف المشكلة بالتفصيل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Attachment (Screenshot picker preview)
                Text(
                  'إرفاق صورة أو لقطة شاشة (اختياري)',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 8),
                if (!_hasAttachment)
                  InkWell(
                    onTap: _pickAttachment,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kDivider, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined, color: kPrimaryTeal, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'اضغط هنا لإرفاق صورة',
                            style: GoogleFonts.cairo(fontSize: 12, color: kTextMedium),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kDivider),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _removeAttachment,
                          icon: const Icon(Icons.delete_outline, color: kError),
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'screenshot_report.png',
                                  style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: kTextDark),
                                ),
                                Text(
                                  '1.2 MB',
                                  style: GoogleFonts.cairo(fontSize: 11, color: kTextLight),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: kLightBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image, color: kPrimaryBlue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      foregroundColor: kWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kWhite,
                            ),
                          )
                        : Text(
                            'إرسال البلاغ',
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
      ),
    );
  }
}
