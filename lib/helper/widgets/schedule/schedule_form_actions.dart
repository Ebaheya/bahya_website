part of 'schedule_form.dart';

extension _ScheduleFormActions on _ScheduleFormWidgetState {
  Widget _selectionBox({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.018, min: 14, max: 22)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7FC),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 18, max: 24),
        ),
        border: Border.all(color: const Color(0xFFF5D7EA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE40070).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: responsiveSize(context, 0.04, min: 40, max: 50),
                height: responsiveSize(context, 0.04, min: 40, max: 50),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAF5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFE40070),
                  size: responsiveSize(context, 0.022, min: 20, max: 26),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.012, min: 8, max: 12)),
              Expanded(
                child: customText(
                  text: title,
                  size: responsiveSize(context, 0.012, min: 16, max: 21),
                  color: const Color(0xFF7A004C),
                  bold: true,
                  isCenter: false,
                ),
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 20)),
          child,
        ],
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.018, min: 12, max: 18),
        vertical: responsiveHeight(context, 0.014, min: 10, max: 14),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFB8D8)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFE40070)),
          SizedBox(width: responsiveSize(context, 0.012, min: 8, max: 12)),
          Expanded(
            child: customText(
              text: text,
              size: responsiveSize(context, 0.01, min: 13, max: 16),
              color: const Color(0xFF7A004C),
              bold: true,
              isCenter: false,
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _ensureFormReadyForPublish(FormModel form) async {
    final status = form.currentVersion?.status.trim().toUpperCase();

    if (status == "PUBLISHED") return true;

    try {
      await web.publishFormVersion(formId: form.id);
      return true;
    } catch (e) {
      final text = e.toString();

      if (text.contains("FORM_VERSION_NOT_DRAFT")) {
        return true;
      }

      debugPrint("publish-version before volunteer publish failed: $e");
      return false;
    }
  }

  Future<void> publishForm() async {
    if (selectedForm == null) {
      logic.showError("اختر نموذجًا للنشر.");
      return;
    }

    if (selectedForm!.isActive != true) {
      logic.showError("هذا النموذج غير مفعّل. فعّله أولاً قبل إعادة النشر.");
      return;
    }

    if (targetType == null) {
      logic.showError("اختر الفئة المستهدفة.");
      return;
    }

    if (targetType == "المرضى") {
      await logic.publishForm(
        selectedForm: selectedForm,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        targetType: targetType,
        patientPublishType: patientPublishType,
        selectedSinglePatient: selectedSinglePatient,
        selectedPatients: selectedPatients,
        selectedVolunteers: selectedVolunteers,
        onSuccess: () {
          logic.showPublishSuccess();
          context.read<PublishScheduleCubit>().loadForms();
        },
      );

      return;
    }

    if (targetType == "المتطوعين") {
      if (selectedVolunteers.isEmpty) {
        logic.showError("يجب اختيار متطوع واحد على الأقل.");
        return;
      }

      if (selectedPatients.isEmpty) {
        logic.showError("يجب اختيار مريض واحد على الأقل.");
        return;
      }

      final ready = await _ensureFormReadyForPublish(selectedForm!);

      if (!mounted) return;

      if (!ready) {
        logic.showError(
          "النموذج غير جاهز للنشر. تأكد أنه يحتوي أسئلة و ranges صحيحة.",
        );
        return;
      }

      await logic.publishForm(
        selectedForm: selectedForm,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        targetType: targetType,
        patientPublishType: patientPublishType,
        selectedSinglePatient: selectedSinglePatient,
        selectedPatients: selectedPatients,
        selectedVolunteers: selectedVolunteers,
        onSuccess: () {
          logic.showPublishSuccess();
          context.read<PublishScheduleCubit>().loadForms();
        },
      );

      return;
    }

    logic.showError("نوع النشر غير صحيح.");
  }

  Future pickCustomTime() async {
    final t = await customTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (!mounted) return;

    if (t != null) {
      _updateState(() => selectedTime = t);
    }
  }

  Future pickCustomDate() async {
    final d = await customDatePicker(
      context: context,
      initialDate: selectedDate,
    );

    if (!mounted) return;

    if (d != null) {
      _updateState(() => selectedDate = d);
    }
  }
}
