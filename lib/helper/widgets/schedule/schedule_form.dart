import 'package:bahya_website/bloc/cubit/publish_schedule_cubit.dart';
import 'package:bahya_website/bloc/states/publish_schedule_state.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_date_picker.dart';
import 'package:bahya_website/helper/custom_dropDown.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/custom_time_picker.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/schedule/schedule_form_widget.dart';
import 'package:bahya_website/logic/schedule_form_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleFormWidget extends StatefulWidget {
  const ScheduleFormWidget({super.key, required this.forms});

  final List<FormModel> forms;

  @override
  State<ScheduleFormWidget> createState() => _ScheduleFormWidgetState();
}

class _ScheduleFormWidgetState extends State<ScheduleFormWidget> {
  final WebService web = WebService();

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
  final List<String> patientPublishItems = ["مجموعه من المرضى", "كل المرضى"];

  ScheduleFormLogic get logic => ScheduleFormLogic(context: context, web: web);

  @override
  void dispose() {
    patientSearchController.dispose();
    volunteerSearchController.dispose();
    super.dispose();
  }

  String? _buildPublishAt() {
    if (selectedDate == null || selectedTime == null) return null;

    final localDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    return localDateTime.toUtc().toIso8601String();
  }

  String _optionName(OptionUserModel user) {
    try {
      final dynamic value = user;
      final name = value.name ?? value.fullName ?? value.label;
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    } catch (_) {}

    return user.id;
  }

