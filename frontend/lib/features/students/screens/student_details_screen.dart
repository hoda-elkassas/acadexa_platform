// file: lib/features/students/screens/student_details_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> studentSummary;

  const StudentDetailsScreen({
    super.key,
    required this.studentSummary,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';

  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _complianceCourses = [];
  List<Map<String, dynamic>> _advisorNotes = [];
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllStudentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadAllStudentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final studentId = widget.studentSummary['id'];

      // 1. Fetch semesters/grades
      final semRes = await _supabase
          .from('student_semesters')
          .select()
          .eq('student_id', studentId)
          .order('semester_number', ascending: true);
      _semesters = List<Map<String, dynamic>>.from(semRes as List);

      // 2. Fetch compliance/courses remaining
      final compRes = await _supabase
          .from('student_courses')
          .select()
          .eq('student_id', studentId);
      _complianceCourses = List<Map<String, dynamic>>.from(compRes as List);

      // 3. Fetch advisor notes
      final notesRes = await _supabase
          .from('advisor_notes')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      _advisorNotes = List<Map<String, dynamic>>.from(notesRes as List);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل سجل الطالب: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addAdvisorNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      final studentId = widget.studentSummary['id'];

      await _supabase.from('advisor_notes').insert({
        'student_id': studentId,
        'advisor_id': user.id,
        'note_text': text,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      _noteController.clear();
      AcSnackbar.show(
        context,
        message: 'تمت إضافة ملاحظة الإرشاد بنجاح',
        type: AcToastType.success,
      );
      _loadAllStudentData();
    } catch (e) {
      if (!mounted) return;
      AcSnackbar.show(
        context,
        message: 'فشل إضافة الملاحظة: ${e.toString()}',
        type: AcToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.studentSummary;
    final gpaVal = s['calculated_gpa'] ?? s['cumulative_gpa'];
    final gpa = double.tryParse(gpaVal?.toString() ?? '') ?? 0.0;
    final isAtRisk = gpa < 2.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الأكاديمي: ${s['full_name']}'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: AcLoadingState())
          : _errorMessage.isNotEmpty
              ? AcErrorState(
                  title: 'خطأ تحميل البيانات',
                  message: _errorMessage,
                  onRetry: _loadAllStudentData,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Header Info Card ────────────────────────────────
                      Card(
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.brCard,
                          side: BorderSide(color: AppColors.border),
                        ),
                        color: AppColors.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
                                child: Text(
                                  (s['full_name']?.toString() ?? 'U').substring(0, 1).toUpperCase(),
                                  style: AppTypography.h3.copyWith(
                                    color: AppColors.primary600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          s['full_name']?.toString() ?? '-',
                                          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isAtRisk
                                                ? AppColors.danger500.withValues(alpha: 0.1)
                                                : AppColors.success500.withValues(alpha: 0.1),
                                            borderRadius: AppRadius.brPill,
                                          ),
                                          child: Text(
                                            isAtRisk ? 'إنذار أكاديمي' : 'منتظم',
                                            style: AppTypography.bodySmall.copyWith(
                                              color: isAtRisk ? AppColors.danger500 : AppColors.success500,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      s['email']?.toString() ?? '-',
                                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'القسم: ${s['department_name'] ?? "-"} | سنة الالتحاق: ${s['enrollment_year'] ?? "-"}',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              // GPA Card
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.primary500.withValues(alpha: 0.05),
                                  borderRadius: AppRadius.brCard,
                                  border: Border.all(color: AppColors.primary500.withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  children: [
                                    Text('المعدل التراكمي', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      gpa.toStringAsFixed(2),
                                      style: AppTypography.h3.copyWith(
                                        color: isAtRisk ? AppColors.danger500 : AppColors.primary600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ─── Tab Bar Navigation ──────────────────────────────
                      Container(
                        color: AppColors.surface,
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: AppColors.primary500,
                          labelColor: AppColors.primary500,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'الفصول الدراسية'),
                            Tab(text: 'الامتثال للخطة الدراسية'),
                            Tab(text: 'سجل الإرشاد الأكاديمي'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ─── Tab Bar Views ───────────────────────────────────
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // 1. Semesters View
                            _buildSemestersTab(),

                            // 2. Compliance View
                            _buildComplianceTab(),

                            // 3. Advisor Notes View
                            _buildAdvisorNotesTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSemestersTab() {
    if (_semesters.isEmpty) {
      return const Center(
        child: AcEmptyState(
          title: 'لا يوجد فصول مسجلة',
          message: 'لم يتم إدخال درجات أو فصول دراسية لهذا الطالب بعد.',
          icon: Icon(Icons.school_outlined),
        ),
      );
    }

    return ListView.builder(
      itemCount: _semesters.length,
      itemBuilder: (context, index) {
        final sem = _semesters[index];
        final sgpa = double.tryParse(sem['semester_gpa']?.toString() ?? '') ?? 0.0;
        final cgpa = double.tryParse(sem['cumulative_gpa']?.toString() ?? '') ?? 0.0;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.brCard,
            side: BorderSide(color: AppColors.border),
          ),
          color: AppColors.surface,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            title: Text(
              'الفصل الدراسي ${sem['semester_number']}',
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'المعدل الفصلي: ${sgpa.toStringAsFixed(2)} | المعدل التراكمي: ${cgpa.toStringAsFixed(2)}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            trailing: CircleAvatar(
              backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
              child: const Icon(Icons.chevron_left_rounded, color: AppColors.primary600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplianceTab() {
    if (_complianceCourses.isEmpty) {
      return const Center(
        child: AcEmptyState(
          title: 'لا توجد مواد مسجلة',
          message: 'هذا الطالب لم يسجل في أي مواد من الخطة بعد.',
          icon: Icon(Icons.menu_book_outlined),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.brCard,
        side: BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _complianceCourses.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final course = _complianceCourses[index];
          final completed = course['status'] == 'COMPLETED';

          return ListTile(
            leading: Icon(
              completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: completed ? AppColors.success500 : AppColors.textSecondary,
            ),
            title: Text(
              course['course_code']?.toString() ?? 'مادة',
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'الدرجة الحاصل عليها: ${course['grade'] ?? "لم ترصد بعد"}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: completed
                    ? AppColors.success500.withValues(alpha: 0.1)
                    : AppColors.warning500.withValues(alpha: 0.1),
                borderRadius: AppRadius.brPill,
              ),
              child: Text(
                completed ? 'مكتملة' : 'قيد الدراسة',
                style: AppTypography.bodySmall.copyWith(
                  color: completed ? AppColors.success500 : AppColors.warning500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvisorNotesTab() {
    return Column(
      children: [
        // Add Note Input Bar
        Row(
          children: [
            Expanded(
              child: AcInputField(
                controller: _noteController,
                label: 'إضافة توصية أو ملاحظة إرشادية جديدة',
                hint: 'أدخل الملاحظة هنا...',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: AcButton(
                label: 'إرسال',
                variant: AcButtonVariant.primary,
                onPressed: _addAdvisorNote,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // List of notes
        Expanded(
          child: _advisorNotes.isEmpty
              ? const Center(
                  child: AcEmptyState(
                    title: 'لا يوجد ملاحظات إرشادية',
                    message: 'لم يتم تسجيل أي ملاحظات إرشادية لهذا الطالب بعد.',
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                  ),
                )
              : ListView.builder(
                  itemCount: _advisorNotes.length,
                  itemBuilder: (context, index) {
                    final note = _advisorNotes[index];
                    final dateStr = note['created_at']?.toString() ?? '';
                    final date = DateTime.tryParse(dateStr)?.toLocal().toString().split(' ')[0] ?? '';

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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'توصية مرشد',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.primary500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  date,
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              note['note_text']?.toString() ?? '',
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
