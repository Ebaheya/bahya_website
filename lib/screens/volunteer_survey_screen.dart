import 'package:bahya_website/bloc/cubit/volunteer_cubit.dart';
import 'package:bahya_website/bloc/states/volunteer_assignments_state.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/animated_background.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/volunteer/patients_list.dart';
import 'package:bahya_website/helper/widgets/volunteer/volunteer_patients_widgets.dart';
import 'package:bahya_website/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VolunteerPatientsScreen extends StatelessWidget {
  const VolunteerPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VolunteerAssignmentsCubit(WebService())..loadAssignments(),
      child: const _VolunteerPatientsView(),
    );
  }
}

class _VolunteerPatientsView extends StatelessWidget {
  const _VolunteerPatientsView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final isMobile = w < 700;
    final isTablet = w >= 700 && w < 1100;

    final pagePadding = responsiveSize(
      context,
      isMobile ? 0.018 : 0.025,
      min: isMobile ? 8 : 12,
      max: isMobile ? 14 : 28,
    );

    final gap = responsiveSize(
      context,
      isMobile ? 0.018 : 0.024,
      min: isMobile ? 10 : 14,
      max: isMobile ? 16 : 30,
    );

    final formPadding = responsiveSize(
      context,
      isMobile ? 0.018 : 0.03,
      min: isMobile ? 12 : 16,
      max: isMobile ? 18 : 32,
    );

    final radius = responsiveSize(
      context,
      isMobile ? 0.045 : 0.026,
      min: isMobile ? 18 : 20,
      max: isMobile ? 22 : 28,
    );

