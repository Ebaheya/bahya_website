part of '../../../screens/patient_clinical_details.dart';

class _PendingReviewTab extends StatelessWidget {
  const _PendingReviewTab({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      PatientAssessmentReviewCubit,
      PatientAssessmentReviewState
    >(
      listener: (context, state) {
        if (state.error != null) {
          customDialog(
            context: context,
            title: 'خطأ',
            message: state.error!,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return _PendingReviewShell(
            child: SizedBox(
              height: responsiveHeight(context, 0.32, min: 240, max: 380),
              child: Center(child: customLoading()),
            ),
          );
        }

        if (state.submissions.isEmpty) {
          return const _PendingReviewEmpty();
        }

        return _PendingReviewShell(
          child: Column(
            crossAxisAlignment: _activeCrossAxisStart,
            children: [
              Row(
                textDirection: _activeTextDirection,
                children: [
                  Container(
                    width: responsiveSize(context, 0.044, min: 44, max: 58),
                    height: responsiveSize(context, 0.044, min: 44, max: 58),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.pending_actions_rounded,
                      color: Color(0xFFE83E8C),
                    ),
                  ),
                  SizedBox(
                    width: responsiveSize(context, 0.012, min: 10, max: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: _activeCrossAxisStart,
                      children: [
                        customText(
                          text: 'التقييمات المعلقة للمراجعة',
                          size: responsiveSize(
                            context,
                            0.014,
                            min: 18,
                            max: 24,
                          ),
                          color: const Color(0xFF271648),
                          bold: true,
                          isCenter: false,
                        ),
                        const SizedBox(height: 5),
                        customText(
                          text: 'راجع الأسئلة والإجابات ثم اعتمدها كتقييم رسمي',
                          size: responsiveSize(
                            context,
                            0.0085,
                            min: 12,
                            max: 15,
                          ),
                          color: const Color(0xFF7A7890),
                          bold: true,
                          isCenter: false,
                        ),
                      ],
                    ),
                  ),
                  _PendingCountBadge(count: state.submissions.length),
                ],
              ),
              SizedBox(
                height: responsiveHeight(context, 0.024, min: 18, max: 26),
              ),
              ...state.submissions.map(
                (submission) => _PendingSubmissionCard(
                  patientId: patientId,
                  submission: submission,
                  isSaving: state.isSaving,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PendingReviewShell extends StatelessWidget {
  const _PendingReviewShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.02, min: 16, max: 30)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF7D6E6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE83E8C).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PendingCountBadge extends StatelessWidget {
  const _PendingCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.012, min: 10, max: 14),
        vertical: responsiveHeight(context, 0.007, min: 6, max: 8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5F1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: customText(
        text: '$count معلق',
        size: responsiveSize(context, 0.008, min: 12, max: 14),
        color: const Color(0xFFE83E8C),
        bold: true,
      ),
    );
  }
}

class _PendingReviewEmpty extends StatelessWidget {
  const _PendingReviewEmpty();

  @override
  Widget build(BuildContext context) {
    return _PendingReviewShell(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: responsiveHeight(context, 0.04, min: 28, max: 48),
        ),
        child: Column(
          children: [
            Container(
              width: responsiveSize(context, 0.075, min: 64, max: 90),
              height: responsiveSize(context, 0.075, min: 64, max: 90),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE5F1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fact_check_outlined,
                color: const Color(0xFFE83E8C),
                size: responsiveSize(context, 0.04, min: 34, max: 50),
              ),
            ),
            SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 22)),
            customText(
              text: 'لا توجد تقييمات معلقة للمراجعة',
              size: responsiveSize(context, 0.013, min: 17, max: 23),
              color: const Color(0xFF271648),
              bold: true,
            ),
            const SizedBox(height: 8),
            customText(
              text:
                  'أي استبيان يتم إرساله من المريض أو المتطوع سيظهر هنا قبل اعتماده كتقييم رسمي.',
              size: responsiveSize(context, 0.009, min: 13, max: 16),
              color: const Color(0xFF7A7890),
              bold: true,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
