part of '../../../screens/patients_info.dart';

class _EditPatientClinicalDialog extends StatefulWidget {
  final PatientModel patient;
  final List<String> diseaseStatusOptions;
  final List<String> tumorBiologyOptions;
  final List<String> surgeryOptions;
  final List<String> chemotherapyOptions;
  final List<String> yesNoOptions;
  final String? Function(String?) toApiValue;

  const _EditPatientClinicalDialog({
    required this.patient,
    required this.diseaseStatusOptions,
    required this.tumorBiologyOptions,
    required this.surgeryOptions,
    required this.chemotherapyOptions,
    required this.yesNoOptions,
    required this.toApiValue,
  });

  @override
  State<_EditPatientClinicalDialog> createState() =>
      _EditPatientClinicalDialogState();
}

class _EditPatientClinicalDialogState
    extends State<_EditPatientClinicalDialog> {
  final bmiController = TextEditingController();
  final familyHistoryController = TextEditingController();
  final drugsController = TextEditingController();
  final notesController = TextEditingController();

  String? diseaseStatus;
  String? tumorBiology;
  String? surgery;
  String? chemotherapy;
  String? radiotherapy;
  String? hormonalTherapy;
  String? targetedTherapy;
  String? immunotherapy;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    bmiController.text = _safeText(widget.patient.bmi);
    familyHistoryController.text = _safeText(widget.patient.familyHistory);
    drugsController.text = widget.patient.drugs
        .map((drug) => drug.toString().trim())
        .where((drug) => drug.isNotEmpty)
        .join(', ');

    diseaseStatus = _safeDropdownValue(
      readablePatientValue(widget.patient.diseaseStatus),
      widget.diseaseStatusOptions,
    );

    tumorBiology = _safeDropdownValue(
      readablePatientValue(widget.patient.tumorBiology),
      widget.tumorBiologyOptions,
    );

    surgery = _safeDropdownValue(
      readablePatientValue(widget.patient.surgery),
      widget.surgeryOptions,
    );

    chemotherapy = _safeDropdownValue(
      readablePatientValue(widget.patient.chemotherapy),
      widget.chemotherapyOptions,
    );

    radiotherapy = _safeDropdownValue(
      _yesNo(widget.patient.radiotherapy),
      widget.yesNoOptions,
    );

    hormonalTherapy = _safeDropdownValue(
      _yesNo(widget.patient.hormonalTherapy),
      widget.yesNoOptions,
    );

    targetedTherapy = _safeDropdownValue(
      _yesNo(widget.patient.targetedTherapy),
      widget.yesNoOptions,
    );

    immunotherapy = _safeDropdownValue(
      _yesNo(widget.patient.immunotherapy),
      widget.yesNoOptions,
    );
  }

  @override
  void dispose() {
    bmiController.dispose();
    familyHistoryController.dispose();
    drugsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  String _safeText(Object? value) {
    if (value == null) return '';
    final text = value.toString();
    if (text == 'null') return '';
    return text;
  }

  List<String> _uniqueItems(List<String> items) {
    return items
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  String? _safeDropdownValue(String? value, List<String> items) {
    if (value == null || value.trim().isEmpty) return null;

    final cleanValue = value.trim();
    final matches = _uniqueItems(items).where((item) => item == cleanValue);

    if (matches.length == 1) return cleanValue;

    return null;
  }

  String? _yesNo(bool? value) {
    if (value == null) return null;
    return value ? 'Yes' : 'No';
  }

  bool? _boolFromYesNo(String? value) {
    if (value == 'Yes') return true;
    if (value == 'No') return false;
    return null;
  }

  List<String> _splitList(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    setState(() => isSaving = true);

    try {
      await WebService().updatePatientClinical(
        patientId: widget.patient.id,
        body: {
          "bmi": bmiController.text.trim().isEmpty
              ? null
              : double.tryParse(bmiController.text.trim()),
          "diseaseStatus": widget.toApiValue(diseaseStatus),
          "tumorBiology": widget.toApiValue(tumorBiology),
          "surgery": widget.toApiValue(surgery),
          "chemotherapy": widget.toApiValue(chemotherapy),
          "radiotherapy": _boolFromYesNo(radiotherapy),
          "hormonalTherapy": _boolFromYesNo(hormonalTherapy),
          "targetedTherapy": _boolFromYesNo(targetedTherapy),
          "immunotherapy": _boolFromYesNo(immunotherapy),
          "medicalHistory": {
            "familyHistory": familyHistoryController.text.trim().isEmpty
                ? null
                : familyHistoryController.text.trim(),
            "drugs": _splitList(drugsController.text),
            "notes": notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
          },
        },
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      customDialog(
        context: context,
        title: 'خطأ',
        message: e.toString(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = getScreenWidth(context) < 760;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.018, min: 12, max: 26),
        vertical: responsiveHeight(context, 0.02, min: 14, max: 26),
      ),
      child: Container(
        width: 820,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFFFD6EA)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A004C).withValues(alpha: 0.18),
              blurRadius: 38,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Directionality(
          textDirection: Directionality.of(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EditPatientDialogHeader(
                patient: widget.patient,
                onClose: isSaving ? null : () => Navigator.pop(context),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    responsiveSize(context, 0.018, min: 16, max: 28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PatientReadonlySummary(patient: widget.patient),
                      const SizedBox(height: 18),
                      _EditDialogSection(
                        title: context.l10n.clinicalData,
                        icon: Icons.medical_services_outlined,
                        children: [
                          _EditFieldWrapper(
                            title: 'BMI',
                            child: CustomFormTextField(
                              controller: bmiController,
                              hintText: 'BMI',
                              keyboardType: CustomTextFieldType.number,
                              textDirection: TextDirection.ltr,
                              isRequired: false,
                              bordered: true,
                              autovalidateMode: AutovalidateMode.disabled,
                            ),
                          ),
                          _EditFieldWrapper(
                            title: 'الحالة الحالية للمرض',
                            child: customDropdown(
                              context: context,
                              value: diseaseStatus,
                              hint: 'الحالة الحالية للمرض',
                              items: _uniqueItems(widget.diseaseStatusOptions),
                              icon: Icons.medical_services_outlined,
                              onChanged: (value) {
                                setState(() => diseaseStatus = value);
                              },
                            ),
                          ),
                          _EditFieldWrapper(
                            title: 'البيولوجيا الورمية',
                            child: customDropdown(
                              context: context,
                              value: tumorBiology,
                              hint: 'البيولوجيا الورمية',
                              items: _uniqueItems(widget.tumorBiologyOptions),
                              icon: Icons.biotech_outlined,
                              onChanged: (value) {
                                setState(() => tumorBiology = value);
                              },
                            ),
                          ),
                          _EditFieldWrapper(
                            title: 'الجراحة',
                            child: customDropdown(
                              context: context,
                              value: surgery,
                              hint: 'الجراحة',
                              items: _uniqueItems(widget.surgeryOptions),
                              icon: Icons.local_hospital_outlined,
                              onChanged: (value) {
                                setState(() => surgery = value);
                              },
                            ),
                          ),
                          _EditFieldWrapper(
                            title: 'العلاج الكيميائي',
                            child: customDropdown(
                              context: context,
                              value: chemotherapy,
                              hint: 'العلاج الكيميائي',
                              items: _uniqueItems(widget.chemotherapyOptions),
                              icon: Icons.science_outlined,
                              onChanged: (value) {
                                setState(() => chemotherapy = value);
                              },
                            ),
                          ),
                          _EditFieldWrapper(
                            title: 'العلاج الإشعاعي',
                            child: customDropdown(
                              context: context,
                              value: radiotherapy,
                              hint: 'العلاج الإشعاعي',
                              items: _uniqueItems(widget.yesNoOptions),
                              icon: Icons.radio_button_checked,
                              onChanged: (value) {
                                setState(() => radiotherapy = value);
                              },
                            ),
                          ),
                          _EditFieldWrapper(
                            title: 'العلاج الهرموني',
                            child: customDropdown(
                              context: context,
                              value: hormonalTherapy,
                              hint: 'العلاج الهرموني',
                              items: _uniqueItems(widget.yesNoOptions),
                              icon: Icons.medication_outlined,
                              onChanged: (value) {
                                setState(() => hormonalTherapy = value);
                              },
                            ),
                          ),
                          _EditFieldWrapper(
                            title: 'العلاج الموجه',
                            child: customDropdown(
                              context: context,
                              value: targetedTherapy,
                              hint: 'العلاج الموجه',
                              items: _uniqueItems(widget.yesNoOptions),
                              icon: Icons.gps_fixed_rounded,
                              onChanged: (value) {
                                setState(() => targetedTherapy = value);
                              },
                            ),
                          ),
                          _EditFieldWrapper(
                            title: 'العلاج المناعي',
                            fullWidth: isSmall,
                            child: customDropdown(
                              context: context,
                              value: immunotherapy,
                              hint: 'العلاج المناعي',
                              items: _uniqueItems(widget.yesNoOptions),
                              icon: Icons.health_and_safety_outlined,
                              onChanged: (value) {
                                setState(() => immunotherapy = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _EditDialogSection(
                        title: context.l10n.medicalHistory,
                        icon: Icons.history_edu_rounded,
                        children: [
                          _EditFieldWrapper(
                            title: context.l10n.familyHistory,
                            fullWidth: true,
                            child: CustomFormTextField(
                              controller: familyHistoryController,
                              hintText: context.l10n.familyHistory,
                              keyboardType: CustomTextFieldType.text,
                              textDirection: Directionality.of(context),
                              isRequired: false,
                              bordered: true,
                              autovalidateMode: AutovalidateMode.disabled,
                            ),
                          ),
                          _EditFieldWrapper(
                            title: context.l10n.drugs,
                            fullWidth: true,
                            child: CustomFormTextField(
                              controller: drugsController,
                              hintText:
                                  context.l10n.writeMedicinesSeparatedByCommas,
                              keyboardType: CustomTextFieldType.text,
                              textDirection: Directionality.of(context),
                              isRequired: false,
                              bordered: true,
                              autovalidateMode: AutovalidateMode.disabled,
                            ),
                          ),
                          _EditFieldWrapper(
                            title: context.l10n.notes,
                            fullWidth: true,
                            child: CustomFormTextField(
                              controller: notesController,
                              hintText: context.l10n.notes,
                              keyboardType: CustomTextFieldType.text,
                              textDirection: Directionality.of(context),
                              isRequired: false,
                              bordered: true,
                              maxLines: 3,
                              autovalidateMode: AutovalidateMode.disabled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _EditPatientDialogFooter(
                isSaving: isSaving,
                onCancel: () => Navigator.pop(context),
                onSave: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditPatientDialogHeader extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback? onClose;

  const _EditPatientDialogHeader({
    required this.patient,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = Directionality.of(context) == TextDirection.ltr;

    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.016, min: 16, max: 24)),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE83E8C), Color(0xFFFF7BB0)],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: responsiveSize(context, 0.052, min: 54, max: 68),
            height: responsiveSize(context, 0.052, min: 54, max: 68),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          SizedBox(width: responsiveSize(context, 0.012, min: 12, max: 18)),
          Expanded(
            child: Column(
              crossAxisAlignment: isEnglish
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                customText(
                  text: 'تعديل البيانات الطبية',
                  size: responsiveSize(context, 0.014, min: 20, max: 27),
                  color: Colors.white,
                  bold: true,
                  isCenter: false,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                customText(
                  text: patient.fullName.isEmpty ? 'Patient' : patient.fullName,
                  size: responsiveSize(context, 0.009, min: 13, max: 16),
                  color: Colors.white.withValues(alpha: 0.86),
                  bold: true,
                  isCenter: false,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                color: onClose == null ? Colors.white54 : Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
