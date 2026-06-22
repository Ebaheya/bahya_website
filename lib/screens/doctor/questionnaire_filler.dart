import 'package:bahya_website/bloc/cubit/doctor_cubit.dart';
import 'package:bahya_website/bloc/states/doctor_state.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/animated_home_background.dart';
import 'package:bahya_website/helper/widgets/doctor_page_header.dart';
import 'package:bahya_website/helper/widgets/filler/saved_filler.dart';
import 'package:bahya_website/helper/widgets/filler/saved_filler_widget.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorFormsCubit(AppRepository())..loadForms(),
      child: const _FormsScreenBody(),
    );
  }
}

class _FormsScreenBody extends StatefulWidget {
  const _FormsScreenBody();

  @override
  State<_FormsScreenBody> createState() => _FormsScreenBodyState();
}

class _FormsScreenBodyState extends State<_FormsScreenBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final isMobile = w < 700;
    final isTablet = w >= 700 && w < 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      body: AnimatedHomeBackground(
        child: SafeArea(
          child: BlocConsumer<DoctorFormsCubit, DoctorFormsState>(
            listenWhen: (previous, current) {
              return previous.error != current.error ||
                  previous.createdAssessment != current.createdAssessment;
            },
            listener: (context, state) {
              if (state.error != null) {
                customSnackBar(context: context, message: state.error!);
              }

              if (state.createdAssessment != null) {
                final score = state.createdAssessment?["score"] ?? 0;
                final diagnosis =
                    state.createdAssessment?["diagnosis"] ??
                    localizedText(context, 'Not specified');
                final patientStatus =
                    state.createdAssessment?["patientStatus"] ??
                    localizedText(context, 'Not specified');
                final diagnosisLabel = localizedText(context, 'Diagnosis');
                final scoreLabel = localizedText(context, 'Score');
                final statusLabel = localizedText(context, 'Patient status');

                customDialog(
                  context: context,
                  title: 'Assessment saved successfully',
                  message:
                      '$diagnosisLabel: $diagnosis\n$scoreLabel: $score\n$statusLabel: $patientStatus',
                  isError: false,
                );

                context.read<DoctorFormsCubit>().clearCreatedAssessment();
              }
            },
            builder: (context, state) {
              if (state.isLoadingForms) {
                return Center(child: customLoading());
              }

              return ValueListenableBuilder<Locale>(
                valueListenable: AppLanguageController.localeNotifier,
                builder: (context, locale, _) {
                  final isEnglish = locale.languageCode == 'en';

                  return Directionality(
                    textDirection: isEnglish
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile
                            ? 18
                            : responsiveSize(context, 0.025, min: 20, max: 42),
                        vertical: responsiveHeight(
                          context,
                          0.030,
                          min: 18,
                          max: 36,
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1360),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _animatedItem(
                                index: 0,
                                child: animatedPageHeader(
                                  context: context,
                                  title: 'Fill out questionnaires',
                                  subtitle:
                                      'اختيار نموذج وتسجيل تقييم المريض بسهولة',
                                  icon: Icons.fact_check_rounded,
                                  showBack: true,
                                  onBackTap: () {
                                    context.go('/home');
                                  },
                                ),
                              ),
                              SizedBox(
                                height: responsiveHeight(
                                  context,
                                  0.030,
                                  min: 20,
                                  max: 34,
                                ),
                              ),
                              _animatedItem(
                                index: 1,
                                child: isMobile
                                    ? _MobileFormsLayout(state: state)
                                    : _DesktopFormsLayout(
                                        state: state,
                                        isTablet: isTablet,
                                        pageHeight: h,
                                      ),
                              ),
                              SizedBox(
                                height: responsiveHeight(
                                  context,
                                  0.040,
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DesktopFormsLayout extends StatelessWidget {
  final DoctorFormsState state;
  final bool isTablet;
  final double pageHeight;

  const _DesktopFormsLayout({
    required this.state,
    required this.isTablet,
    required this.pageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isTablet ? 6 : 7,
          child: _ModernFormsSection(
            title: 'ملء الاستبيان',
            subtitle: 'اختر المريض وأجب على أسئلة النموذج المحدد',
            icon: Icons.edit_document,
            child: state.isLoadingFormDetails
                ? SizedBox(
                    height: responsiveHeight(context, 0.45, min: 360, max: 560),
                    child: Center(child: customLoading()),
                  )
                : DynamicFormFillerWidget(
                    form: state.selectedForm,
                    patients: state.patientOptions,
                    selectedPatient: state.selectedPatient,
                    isSearchingPatients: state.isSearchingPatients,
                    isSubmitting: state.isSubmittingAssessment,
                  ),
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.018, min: 18, max: 28)),
        SizedBox(
          width: isTablet ? 330 : 380,
          child: _ModernFormsSection(
            title: 'النماذج المتاحة',
            subtitle: 'اختر النموذج المطلوب تعبئته',
            icon: Icons.library_books_rounded,
            child: SizedBox(
              height: pageHeight * 0.72,
              child: SavedFormsWidget(
                forms: state.forms,
                selectedFormId: state.selectedForm?.id ?? '',
                isMobileLayout: false,
                onSelect: (id) {
                  context.read<DoctorFormsCubit>().selectForm(id);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileFormsLayout extends StatelessWidget {
  final DoctorFormsState state;

  const _MobileFormsLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ModernFormsSection(
          title: 'النماذج المتاحة',
          subtitle: 'اختر النموذج المطلوب تعبئته',
          icon: Icons.library_books_rounded,
          child: SizedBox(
            height: responsiveHeight(context, 0.42, min: 320, max: 460),
            child: SavedFormsWidget(
              forms: state.forms,
              selectedFormId: state.selectedForm?.id ?? '',
              isMobileLayout: true,
              onSelect: (id) {
                context.read<DoctorFormsCubit>().selectForm(id);
              },
            ),
          ),
        ),
        SizedBox(height: responsiveHeight(context, 0.026, min: 18, max: 30)),
        _ModernFormsSection(
          title: 'ملء الاستبيان',
          subtitle: 'اختر المريض وأجب على أسئلة النموذج',
          icon: Icons.edit_document,
          child: state.isLoadingFormDetails
              ? SizedBox(
                  height: responsiveHeight(context, 0.36, min: 280, max: 420),
                  child: Center(child: customLoading()),
                )
              : DynamicFormFillerWidget(
                  form: state.selectedForm,
                  patients: state.patientOptions,
                  selectedPatient: state.selectedPatient,
                  isSearchingPatients: state.isSearchingPatients,
                  isSubmitting: state.isSubmittingAssessment,
                ),
        ),
      ],
    );
  }
}

class _ModernFormsSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ModernFormsSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_ModernFormsSection> createState() => _ModernFormsSectionState();
}

class _ModernFormsSectionState extends State<_ModernFormsSection> {
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
              _FormsSectionHeader(
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

class _FormsSectionHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _FormsSectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<_FormsSectionHeader> createState() => _FormsSectionHeaderState();
}

class _FormsSectionHeaderState extends State<_FormsSectionHeader>
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