  bool _isDuplicateAssignmentError(Object error) {
    final text = error.toString();

    return text.contains('FORM_DUPLICATE_OPEN_ASSIGNMENT') ||
        text.contains('outstanding copy') ||
        text.contains('already has an outstanding');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return BlocBuilder<PublishScheduleCubit, PublishScheduleState>(
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: isMobile ? double.infinity : getScreenWidth(context) * 0.9,
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.03, min: 14, max: 42),
              vertical: responsiveHeight(context, 0.04, min: 18, max: 42),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.96),
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.024, min: 20, max: 28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: responsiveSize(context, 0.024, min: 18, max: 30),
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                ScheduleHeader(),
                SizedBox(
                  height: responsiveHeight(context, 0.04, min: 22, max: 40),
                ),
                _publishCard(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _publishCard(PublishScheduleState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.025, min: 16, max: 34)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFE),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.022, min: 18, max: 24),
        ),
        border: Border.all(color: const Color(0xFFF5D7EA)),
      ),
      child: Column(
        children: [
          scheduleLabel(context: context, title: "اختر نموذجًا للنشر"),
          SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 20)),
          customDropdown(
            context: context,
            value: selectedForm?.name,
            hint: "اختر نموذج من القائمة",
            items: widget.forms
                .where((form) => form.isActive == true)
                .map((e) => e.name)
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
          SizedBox(height: responsiveHeight(context, 0.035, min: 22, max: 34)),
          ScheduleDateTimeRow(
            selectedDate: selectedDate,
            selectedTime: selectedTime,
            onPickDate: pickCustomDate,
            onPickTime: pickCustomTime,
          ),
          SizedBox(height: responsiveHeight(context, 0.035, min: 22, max: 34)),
          scheduleLabel(context: context, title: "الفئة المستهدفة"),
          SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 20)),
          customDropdown(
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

              context.read<PublishScheduleCubit>().searchPatients("");
              context.read<PublishScheduleCubit>().searchVolunteers("");
            },
          ),
          if (targetType == "المرضى") _patientsTargetSection(state),
          if (targetType == "المتطوعين") _volunteersTargetSection(state),
          SizedBox(height: responsiveHeight(context, 0.04, min: 24, max: 38)),
          CustomGlowButton(
            title: state.isPublishing ? "جاري النشر..." : "نشر النموذج",
            onPressed: () {
              if (!state.isPublishing) publishForm();
            },
            icon: Icons.schedule_send_rounded,
            isGradient: true,
            width: double.infinity,
            height: responsiveHeight(context, 0.06, min: 46, max: 58),
            textSize: responsiveSize(context, 0.01, min: 14, max: 17),
          ),
        ],
      ),
    );
  }

  Widget _patientsTargetSection(PublishScheduleState state) {
    return Column(
      children: [
        SizedBox(height: responsiveHeight(context, 0.035, min: 22, max: 32)),
        scheduleLabel(context: context, title: "نوع النشر"),
        SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 20)),
        customDropdown(
          context: context,
          value: patientPublishType,
          hint: "اختر نوع النشر",
          items: patientPublishItems,
          icon: Icons.person_outline,
          onChanged: (v) {
            setState(() {
              patientPublishType = v;
              selectedSinglePatient = null;
              selectedPatients.clear();
              patientSearchController.clear();
            });

            context.read<PublishScheduleCubit>().searchPatients("");
          },
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: scheduleSwitcherTransition,
          child: patientPublishType == "مجموعه من المرضى"
              ? Padding(
                  key: const ValueKey("patients_group"),
                  padding: EdgeInsets.only(
                    top: responsiveHeight(context, 0.035, min: 22, max: 30),
                  ),
                  child: _selectionBox(
                    title: "اختيار المرضى",
                    icon: Icons.people_alt_outlined,
                    child: Column(
                      children: [
                        SearchSelectUserField(
                          title: "المرضى",
                          hint: "ابحث باسم المريض",
                          controller: patientSearchController,
                          options: state.patientOptions,
                          isLoading: state.isSearchingPatients,
                          noResultsText: "لا يوجد مريض بهذا الاسم",
                          onSearch: (v) {
                            context.read<PublishScheduleCubit>().searchPatients(
                              v,
                            );
                          },
                          onSelect: (patient) {
                            if (selectedPatients.any(
                              (e) => e.id == patient.id,
                            )) {
                              logic.showError("هذا المريض تم اختياره بالفعل.");
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
                        SelectedUsersChips(
                          users: selectedPatients,
                          onRemove: (user) {
                            setState(() => selectedPatients.remove(user));
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _volunteersTargetSection(PublishScheduleState state) {
    return Column(
      children: [
        SizedBox(height: responsiveHeight(context, 0.035, min: 22, max: 30)),
        _selectionBox(
          title: "اختيار المتطوعين",
          icon: Icons.volunteer_activism_outlined,
          child: Column(
            children: [
              SearchSelectUserField(
                title: "المتطوعين",
                hint: "ابحث باسم المتطوع",
                controller: volunteerSearchController,
                options: state.volunteerOptions,
                isLoading: state.isSearchingVolunteers,
                noResultsText: "لا يوجد متطوع بهذا الاسم",
                onSearch: (v) {
                  context.read<PublishScheduleCubit>().searchVolunteers(v);
                },
                onSelect: (volunteer) {
                  if (selectedVolunteers.any((e) => e.id == volunteer.id)) {
                    logic.showError("هذا المتطوع تم اختياره بالفعل.");
                    return;
                  }

                  setState(() {
                    selectedVolunteers.add(volunteer);
                    volunteerSearchController.clear();
                  });

                  context.read<PublishScheduleCubit>().searchVolunteers("");
                },
              ),
              SelectedUsersChips(
                users: selectedVolunteers,
                onRemove: (user) {
                  setState(() => selectedVolunteers.remove(user));
                },
              ),
            ],
          ),
        ),
        SizedBox(height: responsiveHeight(context, 0.03, min: 20, max: 28)),
        _selectionBox(
          title: "اختيار المرضى",
          icon: Icons.personal_injury_outlined,
          child: Column(
            children: [
              SearchSelectUserField(
                title: "المرضى",
                hint: "ابحث باسم المريض",
                controller: patientSearchController,
                options: state.patientOptions,
                isLoading: state.isSearchingPatients,
                noResultsText: "لا يوجد مريض بهذا الاسم",
                onSearch: (v) {
                  context.read<PublishScheduleCubit>().searchPatients(v);
                },
                onSelect: (patient) {
                  if (selectedPatients.any((e) => e.id == patient.id)) {
                    logic.showError("هذا المريض تم اختياره بالفعل.");
                    return;
                  }

                  setState(() {
                    selectedPatients.add(patient);
                    patientSearchController.clear();
                  });

                  context.read<PublishScheduleCubit>().searchPatients("");
                },
              ),
              SelectedUsersChips(
                users: selectedPatients,
                onRemove: (user) {
                  setState(() => selectedPatients.remove(user));
                },
              ),
            ],
          ),
        ),
        SizedBox(height: responsiveHeight(context, 0.018, min: 12, max: 18)),
        _infoBox(
          "يمكن اختيار متطوع واحد لعدة مرضى، أو عدة متطوعين وعدة مرضى بدون اشتراط نفس العدد. سيتم توزيع المرضى على المتطوعين تلقائيًا.",
        ),
      ],
    );
  }

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
            color: const Color(0xFFE40070).withOpacity(0.04),
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

  void _resetAfterPublish() {
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

    context.read<PublishScheduleCubit>().loadForms();
  }

  void afterSuccess() {
    if (!mounted) return;

    logic.showPublishSuccess();
    _resetAfterPublish();
  }

  Future pickCustomTime() async {
    final t = await customTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (!mounted) return;

    if (t != null) {
      setState(() => selectedTime = t);
    }
  }

  Future pickCustomDate() async {
    final d = await customDatePicker(
      context: context,
      initialDate: selectedDate,
    );

    if (!mounted) return;

    if (d != null) {
      setState(() => selectedDate = d);
    }
  }
}
