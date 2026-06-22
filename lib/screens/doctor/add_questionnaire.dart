import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/animated_home_background.dart';
import 'package:bahya_website/helper/widgets/doctor_page_header.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body_widgets.dart';
import 'package:bahya_website/logic/add_questionnaire_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddQuestionnaire extends StatefulWidget {
  const AddQuestionnaire({super.key});

  @override
  State<AddQuestionnaire> createState() => _AddQuestionnaireState();
}

class _AddQuestionnaireState extends State<AddQuestionnaire>
    with SingleTickerProviderStateMixin {
  late final AddQuestionnaireController controller;
  late final AnimationController _pageController;

  @override
  void initState() {
    super.initState();
    controller = AddQuestionnaireController();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAvailableForms(context);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    controller.dispose();
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
    final w = getScreenWidth(context);
    final isMobile = w < 650;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: AnimatedHomeBackground(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile
                    ? 18
                    : responsiveSize(context, 0.02, min: 20, max: 34),
                vertical: responsiveHeight(context, 0.025, min: 18, max: 32),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
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
                            title: controller.isEditMode
                                ? 'تعديل استبيان'
                                : 'إضافة استبيان جديد',
                            subtitle:
                                'إنشاء وإدارة الاستبيانات والأسئلة والتشخيصات',
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
                            0.03,
                            min: 20,
                            max: 34,
                          ),
                        ),
                        _animatedItem(
                          index: 1,
                          child: _QuestionnaireGlassSection(
                            title: 'بيانات الاستبيان',
                            subtitle:
                                'اكتب اسم الاستبيان وأضف الأسئلة المطلوبة',
                            icon: Icons.edit_note_rounded,
                            child: Column(
                              children: [
                                const QuestionnairePageHeader(),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.028,
                                    min: 18,
                                    max: 30,
                                  ),
                                ),
                                SurveyTitleCard(
                                  isEditing: true,
                                  controller: controller.surveyTitleController,
                                ),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.025,
                                    min: 18,
                                    max: 26,
                                  ),
                                ),
                                ...List.generate(controller.questions.length, (
                                  index,
                                ) {
                                  final question = controller.questions[index];

                                  return Padding(
                                    key: ValueKey(question.id),
                                    padding: EdgeInsets.only(
                                      bottom: responsiveHeight(
                                        context,
                                        0.025,
                                        min: 18,
                                        max: 26,
                                      ),
                                    ),
                                    child: question.isDeleting
                                        ? AnimatedRemove(
                                            onAnimationEnd: () => controller
                                                .deleteQuestionAfterAnimation(
                                                  index,
                                                ),
                                            child: QuestionnaireBody(
                                              key: question.key,
                                              questionIndex: index + 1,
                                              canDeleteQuestion: false,
                                              onDeleteQuestion: () {},
                                              initialData: question.initialData,
                                            ),
                                          )
                                        : AnimatedAdd(
                                            key: ValueKey(question.id),
                                            child: QuestionnaireBody(
                                              key: question.key,
                                              questionIndex: index + 1,
                                              canDeleteQuestion:
                                                  controller.questions.length >
                                                  1,
                                              onDeleteQuestion: () =>
                                                  controller.removeQuestion(
                                                    context,
                                                    index,
                                                  ),
                                              initialData: question.initialData,
                                            ),
                                          ),
                                  );
                                }),
                                CustomGlowButton(
                                  title: 'إنشاء سؤال جديد',
                                  onPressed: () =>
                                      controller.addQuestion(context),
                                  icon: Icons.add,
                                  isGradient: true,
                                ),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.03,
                                    min: 20,
                                    max: 32,
                                  ),
                                ),
                                DiagnosisSection(key: controller.diagnosisKey),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.03,
                                    min: 20,
                                    max: 32,
                                  ),
                                ),
                                _SaveActions(controller: controller),
                              ],
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
                          child: _QuestionnaireGlassSection(
                            title: 'النماذج المتاحة',
                            subtitle:
                                'إدارة النماذج المحفوظة وتعديلها أو حذفها',
                            icon: Icons.library_books_rounded,
                            child: _AvailableFormsWidget(
                              controller: controller,
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
            ),
          ),
        );
      },
    );
  }
}

class _SaveActions extends StatelessWidget {
  final AddQuestionnaireController controller;

  const _SaveActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        if (controller.isEditMode)
          CustomGlowButton(
            title: 'إلغاء التعديل',
            onPressed: controller.resetEditor,
            height: responsiveHeight(context, 0.045, min: 40, max: 48),
            width: responsiveSize(context, 0.11, min: 130, max: 165),
            textSize: responsiveSize(context, 0.009, min: 12, max: 15),
            icon: Icons.close,
          ),
        CustomGlowButton(
          title: controller.isSaving
              ? 'جاري الحفظ...'
              : controller.isEditMode
              ? 'حفظ التعديلات'
              : 'حفظ الاستبيان',
          onPressed: () {
            if (!controller.isSaving) {
              controller.saveSurvey(context);
            }
          },
          isGradient: true,
          icon: Icons.save_outlined,
        ),
      ],
    );
  }
}

