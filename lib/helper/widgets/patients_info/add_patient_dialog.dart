part of '../../../screens/doctor/patients_info.dart';

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

class _AddPatientDialogState extends State<AddPatientDialog>
    with SingleTickerProviderStateMixin {
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

  late final AnimationController _pageController;

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
  void initState() {
    super.initState();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  Widget _animatedBlock({required int index, required Widget child}) {
    final animation = CurvedAnimation(
      parent: _pageController,
      curve: Interval(
        (index * 0.08).clamp(0.0, 0.72),
        1,
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    final isPhone = w < 700;
    final dialogWidth = isPhone ? w * 0.96 : w.clamp(760, 1120).toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isPhone ? 10 : 24,
        vertical: isPhone ? 12 : 24,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.96, end: 1),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: dialogWidth,
          constraints: BoxConstraints(maxHeight: h * (isPhone ? 0.94 : 0.90)),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF7FB),
            borderRadius: BorderRadius.circular(isPhone ? 22 : 30),
            border: Border.all(
              color: const Color(0xFFE7549B).withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF831843).withValues(alpha: 0.16),
                blurRadius: 38,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isPhone ? 22 : 30),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  _ModernAddPatientHeader(
                    onClose: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isPhone ? 14 : 24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _animatedBlock(
                              index: 0,
                              child: _PatientPreview(
                                nameController: nameController,
                                crnController: crnController,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _animatedBlock(
                              index: 1,
                              child: _DialogSection(
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
                            ),
                            const SizedBox(height: 16),
                            _animatedBlock(
                              index: 2,
                              child: _DialogSection(
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
                                    onChanged: (value) {
                                      setState(() => gender = value);
                                    },
                                  ),
                                  _TextDialogField(
                                    title: 'العنوان',
                                    controller: addressController,
                                    hint: 'أدخل عنوان المريض',
                                    type: CustomTextFieldType.text,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _animatedBlock(
                              index: 3,
                              child: _DialogSection(
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
                            ),
                            const SizedBox(height: 16),
                            _animatedBlock(
                              index: 4,
                              child: _DialogSection(
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
                                    onChanged: (v) {
                                      setState(() => menopausalStatus = v);
                                    },
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
                                    onChanged: (v) {
                                      setState(() => stageAtDiagnosis = v);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _animatedBlock(
                              index: 5,
                              child: _TreatmentPlanSection(
                                children: [
                                  _DialogDropdown(
                                    title: 'الحالة الحالية للمرض',
                                    value: diseaseStatus,
                                    hint: 'اختر الحالة',
                                    items: widget.diseaseStatusOptions,
                                    icon: Icons.medical_services_outlined,
                                    onChanged: (v) {
                                      setState(() => diseaseStatus = v);
                                    },
                                  ),
                                  _DialogDropdown(
                                    title: 'البيولوجيا الورمية',
                                    value: tumorBiology,
                                    hint: 'اختر النوع',
                                    items: widget.tumorBiologyOptions,
                                    icon: Icons.biotech_outlined,
                                    onChanged: (v) {
                                      setState(() => tumorBiology = v);
                                    },
                                  ),
                                  _DialogDropdown(
                                    title: 'الجراحة',
                                    value: surgery,
                                    hint: 'اختر الجراحة',
                                    items: widget.surgeryOptions,
                                    icon: Icons.medical_services_outlined,
                                    onChanged: (v) {
                                      setState(() => surgery = v);
                                    },
                                  ),
                                  _DialogDropdown(
                                    title: 'العلاج الكيميائي',
                                    value: chemotherapy,
                                    hint: 'اختر العلاج',
                                    items: widget.chemotherapyOptions,
                                    icon: Icons.science_outlined,
                                    onChanged: (v) {
                                      setState(() => chemotherapy = v);
                                    },
                                  ),
                                  _DialogDropdown(
                                    title: 'العلاج الإشعاعي',
                                    value: radiotherapy,
                                    hint: 'نعم / لا',
                                    items: widget.yesNoOptions,
                                    icon: Icons.radio_button_checked,
                                    onChanged: (v) {
                                      setState(() => radiotherapy = v);
                                    },
                                  ),
                                  _DialogDropdown(
                                    title: 'العلاج الهرموني',
                                    value: hormonalTherapy,
                                    hint: 'نعم / لا',
                                    items: widget.yesNoOptions,
                                    icon: Icons.medication_outlined,
                                    onChanged: (v) {
                                      setState(() => hormonalTherapy = v);
                                    },
                                  ),
                                  _DialogDropdown(
                                    title: 'العلاج الموجه',
                                    value: targetedTherapy,
                                    hint: 'نعم / لا',
                                    items: widget.yesNoOptions,
                                    icon: Icons.gps_fixed_rounded,
                                    onChanged: (v) {
                                      setState(() => targetedTherapy = v);
                                    },
                                  ),
                                  _DialogDropdown(
                                    title: 'العلاج المناعي',
                                    value: immunotherapy,
                                    hint: 'نعم / لا',
                                    items: widget.yesNoOptions,
                                    icon: Icons.health_and_safety_outlined,
                                    onChanged: (v) {
                                      setState(() => immunotherapy = v);
                                    },
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
        ),
      ),
    );
  }
}

class _ModernAddPatientHeader extends StatefulWidget {
  final VoidCallback onClose;

  const _ModernAddPatientHeader({required this.onClose});

  @override
  State<_ModernAddPatientHeader> createState() =>
      _ModernAddPatientHeaderState();
}

class _ModernAddPatientHeaderState extends State<_ModernAddPatientHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = getScreenWidth(context) < 700;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final value = _animation.value;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.020, min: 18, max: 28),
            vertical: responsiveHeight(context, 0.018, min: 16, max: 24),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFFE7549B),
                Color(0xFFC044D8),
                Color(0xFF8A2BE2),
              ],
              begin: Alignment(-1 + value, -1),
              end: Alignment(1 - value, 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: responsiveSize(context, 0.050, min: 46, max: 58),
                height: responsiveSize(context, 0.050, min: 46, max: 58),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: responsiveSize(context, 0.026, min: 24, max: 30),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.016, min: 12, max: 18)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: 'إضافة مريض جديد',
                      size: responsiveSize(context, 0.018, min: 19, max: 26),
                      color: Colors.white,
                      bold: true,
                      isCenter: false,
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: responsiveHeight(context, 0.004, min: 4, max: 6),
                    ),
                    customText(
                      text: 'أدخل بيانات المريض والبيانات الطبية وخطة العلاج',
                      size: responsiveSize(context, 0.010, min: 12, max: 15),
                      color: Colors.white.withValues(alpha: 0.78),
                      isCenter: false,
                      maxLines: isPhone ? 2 : 1,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: widget.onClose,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: responsiveSize(context, 0.040, min: 40, max: 46),
                  height: responsiveSize(context, 0.040, min: 40, max: 46),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TreatmentPlanSection extends StatefulWidget {
  final List<Widget> children;

  const _TreatmentPlanSection({required this.children});

  @override
  State<_TreatmentPlanSection> createState() => _TreatmentPlanSectionState();
}

class _TreatmentPlanSectionState extends State<_TreatmentPlanSection> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isPhone = getScreenWidth(context) < 700;

    return MouseRegion(
      onEnter: (_) {
        if (!isPhone) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!isPhone) setState(() => _hover = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        width: double.infinity,
        transform: Matrix4.identity()
          ..translate(0.0, _hover && !isPhone ? -3.0 : 0.0),
        padding: EdgeInsets.all(
          responsiveSize(context, 0.016, min: 14, max: 22),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.020, min: 20, max: 28),
          ),
          border: Border.all(
            color: _hover
                ? const Color(0xFFE7549B).withValues(alpha: 0.30)
                : const Color(0xFFE7549B).withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF831843,
              ).withValues(alpha: _hover ? 0.12 : 0.06),
              blurRadius: _hover ? 24 : 16,
              offset: Offset(0, _hover ? 12 : 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: responsiveSize(context, 0.044, min: 42, max: 54),
                  height: responsiveSize(context, 0.044, min: 42, max: 54),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE7549B).withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_hospital_outlined,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: responsiveSize(context, 0.014, min: 12, max: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      customText(
                        text: 'خطة العلاج',
                        size: responsiveSize(context, 0.016, min: 18, max: 24),
                        bold: true,
                        color: const Color(0xFF831843),
                        isCenter: false,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.004,
                          min: 4,
                          max: 6,
                        ),
                      ),
                      customText(
                        text: 'حدد حالة المرض وأنواع العلاجات المستخدمة',
                        size: responsiveSize(context, 0.010, min: 12, max: 15),
                        color: Colors.grey.shade600,
                        isCenter: false,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: responsiveHeight(context, 0.020, min: 16, max: 24),
            ),
            Wrap(
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.start,
              textDirection: TextDirection.rtl,
              spacing: responsiveSize(context, 0.014, min: 12, max: 18),
              runSpacing: responsiveHeight(context, 0.018, min: 14, max: 20),
              children: widget.children,
            ),
          ],
        ),
      ),
    );
  }
}
