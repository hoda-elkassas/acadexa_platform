// file: lib/features/notifications/screens/send_notification_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../error_handling/screens/success_screen.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String _notificationType = 'عام'; // عام، عاجل، تذكير، ترويجي، أكاديمي
  final List<String> _audienceTargets = ['الطلاب', 'المرشدون الأكاديميون']; // Multiple select chips
  bool _hasImage = false;
  bool _isScheduled = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSending = false;

  final List<String> _allAudiences = ['الجميع', 'الطلاب', 'المرشدون الأكاديميون', 'المشرفون'];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _pickImage() {
    setState(() {
      _hasImage = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت إضافة الصورة المرفقة',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: kSuccess,
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _hasImage = false;
    });
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حفظ المسودة بنجاح',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: kSuccess,
      ),
    );
  }

  void _confirmAndSend() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isScheduled && (_selectedDate == null || _selectedTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تحديد تاريخ ووقت الجدولة للاستمرار',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: kError,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تأكيد الإرسال',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          _isScheduled
              ? 'هل أنت متأكد من جدولة هذا الإشعار للإرسال لاحقاً؟'
              : 'هل أنت متأكد من إرسال هذا الإشعار الآن؟ سيتم بثه للجمهور المستهدف فوراً.',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: kTextMedium),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendNotification();
            },
            child: Text(
              'تأكيد الإرسال',
              style: GoogleFonts.cairo(color: kPrimaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _sendNotification() async {
    setState(() {
      _isSending = true;
    });

    // Simulated API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSending = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: _isScheduled ? 'تمت جدولة الإشعار بنجاح!' : 'تم إرسال الإشعار بنجاح!',
            subtitle: _isScheduled
                ? 'تم حفظ الإشعار وجدولته للبث التلقائي في الموعد المحدد.'
                : 'تم بث الإشعار بنجاح لكافة المستخدمين في الفئة المستهدفة.',
            primaryButtonLabel: 'العودة للرئيسية',
            onPrimaryPressed: () => Navigator.of(context).pop(),
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
          'إرسال إشعار للطلاب',
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
                // 1. Details Card
                _buildSectionTitle('تفاصيل الإشعار'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Title input
                      Text(
                        'عنوان الإشعار *',
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.cairo(color: kTextDark),
                        decoration: InputDecoration(
                          hintText: 'أدخل عنواناً مختصراً للإشعار',
                          hintStyle: GoogleFonts.cairo(color: kTextLight, fontSize: 13),
                          filled: true,
                          fillColor: kScaffoldBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'عنوان الإشعار مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Body input
                      Text(
                        'محتوى الإشعار *',
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bodyController,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        maxLines: 4,
                        style: GoogleFonts.cairo(color: kTextDark),
                        decoration: InputDecoration(
                          hintText: 'أدخل نص الإشعار هنا...',
                          hintStyle: GoogleFonts.cairo(color: kTextLight, fontSize: 13),
                          filled: true,
                          fillColor: kScaffoldBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'محتوى الإشعار مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dropdown type
                      Text(
                        'نوع الإشعار *',
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: kScaffoldBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _notificationType,
                            isExpanded: true,
                            dropdownColor: kWhite,
                            icon: const Icon(Icons.keyboard_arrow_down, color: kPrimaryTeal),
                            items: ['عام', 'عاجل', 'تذكير', 'ترويجي', 'أكاديمي'].map((type) {
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
                              if (val != null) {
                                setState(() {
                                  _notificationType = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Audience Targets
                _buildSectionTitle('إعدادات الجمهور المستهدف'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الجمهور المستهدف *',
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: kTextDark),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        children: _allAudiences.map((aud) {
                          final isSelected = _audienceTargets.contains(aud);
                          return FilterChip(
                            label: Text(
                              aud,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: isSelected ? kWhite : kTextDark,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _audienceTargets.add(aud);
                                } else {
                                  _audienceTargets.remove(aud);
                                }
                              });
                            },
                            selectedColor: kPrimaryTeal,
                            checkmarkColor: kWhite,
                            backgroundColor: kScaffoldBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Image attachment (Optional)
                _buildSectionTitle('صورة مرفقة (اختياري)'),
                const SizedBox(height: 12),
                if (!_hasImage)
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryTeal,
                      side: const BorderSide(color: kPrimaryTeal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text('إضافة صورة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: kDivider)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: const Icon(Icons.delete_outline, color: kError), onPressed: _removeImage),
                        Row(
                          children: [
                            Text(
                              'image_attachment.jpg (450 KB)',
                              style: GoogleFonts.cairo(fontSize: 12, color: kTextDark),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: kLightBlue, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.image, color: kPrimaryBlue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // 4. Scheduling
                _buildSectionTitle('إعدادات الجدولة'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        value: _isScheduled,
                        activeColor: kPrimaryTeal,
                        title: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'جدولة الإرسال لاحقاً',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _isScheduled = val;
                          });
                        },
                      ),
                      if (_isScheduled) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _selectTime,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: kScaffoldBg, borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.access_time, color: kPrimaryTeal),
                                      Text(
                                        _selectedTime != null ? _selectedTime!.format(context) : 'اختر وقت الإرسال',
                                        style: GoogleFonts.cairo(color: kTextDark, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _selectDate,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: kScaffoldBg, borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.calendar_today, color: kPrimaryTeal),
                                      Text(
                                        _selectedDate != null
                                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                            : 'اختر تاريخ الإرسال',
                                        style: GoogleFonts.cairo(color: kTextDark, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Live Preview Card
                _buildSectionTitle('معاينة الإشعار المباشرة'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kPrimaryTeal.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: kPrimaryTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _notificationType,
                              style: GoogleFonts.cairo(fontSize: 10, color: kPrimaryTeal, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            'الآن',
                            style: GoogleFonts.cairo(fontSize: 10, color: kTextLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _titleController.text.isEmpty ? 'عنوان الإشعار المباشر' : _titleController.text,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _titleController.text.isEmpty ? kTextLight : kTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _bodyController.text.isEmpty ? 'محتوى الإشعار وتفاصيله ستظهر هنا للطلاب في الفئة المستهدفة...' : _bodyController.text,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: _bodyController.text.isEmpty ? kTextLight : kTextMedium,
                        ),
                      ),
                      if (_hasImage) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: kScaffoldBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.image, size: 40, color: kPrimaryTeal),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 6. Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _confirmAndSend,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            foregroundColor: kWhite,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: kWhite),
                                )
                              : Text(
                                  _isScheduled ? 'جدولة الإرسال' : 'إرسال الآن',
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _isSending ? null : _saveDraft,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kTextDark,
                            side: const BorderSide(color: kDivider),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'حفظ كمسودة',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
