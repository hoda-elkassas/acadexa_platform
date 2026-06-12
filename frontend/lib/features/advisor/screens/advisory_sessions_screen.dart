// file: lib/features/advisor/screens/advisory_sessions_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class AdvisorySessionsScreen extends StatefulWidget {
  const AdvisorySessionsScreen({super.key});

  @override
  State<AdvisorySessionsScreen> createState() => _AdvisorySessionsScreenState();
}

class _AdvisorySessionsScreenState extends State<AdvisorySessionsScreen> {
  bool _isLoading = false;
  String _errorMessage = '';
  final List<Map<String, dynamic>> _notes = [];
  final List<Map<String, dynamic>> _studentsList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final supabase = Supabase.instance.client;

      // 1. Fetch advisor notes
      final notesResponse = await supabase
          .from('advisor_notes')
          .select('*, students(name, student_code)')
          .order('created_at', ascending: false);
      
      _notes.clear();
      if (notesResponse.isNotEmpty) {
        for (final item in notesResponse) {
          final createdAtStr = item['created_at']?.toString() ?? '';
          String date = '';
          String time = '';
          if (createdAtStr.contains('T')) {
            final parts = createdAtStr.split('T');
            date = parts[0];
            time = parts[1].split('.')[0];
          }

          _notes.add({
            'id': item['id'],
            'student_name': item['students']?['name'] ?? 'طالب غير معروف',
            'student_code': item['students']?['student_code'] ?? item['student_id']?.toString() ?? '',
            'student_id': item['student_id']?.toString() ?? '',
            'date': date,
            'time': time,
            'note': item['note'] ?? '',
            'is_private': item['is_private'] ?? false,
          });
        }
      }

      // 2. Fetch students for new note dropdown
      final studentsResponse = await supabase
          .from('students')
          .select('id, name, student_code')
          .eq('is_active', true)
          .order('name');
      
      _studentsList.clear();
      if (studentsResponse.isNotEmpty) {
        for (final item in studentsResponse) {
          _studentsList.add({
            'id': item['id'],
            'name': item['name'],
            'code': item['student_code'],
          });
        }
      }

    } catch (e) {
      _errorMessage = 'فشل تحميل البيانات من قاعدة البيانات: ${e.toString()}';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNote(int index, String noteId) async {
    final confirmed = await AcDialog.show(
      context,
      title: 'حذف الملاحظة',
      message: 'هل أنت متأكد من حذف هذه الملاحظة الإرشادية؟ لا يمكن التراجع عن هذا الإجراء.',
      type: AcDialogType.danger,
      confirmLabel: 'حذف',
      cancelLabel: 'إلغاء',
    );

    if (confirmed != true) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('advisor_notes').delete().eq('id', noteId);
      setState(() {
        _notes.removeAt(index);
      });
      if (mounted) {
        AcSnackbar.show(
          context,
          message: 'تم حذف الملاحظة بنجاح',
          type: AcToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AcSnackbar.show(
          context,
          message: 'فشل حذف الملاحظة: ${e.toString()}',
          type: AcToastType.error,
        );
      }
    }
  }

  void _showAddNoteDialog() {
    String? selectedStudentId;
    final noteController = TextEditingController();
    bool isPrivate = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.brCard,
              ),
              title: Text(
                'إضافة ملاحظة إرشادية جديدة',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 450,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Student Selector
                      Text(
                        'اختر الطالب',
                        style: AppTypography.labelMedium,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(borderRadius: AppRadius.brInput),
                          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                        ),
                        value: selectedStudentId,
                        hint: const Text('اختر طالب من القائمة', textDirection: TextDirection.rtl),
                        items: _studentsList.map((s) {
                          return DropdownMenuItem<String>(
                            value: s['id'],
                            child: Text(
                              '${s['name']} (${s['code']})',
                              textDirection: TextDirection.rtl,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedStudentId = val;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Note text area
                      Text(
                        'الملاحظة الإرشادية',
                        style: AppTypography.labelMedium,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: noteController,
                        maxLines: 5,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          hintText: 'اكتب تفاصيل الجلسة الإرشادية أو الملاحظات هنا...',
                          border: OutlineInputBorder(borderRadius: AppRadius.brInput),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Private note switch
                      CheckboxListTile(
                        value: isPrivate,
                        title: Text(
                          'ملاحظة خاصة (تظهر للمرشد فقط)',
                          style: AppTypography.bodyMedium,
                          textDirection: TextDirection.rtl,
                        ),
                        onChanged: (val) {
                          setDialogState(() {
                            isPrivate = val ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.brButton),
                  ),
                  onPressed: () async {
                    if (selectedStudentId == null) {
                      AcSnackbar.show(context, message: 'يرجى اختيار الطالب أولاً', type: AcToastType.warning);
                      return;
                    }
                    if (noteController.text.trim().isEmpty) {
                      AcSnackbar.show(context, message: 'يرجى كتابة نص الملاحظة', type: AcToastType.warning);
                      return;
                    }

                    try {
                      final supabase = Supabase.instance.client;
                      final user = supabase.auth.currentUser;
                      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

                      await supabase.from('advisor_notes').insert({
                        'student_id': selectedStudentId,
                        'advisor_id': user.id,
                        'note': noteController.text.trim(),
                        'is_private': isPrivate,
                      });

                      Navigator.pop(context);
                      _loadData();
                      AcSnackbar.show(context, message: 'تم حفظ الملاحظة بنجاح', type: AcToastType.success);
                    } catch (e) {
                      AcSnackbar.show(context, message: 'فشل الحفظ: ${e.toString()}', type: AcToastType.error);
                    }
                  },
                  child: const Text('حفظ الملاحظة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary500,
        onPressed: _showAddNoteDialog,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text('إضافة ملاحظة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الملاحظات وسجلات الإرشاد الأكاديمي',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'توثيق ومتابعة الجلسات الاستشارية والملاحظات الخاصة بالطلاب.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _notes.isEmpty
                  ? const Center(
                      child: AcEmptyState(
                        title: 'لا يوجد ملاحظات مسجلة',
                        message: 'لا توجد ملاحظات إرشاد أكاديمي مسجلة في الوقت الحالي. اضغط على إضافة ملاحظة للبدء.',
                        icon: Icon(Icons.comment_bank_rounded),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        final isPrivate = note['is_private'] as bool;

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.brCard,
                            side: BorderSide(color: AppColors.border),
                          ),
                          color: AppColors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
                                      child: const Icon(Icons.assignment_rounded, color: AppColors.primary600),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            note['student_name'],
                                            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'كود الطالب: ${note['student_code']} | التاريخ: ${note['date']} ${note['time']}',
                                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPrivate
                                            ? AppColors.danger500.withValues(alpha: 0.1)
                                            : AppColors.success500.withValues(alpha: 0.1),
                                        borderRadius: AppRadius.brPill,
                                      ),
                                      child: Text(
                                        isPrivate ? 'خاصة بالمرشد' : 'عامة',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: isPrivate ? AppColors.danger600 : AppColors.success600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    AcIconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger500),
                                      tooltip: 'حذف الملاحظة',
                                      onPressed: () => _deleteNote(index, note['id']?.toString() ?? ''),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                                  child: Divider(),
                                ),
                                Text(
                                  note['note'],
                                  style: AppTypography.bodyMedium,
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
