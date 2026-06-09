// file: lib/features/notifications/screens/notification_center_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _selectedTab = 'الكل';
  bool _isLoading = true;

  final List<String> _tabs = ['الكل', 'غير مقروء', 'أكاديمي'];

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'إنذار أكاديمي: ساعات الغياب',
      'description': 'لقد تجاوزت نسبة الغياب المسموح بها في مادة "هندسة البرمجيات" (12%). يرجى مراجعة أستاذ المادة.',
      'time': 'منذ ساعتين',
      'type': 'academic',
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'تحديث في لائحة 2026',
      'description': 'تم تعديل المتطلب السابق لمادة "الذكاء الاصطناعي" ليصبح "تراكيب البيانات" بدلاً من "مقدمة في البرمجة".',
      'time': 'منذ يومين',
      'type': 'curriculum',
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'رسالة جديدة من المرشد الأكاديمي',
      'description': 'مرحباً، يرجى حضور جلسة الإرشاد الأكاديمي لمراجعة خطتك المقترحة للفصل الدراسي القادم غداً الساعة 10 صباحاً.',
      'time': 'منذ 3 أيام',
      'type': 'advisor',
      'isRead': true,
    },
    {
      'id': '4',
      'title': 'إعلان: بدء فترة التسجيل المبكر',
      'description': 'تبدأ فترة تسجيل المواد للفصل الدراسي الصيفي اعتباراً من الأحد القادم عبر البوابة الأكاديمية.',
      'time': 'منذ 5 أيام',
      'type': 'general',
      'isRead': true,
    },
    {
      'id': '5',
      'title': 'تنبيه: تدني المعدل التراكمي',
      'description': 'تنبيه أكاديمي: انخفض معدلك التراكمي عن 2.0. يرجى التواصل مع مرشدك الأكاديمي لضبط عبئك الدراسي.',
      'time': 'منذ أسبوع',
      'type': 'academic',
      'isRead': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديد الكل كمقروء',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: kSuccess,
      ),
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedTab == 'غير مقروء') {
      return _notifications.where((n) => !n['isRead']).toList();
    } else if (_selectedTab == 'أكاديمي') {
      return _notifications.where((n) => n['type'] == 'academic').toList();
    }
    return _notifications;
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'academic':
        return Icons.warning_amber_rounded;
      case 'curriculum':
        return Icons.menu_book_rounded;
      case 'advisor':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'academic':
        return kError;
      case 'curriculum':
        return kPrimaryTeal;
      case 'advisor':
        return kPrimaryBlue;
      default:
        return kTextMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredNotifications;

    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: AppBar(
        backgroundColor: kDarkNavy,
        foregroundColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'مركز الإشعارات',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_notifications.any((n) => !n['isRead']))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'تحديد الكل كمقروء',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar selection (custom header style)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: kDarkNavy,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _tabs.map((tab) {
                final isSelected = _selectedTab == tab;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kWhite.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tab,
                      style: GoogleFonts.cairo(
                        color: kWhite,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Main body containing shimmer or empty list or items list
          Expanded(
            child: _isLoading
                ? _buildShimmerLoader()
                : list.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return Dismissible(
                            key: Key(item['id']),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) => _deleteNotification(item['id']),
                            background: Container(
                              color: kError.withValues(alpha: 0.1),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete_outline, color: kError, size: 28),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  item['isRead'] = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: item['isRead'] ? Colors.transparent : kPrimaryTeal.withValues(alpha: 0.04),
                                  border: Border(
                                    bottom: BorderSide(color: kDivider.withValues(alpha: 0.5)),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Time
                                    Text(
                                      item['time'],
                                      style: GoogleFonts.cairo(
                                        fontSize: 10,
                                        color: kTextLight,
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Content details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              if (!item['isRead'])
                                                Container(
                                                  margin: const EdgeInsets.only(right: 6),
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                    color: kPrimaryTeal,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              Expanded(
                                                child: Text(
                                                  item['title'],
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.cairo(
                                                    fontWeight: item['isRead'] ? FontWeight.w600 : FontWeight.bold,
                                                    fontSize: 13,
                                                    color: kTextDark,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['description'],
                                            textAlign: TextAlign.right,
                                            textDirection: TextDirection.rtl,
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: kTextMedium,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Icon indicator
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: _getColorForType(item['type']).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getIconForType(item['type']),
                                        color: _getColorForType(item['type']),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 80,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kDivider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(width: 40, height: 40, decoration: const BoxDecoration(color: kScaffoldBg, shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(width: 120, height: 12, decoration: BoxDecoration(color: kScaffoldBg, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 10, decoration: BoxDecoration(color: kScaffoldBg, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kDivider.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined, color: kTextLight, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد إشعارات',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'عند تلقي أي تنبيهات جديدة، ستظهر هنا في هذه الصفحة.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: kTextMedium,
            ),
          ),
        ],
      ),
    );
  }
}
