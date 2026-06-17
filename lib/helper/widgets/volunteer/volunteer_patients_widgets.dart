import 'package:bahya_website/bloc/cubit/volunteer_cubit.dart';
import 'package:bahya_website/bloc/states/volunteer_assignments_state.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'volunteer_question_widgets.dart';

class VolunteerSurveyWidget extends StatelessWidget {
  final Map<String, dynamic> assignmentDetails;
  final Future<void> Function() onSave;

  const VolunteerSurveyWidget({
    super.key,
    required this.assignmentDetails,
    required this.onSave,
  });

  List<Map<String, dynamic>> get _questions {
    final questions =
        assignmentDetails['formVersion']?['questions'] as List? ??
        assignmentDetails['questions'] as List? ??
        [];

    return questions.map((q) => Map<String, dynamic>.from(q)).toList();
  }

  String get _title {
    final template = assignmentDetails['template'];

    if (template is Map && template['name'] != null) {
      return template['name'].toString();
    }

    return 'استبيان';
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = responsiveHeight(context, 0.036, min: 26, max: 42);
    final subtitleSize = responsiveHeight(context, 0.019, min: 14, max: 20);
    final gap = responsiveHeight(context, 0.024, min: 18, max: 28);

    return BlocBuilder<VolunteerAssignmentsCubit, VolunteerAssignmentsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.018, min: 10, max: 18),
              vertical: responsiveHeight(context, 0.014, min: 10, max: 16),
            ),
            child: Column(
              children: [
                customText(
                  text: _title,
                  size: titleSize,
                  bold: true,
                  color: const Color(0xFF7A004C),
                  maxLines: 2,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.008, min: 6, max: 10),
                ),
                customText(
                  text: 'املئي الاستبيان نيابة عن المريضة',
                  size: subtitleSize,
                  color: const Color(0xFFE40070),
                  bold: true,
                ),
                SizedBox(height: gap),

                if (_questions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: customText(
                      text: 'لا توجد أسئلة في هذا الاستبيان.',
                      size: 18,
                      color: Colors.grey,
                      bold: true,
                    ),
                  )
                else
                  ..._questions.asMap().entries.map((entry) {
                    return _QuestionCard(
                      index: entry.key,
                      question: entry.value,
                    );
                  }),

                SizedBox(
                  height: responsiveHeight(context, 0.028, min: 22, max: 34),
                ),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(context, 0.02, min: 14, max: 22),
                    vertical: responsiveHeight(
                      context,
                      0.018,
                      min: 14,
                      max: 20,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBFD),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFD6EA)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE40070).withOpacity(0.07),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: getScreenWidth(context) < 700
                          ? double.infinity
                          : 360,
                      child: AnimatedSaveAnswersButton(
                        isLoading: state.isSubmitting,
                        onTap: state.isSubmitting ? null : onSave,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: responsiveHeight(context, 0.024, min: 18, max: 26),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedSaveAnswersButton extends StatefulWidget {
  final Future<void> Function()? onTap;
  final bool isLoading;

  const AnimatedSaveAnswersButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<AnimatedSaveAnswersButton> createState() =>
      _AnimatedSaveAnswersButtonState();
}

class _AnimatedSaveAnswersButtonState extends State<AnimatedSaveAnswersButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isLoading || widget.onTap == null) return;

    setState(() => isPressed = true);
    await Future.delayed(const Duration(milliseconds: 120));

    if (mounted) setState(() => isPressed = false);

    await widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final v = controller.value;

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

        return AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: isPressed ? 0.97 : 1,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: responsiveHeight(context, 0.062, min: 50, max: 62),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: beginAlignment,
                  end: endAlignment,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.22 + v * 0.16),
                    blurRadius: 18 + v * 12,
                    offset: Offset(0, 8 + v * 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -45 + (v * 90),
                    top: -30,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30 + (v * 45),
                    bottom: -35,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Center(
                    child: widget.isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: responsiveSize(
                                  context,
                                  0.018,
                                  min: 20,
                                  max: 24,
                                ),
                                height: responsiveSize(
                                  context,
                                  0.018,
                                  min: 20,
                                  max: 24,
                                ),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              customText(
                                text: 'جاري الحفظ...',
                                size: responsiveSize(
                                  context,
                                  0.011,
                                  min: 15,
                                  max: 18,
                                ),
                                color: Colors.white,
                                bold: true,
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: responsiveSize(
                                  context,
                                  0.026,
                                  min: 30,
                                  max: 36,
                                ),
                                height: responsiveSize(
                                  context,
                                  0.026,
                                  min: 30,
                                  max: 36,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: responsiveSize(
                                    context,
                                    0.017,
                                    min: 20,
                                    max: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              customText(
                                text: 'حفظ الإجابات',
                                size: responsiveSize(
                                  context,
                                  0.0115,
                                  min: 16,
                                  max: 19,
                                ),
                                color: Colors.white,
                                bold: true,
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
  }
}
