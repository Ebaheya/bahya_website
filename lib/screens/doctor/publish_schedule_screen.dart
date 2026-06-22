import 'dart:ui';

import 'package:bahya_website/bloc/cubit/publish_schedule_cubit.dart';
import 'package:bahya_website/bloc/states/publish_schedule_state.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/animated_home_background.dart';
import 'package:bahya_website/helper/widgets/doctor_page_header.dart';
import 'package:bahya_website/helper/widgets/schedule/schedule_form.dart';
import 'package:bahya_website/helper/widgets/schedule/scheduled_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PublishScheduleScreen extends StatefulWidget {
  const PublishScheduleScreen({super.key});

  @override
  State<PublishScheduleScreen> createState() => _PublishScheduleScreenState();
}

class _PublishScheduleScreenState extends State<PublishScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
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
        (index * 0.12).clamp(0.0, 0.75),
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
    final isMobile = getScreenWidth(context) < 650;

    return BlocProvider(
      create: (_) => PublishScheduleCubit(AppRepository())..loadForms(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: AnimatedHomeBackground(
          child: BlocConsumer<PublishScheduleCubit, PublishScheduleState>(
            listener: (context, state) {
              if (state.error != null) {
                customDialog(
                  context: context,
                  title: "خطأ",
                  message: state.error!,
                  isError: true,
                );
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return Center(child: customLoading());
              }

              return RefreshIndicator(
                color: buttonColor,
                onRefresh: () async {
                  await context.read<PublishScheduleCubit>().loadForms();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile
                        ? 18
                        : responsiveSize(context, 0.02, min: 20, max: 34),
                    vertical: responsiveHeight(
                      context,
                      0.025,
                      min: 18,
                      max: 32,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? double.infinity : 1250,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _animatedItem(
                            index: 0,
                            child: animatedPageHeader(
                              context: context,
                              title: "جدولة النماذج",
                              subtitle:
                                  "إنشاء وجدولة النماذج وإرسالها للمرضى بسهولة",
                              icon: Icons.event_available_rounded,
                              showBack: true,
                              onBackTap: () {
                                context.go('/home');
                              },
                            ),
                          ),
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.03,
                              min: 20,
                              max: 34,
                            ),
                          ),
                          _animatedItem(
                            index: 1,
                            child: _ScheduleGlassSection(
                              title: "بيانات الجدولة",
                              subtitle: "اختر النموذج وحدد تفاصيل الإرسال",
                              icon: Icons.edit_calendar_rounded,
                              child: ScheduleFormWidget(
                                forms: state.activeForms,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.035,
                              min: 22,
                              max: 38,
                            ),
                          ),
                          _animatedItem(
                            index: 2,
                            child: _ScheduleGlassSection(
                              title: "النماذج المنشورة",
                              subtitle:
                                  "متابعة النماذج المجدولة والمنشورة للمرضى",
                              icon: Icons.assignment_turned_in_rounded,
                              child: ScheduledListWidget(
                                scheduled: const [],
                                publishedForms: state.publishedForms,
                                publishedAssignments:
                                    state.publishedAssignments,
                                isLoadingAssignments:
                                    state.isLoadingAssignments,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.04,
                              min: 24,
                              max: 42,
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
      ),
    );
  }
}

class _ScheduleGlassSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ScheduleGlassSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_ScheduleGlassSection> createState() => _ScheduleGlassSectionState();
}

class _ScheduleGlassSectionState extends State<_ScheduleGlassSection> {
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: double.infinity,
        transform: Matrix4.identity()
          ..translate(0.0, _hover && !isMobile ? -6.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _hover ? 0.96 : 0.90),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 28, max: 36),
          ),
          border: Border.all(
            color: _hover
                ? const Color(0xFFE7549B).withValues(alpha: 0.45)
                : const Color(0xFFE7549B).withValues(alpha: 0.15),
            width: _hover ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFE7549B,
              ).withValues(alpha: _hover ? 0.12 : 0.05),
              blurRadius: _hover ? 30 : 20,
              offset: Offset(0, _hover ? 15 : 10),
            ),
            BoxShadow(
              color: const Color(
                0xFF14213D,
              ).withValues(alpha: _hover ? 0.08 : 0.04),
              blurRadius: _hover ? 40 : 25,
              offset: Offset(0, _hover ? 20 : 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 26, max: 34),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                _ScheduleSectionHeader(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  icon: widget.icon,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    responsiveSize(context, 0.020, min: 20, max: 30),
                  ),
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleSectionHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ScheduleSectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<_ScheduleSectionHeader> createState() => _ScheduleSectionHeaderState();
}

class _ScheduleSectionHeaderState extends State<_ScheduleSectionHeader>
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
