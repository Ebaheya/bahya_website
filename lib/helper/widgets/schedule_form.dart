import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_date_picker.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/custom_time_picker.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/schedule_form_widget.dart';
import 'package:flutter/material.dart';

class ScheduleFormWidget extends StatefulWidget {
  const ScheduleFormWidget({super.key});

  @override
  State<ScheduleFormWidget> createState() => _ScheduleFormWidgetState();
}

class _ScheduleFormWidgetState extends State<ScheduleFormWidget> {
  String? selectedForm;
  String repeat = "لا يتكرر";
  String? targetType;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController patientCodeController = TextEditingController();
  final TextEditingController volunteerCodeController = TextEditingController();

  final List<String> patientCodes = [];
  final List<String> volunteerCodes = [];

  final List<String> forms = ["PHQ-9", "PHQ-4", "GAD-7", "استبيان النوم"];
  final List<String> repeatItems = ["لا يتكرر", "يومي", "أسبوعي", "شهري"];
  final List<String> targetItems = ["المرضى", "المتطوعين"];

  @override
  void dispose() {
    patientCodeController.dispose();
    volunteerCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: w * 0.9,
        padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.04),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.96),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: w * 0.1,
              height: h * 0.08,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF1FA),
              ),
              child: Icon(
                Icons.edit_calendar_rounded,
                color: const Color(0xFFE40070),
                size: w * 0.03,
              ),
            ),
            SizedBox(height: h * 0.02),
            customText(
              text: "جدولة نشر النموذج",
              size: w * 0.025,
              bold: true,
              color: textColor,
            ),
            SizedBox(height: h * 0.012),
            customText(
              text: "حدد النموذج والوقت والفئة المناسبة للنشر",
              size: h * 0.021,
              color: Colors.black54,
            ),
            SizedBox(height: h * 0.045),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(w * 0.025),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCFE),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF5D7EA)),
              ),
              child: Column(
                children: [
                  scheduleLabel(context: context, title: "اختر نموذجًا للنشر"),
                  const SizedBox(height: 20),
                  scheduleDropdown(
                    context: context,
                    value: selectedForm,
                    hint: "اختر نموذج من القائمة",
                    items: forms,
                    icon: Icons.description_outlined,
                    onChanged: (v) {
                      setState(() => selectedForm = v);
                    },
                  ),
                  SizedBox(height: h * 0.035),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            scheduleLabel(context: context, title: "وقت النشر"),
                            const SizedBox(height: 20),
                            schedulePickerField(
                              context: context,
                              text: selectedTime == null
                                  ? "اختر الوقت"
                                  : selectedTime!.format(context),
                              icon: Icons.access_time_rounded,
                              onTap: pickCustomTime,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 70),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            scheduleLabel(
                              context: context,
                              title: "تاريخ النشر",
                            ),
                            const SizedBox(height: 20),
                            schedulePickerField(
                              context: context,
                              text: selectedDate == null
                                  ? "اختر التاريخ"
                                  : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                              icon: Icons.calendar_month_rounded,
                              onTap: pickCustomDate,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  scheduleLabel(context: context, title: "حالة التكرار"),
                  const SizedBox(height: 20),
                  scheduleDropdown(
                    context: context,
                    value: repeat,
                    hint: "اختر حالة التكرار",
                    items: repeatItems,
                    icon: Icons.flag_outlined,
                    onChanged: (v) {
                      setState(() => repeat = v!);
                    },
                  ),
                  const SizedBox(height: 30),
                  scheduleLabel(context: context, title: "الفئة المستهدفة"),
                  const SizedBox(height: 20),
                  scheduleDropdown(
                    context: context,
                    value: targetType,
                    hint: "اختر المرضى أو المتطوعين",
                    items: targetItems,
                    icon: Icons.group_outlined,
                    onChanged: (v) {
                      setState(() {
                        targetType = v;
                        patientCodeController.clear();
                        volunteerCodeController.clear();
                        patientCodes.clear();
                        volunteerCodes.clear();
                      });
                    },
                  ),
                  if (targetType != null) ...[
                    const SizedBox(height: 30),
                    if (targetType == "المتطوعين") ...[
                      scheduleCodeInputSection(
                        context: context,
                        title: "إضافة رقم المتطوع",
                        hint: "اكتب رقم المتطوع",
                        controller: volunteerCodeController,
                        codes: volunteerCodes,
                        onAdd: addVolunteerCode,
                        onRemove: (code) {
                          setState(() {
                            volunteerCodes.remove(code);
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                    scheduleCodeInputSection(
                      context: context,
                      title: "إضافة الرقم الطبي للمريض",
                      hint: "اكتب الرقم الطبي للمريض",
                      controller: patientCodeController,
                      codes: patientCodes,
                      onAdd: addPatientCode,
                      onRemove: (code) {
                        setState(() {
                          patientCodes.remove(code);
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 35),
                  CustomGlowButton(
                    title: "جدولة النشر",
                    onPressed: schedulePublish,
                    icon: Icons.schedule_send_rounded,
                    isGradient: true,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addPatientCode() {
    final code = patientCodeController.text.trim();

    if (code.isEmpty) {
      showError("اكتب الرقم الطبي للمريض أولاً.");
      return;
    }

    if (patientCodes.contains(code)) {
      showError("هذا الرقم الطبي تم إضافته بالفعل في قائمة المرضى.");
      return;
    }

    if (volunteerCodes.contains(code)) {
      showError(
        "هذا الرقم موجود بالفعل في قائمة المتطوعين، لا يمكن إضافته كمريض.",
      );
      return;
    }

    setState(() {
      patientCodes.add(code);
      patientCodeController.clear();
    });
  }

  void addVolunteerCode() {
    final code = volunteerCodeController.text.trim();

    if (code.isEmpty) {
      showError("اكتب رقم المتطوع أولاً.");
      return;
    }

    if (volunteerCodes.contains(code)) {
      showError("هذا رقم المتطوع تم إضافته بالفعل في قائمة المتطوعين.");
      return;
    }

    if (patientCodes.contains(code)) {
      showError(
        "هذا الرقم موجود بالفعل في قائمة المرضى، لا يمكن إضافته كمتطوع.",
      );
      return;
    }

    setState(() {
      volunteerCodes.add(code);
      volunteerCodeController.clear();
    });
  }

  void schedulePublish() {
    if (selectedForm == null) {
      showError("اختر نموذجًا للنشر.");
      return;
    }

    if (selectedDate == null) {
      showError("اختر تاريخ النشر.");
      return;
    }

    if (selectedTime == null) {
      showError("اختر وقت النشر.");
      return;
    }

    if (repeat.trim().isEmpty) {
      showError("اختر حالة التكرار.");
      return;
    }

    if (targetType == null) {
      showError("اختر الفئة المستهدفة: المرضى أو المتطوعين.");
      return;
    }

    if (targetType == "المرضى" && patientCodes.isEmpty) {
      showError("أضف رقم طبي لمريض واحد على الأقل.");
      return;
    }

    if (targetType == "المتطوعين") {
      if (volunteerCodes.isEmpty) {
        showError("أضف رقم متطوع واحد على الأقل.");
        return;
      }

      if (patientCodes.isEmpty) {
        showError("أضف رقم طبي لمريض واحد على الأقل.");
        return;
      }
    }

    debugPrint("Selected form: $selectedForm");
    debugPrint("Selected date: $selectedDate");
    debugPrint("Selected time: ${selectedTime!.format(context)}");
    debugPrint("Repeat: $repeat");
    debugPrint("Target type: $targetType");
    debugPrint("Patient codes: $patientCodes");
    debugPrint("Volunteer codes: $volunteerCodes");

    customDialog(
      context: context,
      title: "جدولة النشر",
      message: "تم جدولة نشر النموذج بنجاح.",
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

  Future pickCustomTime() async {
    final t = await customTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (t != null) {
      setState(() => selectedTime = t);
    }
  }

  Future pickCustomDate() async {
    final d = await customDatePicker(
      context: context,
      initialDate: selectedDate,
    );

    if (d != null) {
      setState(() => selectedDate = d);
    }
  }
}
