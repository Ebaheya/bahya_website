import 'package:bahya_website/bloc/cubit/doctor_cubit.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'saved_filler_fields.dart';

class DynamicFormFillerWidget extends StatefulWidget {
  final FormModel? form;
  final List<OptionUserModel> patients;
  final OptionUserModel? selectedPatient;
  final bool isSearchingPatients;
  final bool isSubmitting;

  const DynamicFormFillerWidget({
    super.key,
    required this.form,
    required this.patients,
    required this.selectedPatient,
    required this.isSearchingPatients,
    required this.isSubmitting,
  });

  @override
  State<DynamicFormFillerWidget> createState() =>
      _DynamicFormFillerWidgetState();
}

class _DynamicFormFillerWidgetState extends State<DynamicFormFillerWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController patientSearchController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  late final AnimationController _controller;

  int _step = 0;
  int _questionIndex = 0;
  String? _lastFormId;

  bool get _isMobile => MediaQuery.sizeOf(context).width < 700;

  int get _questionsCount => widget.form?.currentVersion?.questions.length ?? 0;

  double get _progress {
    if (widget.form == null) return 0;
    if (_step == 0) return 0.20;
    if (_step == 2) return 1;
    if (_questionsCount == 0) return 0.70;
    return 0.35 + ((_questionIndex + 1) / _questionsCount) * 0.45;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant DynamicFormFillerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentId = widget.form?.id;

    if (_lastFormId != currentId) {
      _lastFormId = currentId;
      _step = 0;
      _questionIndex = 0;
      noteController.clear();
      patientSearchController.clear();
      _restartAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    patientSearchController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _updateState(VoidCallback callback) => setState(callback);

  void _restartAnimation() {
    _controller.reset();
    _controller.forward();
  }

  void _showRequiredMessage(String message) {
    customDialog(
      context: context,
      title: 'تنبيه',
      message: message,
      isInfo: true,
    );
  }

  void _next() {
    if (widget.form == null) return;

    if (_step == 0) {
      if (widget.selectedPatient == null) {
        _showRequiredMessage('من فضلك اختر المريض أولاً');
        return;
      }

      setState(() {
        _step = _questionsCount == 0 ? 2 : 1;
        _questionIndex = 0;
      });

      _restartAnimation();
      return;
    }

    if (_step == 1) {
      final question = widget.form!.currentVersion!.questions[_questionIndex];

      if (!_isQuestionAnswered(question)) {
        _showRequiredMessage(
          'لازم تجاوب السؤال الحالي قبل الانتقال للسؤال التالي',
        );
        return;
      }

      if (_questionIndex < _questionsCount - 1) {
        setState(() => _questionIndex++);
      } else {
        setState(() => _step = 2);
      }

      _restartAnimation();
      return;
    }
  }

  void _previous() {
    if (_step == 0) return;

    if (_step == 2) {
      setState(() {
        _step = _questionsCount == 0 ? 0 : 1;
        _questionIndex = _questionsCount == 0 ? 0 : _questionsCount - 1;
      });

      _restartAnimation();
      return;
    }

    if (_step == 1 && _questionIndex > 0) {
      setState(() => _questionIndex--);
      _restartAnimation();
      return;
    }

    setState(() => _step = 0);
    _restartAnimation();
  }

  bool _isQuestionAnswered(dynamic question) {
    final cubit = context.read<DoctorFormsCubit>();

    if (question.type == 'SCALE') {
      return cubit.getScaleAnswer(question.id) != null;
    }

    if (question.type == 'MULTI_SELECT') {
      final choices = question.choices ?? [];

      for (final choice in choices) {
        if (cubit.isChoiceSelected(
          questionId: question.id,
          choiceId: choice.id,
        )) {
          return true;
        }
      }

      return false;
    }

    return cubit.getSingleChoiceAnswer(question.id) != null;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DoctorFormsCubit>().state;
    final cubit = context.read<DoctorFormsCubit>();

    if (widget.form == null) {
      return _emptySelectFormState();
    }

    final form = widget.form!;
    final score = cubit.calculateScore();
    final diagnosis = cubit.calculateDiagnosis();
    final patientStatus = cubit.getArabicStatus(state.selectedStatus);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(
          responsiveSize(context, 0.018, min: 12, max: 22),
        ),
        child: Column(
          children: [
            _FlowHeroHeader(
              form: form,
              currentStep: _step,
              questionIndex: _questionIndex,
              questionsCount: _questionsCount,
              diagnosisCount: form.currentVersion?.scoreRanges.length ?? 0,
              progress: _progress,
            ),
            SizedBox(
              height: responsiveHeight(context, 0.024, min: 18, max: 28),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: _stepBody(
                key: ValueKey('${form.id}_${_step}_$_questionIndex'),
                score: score,
                diagnosis: diagnosis,
                patientStatus: patientStatus,
              ),
            ),
            SizedBox(
              height: responsiveHeight(context, 0.026, min: 20, max: 32),
            ),
            _navigationBar(),
            SizedBox(
              height: responsiveHeight(context, 0.030, min: 22, max: 36),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody({
    required Key key,
    required int score,
    required String diagnosis,
    required String patientStatus,
  }) {
    if (_step == 0) {
      return _StepShell(
        key: key,
        icon: Icons.person_search_rounded,
        title: 'اختيار المريض',
        subtitle: 'اختر المريض الذي تريد تعبئة النموذج له',
        child: _patientSearch(),
      );
    }

    if (_step == 1) {
      final question = widget.form!.currentVersion!.questions[_questionIndex];

      return _StepShell(
        key: key,
        icon: Icons.quiz_rounded,
        title: 'السؤال ${_questionIndex + 1} من $_questionsCount',
        subtitle: 'يجب الإجابة على السؤال قبل الانتقال للتالي',
        child: _questionCard(index: _questionIndex, question: question),
      );
    }

    return _StepShell(
      key: key,
      icon: Icons.analytics_rounded,
      title: 'النتيجة والتشخيص',
      subtitle: 'راجع التشخيص وحالة المريض ثم احفظ التقييم',
      child: _resultStep(
        score: score,
        diagnosis: diagnosis,
        patientStatus: patientStatus,
      ),
    );
  }

  Widget _navigationBar() {
    final isFirst = _step == 0;
    final isLast = _step == 2;

    return Row(
      children: [
        if (!isFirst)
          Expanded(
            child: _FlowButton(
              title: 'السابق',
              icon: Icons.arrow_back_rounded,
              filled: false,
              onTap: _previous,
            ),
          ),
        if (!isFirst) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _FlowButton(
            title: isLast
                ? widget.isSubmitting
                      ? 'جاري الحفظ...'
                      : 'حفظ التقييم'
                : 'التالي',
            icon: isLast ? Icons.save_rounded : Icons.arrow_forward_rounded,
            filled: true,
            onTap: () {
              if (isLast) {
                if (widget.isSubmitting) return;

                context.read<DoctorFormsCubit>().submitManualAssessment(
                  doctorNote: noteController.text.trim(),
                );
              } else {
                _next();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _emptySelectFormState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.024, min: 18, max: 30),
        vertical: responsiveHeight(context, 0.055, min: 42, max: 70),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFBFD),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.024, min: 24, max: 34),
        ),
        border: Border.all(
          color: const Color(0xFFE7549B).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF831843).withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: responsiveSize(context, 0.070, min: 64, max: 84),
            height: responsiveSize(context, 0.070, min: 64, max: 84),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.library_books_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          customText(
            text: 'اختر نموذجًا لبدء ملء الاستبيان',
            size: responsiveSize(context, 0.016, min: 18, max: 24),
            bold: true,
            color: const Color(0xFF831843),
          ),
          const SizedBox(height: 8),
          customText(
            text: 'بعد اختيار النموذج ستبدأ خطوات التقييم',
            size: responsiveSize(context, 0.010, min: 12, max: 15),
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }
}

class _FlowHeroHeader extends StatelessWidget {
  final FormModel form;
  final int currentStep;
  final int questionIndex;
  final int questionsCount;
  final int diagnosisCount;
  final double progress;

  const _FlowHeroHeader({
    required this.form,
    required this.currentStep,
    required this.questionIndex,
    required this.questionsCount,
    required this.diagnosisCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final stepLabel = currentStep == 0
        ? 'اختيار المريض'
        : currentStep == 1
        ? 'سؤال ${questionIndex + 1} من $questionsCount'
        : 'النتيجة النهائية';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.020, min: 18, max: 26)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.024, min: 24, max: 34),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE7549B).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: responsiveSize(context, 0.052, min: 52, max: 66),
                height: responsiveSize(context, 0.052, min: 52, max: 66),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.016, min: 12, max: 18)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: form.name,
                      size: responsiveSize(context, 0.017, min: 18, max: 26),
                      bold: true,
                      color: Colors.white,
                      isCenter: false,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 6),
                    customText(
                      text: stepLabel,
                      size: responsiveSize(context, 0.010, min: 12, max: 15),
                      color: Colors.white.withValues(alpha: 0.78),
                      isCenter: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.022, min: 16, max: 24)),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: responsiveHeight(context, 0.016, min: 12, max: 18)),
          Row(
            children: [
              Expanded(
                child: _StepChip(
                  title: '$questionsCount',
                  label: 'الأسئلة',
                  icon: Icons.quiz_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StepChip(
                  title: '$diagnosisCount',
                  label: 'التشخيص',
                  icon: Icons.psychology_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final String title;
  final String label;
  final IconData icon;

  const _StepChip({
    required this.title,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.010, min: 8, max: 12),
        vertical: responsiveHeight(context, 0.010, min: 8, max: 10),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          customText(
            text: '$title $label',
            size: responsiveSize(context, 0.0085, min: 11, max: 13),
            color: Colors.white,
            bold: true,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _StepShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _StepShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.020, min: 18, max: 26)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.024, min: 24, max: 34),
        ),
        border: Border.all(
          color: const Color(0xFFE7549B).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF831843).withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: responsiveSize(context, 0.046, min: 46, max: 58),
                height: responsiveSize(context, 0.046, min: 46, max: 58),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4FA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: const Color(0xFFE7549B), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: title,
                      size: responsiveSize(context, 0.015, min: 17, max: 22),
                      bold: true,
                      color: const Color(0xFF831843),
                      isCenter: false,
                    ),
                    const SizedBox(height: 5),
                    customText(
                      text: subtitle,
                      size: responsiveSize(context, 0.010, min: 12, max: 15),
                      color: Colors.grey.shade600,
                      isCenter: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.024, min: 18, max: 26)),
          child,
        ],
      ),
    );
  }
}

class _FlowButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _FlowButton({
    required this.title,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomGlowButton(
      title: title,
      icon: icon,
      isGradient: filled,
      onPressed: onTap,
      height: responsiveHeight(context, 0.052, min: 46, max: 56),
      textSize: responsiveSize(context, 0.010, min: 13, max: 16),
    );
  }
}
