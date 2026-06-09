// file: lib/features/students/screens/students_list_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/themes/app_radius.dart';
import '../../../core/themes/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import 'student_details_screen.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  
  String _searchQuery = '';
  String _selectedDept = 'الكل';
  List<String> _departmentsList = ['الكل'];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final res = await _supabase.from('student_full_summary').select();
      final data = List<Map<String, dynamic>>.from(res as List);
      
      // Extract unique departments
      final depts = {'الكل'};
      for (final s in data) {
        final dName = s['department_name']?.toString();
        if (dName != null && dName.isNotEmpty) {
          depts.add(dName);
        }
      }

      setState(() {
        _allStudents = data;
        _departmentsList = depts.toList();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل بيانات الطلاب: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var list = _allStudents;
    
    if (_searchQuery.isNotEmpty) {
      list = list.where((s) {
        final name = s['full_name']?.toString().toLowerCase() ?? '';
        final email = s['email']?.toString().toLowerCase() ?? '';
        final id = s['id']?.toString().toLowerCase() ?? '';
        final q = _searchQuery.toLowerCase();
        return name.contains(q) || email.contains(q) || id.contains(q);
      }).toList();
    }

    if (_selectedDept != 'الكل') {
      list = list.where((s) => s['department_name']?.toString() == _selectedDept).toList();
    }

    setState(() {
      _filteredStudents = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: AcLoadingState());
    }

    if (_errorMessage.isNotEmpty) {
      return AcErrorState(
        title: 'حدث خطأ أثناء تحميل الطلاب',
        message: _errorMessage,
        onRetry: _fetchStudents,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header filters ──────────────────────────────────────────
          Card(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brCard,
              side: BorderSide(color: AppColors.border),
            ),
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AcSearchField(
                      controller: _searchController,
                      hint: 'بحث باسم الطالب، البريد الإلكتروني أو الرقم الجامعي...',
                      onChanged: (val) {
                        setState(() => _searchQuery = val.trim());
                        _applyFilters();
                      },
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 1,
                    child: AcDropdownField<String>(
                      label: 'القسم الدراسي',
                      value: _selectedDept,
                      onChanged: (val) {
                        setState(() => _selectedDept = val ?? 'الكل');
                        _applyFilters();
                      },
                      items: _departmentsList.map((dept) {
                        return DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ─── Students count summary ──────────────────────────────────
          Row(
            children: [
              Text(
                'إجمالي الطلاب المطابقين للبحث: ',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '${_filteredStudents.length}',
                style: AppTypography.h4.copyWith(color: AppColors.primary500, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ─── Table ───────────────────────────────────────────────────
          Expanded(
            child: Card(
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.brCard,
                side: BorderSide(color: AppColors.border),
              ),
              color: AppColors.surface,
              child: _filteredStudents.isEmpty
                  ? const AcEmptyState(
                      title: 'لا يوجد طلاب',
                      message: 'لا توجد سجلات طلاب مطابقة لمعايير التصفية والبحث المحددة.',
                      icon: Icon(Icons.people_outline_rounded),
                    )
                  : AcDataTable<Map<String, dynamic>>(
                      columns: [
                        AcTableColumn(
                          key: 'name',
                          label: 'الطالب',
                          cellBuilder: (s, _) => Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary500.withValues(alpha: 0.1),
                                child: Text(
                                  (s['full_name']?.toString() ?? 'U').substring(0, 1).toUpperCase(),
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.primary600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    s['full_name']?.toString() ?? '-',
                                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    s['email']?.toString() ?? '-',
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          flex: 3,
                        ),
                        AcTableColumn(
                          key: 'dept',
                          label: 'القسم والبرنامج',
                          cellBuilder: (s, _) => Text(s['department_name']?.toString() ?? '-'),
                          flex: 2,
                        ),
                        AcTableColumn(
                          key: 'year',
                          label: 'سنة الالتحاق',
                          cellBuilder: (s, _) => Text(s['enrollment_year']?.toString() ?? '-'),
                        ),
                        AcTableColumn(
                          key: 'gpa',
                          label: 'المعدل التراكمي (GPA)',
                          cellBuilder: (s, _) {
                            final gpaVal = s['calculated_gpa'] ?? s['cumulative_gpa'];
                            final gpa = double.tryParse(gpaVal?.toString() ?? '') ?? 0.0;
                            final color = gpa >= 3.5
                                ? AppColors.success500
                                : (gpa >= 2.5 ? AppColors.primary500 : (gpa >= 2.0 ? AppColors.warning500 : AppColors.danger500));
                            return Text(
                              gpa.toStringAsFixed(2),
                              style: AppTypography.labelLarge.copyWith(color: color, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        AcTableColumn(
                          key: 'status',
                          label: 'الحالة الأكاديمية',
                          cellBuilder: (s, _) {
                            final gpaVal = s['calculated_gpa'] ?? s['cumulative_gpa'];
                            final gpa = double.tryParse(gpaVal?.toString() ?? '') ?? 0.0;
                            final (status, color) = gpa >= 2.0
                                ? ('منتظم', AppColors.success500)
                                : ('إنذار أكاديمي', AppColors.danger500);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: AppRadius.brPill,
                              ),
                              child: Text(
                                status,
                                style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                        AcTableColumn(
                          key: 'actions',
                          label: 'الإجراءات',
                          cellBuilder: (s, _) => AcButton(
                            label: 'عرض السجل',
                            variant: AcButtonVariant.secondary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentDetailsScreen(studentSummary: s),
                                ),
                              );
                            },
                          ),
                          width: 130,
                        ),
                      ],
                      rows: _filteredStudents,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
