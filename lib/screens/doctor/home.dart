import 'dart:developer';

import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/animated_home_background.dart';
import 'package:bahya_website/helper/widgets/diagnosis_chart.dart';
import 'package:bahya_website/helper/widgets/doctor_page_header.dart';
import 'package:bahya_website/helper/widgets/home_feature_grid.dart';
import 'package:bahya_website/helper/widgets/state_card.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:bahya_website/screens/profile_widget.dart';
import 'package:bahya_website/screens/send_report.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _pageController;

  String userName = 'Loading...';

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    loadUser();
    _pageController.forward();
  }

  Future<void> loadUser() async {
    try {
      final storage = SecureStorageService();
      final token = await storage.getAccessToken();

      if (token == null) return;

      final repo = AppRepository();
      final user = await repo.getUserProfile(accessToken: token);

      if (!mounted) return;

      setState(() {
        userName = user.name;
      });

      log('name: $userName');
    } catch (e) {
      log('loadUser error: $e');
    }
  }
void _showAnimatedReportDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Report Problem',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.86, end: 1).animate(curvedAnimation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Builder(
                    builder: (context) {
                      Future.microtask(() {
                        Navigator.of(dialogContext).pop();
                        showReportProblemDialog(context);
                      });

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _animatedItem({required int index, required Widget child}) {
    final animation = CurvedAnimation(
      parent: _pageController,
      curve: Interval(
        (index * 0.10).clamp(0.0, 0.75),
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
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    final isMobile = w < 650;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      body: AnimatedHomeBackground(
        child: ValueListenableBuilder<Locale>(
          valueListenable: AppLanguageController.localeNotifier,
          builder: (context, locale, _) {
            final isEnglish = locale.languageCode == 'en';

            return Directionality(
              textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : w * 0.035,
                  vertical: h < 750 ? 18 : h * 0.035,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1360),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _animatedItem(
                          index: 0,
                          child: animatedPageHeader(
                            context: context,
                            title: 'Psychological Support Team',
                            subtitle: 'Welcome, $userName',
                            icon: Icons.favorite_rounded,
                            isHome: true,
                            showLanguage: true,
                            onProfileTap: () {
                              showProfileDialog(context);
                            },
                          ),
                        ),
                        SizedBox(height: isMobile ? 18 : 24),
                        _animatedItem(
                          index: 1,
                          child: _QuickActionsSection(
                          onReportTap: () =>
                                _showAnimatedReportDialog(context),
                            onChatBotTap: () => context.go('/doctor_dashboard'),
                          ),
                        ),
                        SizedBox(height: isMobile ? 22 : 30),
                        _animatedItem(
                          index: 2,
                          child: _ModernSection(
                            title: 'لوحة الإحصائيات العامة',
                            subtitle: 'نظرة سريعة على الحالات والتشخيصات',
                            icon: Icons.analytics_rounded,
                            child: StatsHorizontalGrid(
                              items: getStatCards(context),
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 22 : 30),
                        _animatedItem(
                          index: 3,
                          child: _ModernSection(
                            title: 'مخطط مقارنة التشخيصات',
                            subtitle: 'تحليل بصري لعدد الحالات والنسب',
                            icon: Icons.bar_chart_rounded,
                            child: Column(
                              children: [
                                DiagnosisComparisonChart(
                                  data: chartData,
                                  height: isMobile ? 330 : h * 0.46,
                                ),
                                const SizedBox(height: 12),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LegendDot(
                                      color: Color(0xFFB36BFF),
                                      label: 'Count',
                                    ),
                                    SizedBox(width: 18),
                                    LegendDot(
                                      color: Color(0xFFFF5C9A),
                                      label: 'Percent',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 22 : 30),
                        _animatedItem(
                          index: 4,
                          child: const _ModernSection(
                            title: 'الخدمات',
                            subtitle: 'اختر الخدمة المطلوبة من القائمة',
                            icon: Icons.grid_view_rounded,
                            child: Padding(
                              padding: EdgeInsets.all(22),
                              child: HomeFeaturesGrid(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final VoidCallback onReportTap;
  final VoidCallback onChatBotTap;

  const _QuickActionsSection({
    required this.onReportTap,
    required this.onChatBotTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);
    final isMobile = width < 650;
    final isTablet = width >= 650 && width < 1050;

    final items = [
      _QuickActionItem(
        title: 'الإبلاغ عن مشكلة',
        subtitle: 'Send technical issue report',
        icon: Icons.report_problem_rounded,
        onTap: onReportTap,
      ),
      _QuickActionItem(
        title: 'Chatbot support',
        subtitle: 'Review AI transferred cases',
        icon: Icons.smart_toy_rounded,
        onTap: onChatBotTap,
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 2),
        crossAxisSpacing: responsiveSize(context, 0.016, min: 14, max: 20),
        mainAxisSpacing: responsiveHeight(context, 0.018, min: 14, max: 20),
        childAspectRatio: isMobile ? 3.15 : 5.5,
      ),
      itemBuilder: (context, index) => items[index],
    );
  }
}

class _QuickActionItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);
    final isMobile = width < 650;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!isMobile) setState(() => _hover = false);
      },
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 22, max: 28),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.018, min: 16, max: 22),
            vertical: responsiveHeight(context, 0.018, min: 14, max: 20),
          ),
          transform: Matrix4.identity()..translate(0.0, _hover ? -5.0 : 0.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFEFBFD),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.018, min: 22, max: 28),
            ),
            border: Border.all(
              color: _hover
                  ? const Color(0xFFE7549B).withValues(alpha: 0.45)
                  : const Color(0xFFE7549B).withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF831843,
                ).withValues(alpha: _hover ? 0.16 : 0.09),
                blurRadius: _hover ? 30 : 22,
                offset: Offset(0, _hover ? 14 : 9),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: responsiveSize(context, 0.052, min: 50, max: 62),
                height: responsiveSize(context, 0.052, min: 50, max: 62),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.016, min: 18, max: 22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE7549B).withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: responsiveSize(context, 0.026, min: 26, max: 32),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.026, min: 12, max: 18)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: widget.title,
                      size: responsiveSize(context, 0.038, min: 15, max: 18),
                      color: const Color(0xFF14213D),
                      bold: true,
                      isEnglish: false,
                      isCenter: false,
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: responsiveHeight(context, 0.006, min: 4, max: 7),
                    ),
                    customText(
                      text: widget.subtitle,
                      size: responsiveSize(context, 0.030, min: 11, max: 13),
                      color: Colors.grey[600],
                      isEnglish: true,
                      isCenter: false,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: responsiveSize(context, 0.030, min: 13, max: 16),
                color: const Color(0xFFE7549B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ModernSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_ModernSection> createState() => _ModernSectionState();
}

class _ModernSectionState extends State<_ModernSection> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!isMobile) setState(() => _hover = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        width: double.infinity,
        transform: Matrix4.identity()
          ..translate(0.0, _hover && !isMobile ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 26, max: 34),
          ),
          border: Border.all(
            color: _hover
                ? const Color(0xFFE7549B).withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF14213D,
              ).withValues(alpha: _hover ? 0.14 : 0.08),
              blurRadius: _hover ? 34 : 24,
              offset: Offset(0, _hover ? 18 : 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 26, max: 34),
          ),
          child: Column(
            children: [
              _SectionHeader(
                title: widget.title,
                subtitle: widget.subtitle,
                icon: widget.icon,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  responsiveSize(context, 0.018, min: 16, max: 26),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<_SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<_SectionHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final value = _animation.value;

        return Container(

          height: isMobile ? 86 : 96,
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.020, min: 18, max: 28),
            vertical: responsiveHeight(context, 0.014, min: 14, max: 18),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFFE7549B),
                Color(0xFFC044D8),
                Color(0xFF8A2BE2),
              ],
              begin: Alignment(-1 + value, -1),
              end: Alignment(1 - value, 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: responsiveSize(context, 0.052, min: 46, max: 54),
                height: responsiveSize(context, 0.052, min: 46, max: 54),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.016, min: 15, max: 18),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: responsiveSize(context, 0.026, min: 24, max: 28),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.018, min: 12, max: 16)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: widget.title,
                      size: responsiveSize(context, 0.042, min: 18, max: 20),
                      color: Colors.white,
                      bold: true,
                      isCenter: false,
                      maxLines: isMobile ? 2 : 1,
                    ),
                    SizedBox(
                      height: responsiveHeight(context, 0.005, min: 4, max: 6),
                    ),
                    customText(
                      text: widget.subtitle,
                      size: responsiveSize(context, 0.030, min: 12, max: 13),
                      color: Colors.white.withValues(alpha: 0.78),
                      isCenter: false,
                      maxLines: isMobile ? 2 : 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
