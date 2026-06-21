import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/heart_pull_refresh.dart';
import 'package:bahya_app/helper/custom_searchbar.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _listController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

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
              'بناءً على الأعراض المذكورة وفترة الألم، يرجى التوجه لعمل فحص سريري عاجل وأشعة ماموجرام للتحقق من الأنسجة.',
        },
        {
          'sender': 'user',
          'message':
              'هل الألم مستمر حتى مع المسكنات؟ نعم لا يستجيب للمسكنات العادية.',
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
        {
          'sender': 'user',
          'message': 'ظهرت نتيجة الفحص الدوري السنوي وأريد الاطمئنان.',
        },
        {
          'sender': 'bot',
          'message':
              'التقرير يشير إلى أنسجة طبيعية تماماً مصنفة BI-RADS 1، ننصح فقط بالاستمرار على الفحص الدوري السنوي.',
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
        {
          'sender': 'user',
          'message':
              'لاحظت وجود تغير في ملمس الجلد الخارجي يشبه قشرة البرتقال.',
        },
        {
          'sender': 'bot',
          'message':
              'هذا العرض يتطلب فحصاً مجهرياً دقيقاً وأخذ خزعة توجيهية (Biopsy) لتحديد طبيعة الخلايا بدقة.',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _filteredPatients = _allPatients;
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fakeLoad();
  }

  Future<void> _fakeLoad() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _listController.forward();
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients
            .where(
              (p) =>
                  p['name'].toString().contains(query) ||
                  p['fileNumber'].toString().contains(query) ||
                  p['diagnosis'].toString().contains(query),
            )
            .toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    if (status == 'حرجة') return const Color(0xFFD90429);
    if (status == 'متوسطة') return const Color(0xFFF77F00);
    return const Color(0xFF2A9D8F);
  }

  void _openChatDialog(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ChatHistoryDialog(
        patient: patient,
        onApprove: () {
          customDialog(
            context: context,
            title: context.tr('تم الاعتماد'),
            message: context.tr(
              'تمت الموافقة على تشخيص المودل وإدراجه بالملف.',
            ),
            isSuccess: true,
          );
        },
        onReject: () {
          customDialog(
            context: context,
            title: context.tr('تم الرفض'),
            message: context.tr(
              'تم رفض التشخيص وسيتم تحويل الحالة لإعادة التقييم التلقائي.',
            ),
            isError: true,
          );
        },
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _filteredPatients = _allPatients;
      _isLoading = false;
    });

    _listController.reset();
    _listController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = localeNotifier.isArabic;
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: context.appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: HeartPullRefreshScrollView(
          onRefresh: _refreshDashboard,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  customAppBar(
                    context: context,
                    title: context.tr('لوحة الطبيب المختص'),
                    subTitle: context.tr(
                      'مراجعة الحالات المحولة من الذكاء الاصطناعي',
                    ),
                    isHome: true,
                  ),
                  if (_isLoading)
                    SizedBox(
                      height: h * 0.60,
                      width: double.infinity,
                      child: Center(child: customLoading()),
                    )
                  else ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.04,
                        vertical: h * 0.015,
                      ),
                      child: CustomSearchBarWithFilter(
                        hintText: context.tr(
                          'ابحث باسم المريضة أو رقم الملف...',
                        ),
                        controller: _searchController,
                        onChanged: _filterPatients,
                        onFilterTap: () {},
                      ),
                    ),
                    if (_filteredPatients.isEmpty)
                      SizedBox(
                        height: h * 0.48,
                        width: double.infinity,
                        child: Center(
                          child: customText(
                            text: context.tr(
                              'لا توجد حالات مطابقة للبحث حالياً',
                            ),
                            size: w * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        itemCount: _filteredPatients.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: h * 0.04,
                          left: w * 0.04,
                          right: w * 0.04,
                        ),
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];

                          final int totalItems = _filteredPatients.length;
                          final double start = index / totalItems;
                          final double end = (index + 1) / totalItems;

                          final animation =
                              Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _listController,
                                  curve: Interval(
                                    start,
                                    end,
                                    curve: Curves.easeOutBack,
                                  ),
                                ),
                              );

                          final slideAnimation =
                              Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _listController,
                                  curve: Interval(
                                    start,
                                    end,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                              );

                          return AnimatedBuilder(
                            animation: _listController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: animation.value.clamp(0.0, 1.0),
                                child: Transform.translate(
                                  offset: slideAnimation.value * h,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: h * 0.018),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF14213D,
                                    ).withOpacity(0.04),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(
                                  color: _getStatusColor(
                                    patient['status'],
                                  ).withOpacity(0.15),
                                  width: 1.2,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: () => _openChatDialog(patient),
                                  child: Padding(
                                    padding: EdgeInsets.all(w * 0.045),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: w * 0.03,
                                                vertical: h * 0.005,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF14213D,
                                                ).withOpacity(0.06),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: customText(
                                                text: patient['fileNumber'],
                                                size: w * 0.032,
                                                color: const Color(0xff14213D),
                                                bold: true,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: w * 0.03,
                                                vertical: h * 0.006,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                  patient['status'],
                                                ).withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: customText(
                                                text: context.tr(
                                                  patient['status'],
                                                ),
                                                size: w * 0.029,
                                                color: _getStatusColor(
                                                  patient['status'],
                                                ),
                                                bold: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: h * 0.015),
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: w * 0.055,
                                              backgroundColor: const Color(
                                                0xFFE7549B,
                                              ).withOpacity(0.1),
                                              child: const Icon(
                                                Icons.person_search_rounded,
                                                color: Color(0xFFE7549B),
                                              ),
                                            ),
                                            SizedBox(width: w * 0.03),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  customText(
                                                    text: patient['name'],
                                                    size: w * 0.042,
                                                    color: const Color(
                                                      0xff14213D,
                                                    ),
                                                    bold: true,
                                                  ),
                                                  SizedBox(height: h * 0.004),
                                                  customText(
                                                    text:
                                                        '${context.tr("السن")}: ${patient['age']} ${context.tr("عاماً")}',
                                                    size: w * 0.032,
                                                    color: Colors.grey[600],
                                                    bold: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: h * 0.012,
                                          ),
                                          child: Divider(
                                            color: Colors.grey.withOpacity(
                                              0.15,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.psychology_rounded,
                                              size: w * 0.045,
                                              color: Colors.purple[400],
                                            ),
                                            SizedBox(width: w * 0.018),
                                            Expanded(
                                              child: RichText(
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          '${context.tr("تشخيص المودل")}: ',
                                                      style: TextStyle(
                                                        fontSize: w * 0.033,
                                                        color:
                                                            Colors.purple[700],
                                                        fontFamily:
                                                            'ArabicCustomFont',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          patient['diagnosis'],
                                                      style: TextStyle(
                                                        fontSize: w * 0.033,
                                                        color: Colors.grey[800],
                                                        fontFamily:
                                                            'ArabicCustomFont',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: h * 0.015),
                                        Align(
                                          alignment: isArabic
                                              ? Alignment.bottomLeft
                                              : Alignment.bottomRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              customText(
                                                text: context.tr(
                                                  'عرض محادثة الشات بوت',
                                                ),
                                                size: w * 0.032,
                                                color: const Color(0xFFE7549B),
                                                bold: true,
                                              ),
                                              SizedBox(width: w * 0.01),
                                              Icon(
                                                isArabic
                                                    ? Icons
                                                          .arrow_back_ios_rounded
                                                    : Icons
                                                          .arrow_forward_ios_rounded,
                                                size: w * 0.03,
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
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          ],
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
      duration: const Duration(milliseconds: 400),
    );
    _messagesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _dialogController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeOut,
    );

    _dialogController.forward().then((_) {
      _messagesController.forward();
    });
  }

  @override
  void dispose() {
    _dialogController.dispose();
    _messagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final List<dynamic> chatList = widget.patient['chatHistory'];

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: w * 0.04,
            vertical: h * 0.03,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF14213D).withOpacity(0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.05,
                    vertical: h * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14213D).withOpacity(0.03),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(
                          0xFFE7549B,
                        ).withOpacity(0.12),
                        child: const Icon(
                          Icons.forum_rounded,
                          color: Color(0xFFE7549B),
                        ),
                      ),
                      SizedBox(width: w * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            customText(
                              text: widget.patient['name'],
                              size: w * 0.04,
                              color: const Color(0xff14213D),
                              bold: true,
                            ),
                            customText(
                              text:
                                  '${context.tr("ملف رقم")}: ${widget.patient['fileNumber']}',
                              size: w * 0.03,
                              color: Colors.grey,
                              bold: false,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: chatList.length,
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: h * 0.02,
                    ),
                    itemBuilder: (context, index) {
                      final chat = chatList[index];
                      final isUser = chat['sender'] == 'user';

                      final double msgStart = index / chatList.length;
                      final double msgEnd = (index + 1) / chatList.length;
                      final msgAnimation = Tween<double>(begin: 0.0, end: 1.0)
                          .animate(
                            CurvedAnimation(
                              parent: _messagesController,
                              curve: Interval(
                                msgStart,
                                msgEnd,
                                curve: Curves.easeInOutCubic,
                              ),
                            ),
                          );

                      return AnimatedBuilder(
                        animation: _messagesController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: msgAnimation.value.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                (1.0 - msgAnimation.value) * 25,
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(bottom: h * 0.015),
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.04,
                              vertical: h * 0.014,
                            ),
                            constraints: BoxConstraints(maxWidth: w * 0.72),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFFE7549B).withOpacity(0.08)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 0),
                                bottomRight: Radius.circular(isUser ? 0 : 16),
                              ),
                              border: Border.all(
                                color: isUser
                                    ? const Color(0xFFE7549B).withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                customText(
                                  text: isUser
                                      ? context.tr('المريضة')
                                      : context.tr('شات بوت الذكاء الاصطناعي'),
                                  size: w * 0.028,
                                  color: isUser
                                      ? const Color(0xFFE7549B)
                                      : Colors.purple,
                                  bold: true,
                                ),
                                SizedBox(height: h * 0.006),
                                Text(
                                  chat['message'],
                                  style: TextStyle(
                                    fontSize: w * 0.035,
                                    color: Colors.black87,
                                    fontFamily: 'ArabicCustomFont',
                                    height: 1.35,
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
                Container(
                  padding: EdgeInsets.all(w * 0.045),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onReject();
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: h * 0.055,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.2),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: customText(
                              text: context.tr('رفض التشخيص'),
                              size: w * 0.036,
                              color: Colors.red,
                              bold: true,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: w * 0.03),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onApprove();
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: h * 0.055,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE7549B), Colors.purple],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE7549B,
                                  ).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: customText(
                              text: context.tr('اعتماد وقبول'),
                              size: w * 0.036,
                              color: Colors.white,
                              bold: true,
                            ),
                          ),
                        ),
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
