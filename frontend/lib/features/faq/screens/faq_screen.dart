// file: lib/features/faq/screens/faq_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/app_colors.dart';
import '../../support/screens/report_issue_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  bool _isLoading = false;

  final List<String> _categories = ['الكل', 'عام', 'الحساب', 'الأكاديميات', 'المساعدة'];

  List<Map<String, String>> _faqItems = [
    {
      'question': 'ما هي منصة أكاديكسا وكيف تساعدني؟',
      'answer': 'أكاديكسا هي منصة إرشاد أكاديمي ذكية تساعد الطلاب على تنظيم خططهم الدراسية ومتابعة تقدمهم، ومعرفة متطلبات التخرج وحساب المعدل التراكمي وتنبيههم للمواد المتبقية والمتطلبات السابقة.',
      'category': 'عام',
    },
    {
      'question': 'كيف يمكنني تسجيل الدخول إلى حسابي؟',
      'answer': 'يمكنك تسجيل الدخول باستخدام البريد الإلكتروني الجامعي وكلمة المرور الخاصة بك. إذا نسيت كلمة المرور، يمكنك استعادتها عبر خيار "نسيت كلمة المرور" وسنرسل لك رمز تحقق OTP.',
      'category': 'الحساب',
    },
    {
      'question': 'كيف أضيف مادة دراسية إلى خطتي؟',
      'answer': 'اذهب إلى شاشة "الخطة الدراسية"، واضغط على زر تعديل أو إضافة مادة. يمكنك اختيار المادة من الفئات المتاحة (إجباري، اختياري، متطلبات جامعة) بعد التأكد من استيفاء المتطلبات السابقة.',
      'category': 'الأكاديميات',
    },
    {
      'question': 'ماذا يحدث إذا رسبت في مادة متطلبة؟',
      'answer': 'لن تتمكن من تسجيل المواد المتقدمة التي تعتمد على هذه المادة كمتطلب سابق حتى تقوم بإعادة دراستها واجتيازها بنجاح.',
      'category': 'الأكاديميات',
    },
    {
      'question': 'كيف يتم حساب العبء الأكاديمي (الحد الأقصى للساعات)؟',
      'answer': 'يتم حساب العبء الأكاديمي تلقائياً وفقاً لمعدلك التراكمي ولائحة كليتك. على سبيل المثال، المعدل المرتفع يسمح بتسجيل ساعات إضافية (تسجيل استثنائي)، بينما الإنذار الأكاديمي يقلل الحد الأقصى للساعات المسموح بها.',
      'category': 'الأكاديميات',
    },
    {
      'question': 'كيف يمكنني التواصل مع مستشاري الأكاديمي؟',
      'answer': 'توفر المنصة قسماً خاصاً للإرشاد الأكاديمي حيث يمكنك الاطلاع على اسم مستشارك، وإرسال رسائل أو استفسارات مباشرة له، وحجز موعد استشارة.',
      'category': 'المساعدة',
    },
    {
      'question': 'هل المنصة تدعم اللائحة القديمة والجديدة؟',
      'answer': 'نعم، تدعم المنصة لوائح متعددة (مثل لائحة 2019، 2024، و2026) وتتعامل مع قواعد كل لائحة بشكل منفصل ودقيق.',
      'category': 'عام',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    setState(() { _isLoading = true; });
    try {
      final client = Supabase.instance.client;
      final res = await client.from('faqs').select('question, answer, category');
      if ((res as List).isNotEmpty) {
        final dbList = (res as List).map((item) {
          final m = item as Map<String, dynamic>;
          return {
            'question': m['question']?.toString() ?? '',
            'answer': m['answer']?.toString() ?? '',
            'category': m['category']?.toString() ?? 'عام',
          };
        }).toList();
        setState(() {
          _faqItems = dbList;
        });
      }
    } catch (_) {
      // Keep static defaults on database omission or missing table
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredFaqs {
    return _faqItems.where((item) {
      final matchesCategory = _selectedCategory == 'الكل' || item['category'] == _selectedCategory;
      final matchesSearch = item['question']!.contains(_searchQuery) || item['answer']!.contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _resetSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'الكل';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredFaqs;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: kScaffoldBg,
        appBar: AppBar(
          backgroundColor: kDarkNavy,
          foregroundColor: kWhite,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الأسئلة الشائعة FAQ',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: kPrimaryTeal)),
      );
    }

    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: AppBar(
        backgroundColor: kDarkNavy,
        foregroundColor: kWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الأسئلة الشائعة FAQ',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: const BoxDecoration(
              color: kDarkNavy,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: GoogleFonts.cairo(color: kWhite),
              decoration: InputDecoration(
                hintText: 'ابحث عن سؤالك هنا...',
                hintStyle: GoogleFonts.cairo(color: kTextLight),
                prefixIcon: const Icon(Icons.search, color: kPrimaryTeal),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: kTextLight),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: kWhite.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Categories Chips horizontal list
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true, // RTL layout
              itemCount: _categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? kWhite : kTextDark,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: kPrimaryTeal,
                    backgroundColor: kWhite,
                    checkmarkColor: kWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? kPrimaryTeal : kDivider),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // FAQ items list
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kTextDark.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            iconColor: kPrimaryTeal,
                            collapsedIconColor: kTextMedium,
                            title: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                item['question']!,
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: kTextDark,
                                ),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Text(
                                  item['answer']!,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.justify,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    height: 1.6,
                                    color: kTextMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom support section
          _buildSupportBanner(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kDivider.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.help_outline_rounded, color: kTextLight, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد نتائج بحث مطابقة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب استخدام كلمات دلالية أخرى أو قم بتغيير فئة الفلترة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: kTextMedium,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _resetSearch,
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryBlue,
                side: const BorderSide(color: kDivider),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'إعادة تعيين الفلترة',
                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: kTextDark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'لم تجد إجابة لسؤالك؟',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReportIssueScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.support_agent_rounded, size: 20),
              label: Text(
                'تواصل مع الدعم الفني',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
