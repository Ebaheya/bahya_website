import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/doctor_page_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gridController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  int _currentPage = 0;
  static const int _itemsPerPage = 6;

  final List<Map<String, dynamic>> _allPatients = [
    {
      'fileNumber': 'PT-2026-889',
      'name': 'أمل محمد أحمد',
      'age': 43,
      'status': 'حرجة',
      'diagnosis': 'اشتباه ورم ليفي نشط - متلازمة ألم حاد',
      'chatHistory': [
        {
          'sender': 'user',
          'message':
              'أشعر بألم شديد مستمر في منطقة الصدر منذ يومين ويمتد للكتف.',
        },
        {
          'sender': 'bot',
          'message':
              'يرجى التوجه لعمل فحص سريري عاجل وأشعة ماموجرام للتحقق من الأنسجة.',
        },
      ],
    },
    {
      'fileNumber': 'PT-2026-412',
      'name': 'فاطمة الزهراء محمود',
      'age': 35,
      'status': 'مستقرة',
      'diagnosis': 'متابعة ما بعد الفحص الدوري - أنسجة طبيعية',
      'chatHistory': [
        {'sender': 'user', 'message': 'أريد الاطمئنان على نتيجة الفحص.'},
        {
          'sender': 'bot',
          'message': 'التقرير يشير إلى أنسجة طبيعية BI-RADS 1.',
        },
      ],
    },
    {
      'fileNumber': 'PT-2026-105',
      'name': 'منى عبد العزيز كريم',
      'age': 52,
      'status': 'متوسطة',
      'diagnosis': 'تغير في جدار الجلد الخارجي - بحاجة لخزعة توجيهية',
      'chatHistory': [
        {'sender': 'user', 'message': 'لاحظت تغير في ملمس الجلد الخارجي.'},
        {'sender': 'bot', 'message': 'هذا العرض يتطلب فحصاً دقيقاً وأخذ خزعة.'},
      ],
    },
    {
      'fileNumber': 'PT-2026-711',
      'name': 'سارة علي حسن',
      'age': 46,
      'status': 'حرجة',
      'diagnosis': 'ألم حاد مع إفرازات غير طبيعية - يحتاج مراجعة عاجلة',
      'chatHistory': [
        {'sender': 'user', 'message': 'يوجد ألم شديد وإفرازات.'},
        {'sender': 'bot', 'message': 'الحالة تحتاج مراجعة عاجلة للطبيب.'},
      ],
    },
    {
      'fileNumber': 'PT-2026-230',
      'name': 'هالة سمير يوسف',
      'age': 39,
      'status': 'مستقرة',
      'diagnosis': 'متابعة علاج هرموني - الحالة مستقرة',
      'chatHistory': [
        {'sender': 'user', 'message': 'هل العلاج الحالي مناسب؟'},
        {'sender': 'bot', 'message': 'الحالة مستقرة مع المتابعة الدورية.'},
      ],
    },
    {
      'fileNumber': 'PT-2026-604',
      'name': 'دعاء مصطفى كامل',
      'age': 49,
      'status': 'متوسطة',
      'diagnosis': 'كتلة صغيرة تحتاج متابعة بالسونار',
      'chatHistory': [
        {'sender': 'user', 'message': 'ظهر شيء صغير في السونار.'},
        {'sender': 'bot', 'message': 'ينصح بالمتابعة وإعادة الفحص.'},
      ],
    },
    {
      'fileNumber': 'PT-2026-908',
      'name': 'نجلاء إبراهيم',
      'age': 55,
      'status': 'حرجة',
      'diagnosis': 'أعراض متقدمة تحتاج تقييم فوري',
      'chatHistory': [
        {'sender': 'user', 'message': 'الألم زاد بشكل كبير.'},
        {'sender': 'bot', 'message': 'يرجى مراجعة الطبيب فوراً.'},
      ],
    },
    {
      'fileNumber': 'PT-2026-331',
      'name': 'ريم خالد محمود',
      'age': 31,
      'status': 'مستقرة',
      'diagnosis': 'فحص دوري طبيعي',
      'chatHistory': [
        {'sender': 'user', 'message': 'نتيجة الفحص طبيعية؟'},
        {'sender': 'bot', 'message': 'نعم، لا توجد مؤشرات خطيرة.'},
      ],
    },
  ];

  List<Map<String, dynamic>> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _filteredPatients = _allPatients;
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() => _isLoading = false);
    _gridController.forward();
  }

  @override
  void dispose() {
    _gridController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPatients(String query) {
    setState(() {
      _currentPage = 0;

      if (query.trim().isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        final q = query.trim().toLowerCase();

        _filteredPatients = _allPatients.where((patient) {
          return patient['name'].toString().toLowerCase().contains(q) ||
              patient['fileNumber'].toString().toLowerCase().contains(q) ||
              patient['diagnosis'].toString().toLowerCase().contains(q);
        }).toList();
      }
    });

    _gridController.reset();
    _gridController.forward();
  }

  List<Map<String, dynamic>> get _currentPatients {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, _filteredPatients.length);
    return _filteredPatients.sublist(start, end);
  }

  int get _totalPages {
    if (_filteredPatients.isEmpty) return 1;
    return (_filteredPatients.length / _itemsPerPage).ceil();
  }

  Color _getStatusColor(String status) {
    if (status == 'حرجة') return const Color(0xFFD90429);
    if (status == 'متوسطة') return const Color(0xFFF77F00);
    return const Color(0xFF2A9D8F);
  }

  void _changePage(int page) {
    if (page < 0 || page >= _totalPages) return;

    setState(() => _currentPage = page);

    _gridController.reset();
    _gridController.forward();
  }

  void _openChatDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ChatHistoryDialog(
        patient: patient,
        onApprove: () {
          customDialog(
            context: context,
            title: 'تم الاعتماد',
            message: 'تمت الموافقة على تشخيص المودل وإدراجه بالملف.',
            isSuccess: true,
          );
        },
        onReject: () {
          customDialog(
            context: context,
            title: 'تم الرفض',
            message: 'تم رفض التشخيص وسيتم تحويل الحالة لإعادة التقييم.',
            isError: true,
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1050) return 3;
    if (width >= 680) return 2;
    return 1;
  }

double _getCardAspectRatio(BuildContext context, double width) {
    if (width >= 1050) return 1.55;
    if (width >= 680) return 1.45;
    return getScreenWidth(context) < 380 ? 1.22 : 1.5;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: _isLoading
            ? Center(child: customLoading())
            : SingleChildScrollView(
                padding: EdgeInsets.all(
                  responsiveSize(context, 0.022, min: 14, max: 28),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        animatedPageHeader(
                          context: context,
                          title: 'لوحة الطبيب المختص',
                          subtitle:
                              'مراجعة الحالات المحولة من الذكاء الاصطناعي',
                          icon: Icons.smart_toy_rounded,
                          showBack: true,
                          showTotal: true,
                          totalCount: _filteredPatients.length,
                          totalLabel: 'حالة',
                          onBackTap: () => context.go('/home'),
                        ),
                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.026,
                            min: 16,
                            max: 24,
                          ),
                        ),
                        SizedBox(
                          width: isMobile
                              ? double.infinity
                              : responsiveSize(
                                  context,
                                  0.42,
                                  min: 420,
                                  max: 520,
                                ),
                          child: CustomFormTextField(
                            isSearch: true,
                            hintText: 'ابحث باسم المريضة أو رقم الملف...',
                            controller: _searchController,
                            keyboardType: CustomTextFieldType.text,
                            onChange:  _filterPatients,
                          ),
                        ),
                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.03,
                            min: 18,
                            max: 26,
                          ),
                        ),
                        if (_filteredPatients.isEmpty)
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.42,
                              min: 260,
                              max: 360,
                            ),
                            child: Center(
                              child: customText(
                                text: 'لا توجد حالات مطابقة للبحث حالياً',
                                size: responsiveSize(
                                  context,
                                  0.014,
                                  min: 14,
                                  max: 18,
                                ),
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = _getCrossAxisCount(
                                constraints.maxWidth,
                              );

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _currentPatients.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: responsiveSize(
                                        context,
                                        0.014,
                                        min: 12,
                                        max: 18,
                                      ),
                                      mainAxisSpacing: responsiveHeight(
                                        context,
                                        0.02,
                                        min: 12,
                                        max: 18,
                                      ),
                                      childAspectRatio: _getCardAspectRatio(
                                        context,
                                        constraints.maxWidth,
                                      ),
                                    ),
                                itemBuilder: (context, index) {
                                  final patient = _currentPatients[index];

                                  final animation = CurvedAnimation(
                                    parent: _gridController,
                                    curve: Interval(
                                      index / _currentPatients.length,
                                      1,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  );

                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.12),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: _PatientCard(
                                        patient: patient,
                                        statusColor: _getStatusColor(
                                          patient['status'],
                                        ),
                                        onTap: () => _openChatDialog(patient),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.032,
                            min: 20,
                            max: 28,
                          ),
                        ),
                        if (_filteredPatients.isNotEmpty)
                          _PaginationBar(
                            currentPage: _currentPage,
                            totalPages: _totalPages,
                            onPageChanged: _changePage,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;
  final Color statusColor;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = true;
    final isMobile = getScreenWidth(context) < 650;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.02, min: 18, max: 24),
        ),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14213D).withValues(alpha: 0.05),
            blurRadius: responsiveSize(context, 0.018, min: 14, max: 18),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.02, min: 18, max: 24),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              responsiveSize(context, 0.018, min: 16, max: 22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: responsiveSize(context, 0.01, min: 8, max: 12),
                  runSpacing: responsiveHeight(context, 0.008, min: 6, max: 8),
                  children: [
                    _Tag(
                      text: patient['fileNumber'],
                      color: const Color(0xFF14213D),
                    ),
                    _Tag(
                      text: patient['status'],
                      color: statusColor,
                      filled: true,
                    ),
                  ],
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.02, min: 12, max: 18),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: responsiveSize(context, 0.024, min: 22, max: 27),
                      backgroundColor: const Color(
                        0xFFE7549B,
                      ).withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person_search_rounded,
                        color: const Color(0xFFE7549B),
                        size: responsiveSize(context, 0.02, min: 20, max: 24),
                      ),
                    ),
                    SizedBox(
                      width: responsiveSize(context, 0.012, min: 10, max: 14),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customText(
                            text: patient['name'],
                            size: responsiveSize(
                              context,
                              0.014,
                              min: 15,
                              max: 18,
                            ),
                            color: const Color(0xFF14213D),
                            bold: true,
                            maxLines: 1,
                          ),
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.004,
                              min: 3,
                              max: 4,
                            ),
                          ),
                          customText(
                            text: 'السن: ${patient['age']} عاماً',
                            size: responsiveSize(
                              context,
                              0.011,
                              min: 12,
                              max: 14,
                            ),
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.018, min: 12, max: 16),
                ),
                Divider(color: Colors.grey.withValues(alpha: 0.14)),
                SizedBox(
                  height: responsiveHeight(context, 0.01, min: 6, max: 10),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.psychology_rounded,
                      size: responsiveSize(context, 0.018, min: 19, max: 22),
                      color: Colors.purple[400],
                    ),
                    SizedBox(
                      width: responsiveSize(context, 0.008, min: 6, max: 8),
                    ),
                    Expanded(
                      child: Text.rich(
                        maxLines: isMobile ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'تشخيص المودل: ',
                              style: TextStyle(
                                fontSize: responsiveSize(
                                  context,
                                  0.011,
                                  min: 12,
                                  max: 14,
                                ),
                                color: Colors.purple[700],
                                fontFamily: 'ArabicCustomFont',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: patient['diagnosis'],
                              style: TextStyle(
                                fontSize: responsiveSize(
                                  context,
                                  0.011,
                                  min: 12,
                                  max: 14,
                                ),
                                color: Colors.grey[800],
                                fontFamily: 'ArabicCustomFont',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: isArabic
                      ? Alignment.bottomLeft
                      : Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      customText(
                        text: 'عرض محادثة الشات بوت',
                        size: responsiveSize(context, 0.011, min: 12, max: 14),
                        color: const Color(0xFFE7549B),
                        bold: true,
                      ),
                      SizedBox(
                        width: responsiveSize(context, 0.006, min: 5, max: 6),
                      ),
                      Icon(
                        isArabic
                            ? Icons.arrow_forward_ios_rounded
                            : Icons.arrow_back_ios_rounded,
                        size: responsiveSize(context, 0.011, min: 12, max: 14),
                        color: const Color(0xFFE7549B),
                      ),
                    ],
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

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;

  const _Tag({required this.text, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.01, min: 10, max: 12),
        vertical: responsiveHeight(context, 0.008, min: 6, max: 7),
      ),
      decoration: BoxDecoration(
        color: filled
            ? color.withValues(alpha: 0.11)
            : color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 10, max: 12),
        ),
      ),
      child: customText(
        text: text,
        size: responsiveSize(context, 0.01, min: 11, max: 13),
        color: color,
        bold: true,
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return Center(
      child: Container(
        padding: EdgeInsets.all(responsiveSize(context, 0.007, min: 6, max: 8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.018, min: 18, max: 22),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14213D).withValues(alpha: 0.06),
              blurRadius: responsiveSize(context, 0.018, min: 14, max: 18),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PageButton(
              icon: Icons.chevron_left_rounded,
              enabled: currentPage > 0,
              onTap: () => onPageChanged(currentPage - 1),
            ),
            SizedBox(width: responsiveSize(context, 0.006, min: 4, max: 6)),
            ...List.generate(totalPages, (index) {
              final selected = index == currentPage;

              return InkWell(
                onTap: () => onPageChanged(index),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 4),
                  width: selected
                      ? responsiveSize(context, 0.04, min: 38, max: 42)
                      : responsiveSize(context, 0.034, min: 34, max: 36),
                  height: responsiveSize(context, 0.034, min: 34, max: 36),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFE7549B)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: customText(
                    text: '${index + 1}',
                    size: responsiveSize(context, 0.011, min: 12, max: 14),
                    color: selected ? Colors.white : const Color(0xFF14213D),
                    bold: true,
                  ),
                ),
              );
            }),
            SizedBox(width: responsiveSize(context, 0.006, min: 4, max: 6)),
            _PageButton(
              icon: Icons.chevron_right_rounded,
              enabled: currentPage < totalPages - 1,
              onTap: () => onPageChanged(currentPage + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: responsiveSize(context, 0.036, min: 34, max: 38),
        height: responsiveSize(context, 0.034, min: 34, max: 36),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF14213D).withValues(alpha: 0.06)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF14213D) : Colors.grey,
          size: responsiveSize(context, 0.018, min: 20, max: 24),
        ),
      ),
    );
  }
}