class _QuestionnaireGlassSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _QuestionnaireGlassSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_QuestionnaireGlassSection> createState() =>
      _QuestionnaireGlassSectionState();
}

class _QuestionnaireGlassSectionState
    extends State<_QuestionnaireGlassSection> {
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
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 26, max: 34),
          ),
          border: Border.all(
            color: _hover
                ? const Color(0xFFE7549B).withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.85),
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
              _QuestionnaireSectionHeader(
                title: widget.title,
                subtitle: widget.subtitle,
                icon: widget.icon,
              ),
              Padding(
                padding: EdgeInsets.all(
                  responsiveSize(context, 0.018, min: 16, max: 26),
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

class _QuestionnaireSectionHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _QuestionnaireSectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<_QuestionnaireSectionHeader> createState() =>
      _QuestionnaireSectionHeaderState();
}

class _QuestionnaireSectionHeaderState
    extends State<_QuestionnaireSectionHeader>
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

class _AvailableFormsWidget extends StatefulWidget {
  final AddQuestionnaireController controller;

  const _AvailableFormsWidget({required this.controller});

  @override
  State<_AvailableFormsWidget> createState() => _AvailableFormsWidgetState();
}

class _AvailableFormsWidgetState extends State<_AvailableFormsWidget>
    with SingleTickerProviderStateMixin {
  static const int _itemsPerPage = 3;

  late final AnimationController _animationController;
  int _currentPage = 0;

  int get _totalPages {
    if (widget.controller.availableForms.isEmpty) return 1;
    return (widget.controller.availableForms.length / _itemsPerPage).ceil();
  }

  List<dynamic> get _currentForms {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(
      0,
      widget.controller.availableForms.length,
    );

    return widget.controller.availableForms.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant _AvailableFormsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_currentPage >= _totalPages) {
      _currentPage = (_totalPages - 1).clamp(0, _totalPages);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changePage(int page) {
    if (page < 0 || page >= _totalPages || page == _currentPage) return;

    setState(() => _currentPage = page);

    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.isLoadingForms) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: responsiveHeight(context, 0.025, min: 18, max: 30),
        ),
        child: Center(child: customLoading()),
      );
    }

    if (widget.controller.availableForms.isEmpty) {
      return const _EmptyFormsState();
    }

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: LayoutBuilder(
            key: ValueKey(_currentPage),
            builder: (context, constraints) {
              final isMobile = getScreenWidth(context) < 700;
              final forms = _currentForms;
              final crossAxisCount = isMobile
                  ? 1
                  : constraints.maxWidth < 900
                  ? 2
                  : 3;

              return GridView.builder(
                itemCount: forms.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: responsiveSize(
                    context,
                    0.020,
                    min: 16,
                    max: 24,
                  ),
                  mainAxisSpacing: responsiveHeight(
                    context,
                    0.024,
                    min: 16,
                    max: 24,
                  ),
                  childAspectRatio: isMobile ? 1.15 : 1.2,
                ),
                itemBuilder: (context, index) {
                  final form = forms[index];
                  final active = widget.controller.editingFormId == form['id'];

                  final animation = CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (index * 0.12).clamp(0.0, 0.70),
                      1,
                      curve: Curves.easeOutCubic,
                    ),
                  );

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.14),
                        end: Offset.zero,
                      ).animate(animation),
                      child: _AvailableFormCard(
                        form: form,
                        active: active,
                        controller: widget.controller,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (_totalPages > 1) ...[
          SizedBox(height: responsiveHeight(context, 0.028, min: 18, max: 28)),
          _FormsPaginationBar(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPageChanged: _changePage,
          ),
        ],
      ],
    );
  }
}

class _AvailableFormCard extends StatefulWidget {
  final dynamic form;
  final bool active;
  final AddQuestionnaireController controller;

  const _AvailableFormCard({
    required this.form,
    required this.active,
    required this.controller,
  });

  @override
  State<_AvailableFormCard> createState() => _AvailableFormCardState();
}

