import 'package:bahya_website/bloc/cubit/publish_schedule_cubit.dart';
import 'package:bahya_website/bloc/states/publish_schedule_state.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
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
                const ScheduleHeader(),
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
                  child: Column(
                    children: [
                      SearchSelectUserField(
                        title: "اختيار المرضى",
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
                          if (selectedPatients.any((e) => e.id == patient.id)) {
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
        SearchSelectUserField(
          title: "اختيار المتطوع",
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
        SizedBox(height: responsiveHeight(context, 0.035, min: 22, max: 30)),
        SearchSelectUserField(
          title: "اختيار المريض",
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
    );
  }

  Future<void> publishForm() async {
    if (targetType == "المرضى" &&
        patientPublishType == "مجموعه من المرضى" &&
        selectedPatients.isEmpty) {
      logic.showError("يجب اختيار مريض واحد على الأقل.");
      return;
    }

    await logic.publishForm(
      selectedForm: selectedForm,
      selectedDate: selectedDate,
      selectedTime: selectedTime,
      targetType: targetType,
      patientPublishType: patientPublishType,
      selectedSinglePatient: selectedPatients.isNotEmpty
          ? selectedPatients.first
          : null,
      selectedPatients: selectedPatients,
      selectedVolunteers: selectedVolunteers,
      onSuccess: afterSuccess,
    );
  }

  void afterSuccess() {
    if (!mounted) return;

    logic.showPublishSuccess();

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