class _ChatHistoryDialog extends StatefulWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ChatHistoryDialog({
    required this.patient,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_ChatHistoryDialog> createState() => _ChatHistoryDialogState();
}

class _ChatHistoryDialogState extends State<_ChatHistoryDialog>
    with TickerProviderStateMixin {
  late final AnimationController _dialogController;
  late final AnimationController _messagesController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _dialogController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _messagesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _dialogController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeOut,
    );

    _dialogController.forward().then((_) => _messagesController.forward());
  }

  @override
  void dispose() {
    _dialogController.dispose();
    _messagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> chatList = widget.patient['chatHistory'];
    final isMobile = getScreenWidth(context) < 650;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(
            responsiveSize(context, 0.018, min: 12, max: 28),
          ),
          child: Container(
            width: isMobile
                ? double.infinity
                : responsiveSize(context, 0.58, min: 620, max: 720),
            height: responsiveHeight(context, 0.78, min: 520, max: 620),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.024, min: 20, max: 28),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF14213D).withValues(alpha: 0.16),
                  blurRadius: responsiveSize(context, 0.026, min: 20, max: 28),
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                _DialogHeader(patient: widget.patient),
                Expanded(
                  child: ListView.builder(
                    itemCount: chatList.length,
                    padding: EdgeInsets.all(
                      responsiveSize(context, 0.02, min: 14, max: 24),
                    ),
                    itemBuilder: (context, index) {
                      final chat = chatList[index];
                      final isUser = chat['sender'] == 'user';

                      final animation = CurvedAnimation(
                        parent: _messagesController,
                        curve: Interval(
                          index / chatList.length,
                          1,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.16),
                            end: Offset.zero,
                          ).animate(animation),
                          child: Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: responsiveHeight(
                                  context,
                                  0.016,
                                  min: 10,
                                  max: 14,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: responsiveSize(
                                  context,
                                  0.016,
                                  min: 14,
                                  max: 18,
                                ),
                                vertical: responsiveHeight(
                                  context,
                                  0.014,
                                  min: 12,
                                  max: 14,
                                ),
                              ),
                              constraints: BoxConstraints(
                                maxWidth: isMobile
                                    ? getScreenWidth(context) * 0.78
                                    : 500,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? const Color(
                                        0xFFE7549B,
                                      ).withValues(alpha: 0.08)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                                  bottomRight: Radius.circular(isUser ? 4 : 18),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  customText(
                                    text: isUser
                                        ? 'المريضة'
                                        : 'شات بوت الذكاء الاصطناعي',
                                    size: responsiveSize(
                                      context,
                                      0.01,
                                      min: 12,
                                      max: 13,
                                    ),
                                    color: isUser
                                        ? const Color(0xFFE7549B)
                                        : Colors.purple,
                                    bold: true,
                                  ),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.006,
                                      min: 5,
                                      max: 6,
                                    ),
                                  ),
                                  Text(
                                    chat['message'],
                                    style: TextStyle(
                                      fontSize: responsiveSize(
                                        context,
                                        0.012,
                                        min: 13,
                                        max: 15,
                                      ),
                                      color: Colors.black87,
                                      fontFamily: 'ArabicCustomFont',
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _DialogActions(
                  onApprove: () {
                    Navigator.pop(context);
                    widget.onApprove();
                  },
                  onReject: () {
                    Navigator.pop(context);
                    widget.onReject();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final Map<String, dynamic> patient;

  const _DialogHeader({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.018, min: 16, max: 22)),
      decoration: BoxDecoration(
        color: const Color(0xFF14213D).withValues(alpha: 0.03),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            responsiveSize(context, 0.024, min: 20, max: 28),
          ),
          topRight: Radius.circular(
            responsiveSize(context, 0.024, min: 20, max: 28),
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: responsiveSize(context, 0.022, min: 20, max: 24),
            backgroundColor: const Color(0xFFE7549B).withValues(alpha: 0.12),
            child: Icon(
              Icons.forum_rounded,
              color: const Color(0xFFE7549B),
              size: responsiveSize(context, 0.018, min: 19, max: 22),
            ),
          ),
          SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: patient['name'],
                  size: responsiveSize(context, 0.014, min: 15, max: 18),
                  color: const Color(0xFF14213D),
                  bold: true,
                  maxLines: 1,
                ),
                customText(
                  text: "ملف رقم: ${patient['fileNumber']}",
                  size: responsiveSize(context, 0.011, min: 12, max: 14),
                  color: Colors.grey,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              size: responsiveSize(context, 0.02, min: 22, max: 26),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _DialogActions({required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 430;

    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.018, min: 14, max: 22)),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
        ),
      ),
      child: isMobile
          ? Column(
              children: [
                _ActionButton(
                  text: 'اعتماد وقبول',
                  color: const Color(0xFFE7549B),
                  filled: true,
                  onTap: onApprove,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.012, min: 10, max: 12),
                ),
                _ActionButton(
                  text: 'رفض التشخيص',
                  color: Colors.red,
                  filled: false,
                  onTap: onReject,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    text: 'رفض التشخيص',
                    color: Colors.red,
                    filled: false,
                    onTap: onReject,
                  ),
                ),
                SizedBox(
                  width: responsiveSize(context, 0.014, min: 12, max: 14),
                ),
                Expanded(
                  child: _ActionButton(
                    text: 'اعتماد وقبول',
                    color: const Color(0xFFE7549B),
                    filled: true,
                    onTap: onApprove,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.014, min: 14, max: 16),
      ),
      child: Container(
        height: responsiveHeight(context, 0.052, min: 46, max: 50),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.014, min: 14, max: 16),
          ),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: customText(
          text: text,
          size: responsiveSize(context, 0.012, min: 13, max: 15),
          color: filled ? Colors.white : color,
          bold: true,
        ),
      ),
    );
  }
}
