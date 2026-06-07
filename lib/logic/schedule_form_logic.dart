import 'package:bahya_website/bloc/cubit/publish_schedule_cubit.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleFormLogic {
  ScheduleFormLogic({required this.context, required this.web});

  final BuildContext context;
  final WebService web;

  String? buildPublishAt({
    required DateTime? selectedDate,
    required TimeOfDay? selectedTime,
  }) {
    if (selectedDate == null && selectedTime == null) return null;

    if (selectedDate == null || selectedTime == null) {
      showError(
        "لازم تختار التاريخ والوقت معًا أو تسيب الاتنين فاضيين للنشر الفوري.",
      );
      return "INVALID_DATE_TIME";
    }

    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    return dateTime.toUtc().toIso8601String();
  }

  Future<bool> publishSomePatients({
    required FormModel form,
    required List<OptionUserModel> patients,
    required String? publishAt,
  }) async {
    try {
      final body = {
        "target": "SELECTED_PATIENTS",
        "patientIds": patients.map((e) => e.id).toList(),
        "publishAt": publishAt,
      };

      debugPrint("Publish body: $body");

      return await context.read<PublishScheduleCubit>().publishForm(
        form: form,
        body: body,
      );
    } catch (e) {
      debugPrint("Error in publishSomePatients: $e");
      return false;
    }
  }

  Future<bool> publishAllPatients({
    required FormModel form,
    required String? publishAt,
  }) async {
    try {
      final body = {"target": "ALL_PATIENTS", "publishAt": publishAt};

      debugPrint("Publish body: $body");

      return await context.read<PublishScheduleCubit>().publishForm(
        form: form,
        body: body,
      );
    } catch (e) {
      debugPrint("Error in publishAllPatients: $e");
      return false;
    }
  }

  Future<bool> publishVolunteerForPatient({
    required FormModel form,
    required OptionUserModel patient,
    required OptionUserModel volunteer,
    required String? publishAt,
  }) async {
    try {
      final body = {
        "target": "VOLUNTEER_FOR_PATIENT",
        "patientId": patient.id,
        "volunteerId": volunteer.id,
        "publishAt": publishAt,
      };

      debugPrint("Publish body: $body");

      return await context.read<PublishScheduleCubit>().publishForm(
        form: form,
        body: body,
      );
    } catch (e) {
      debugPrint("Error in publishVolunteerForPatient: $e");
      return false;
    }
  }

  Future<void> deactivateForm(FormModel form) async {
    await web.changeFormStatus(formId: form.id, isActive: false);
  }

  Future<void> activateForm(FormModel form) async {
    await web.changeFormStatus(formId: form.id, isActive: true);
  }

  Future<void> publishForm({
    required FormModel? selectedForm,
    required DateTime? selectedDate,
    required TimeOfDay? selectedTime,
    required String? targetType,
    required String? patientPublishType,
    required OptionUserModel? selectedSinglePatient,
    required List<OptionUserModel> selectedPatients,
    required List<OptionUserModel> selectedVolunteers,
    required VoidCallback onSuccess,
  }) async {
    if (selectedForm == null) {
      showError("اختر نموذجًا للنشر.");
      return;
    }

    if (selectedForm.isActive != true) {
      showError("هذا النموذج غير مفعّل. فعّله أولاً قبل إعادة النشر.");
      return;
    }

    if (targetType == null) {
      showError("اختر الفئة المستهدفة.");
      return;
    }

    final publishAt = buildPublishAt(
      selectedDate: selectedDate,
      selectedTime: selectedTime,
    );
    if (publishAt == "INVALID_DATE_TIME") return;
    if (targetType == "المرضى") {
      await _publishForPatients(
        selectedForm: selectedForm,
        patientPublishType: patientPublishType,
        selectedPatients: selectedPatients,
        publishAt: publishAt,
        onSuccess: onSuccess,
      );
      return;
    }

    if (targetType == "المتطوعين") {
      await _publishForVolunteers(
        selectedForm: selectedForm,
        selectedPatients: selectedPatients,
        selectedVolunteers: selectedVolunteers,
        publishAt: publishAt,
        onSuccess: onSuccess,
      );
      return;
    }
  }

  Future<void> _publishForPatients({
    required FormModel selectedForm,
    required String? patientPublishType,
    required List<OptionUserModel> selectedPatients,
    required String? publishAt,
    required VoidCallback onSuccess,
  }) async {
    if (patientPublishType == null) {
      showError("اختر نوع النشر للمرضى.");
      return;
    }

    if (patientPublishType == "مجموعه من المرضى") {
      if (selectedPatients.isEmpty) {
        showError("اختر مريضًا واحدًا على الأقل.");
        return;
      }

      final success = await publishSomePatients(
        form: selectedForm,
        patients: selectedPatients,
        publishAt: publishAt,
      );

      if (success) onSuccess();
      return;
    }

    final success = await publishAllPatients(
      form: selectedForm,
      publishAt: publishAt,
    );

    if (success) onSuccess();
  }

  Future<void> _publishForVolunteers({
    required FormModel selectedForm,
    required List<OptionUserModel> selectedPatients,
    required List<OptionUserModel> selectedVolunteers,
    required String? publishAt,
    required VoidCallback onSuccess,
  }) async {
    if (selectedPatients.isEmpty) {
      showError("اختر مريض واحد على الأقل.");
      return;
    }

    if (selectedVolunteers.isEmpty) {
      showError("اختر متطوع واحد على الأقل.");
      return;
    }

    if (selectedPatients.length != selectedVolunteers.length) {
      showError("عدد المرضى يجب أن يساوي عدد المتطوعين.");
      return;
    }

    bool allSuccess = true;

    for (int i = 0; i < selectedPatients.length; i++) {
      final success = await publishVolunteerForPatient(
        form: selectedForm,
        patient: selectedPatients[i],
        volunteer: selectedVolunteers[i],
        publishAt: publishAt,
      );

      if (!success) allSuccess = false;
    }

    if (allSuccess) {
      onSuccess();
    } else {
      showError("حدث خطأ أثناء نشر بعض النماذج.");
    }
  }

  Future<void> cancelPublish({
    required FormModel form,
    required VoidCallback onSuccess,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: customText(
            text: "إلغاء النشر",
            size: 18,
            color: Colors.black87,
            isCenter: false,
          ),
          content: customText(
            text:
                "سيتم تعطيل نموذج (${form.name}) ولن يكون متاحًا للنشر. هل تريد المتابعة؟",
            size: 16,
            color: Colors.black87,
            isCenter: false,
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: customText(text: "إلغاء", size: 14, color: Colors.pink),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: customText(text: "تأكيد", size: 14, color: Colors.red),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await deactivateForm(form);

      customDialog(
        context: context,
        title: "تم إلغاء النشر",
        message: "تم تعطيل النموذج بنجاح.",
        isSuccess: true,
      );

      onSuccess();
    } catch (e) {
      showError("حدث خطأ أثناء تعطيل النموذج.");
    }
  }

  Future<void> activateInactiveForm({
    required FormModel form,
    required VoidCallback onSuccess,
  }) async {
    try {
      await activateForm(form);

      customDialog(
        context: context,
        title: "تم التفعيل",
        message: "تم تفعيل النموذج ويمكن إعادة نشره الآن.",
        isSuccess: true,
      );

      onSuccess();
    } catch (e) {
      showError("حدث خطأ أثناء تفعيل النموذج.");
    }
  }

  void showRepublishMessage() {
    customDialog(
      context: context,
      title: "إعادة النشر",
      message: "تم اختيار النموذج. اختر الفئة المستهدفة ثم اضغط نشر النموذج.",
      isInfo: true,
    );
  }

  void showPublishSuccess() {
    customDialog(
      context: context,
      title: "تم النشر",
      message: "تم نشر النموذج بنجاح.",
      isSuccess: true,
    );
  }

  void showError(String message) {
    customDialog(
      context: context,
      title: "تنبيه",
      message: message,
      isError: true,
    );
  }
}