class _AvailableFormCardState extends State<_AvailableFormCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: widget.active
                  ? const Color(0xFFE7549B)
                  : const Color(0xFFE7549B).withValues(alpha: 0.08),
              width: widget.active ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF14213D,
                ).withValues(alpha: _hover ? 0.08 : 0.04),
                blurRadius: _hover ? 24 : 16,
                offset: Offset(0, _hover ? 12 : 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusPill(active: widget.active),
                    Row(
                      children: [
                        _FormTopIcon(active: widget.active),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.more_vert_rounded,
                          color: Colors.grey.shade400,
                          size: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CenterDecorativeIcon(hover: _hover),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: customText(
                          text: widget.form['name'].toString(),
                          size: responsiveSize(
                            context,
                            0.015,
                            min: 18,
                            max: 22,
                          ),
                          bold: true,
                          color: const Color(0xFF14213D),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _SmallFormButton(
                        title: 'حذف',
                        icon: Icons.delete_outline_rounded,
                        color: const Color(0xFFE7549B),
                        filled: false,
                        onTap: () => widget.controller.deleteForm(
                          context,
                          widget.form['id'],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SmallFormButton(
                        title: 'تعديل',
                        icon: Icons.edit_rounded,
                        color: const Color(0xFFE7549B),
                        filled: true,
                        onTap: () => widget.controller.editForm(
                          context,
                          widget.form['id'],
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
  }
}

class _FormTopIcon extends StatelessWidget {
  final bool active;

  const _FormTopIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFE7549B)
            : const Color(0xFFE7549B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.assignment_outlined,
        color: active ? Colors.white : const Color(0xFFE7549B),
        size: 20,
      ),
    );
  }
}

class _CenterDecorativeIcon extends StatelessWidget {
  final bool hover;

  const _CenterDecorativeIcon({required this.hover});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: hover ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE7549B).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE7549B).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Color(0xFFE7549B),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool active;

  const _StatusPill({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFE7549B).withValues(alpha: 0.14)
            : const Color(0xFFE7549B).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active
                ? Icons.edit_note_rounded
                : Icons.check_circle_outline_rounded,
            color: const Color(0xFFE7549B),
            size: 16,
          ),
          const SizedBox(width: 6),
          customText(
            text: active ? 'قيد التعديل' : 'محفوظ بالكامل',
            size: responsiveSize(context, 0.008, min: 12, max: 13),
            color: const Color(0xFFE7549B),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SmallFormButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _SmallFormButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: responsiveHeight(context, 0.046, min: 42, max: 48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: filled ? Colors.transparent : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: filled ? Colors.white : color,
              size: responsiveSize(context, 0.014, min: 16, max: 19),
            ),
            const SizedBox(width: 6),
            customText(
              text: title,
              size: responsiveSize(context, 0.009, min: 13, max: 15),
              color: filled ? Colors.white : color,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleFormAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleFormAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: responsiveSize(context, 0.040, min: 38, max: 44),
        height: responsiveSize(context, 0.040, min: 38, max: 44),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Icon(
          icon,
          color: color,
          size: responsiveSize(context, 0.018, min: 20, max: 24),
        ),
      ),
    );
  }
}

class _FormsPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _FormsPaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 700;

    return Center(
      child: Container(
        padding: EdgeInsets.all(responsiveSize(context, 0.006, min: 6, max: 9)),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFBFD),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.018, min: 20, max: 24),
          ),
          border: Border.all(
            color: const Color(0xFFE7549B).withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF831843).withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PageIconButton(
              icon: Icons.chevron_right_rounded,
              enabled: currentPage > 0,
              onTap: () => onPageChanged(currentPage - 1),
            ),
            SizedBox(width: isMobile ? 4 : 6),
            ...List.generate(totalPages, (index) {
              final selected = index == currentPage;

              return InkWell(
                onTap: () => onPageChanged(index),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 4),
                  width: selected
                      ? responsiveSize(context, 0.038, min: 38, max: 44)
                      : responsiveSize(context, 0.034, min: 34, max: 38),
                  height: responsiveSize(context, 0.034, min: 34, max: 38),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: selected ? null : const Color(0xFFF8EEF6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: customText(
                    text: '${index + 1}',
                    size: responsiveSize(context, 0.010, min: 13, max: 15),
                    color: selected ? Colors.white : const Color(0xFF831843),
                    bold: true,
                  ),
                ),
              );
            }),
            SizedBox(width: isMobile ? 4 : 6),
            _PageIconButton(
              icon: Icons.chevron_left_rounded,
              enabled: currentPage < totalPages - 1,
              onTap: () => onPageChanged(currentPage + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIconButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: responsiveSize(context, 0.034, min: 34, max: 38),
        height: responsiveSize(context, 0.034, min: 34, max: 38),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFE7549B).withValues(alpha: 0.10)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFFE7549B) : Colors.grey,
          size: responsiveSize(context, 0.018, min: 20, max: 24),
        ),
      ),
    );
  }
}

class _EmptyFormsState extends StatelessWidget {
  const _EmptyFormsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.018, min: 16, max: 24),
        vertical: responsiveHeight(context, 0.035, min: 24, max: 36),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4FA),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 20, max: 26),
        ),
        border: Border.all(
          color: const Color(0xFFE7549B).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            color: const Color(0xFFE7549B),
            size: responsiveSize(context, 0.04, min: 42, max: 58),
          ),
          SizedBox(height: responsiveHeight(context, 0.012, min: 10, max: 14)),
          customText(
            text: 'لا توجد نماذج محفوظة حتى الآن.',
            size: responsiveSize(context, 0.012, min: 14, max: 18),
            color: Colors.grey.shade700,
            bold: true,
          ),
        ],
      ),
    );
  }
}
