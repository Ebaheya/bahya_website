import 'package:bahya_website/helper/admin_widgets/recent%20activity/recent_activity_widgets.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class RecentActivityDialog extends StatefulWidget {
  final List<ActivityModel> activities;

  const RecentActivityDialog({super.key, required this.activities});

  @override
  State<RecentActivityDialog> createState() => _RecentActivityDialogState();
}

class _RecentActivityDialogState extends State<RecentActivityDialog>
    with SingleTickerProviderStateMixin {
  int currentPage = 0;
  static const int pageSize = 5;

  late final AnimationController _pageController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  int get totalPages {
    if (widget.activities.isEmpty) return 1;
    return (widget.activities.length / pageSize).ceil();
  }

  List<ActivityModel> get currentItems {
    final start = currentPage * pageSize;
    final end = (start + pageSize) > widget.activities.length
        ? widget.activities.length
        : start + pageSize;

    if (start >= widget.activities.length) return [];
    return widget.activities.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
        );

    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animatePageChange(VoidCallback changePage) {
    _pageController.reverse().then((_) {
      if (!mounted) return;

      setState(changePage);

      _pageController.forward();
    });
  }

  void nextPage() {
    if (currentPage >= totalPages - 1) return;

    _animatePageChange(() {
      currentPage++;
    });
  }

  void previousPage() {
    if (currentPage <= 0) return;

    _animatePageChange(() {
      currentPage--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isMobile
              ? MediaQuery.sizeOf(context).width * 0.92
              : responsiveSize(context, 0.52, min: 620, max: 820),
          height: isMobile
              ? MediaQuery.sizeOf(context).height * 0.78
              : MediaQuery.sizeOf(context).height * 0.76,
          padding: EdgeInsets.all(
            responsiveSize(context, 0.018, min: 18, max: 28),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.018, min: 20, max: 28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: responsiveSize(context, 0.04, min: 42, max: 58),
                    height: responsiveSize(context, 0.04, min: 42, max: 58),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: responsiveSize(context, 0.006, min: 6, max: 9),
                  ),
                  customText(
                    text: "الأنشطة الأخيرة",
                    size: responsiveSize(context, 0.014, min: 18, max: 24),
                    color: const Color(0xFF272044),
                    bold: true,
                    isCenter: false,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(
                height: responsiveHeight(context, 0.026, min: 18, max: 28),
              ),
              Expanded(
                child: currentItems.isEmpty
                    ? Center(
                        child: customText(
                          text: "لا توجد أنشطة حالياً",
                          size: responsiveSize(
                            context,
                            0.012,
                            min: 14,
                            max: 17,
                          ),
                          color: Colors.grey,
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: FadeTransition(
                          key: ValueKey(currentPage),
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: ListView.builder(
                              key: ValueKey("activity_page_$currentPage"),
                              itemCount: currentItems.length,
                              itemBuilder: (context, index) {
                                final item = currentItems[index];

                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(
                                    milliseconds: 260 + (index * 70),
                                  ),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(18 * (1 - value), 0),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: ActivityItem(
                                    dotColor: item.dotColor,
                                    iconColor: item.iconColor,
                                    icon: item.icon,
                                    title: item.title,
                                    description: item.description,
                                    time: item.time,
                                    showLine: index != currentItems.length - 1,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
              ),
              SizedBox(
                height: responsiveHeight(context, 0.02, min: 14, max: 22),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveSize(context, 0.01, min: 10, max: 14),
                  vertical: responsiveHeight(context, 0.008, min: 6, max: 8),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5FB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AnimatedPageButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      enabled: currentPage > 0,
                      onTap: previousPage,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveSize(
                          context,
                          0.014,
                          min: 14,
                          max: 18,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: customText(
                          text: "${currentPage + 1} / $totalPages",
                          size: responsiveSize(context, 0.01, min: 13, max: 16),
                          color: const Color(0xFF272044),
                          bold: true,
                          isEnglish: true,
                        ),
                      ),
                    ),
                    _AnimatedPageButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      enabled: currentPage < totalPages - 1,
                      onTap: nextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedPageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _AnimatedPageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: enabled ? 1 : 0.92,
      duration: const Duration(milliseconds: 180),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: responsiveSize(context, 0.034, min: 34, max: 40),
          height: responsiveSize(context, 0.034, min: 34, max: 40),
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFFE7549B).withValues(alpha: 0.10)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: responsiveSize(context, 0.014, min: 15, max: 18),
            color: enabled ? const Color(0xFFE7549B) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
