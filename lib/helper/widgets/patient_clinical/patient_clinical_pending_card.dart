part of '../../../screens/patient_clinical_details.dart';

class _PendingSubmissionCard extends StatefulWidget {
  const _PendingSubmissionCard({
    required this.patientId,
    required this.submission,
    required this.isSaving,
  });

  final String patientId;
  final Map<String, dynamic> submission;
  final bool isSaving;

  @override
  State<_PendingSubmissionCard> createState() => _PendingSubmissionCardState();
}

class _PendingSubmissionCardState extends State<_PendingSubmissionCard> {
  String status = 'MODERATE';
  bool isOpen = true;
  final TextEditingController noteController = TextEditingController();

  final Map<String, String> statusLabels = const {
    'NORMAL': 'طبيعي',
    'MILD': 'بسيط',
    'MODERATE': 'متوسط',
    'SEVERE': 'شديد',
    'CRITICAL': 'حرج',
  };
  String get diagnosis {
    final value =
        widget.submission['diagnosis'] ??
        widget.submission['statusLabel'] ??
        widget.submission['interpretation'] ??
        widget.submission['severity'];

    if (value is Map) {
      return value['label']?.toString() ??
          value['name']?.toString() ??
          value['status']?.toString() ??
          '-';
    }

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }

    return statusLabels[status] ?? status;
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  String get formName {
    final assignment = widget.submission['assignment'];
    final template = assignment is Map ? assignment['template'] : null;

    if (template is Map && template['name'] != null) {
      return template['name'].toString();
    }

    final templateMap = widget.submission['template'];
    if (templateMap is Map && templateMap['name'] != null) {
      return templateMap['name'].toString();
    }

    return 'استبيان';
  }

