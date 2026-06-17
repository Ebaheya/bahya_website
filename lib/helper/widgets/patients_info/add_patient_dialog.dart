part of '../../../screens/patients_info.dart';

class AddPatientDialog extends StatefulWidget {
  final List<String> diseaseStatusOptions;
  final List<String> tumorBiologyOptions;
  final List<String> surgeryOptions;
  final List<String> chemotherapyOptions;
  final List<String> yesNoOptions;
  final Future<bool> Function(NewPatientData patient) onSave;

  const AddPatientDialog({
    super.key,
    required this.diseaseStatusOptions,
    required this.tumorBiologyOptions,
    required this.surgeryOptions,
    required this.chemotherapyOptions,
    required this.yesNoOptions,
    required this.onSave,
  });

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final formKey = GlobalKey<FormState>();

  final crnController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final addressController = TextEditingController();
  final emergencyNameController = TextEditingController();
  final emergencyPhoneController = TextEditingController();
  final comorbiditiesController = TextEditingController();
  final bmiController = TextEditingController();
  final familyHistoryController = TextEditingController();
  final diagnosisDateController = TextEditingController();
  final drugsController = TextEditingController();

  String? gender;
  String? menopausalStatus;
  String? stageAtDiagnosis;
  String? diseaseStatus;
  String? tumorBiology;
  String? surgery;
  String? chemotherapy;
  String? radiotherapy;
  String? hormonalTherapy;
  String? targetedTherapy;
  String? immunotherapy;
  bool isSaving = false;

  static const List<String> stageOptions = [
    'STAGE_0',
    'STAGE_I',
    'STAGE_II',
    'STAGE_III',
    'STAGE_IV',
  ];

  @override
  void dispose() {
    crnController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    addressController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
    comorbiditiesController.dispose();
    bmiController.dispose();
    familyHistoryController.dispose();
    diagnosisDateController.dispose();
    drugsController.dispose();
    super.dispose();
  }

  Future<void> savePatient() async {
    if (isSaving) return;
    if (!formKey.currentState!.validate()) return;

    if (_hasMissingSelections) {
      customDialog(
        isError: true,
        title: 'خطأ',
        context: context,
        message: 'من فضلك أكمل كل الاختيارات المطلوبة',
      );
      return;
    }
    setState(() => isSaving = true);

    final saved = await widget.onSave(
      NewPatientData(
        crn: crnController.text.trim(),
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phone: phoneController.text.trim(),
        dateOfBirth: dateOfBirthController.text.trim(),
        gender: gender!,
        address: addressController.text.trim(),
        emergencyContactName: emergencyNameController.text.trim(),
        emergencyContactPhone: emergencyPhoneController.text.trim(),
        comorbidities: comorbiditiesController.text.trim(),
        bmi: bmiController.text.trim(),
        familyHistory: familyHistoryController.text.trim(),
        menopausalStatus: menopausalStatus!,
        diagnosisDate: diagnosisDateController.text.trim(),
        stageAtDiagnosis: stageAtDiagnosis!,
        diseaseStatus: diseaseStatus!,
        tumorBiology: tumorBiology!,
        surgery: surgery!,
        chemotherapy: chemotherapy!,
        radiotherapy: radiotherapy!,
        hormonalTherapy: hormonalTherapy!,
        targetedTherapy: targetedTherapy!,
        immunotherapy: immunotherapy!,
        drugs: _splitCommaList(drugsController.text),
      ),
    );

    if (!mounted) return;
    setState(() => isSaving = false);
    if (saved) Navigator.pop(context);
  }

  bool get _hasMissingSelections {
    return gender == null ||
        diseaseStatus == null ||
        menopausalStatus == null ||
        stageAtDiagnosis == null ||
        tumorBiology == null ||
        surgery == null ||
        chemotherapy == null ||
        radiotherapy == null ||
        hormonalTherapy == null ||
        targetedTherapy == null ||
        immunotherapy == null ||
        dateOfBirthController.text.trim().isEmpty ||
        diagnosisDateController.text.trim().isEmpty;
  }

