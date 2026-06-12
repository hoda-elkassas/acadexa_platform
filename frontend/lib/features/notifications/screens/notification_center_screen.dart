// file: lib/features/notifications/screens/notification_center_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/states/ac_states.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _supabase = Supabase.instance.client;

  String _selectedTab = 'الكل';
  bool _isLoading = true;
  String _errorMessage = '';

  final List<String> _tabs = ['الكل', 'غير مقروء', 'أكاديمي'];

  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) { setState(() { _isLoading = false; }); return; }
      final res = await _supabase
          .from('notification_history')
          .select()
          .eq('student_id', user.id)
          .order('created_at', ascending: false);
      if (mounted) {
        final rawList = res as List<dynamic>;
        final mappedList = rawList.map((item) {
          final dbItem = item as Map<String, dynamic>;
          String timeStr = '';
          if (dbItem['created_at'] != null) {
            timeStr = dbItem['created_at'].toString().split('T')[0];
          } else if (dbItem['sent_at'] != null) {
            timeStr = dbItem['sent_at'].toString().split('T')[0];
          }
          return {
            'id': dbItem['id']?.toString() ?? '',
            'title': dbItem['title']?.toString() ?? 'إشعار جديد',
            'description': dbItem['body']?.toString() ?? dbItem['description']?.toString() ?? '',
            'isRead': dbItem['read'] == true || dbItem['is_read'] == true,
            'time': timeStr,
            'type': dbItem['type']?.toString() ?? dbItem['notification_type']?.toString() ?? 'system',
          };
        }).toList();

        setState(() {
          _notifications = mappedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _errorMessage = 'فشل تحميل الإشعارات: ${e.toString()}'; _isLoading = false; });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });

    try {
      try {
        await _supabase
            .from('notification_history')
            .update({'read': true})
            .eq('student_id', user.id);
      } catch (_) {
        await _supabase
            .from('notification_history')
            .update({'is_read': true})
            .eq('student_id', user.id);
      }
    } catch (_) {}

    if (mounted) {
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
  }

  Future<void> _deleteNotification(String id) async {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
    try {
      await _supabase
          .from('notification_history')
          .delete()
          .eq('id', id);
    } catch (_) {}
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

    if (_errorMessage.isNotEmpty) return AcErrorState(title: 'خطأ', message: _errorMessage, onRetry: _loadNotifications);

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
                              onTap: () async {
                                if (!item['isRead']) {
                                  setState(() {
                                    item['isRead'] = true;
                                  });
                                  try {
                                    try {
                                      await _supabase
                                          .from('notification_history')
                                          .update({'read': true})
                                          .eq('id', item['id']);
                                    } catch (_) {
                                      await _supabase
                                          .from('notification_history')
                                          .update({'is_read': true})
                                          .eq('id', item['id']);
                                    }
                                  } catch (_) {}
                                }
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
