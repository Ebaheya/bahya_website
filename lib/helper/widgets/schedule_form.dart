import 'package:bahya_website/bloc/cubit/publish_schedule_cubit.dart';
import 'package:bahya_website/bloc/states/publish_schedule_state.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_date_picker.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/custom_time_picker.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/schedule_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleFormWidget extends StatefulWidget {
  const ScheduleFormWidget({super.key, required this.forms});

  final List<FormModel> forms;

  @override
  State<ScheduleFormWidget> createState() => _ScheduleFormWidgetState();
}

class _ScheduleFormWidgetState extends State<ScheduleFormWidget> {
  FormModel? selectedForm;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String? targetType;
  String? patientPublishType;

  OptionUserModel? selectedSinglePatient;

  final List<OptionUserModel> selectedPatients = [];
  final List<OptionUserModel> selectedVolunteers = [];

  final TextEditingController patientSearchController = TextEditingController();
  final TextEditingController volunteerSearchController =
      TextEditingController();

  final List<String> targetItems = ["المرضى", "المتطوعين"];
  final List<String> patientPublishItems = ["مريض واحد", "كل المرضى"];

  @override
  void dispose() {
    patientSearchController.dispose();
    volunteerSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return BlocBuilder<PublishScheduleCubit, PublishScheduleState>(
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: w * 0.9,
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.03,
              vertical: h * 0.04,
            ),
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
                Icon(
                  Icons.publish_rounded,
                  color: const Color(0xFFE40070),
                  size: w * 0.04,
                ),
                SizedBox(height: h * 0.02),
                customText(
                  text: "نشر النموذج",
                  size: w * 0.025,
                  bold: true,
                  color: textColor,
                ),
                SizedBox(height: h * 0.04),
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
                      scheduleLabel(
                        context: context,
                        title: "اختر نموذجًا للنشر",
                      ),
                      const SizedBox(height: 20),
                      scheduleDropdown(
                        context: context,
                        value: selectedForm?.name,
                        hint: "اختر نموذج من القائمة",
                        items: widget.forms
                            .map((e) => e.name ?? "")
                            .where((name) => name.isNotEmpty)
                            .toList(),
                        icon: Icons.description_outlined,
                        onChanged: (v) {
                          setState(() {
                            selectedForm = widget.forms.firstWhere(
                              (form) => form.name == v,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                scheduleLabel(
                                  context: context,
                                  title: "وقت النشر",
                                ),
                                const SizedBox(height: 20),
                                schedulePickerField(
                                  context: context,
                                  text: selectedTime == null
                                      ? "اختياري"
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
                                      ? "اختياري"
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
                            patientPublishType = null;
                            selectedSinglePatient = null;
                            selectedPatients.clear();
                            selectedVolunteers.clear();
                            patientSearchController.clear();
                            volunteerSearchController.clear();
                          });

                          context.read<PublishScheduleCubit>().searchPatients(
                            "",
                          );
                          context.read<PublishScheduleCubit>().searchVolunteers(
                            "",
                          );
                        },
                      ),
                      if (targetType == "المرضى") ...[
                        const SizedBox(height: 30),
                        scheduleLabel(context: context, title: "نوع النشر"),
                        const SizedBox(height: 20),
                        scheduleDropdown(
                          context: context,
                          value: patientPublishType,
                          hint: "اختر نوع النشر",
                          items: patientPublishItems,
                          icon: Icons.person_outline,
                          onChanged: (v) {
                            setState(() {
                              patientPublishType = v;
                              selectedSinglePatient = null;
                              patientSearchController.clear();
                            });

                            context.read<PublishScheduleCubit>().searchPatients(
                              "",
                            );
                          },
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1,
                                child: child,
                              ),
                            );
                          },
                          child: patientPublishType == "مريض واحد"
                              ? Padding(
                                  key: const ValueKey("single_patient"),
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Column(
                                    children: [
                                      searchSelectUserField(
                                        title: "اختيار المريض",
                                        hint: "ابحث باسم المريض",
                                        controller: patientSearchController,
                                        options: state.patientOptions,
                                        isLoading: state.isSearchingPatients,
                                        onSearch: (v) {
                                          context
                                              .read<PublishScheduleCubit>()
                                              .searchPatients(v);
                                        },
                                        onSelect: (patient) {
                                          setState(() {
                                            selectedSinglePatient = patient;
                                            patientSearchController.clear();
                                          });

                                          context
                                              .read<PublishScheduleCubit>()
                                              .searchPatients("");
                                        },
                                      ),
                                      selectedUsersChips(
                                        users: selectedSinglePatient == null
                                            ? []
                                            : [selectedSinglePatient!],
                                        onRemove: (_) {
                                          setState(() {
                                            selectedSinglePatient = null;
                                            patientSearchController.clear();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                      if (targetType == "المتطوعين") ...[
                        const SizedBox(height: 30),
                        searchSelectUserField(
                          title: "اختيار المتطوع",
                          hint: "ابحث باسم المتطوع",
                          controller: volunteerSearchController,
                          options: state.volunteerOptions,
                          isLoading: state.isSearchingVolunteers,
                          onSearch: (v) {
                            context
                                .read<PublishScheduleCubit>()
                                .searchVolunteers(v);
                          },
                          onSelect: (volunteer) {
                            if (selectedVolunteers.any(
                              (e) => e.id == volunteer.id,
                            )) {
                              showError("هذا المتطوع تم اختياره بالفعل.");
                              return;
                            }

                            setState(() {
                              selectedVolunteers.add(volunteer);
                              volunteerSearchController.clear();
                            });

                            context
                                .read<PublishScheduleCubit>()
                                .searchVolunteers("");
                          },
                        ),
                        selectedUsersChips(
                          users: selectedVolunteers,
                          onRemove: (user) {
                            setState(() {
                              selectedVolunteers.remove(user);
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        searchSelectUserField(
                          title: "اختيار المريض",
                          hint: "ابحث باسم المريض",
                          controller: patientSearchController,
                          options: state.patientOptions,
                          isLoading: state.isSearchingPatients,
                          onSearch: (v) {
                            context.read<PublishScheduleCubit>().searchPatients(
                              v,
                            );
                          },
                          onSelect: (patient) {
                            if (selectedPatients.any(
                              (e) => e.id == patient.id,
                            )) {
                              showError("هذا المريض تم اختياره بالفعل.");
                              return;
                            }

                            setState(() {
                              selectedPatients.add(patient);
                              patientSearchController.clear();
                            });

                            context.read<PublishScheduleCubit>().searchPatients(
                              "",
                            );
                          },
                        ),
                        selectedUsersChips(
                          users: selectedPatients,
                          onRemove: (user) {
                            setState(() {
                              selectedPatients.remove(user);
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 35),
                      CustomGlowButton(
                        title: state.isPublishing
                            ? "جاري النشر..."
                            : "نشر النموذج",
                        onPressed: () {
                          if (!state.isPublishing) {
                            publishForm();
                          }
                        },
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
      },
    );
  }

  Widget searchSelectUserField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required List<OptionUserModel> options,
    required bool isLoading,
    required void Function(String value) onSearch,
    required void Function(OptionUserModel user) onSelect,
  }) {
    final h = getScreenHeight(context);
    final hasSearchText = controller.text.trim().isNotEmpty;
    final showNoResults = hasSearchText && !isLoading && options.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        scheduleLabel(context: context, title: title),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          onChanged: (value) {
            setState(() {});
            onSearch(value);
          },
          style: TextStyle(
            fontFamily: "ArabicCustomFont",
            fontSize: h * 0.018,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B2B2B),
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF7B1FA2),
            ),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFE5007D),
                    ),
                    onPressed: () {
                      setState(() {
                        controller.clear();
                      });
                      onSearch("");
                    },
                  )
                : null,
            hintStyle: TextStyle(
              fontFamily: "ArabicCustomFont",
              fontSize: h * 0.017,
              color: Colors.black38,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF2C9E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF2C9E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5007D)),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            );
          },
          child: options.isNotEmpty
              ? Container(
                  key: ValueKey("options_${title}_${options.length}"),
                  margin: const EdgeInsets.only(top: 10),
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF2C9E0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = options[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFFE5007D),
                        ),
                        title: customText(
                          text: user.fullName,
                          size: h * 0.018,
                          bold: true,
                          color: const Color(0xFF2B2B2B),
                        ),
                        onTap: () => onSelect(user),
                      );
                    },
                  ),
                )
              : showNoResults
              ? Container(
                  key: ValueKey("no_results_$title"),
                  margin: const EdgeInsets.only(top: 10),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF2C9E0)),
                  ),
                  child: customText(
                    text: title.contains("المريض")
                        ? "لا يوجد مريض بهذا الاسم"
                        : "لا يوجد متطوع بهذا الاسم",
                    size: h * 0.017,
                    bold: true,
                    color: const Color(0xFFE5007D),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget selectedUsersChips({
    required List<OptionUserModel> users,
    required void Function(OptionUserModel user) onRemove,
  }) {
    final h = getScreenHeight(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: users.isEmpty
          ? const SizedBox.shrink(key: ValueKey("empty_chips"))
          : Padding(
              key: ValueKey(users.map((e) => e.id).join(",")),
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: users.map((user) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1),
                    duration: const Duration(milliseconds: 250),
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFBCD4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          customText(
                            text: user.fullName,
                            size: h * 0.017,
                            bold: true,
                            color: const Color(0xFF7B1FA2),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => onRemove(user),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Color(0xFFE5007D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  String? buildPublishAt() {
    if (selectedDate == null || selectedTime == null) return null;

    final dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    return dateTime.toUtc().toIso8601String();
  }

  Future<bool> publishOne(Map<String, dynamic> body) async {
    debugPrint("Publish body: $body");

    return await context.read<PublishScheduleCubit>().publishForm(
      form: selectedForm!,
      body: body,
    );
  }

  Future<void> publishForm() async {
    if (selectedForm == null) {
      showError("اختر نموذجًا للنشر.");
      return;
    }

    if (targetType == null) {
      showError("اختر الفئة المستهدفة.");
      return;
    }

    if (targetType == "المرضى") {
      if (patientPublishType == null) {
        showError("اختر نوع النشر للمرضى.");
        return;
      }

      if (patientPublishType == "مريض واحد") {
        if (selectedSinglePatient == null) {
          showError("اختر المريض أولاً.");
          return;
        }

        final body = {
          "target": "SINGLE_PATIENT",
          "patientId": selectedSinglePatient!.id,
          "publishAt": buildPublishAt(),
        };

        final success = await publishOne(body);
        if (!mounted) return;

        if (success) afterSuccess();
        return;
      }

      // حالة كل المرضى ALL_PATIENTS
      final body = {"target": "ALL_PATIENTS", "publishAt": buildPublishAt()};
      final success = await publishOne(body);
      if (!mounted) return;

      if (success) afterSuccess();
      return;
    }

    if (targetType == "المتطوعين") {
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

      // نقوم بعمل النشر للكل أولاً وننتظر حتى تنتهي العمليات
      for (int i = 0; i < selectedPatients.length; i++) {
        final body = {
          "target": "VOLUNTEER_FOR_PATIENT",
          "patientId": selectedPatients[i].id,
          "volunteerId": selectedVolunteers[i].id,
          "publishAt": buildPublishAt(),
        };

        final success = await publishOne(body);
        if (!success) {
          allSuccess = false;
        }
      }

      if (!mounted) return;

      // استدعاء بعد النجاح لمرة واحدة فقط خارج الـ Loop
      if (allSuccess) {
        afterSuccess();
      } else {
        showError("حدث خطأ أثناء نشر بعض النماذج.");
      }
    }
  }

  void afterSuccess() {
    if (!mounted) return;

    // 1. إظهار الديالوج أولاً
    customDialog(
      context: context,
      title: "تم النشر",
      message: "تم نشر النموذج بنجاح.",
      isSuccess: true,
    );

    // 2. تحديث الحالة وتصفير البيانات بعد الديالوج مباشرة دون تداخل
    setState(() {
      selectedForm = null;
      selectedDate = null;
      selectedTime = null;
      targetType = null;
      patientPublishType = null;
      selectedSinglePatient = null;
      selectedPatients.clear();
      selectedVolunteers.clear();
      patientSearchController.clear();
      volunteerSearchController.clear();
    });
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