  List<String> _splitCommaList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isPhone = w < 700;
    final dialogWidth = isPhone ? w * 0.96 : w.clamp(720, 1040).toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isPhone ? 10 : 24,
        vertical: isPhone ? 12 : 24,
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: getScreenHeight(context) * (isPhone ? 0.94 : 0.90),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7FB),
          borderRadius: BorderRadius.circular(isPhone ? 18 : 24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 35,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Directionality(
          textDirection: _activeTextDirection,
          child: Column(
            children: [
              _DialogHeader(onClose: () => Navigator.pop(context)),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isPhone ? 14 : 22),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _PatientPreview(
                          nameController: nameController,
                          crnController: crnController,
                        ),
                        const SizedBox(height: 16),
                        _DialogSection(
                          title: 'بيانات الدخول والتعريف',
                          icon: Icons.badge_outlined,
                          children: [
                            _TextDialogField(
                              title: 'CRN',
                              controller: crnController,
                              hint: 'رقم المريض',
                              type: CustomTextFieldType.number,
                              isEnglish: true,
                            ),
                            _TextDialogField(
                              title: 'اسم المريض',
                              controller: nameController,
                              hint: 'أدخل اسم المريض بالكامل',
                              type: CustomTextFieldType.text,
                            ),
                            _TextDialogField(
                              title: 'البريد الإلكتروني',
                              controller: emailController,
                              hint: 'patient@example.com',
                              type: CustomTextFieldType.email,
                              isEnglish: true,
                            ),
                            _TextDialogField(
                              title: 'كلمة المرور',
                              controller: passwordController,
                              hint: '8 أحرف على الأقل',
                              type: CustomTextFieldType.password,
                              obscure: true,
                              isEnglish: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _DialogSection(
                          title: 'البيانات الشخصية',
                          icon: Icons.person_outline,
                          children: [
                            _TextDialogField(
                              title: 'رقم الهاتف',
                              controller: phoneController,
                              hint: '01012345678',
                              type: CustomTextFieldType.phone,
                              isEnglish: true,
                            ),
                            _DialogField(
                              title: 'تاريخ الميلاد',
                              child: CustomDatePickerField(
                                controller: dateOfBirthController,
                                hintText: localizedText(
                                  context,
                                  'اختر تاريخ الميلاد',
                                ),
                                bordered: true,
                              ),
                            ),
                            _GenderPicker(
                              value: gender,
                              onChanged: (value) =>
                                  setState(() => gender = value),
                            ),
                            _TextDialogField(
                              title: 'العنوان',
                              controller: addressController,
                              hint: 'أدخل عنوان المريض',
                              type: CustomTextFieldType.text,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _DialogSection(
                          title: 'بيانات الطوارئ',
                          icon: Icons.contact_emergency_outlined,
                          children: [
                            _TextDialogField(
                              title: 'جهة اتصال الطوارئ',
                              controller: emergencyNameController,
                              hint: 'اسم جهة الاتصال',
                              type: CustomTextFieldType.text,
                            ),
                            _TextDialogField(
                              title: 'رقم الطوارئ',
                              controller: emergencyPhoneController,
                              hint: '01012345678',
                              type: CustomTextFieldType.phone,
                              isEnglish: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _DialogSection(
                          title: 'البيانات السريرية',
                          icon: Icons.medical_information_outlined,
                          children: [
                            _TextDialogField(
                              title: 'الأمراض المصاحبة',
                              controller: comorbiditiesController,
                              hint: 'مثال: السكر، ضغط الدم',
                              type: CustomTextFieldType.text,
                              requiredField: false,
                            ),
                            _TextDialogField(
                              title: 'BMI',
                              controller: bmiController,
                              hint: 'مثال: 27',
                              type: CustomTextFieldType.number,
                              requiredField: false,
                              isEnglish: true,
                            ),
                            _TextDialogField(
                              title: 'التاريخ العائلي',
                              controller: familyHistoryController,
                              hint: 'مثال: لا يوجد',
                              type: CustomTextFieldType.text,
                              requiredField: false,
                            ),
                            _DialogDropdown(
                              title: 'حالة سن اليأس',
                              value: menopausalStatus,
                              hint: 'اختر حالة سن اليأس',
                              items: const [
                                'Pre-menopausal',
                                'Peri-menopausal',
                                'Post-menopausal',
                              ],
                              icon: Icons.woman_outlined,
                              onChanged: (v) =>
                                  setState(() => menopausalStatus = v),
                            ),
                            _DialogField(
                              title: 'تاريخ التشخيص',
                              child: CustomDatePickerField(
                                initialDate: DateTime.now().subtract(
                                  const Duration(days: 365 * 15),
                                ),
                                controller: diagnosisDateController,
                                hintText: localizedText(
                                  context,
                                  'اختر تاريخ التشخيص',
                                ),
                                bordered: true,
                              ),
                            ),
                            _DialogDropdown(
                              title: 'المرحلة عند التشخيص',
                              value: stageAtDiagnosis,
                              hint: 'اختر المرحلة',
                              items: stageOptions,
                              icon: Icons.stacked_bar_chart_rounded,
                              onChanged: (v) =>
                                  setState(() => stageAtDiagnosis = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _DialogSection(
                          title: 'خطة العلاج',
                          icon: Icons.local_hospital_outlined,
                          children: [
                            _DialogDropdown(
                              title: 'الحالة الحالية للمرض',
                              value: diseaseStatus,
                              hint: 'اختر الحالة',
                              items: widget.diseaseStatusOptions,
                              icon: Icons.medical_services_outlined,
                              onChanged: (v) =>
                                  setState(() => diseaseStatus = v),
                            ),
                            _DialogDropdown(
                              title: 'البيولوجيا الورمية',
                              value: tumorBiology,
                              hint: 'اختر النوع',
                              items: widget.tumorBiologyOptions,
                              icon: Icons.biotech_outlined,
                              onChanged: (v) =>
                                  setState(() => tumorBiology = v),
                            ),
                            _DialogDropdown(
                              title: 'الجراحة',
                              value: surgery,
                              hint: 'اختر الجراحة',
                              items: widget.surgeryOptions,
                              icon: Icons.medical_services_outlined,
                              onChanged: (v) => setState(() => surgery = v),
                            ),
                            _DialogDropdown(
                              title: 'العلاج الكيميائي',
                              value: chemotherapy,
                              hint: 'اختر العلاج',
                              items: widget.chemotherapyOptions,
                              icon: Icons.science_outlined,
                              onChanged: (v) =>
                                  setState(() => chemotherapy = v),
                            ),
                            _DialogDropdown(
                              title: 'العلاج الإشعاعي',
                              value: radiotherapy,
                              hint: 'نعم / لا',
                              items: widget.yesNoOptions,
                              icon: Icons.radio_button_checked,
                              onChanged: (v) =>
                                  setState(() => radiotherapy = v),
                            ),
                            _DialogDropdown(
                              title: 'العلاج الهرموني',
                              value: hormonalTherapy,
                              hint: 'نعم / لا',
                              items: widget.yesNoOptions,
                              icon: Icons.medication_outlined,
                              onChanged: (v) =>
                                  setState(() => hormonalTherapy = v),
                            ),
                            _DialogDropdown(
                              title: 'العلاج الموجه',
                              value: targetedTherapy,
                              hint: 'نعم / لا',
                              items: widget.yesNoOptions,
                              icon: Icons.gps_fixed_rounded,
                              onChanged: (v) =>
                                  setState(() => targetedTherapy = v),
                            ),
                            _DialogDropdown(
                              title: 'العلاج المناعي',
                              value: immunotherapy,
                              hint: 'نعم / لا',
                              items: widget.yesNoOptions,
                              icon: Icons.health_and_safety_outlined,
                              onChanged: (v) =>
                                  setState(() => immunotherapy = v),
                            ),
                            _TextDialogField(
                              title: 'الأدوية',
                              controller: drugsController,
                              hint: 'افصل بين الأدوية بفاصلة',
                              type: CustomTextFieldType.text,
                              requiredField: false,
                              maxLines: 5,
                              minLines: 4,
                              fullWidth: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _DialogFooter(
                isSaving: isSaving,
                onCancel: () => Navigator.pop(context),
                onSave: savePatient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