  String get fillerName {
    final submittedBy = widget.submission['submittedBy'];

    if (submittedBy is Map) {
      final name =
          submittedBy['fullName'] ??
          submittedBy['name'] ??
          submittedBy['email'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }

    return 'غير معروف';
  }

  String get totalScore {
    final value =
        widget.submission['totalScore'] ??
        widget.submission['score'] ??
        widget.submission['total'];
    return value == null ? '-' : value.toString();
  }

  String get submitDate {
    final value =
        widget.submission['submittedAt'] ??
        widget.submission['createdAt'] ??
        widget.submission['updatedAt'];
    return value == null ? '-' : value.toString().split('T').first;
  }

  String get doctorNote {
    final value =
        widget.submission['doctorNote'] ??
        widget.submission['doctor_note'] ??
        widget.submission['note'];
    return value == null ? '' : value.toString().trim();
  }

  List<_ReviewAnswerItem> get answers {
    return _ReviewAnswerItem.fromSubmission(widget.submission);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 780;

    return Container(
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.018, min: 14, max: 22),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => isOpen = !isOpen),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Padding(
              padding: EdgeInsets.all(
                responsiveSize(context, 0.016, min: 14, max: 20),
              ),
              child: isMobile ? _mobileHeader() : _desktopHeader(),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: isOpen
                  ? _detailsContent(isMobile)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopHeader() {
    return Row(
      textDirection: _activeTextDirection,
      children: [
        _submissionIcon(),
        SizedBox(width: responsiveSize(context, 0.014, min: 10, max: 16)),
        Expanded(child: _titleBlock()),
        _InfoBadge(title: 'Score', value: totalScore),
        const SizedBox(width: 10),
        _InfoBadge(title: 'التشخيص', value: diagnosis),
        const SizedBox(width: 10),
        _InfoBadge(title: 'Date', value: submitDate),
        const SizedBox(width: 10),
        Icon(
          isOpen
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: const Color(0xFFE83E8C),
        ),
      ],
    );
  }

  Widget _mobileHeader() {
    return Column(
      crossAxisAlignment: _activeCrossAxisStart,
      children: [
        Row(
          textDirection: _activeTextDirection,
          children: [
            _submissionIcon(),
            SizedBox(width: responsiveSize(context, 0.014, min: 10, max: 16)),
            Expanded(child: _titleBlock()),
            Icon(
              isOpen
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFE83E8C),
            ),
          ],
        ),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
        Wrap(
          textDirection: _activeTextDirection,
          spacing: 10,
          runSpacing: 10,
          children: [
            _InfoBadge(title: 'Score', value: totalScore),
            _InfoBadge(title: 'التشخيص', value: diagnosis),
            _InfoBadge(title: 'Date', value: submitDate),
          ],
        ),
      ],
    );
  }

  Widget _submissionIcon() {
    return Container(
      width: responsiveSize(context, 0.048, min: 48, max: 60),
      height: responsiveSize(context, 0.048, min: 48, max: 60),
      decoration: const BoxDecoration(
        color: Color(0xFFFFE5F1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.assignment_turned_in_outlined,
        color: Color(0xFFE83E8C),
      ),
    );
  }

  Widget _titleBlock() {
    return Column(
      crossAxisAlignment: _activeCrossAxisStart,
      children: [
        customText(
          text: formName,
          size: responsiveSize(context, 0.012, min: 16, max: 21),
          color: const Color(0xFF271648),
          bold: true,
          isCenter: false,
          maxLines: 1,
        ),
        const SizedBox(height: 5),
        customText(
          text: 'تم الإرسال بواسطة: $fillerName',
          size: responsiveSize(context, 0.0085, min: 12, max: 15),
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _detailsContent(bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsiveSize(context, 0.016, min: 14, max: 20),
        0,
        responsiveSize(context, 0.016, min: 14, max: 20),
        responsiveSize(context, 0.016, min: 14, max: 20),
      ),
      child: Column(
        crossAxisAlignment: _activeCrossAxisStart,
        children: [
          const Divider(color: Color(0xFFF7D6E6)),
          SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
          customText(
            text: 'إجابات الاستبيان',
            size: responsiveSize(context, 0.011, min: 16, max: 20),
            color: const Color(0xFFE83E8C),
            bold: true,
            isCenter: false,
          ),
          SizedBox(height: responsiveHeight(context, 0.016, min: 12, max: 18)),
          if (answers.isEmpty)
            _emptyAnswers()
          else if (isMobile)
            Column(
              children: List.generate(
                answers.length,
                (index) =>
                    _ReviewAnswerMobileCard(index: index, item: answers[index]),
              ),
            )
          else
            _ReviewAnswersTable(answers: answers),
          SizedBox(height: responsiveHeight(context, 0.022, min: 16, max: 24)),
          if (doctorNote.isNotEmpty) ...[
            _DoctorNoteCard(note: doctorNote),
            SizedBox(
              height: responsiveHeight(context, 0.022, min: 16, max: 24),
            ),
          ],
          _doctorReviewForm(isMobile),
        ],
      ),
    );
  }

  Widget _emptyAnswers() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.018, min: 16, max: 22)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: customText(
        text: 'لا توجد إجابات ظاهرة في هذا الـ submission.',
        size: responsiveSize(context, 0.009, min: 13, max: 16),
        color: Colors.grey,
        bold: true,
      ),
    );
  }

  Widget _doctorReviewForm(bool isMobile) {
    final statusItems = statusLabels.keys.toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.016, min: 14, max: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        crossAxisAlignment: _activeCrossAxisStart,
        children: [
          customText(
            text: 'مراجعة الدكتور',
            size: responsiveSize(context, 0.011, min: 15, max: 19),
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
          ),
          SizedBox(height: responsiveHeight(context, 0.018, min: 12, max: 18)),
          isMobile
              ? Column(
                  children: [
                    _statusDropDown(statusItems),
                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.014,
                        min: 10,
                        max: 14,
                      ),
                    ),
                    _noteField(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _noteField()),
                    SizedBox(
                      width: responsiveSize(context, 0.014, min: 10, max: 18),
                    ),
                    SizedBox(width: 240, child: _statusDropDown(statusItems)),
                  ],
                ),
          SizedBox(height: responsiveHeight(context, 0.018, min: 14, max: 20)),
          Align(
            alignment: _activeCenterEnd,
            child: SizedBox(
              width: isMobile ? double.infinity : 280,
              child: ElevatedButton.icon(
                onPressed: widget.isSaving ? null : _approve,
                icon: const Icon(Icons.verified_rounded),
                label: Text(
                  widget.isSaving ? 'جاري الاعتماد...' : 'اعتماد كتقييم رسمي',
                  style: const TextStyle(
                    fontFamily: 'ArabicCustomFont',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE83E8C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: responsiveHeight(
                      context,
                      0.016,
                      min: 13,
                      max: 18,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDropDown(List<String> statusItems) {
    return customDropdown(
      context: context,
      value: status,
      hint: 'اختر التشخيص / الشدة',
      items: statusItems,
      icon: Icons.health_and_safety_outlined,
      onChanged: (value) {
        if (value != null) {
          setState(() => status = value);
        }
      },
    );
  }

  Widget _noteField() {
    return TextField(
      controller: noteController,
      maxLines: 3,
      textDirection: _activeTextDirection,
      decoration: InputDecoration(
        hintText: 'ملاحظات الدكتور...',
        hintStyle: const TextStyle(fontFamily: 'ArabicCustomFont'),
        filled: true,
        fillColor: const Color(0xFFFFFAFD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF7D6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE83E8C)),
        ),
      ),
      style: const TextStyle(fontFamily: 'ArabicCustomFont'),
    );
  }

  Future<void> _approve() async {
    final success = await context
        .read<PatientAssessmentReviewCubit>()
        .approveSubmission(
          patientId: widget.patientId,
          submission: widget.submission,
          status: status,
          doctorNote: noteController.text,
        );

    if (!mounted) return;

    if (success) {
      customDialog(
        context: context,
        title: 'تم الاعتماد',
        message: 'تم تحويل الاستبيان إلى تقييم رسمي.',
        isSuccess: true,
      );
    }
  }
}