    final patientsHeight = responsiveHeight(
      context,
      isMobile ? 0.34 : 0.70,
      min: isMobile ? 380 : 500,
      max: isMobile ? 560 : h,
    );

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: BlocConsumer<VolunteerAssignmentsCubit, VolunteerAssignmentsState>(
            listener: (context, state) {
              if (state.error != null) {
                customDialog(
                  context: context,
                  title: 'تنبيه',
                  message: state.error!,
                  isError: true,
                );
              }
            },
            builder: (context, state) {
              if (state.isLoading && !state.hasLoaded) {
                return Center(child: customLoading());
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SizedBox(
                      width: isMobile ? w : w * 0.95,
                      height: constraints.maxHeight,
                      child: Padding(
                        padding: EdgeInsets.all(pagePadding),
                        child: Column(
                          children: [
                            _VolunteerHeader(isMobile: isMobile),
                            SizedBox(height: gap),
                            Expanded(
                              child: isMobile
                                  ? Column(
                                      children: [
                                        SizedBox(
                                          height: patientsHeight,
                                          child: _panel(
                                            context: context,
                                            radius: radius,
                                            padding: 0,
                                            child: PatientsListWidget(
                                              assignments: state.assignments,
                                              selectedAssignmentId: state
                                                  .selectedAssignment?['id']
                                                  ?.toString(),
                                              onSelect: (assignment) {
                                                context
                                                    .read<
                                                      VolunteerAssignmentsCubit
                                                    >()
                                                    .selectAssignment(
                                                      assignment,
                                                    );
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: gap),
                                        Expanded(
                                          child: _formContainer(
                                            context: context,
                                            state: state,
                                            padding: formPadding,
                                            radius: radius,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: isTablet ? 2 : 3,
                                          child: _formContainer(
                                            context: context,
                                            state: state,
                                            padding: formPadding,
                                            radius: radius,
                                          ),
                                        ),
                                        SizedBox(width: gap),
                                        SizedBox(
                                          width: isTablet ? w * 0.32 : w * 0.24,
                                          height: constraints.maxHeight,
                                          child: _panel(
                                            context: context,
                                            radius: radius,
                                            padding: 0,
                                            child: PatientsListWidget(
                                              assignments: state.assignments,
                                              selectedAssignmentId: state
                                                  .selectedAssignment?['id']
                                                  ?.toString(),
                                              onSelect: (assignment) {
                                                context
                                                    .read<
                                                      VolunteerAssignmentsCubit
                                                    >()
                                                    .selectAssignment(
                                                      assignment,
                                                    );
                                              },
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
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget _panel({
    required BuildContext context,
    required double radius,
    required double padding,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: _cardDecoration(radius),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _formContainer({
    required BuildContext context,
    required VolunteerAssignmentsState state,
    required double padding,
    required double radius,
  }) {
    if (state.assignments.isEmpty) {
      return _emptyCard(
        text: 'لا توجد استبيانات مسندة لك حالياً.',
        padding: padding,
        radius: radius,
      );
    }

    if (state.isLoadingDetails) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(padding),
        decoration: _cardDecoration(radius),
        child: Center(child: customLoading()),
      );
    }

    if (state.selectedAssignmentDetails == null) {
      return _emptyCard(
        text: 'اختاري مريض من القائمة لعرض الاستبيان.',
        padding: padding,
        radius: radius,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: _cardDecoration(radius),
      child: VolunteerSurveyWidget(
        assignmentDetails: state.selectedAssignmentDetails!,
        onSave: () async {
          final success = await context
              .read<VolunteerAssignmentsCubit>()
              .submitSelectedAssignment();

          if (!context.mounted) return;

          if (success) {
            customDialog(
              context: context,
              title: "تم الحفظ",
              message: "تم تسجيل الاستبيان بنجاح.",
              isSuccess: true,
            );
          }
        },
      ),
    );
  }

  static BoxDecoration _cardDecoration(double radius) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFFFD6EA)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF7A004C).withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _emptyCard({
    required String text,
    required double padding,
    required double radius,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: _cardDecoration(radius),
      child: Center(
        child: customText(text: text, size: 18, color: Colors.grey, bold: true),
      ),
    );
  }
}

class _VolunteerHeader extends StatefulWidget {
  const _VolunteerHeader({required this.isMobile});

  final bool isMobile;

  @override
  State<_VolunteerHeader> createState() => _VolunteerHeaderState();
}

class _VolunteerHeaderState extends State<_VolunteerHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
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

  Widget _actionsRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LanguageToggleButton(padding: EdgeInsets.zero),
        SizedBox(width: responsiveSize(context, 0.01, min: 10, max: 14)),
        _LogoutActionButton(
          onTap: () async {
            await authNotifier.logout();

            if (!context.mounted) return;

            context.go('/login');
          },
        ),
      ],
    );
  }

  Widget _iconBox(BuildContext context) {
    return Container(
      width: responsiveSize(context, 0.052, min: 56, max: 82),
      height: responsiveSize(context, 0.052, min: 56, max: 82),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 18, max: 24),
        ),
      ),
      child: Icon(
        Icons.volunteer_activism_rounded,
        color: Colors.white,
        size: responsiveSize(context, 0.03, min: 32, max: 46),
      ),
    );
  }

  Widget _textBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(
          text: 'متطوع Workspace',
          size: responsiveSize(context, 0.021, min: 26, max: 38),
          bold: true,
          color: Colors.white,
          isEnglish: false,
          isCenter: false,
          maxLines: 1,
        ),
        SizedBox(height: responsiveHeight(context, 0.006, min: 5, max: 8)),
        customText(
          text: 'اختر patient واملأ assigned surveys',
          size: responsiveSize(context, 0.0095, min: 13, max: 16),
          color: Colors.white.withValues(alpha: 0.82),
          bold: true,
          isEnglish: false,
          isCenter: false,
          maxLines: 2,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final v = _animation.value;

          final beginAlignment = Alignment.lerp(
            Alignment.centerLeft,
            Alignment.centerRight,
            v,
          )!;

          final endAlignment = Alignment.lerp(
            Alignment.centerRight,
            Alignment.centerLeft,
            v,
          )!;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.02, min: 18, max: 34),
              vertical: responsiveHeight(context, 0.024, min: 20, max: 30),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.026, min: 22, max: 34),
              ),
              gradient: LinearGradient(
                colors: gradientColors,
                begin: beginAlignment,
                end: endAlignment,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withValues(alpha: 0.18 + (v * 0.12)),
                  blurRadius: responsiveSize(
                    context,
                    0.02 + (v * 0.006),
                    min: 20,
                    max: 36,
                  ),
                  offset: Offset(
                    0,
                    responsiveHeight(
                      context,
                      0.012 + (v * 0.004),
                      min: 8,
                      max: 16,
                    ),
                  ),
                ),
              ],
            ),
            child: child,
          );
        },
        child: widget.isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _iconBox(context),
                      SizedBox(
                        width: responsiveSize(context, 0.014, min: 12, max: 18),
                      ),
                      Expanded(child: _textBlock(context)),
                    ],
                  ),
                  SizedBox(height: responsiveHeight(context, 0.018, min: 14)),
                  Wrap(
                    spacing: responsiveSize(context, 0.008, min: 8, max: 12),
                    runSpacing: responsiveHeight(
                      context,
                      0.01,
                      min: 8,
                      max: 12,
                    ),
                    children: [_actionsRow(context)],
                  ),
                ],
              )
            : Row(
                children: [
                  _iconBox(context),
                  SizedBox(
                    width: responsiveSize(context, 0.014, min: 14, max: 22),
                  ),
                  Expanded(child: _textBlock(context)),
                  _actionsRow(context),
                ],
              ),
      ),
    );
  }
}

class _LogoutActionButton extends StatefulWidget {
  const _LogoutActionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_LogoutActionButton> createState() => _LogoutActionButtonState();
}

class _LogoutActionButtonState extends State<_LogoutActionButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 14, max: 18),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.014, min: 14, max: 18),
            vertical: responsiveHeight(context, 0.012, min: 9, max: 12),
          ),
          decoration: BoxDecoration(
            color: hover ? const Color(0xFFFFEEF2) : Colors.white,
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.014, min: 14, max: 18),
            ),
            border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: hover ? 0.12 : 0.07),
                blurRadius: hover ? 18 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: responsiveSize(context, 0.014, min: 18, max: 22),
              ),
              SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 10)),
              customText(
                text: "Logout",
                size: responsiveSize(context, 0.0085, min: 12, max: 14),
                color: Colors.red,
                bold: true,
                isEnglish: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
