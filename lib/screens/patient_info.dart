import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_dropDown.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:excel/excel.dart' hide Border;
import 'package:file_saver/file_saver.dart';
import 'patient_clinical_details.dart';

class PatientInfo extends StatefulWidget {
  const PatientInfo({super.key});

  @override
  State<PatientInfo> createState() => _PatientInfoState();
}

class _PatientInfoState extends State<PatientInfo> {
  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  String? selectedDiseaseStatus;
  String? selectedTumorBiology;
  String? selectedSurgery;
  String? selectedChemotherapy;
  String? selectedRadiotherapy;
  String? selectedHormonalTherapy;
  String? selectedTargetedTherapy;
  String? selectedImmunotherapy;

  final List<String> diseaseStatusOptions = [
    'Newly diagnosed',
    'Active treatment',
    'Follow-up',
    'Recurrence',
    'Metastatic',
  ];

  final List<String> tumorBiologyOptions = [
    'Luminal A',
    'Luminal B',
    'HER2-enriched',
    'TNBC',
  ];

  final List<String> surgeryOptions = [
    'None',
    'Breast Conservative surgery',
    'Mastectomy',
  ];

  final List<String> chemotherapyOptions = [
    'No',
    'Neoadjuvant',
    'Adjuvant',
    'Metastatic',
  ];

  final List<String> yesNoOptions = ['Yes', 'No'];
Future<void> exportPatientsToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Patients'];

    excel.delete('Sheet1');

    sheet.appendRow([
      TextCellValue('File Number'),
      TextCellValue('Patient Name'),
      TextCellValue('Age'),
      TextCellValue('Registration Date'),
      TextCellValue('Current Disease Status'),
      TextCellValue('Tumor Biology'),
      TextCellValue('Surgery'),
      TextCellValue('Chemotherapy'),
      TextCellValue('Radiotherapy'),
      TextCellValue('Hormonal Therapy'),
      TextCellValue('Targeted Therapy'),
      TextCellValue('Immunotherapy'),
    ]);

    for (int i = 0; i < filteredPatients.length; i++) {
      final patient = filteredPatients[i];

      sheet.appendRow([
        TextCellValue('PT-${2504 - i * 7}'),
        TextCellValue(patient["name"].toString()),
        TextCellValue(patient["age"].toString()),
        TextCellValue(_demoDates[i % _demoDates.length]),
        TextCellValue(_demoDiseaseStatuses[i % _demoDiseaseStatuses.length]),
        TextCellValue(_demoTumorBiologies[i % _demoTumorBiologies.length]),
        TextCellValue(_demoSurgeries[i % _demoSurgeries.length]),
        TextCellValue(_demoChemotherapy[i % _demoChemotherapy.length]),
        TextCellValue(i.isEven ? 'Yes' : 'No'),
        TextCellValue(i.isEven ? 'Yes' : 'No'),
        TextCellValue(i % 3 == 0 ? 'Yes' : 'No'),
        TextCellValue(i % 4 == 0 ? 'Yes' : 'No'),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    await FileSaver.instance.saveFile(
      name: 'patients_clinical_data.xlsx',
      bytes: Uint8List.fromList(bytes),
      mimeType: MimeType.microsoftExcel,
    );
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void resetFilters() {
    setState(() {
      searchText = '';
      searchController.clear();
      selectedDiseaseStatus = null;
      selectedTumorBiology = null;
      selectedSurgery = null;
      selectedChemotherapy = null;
      selectedRadiotherapy = null;
      selectedHormonalTherapy = null;
      selectedTargetedTherapy = null;
      selectedImmunotherapy = null;
    });
  }

  int get activeFiltersCount {
    int count = 0;
    if (selectedDiseaseStatus != null) count++;
    if (selectedTumorBiology != null) count++;
    if (selectedSurgery != null) count++;
    if (selectedChemotherapy != null) count++;
    if (selectedRadiotherapy != null) count++;
    if (selectedHormonalTherapy != null) count++;
    if (selectedTargetedTherapy != null) count++;
    if (selectedImmunotherapy != null) count++;
    return count;
  }

  List<Map<String, dynamic>> get filteredPatients {
    return patients.where((p) {
      final name = p["name"].toString();
      if (searchText.trim().isNotEmpty && !name.contains(searchText.trim())) {
        return false;
      }
      return true;
    }).toList();
  }

  void openPatientDetails(Map<String, dynamic> patient, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientClinicalDetails(
          patient: buildClinicalPatient(patient, index),
        ),
      ),
    );
  }

  ClinicalPatient buildClinicalPatient(
    Map<String, dynamic> patient,
    int index,
  ) {
    return ClinicalPatient(
      fileNumber: 'PT-${2504 - index * 7}',
      name: patient["name"].toString(),
      age: patient["age"] as int,
      phone: '0102 345 6789',
      emergencyContactName: 'أحمد محمد',
      emergencyContactPhone: '0100 223 4455',
      registrationDate: _demoDates[index % _demoDates.length],
      comorbidities: 'السكري، ارتفاع ضغط الدم',
      bmi: '27.4',
      familyHistory: 'نعم - سرطان الثدي',
      menopausalStatus: 'بعد سن اليأس',
      diagnosisDate: '2024 - 11 - 10',
      stageAtDiagnosis: 'المرحلة الثانية (II)',
      diseaseStatus: _demoDiseaseStatuses[index % _demoDiseaseStatuses.length],
      tumorBiology: _demoTumorBiologies[index % _demoTumorBiologies.length],
      surgery: _demoSurgeries[index % _demoSurgeries.length],
      chemotherapy: _demoChemotherapy[index % _demoChemotherapy.length],
      radiotherapy: index.isEven ? 'Yes' : 'No',
      hormonalTherapy: index.isEven ? 'Yes' : 'No',
      targetedTherapy: index % 3 == 0 ? 'Yes' : 'No',
      immunotherapy: index % 4 == 0 ? 'Yes' : 'No',
      drugs: const [
        'تاموكسيفين 20 مجم يوميًا',
        'كالسيوم + فيتامين د',
        'أتورفاستاتين 10 مجم يوميًا',
        'ميتفورمين 500 مجم مرتين يوميًا',
      ],
      assessments: [
        PatientAssessment(
          formName: 'PHQ-9',
          submitDate: '2025 - 05 - 20',
          score: 12,
        ),
        PatientAssessment(
          formName: 'PHQ-4',
          submitDate: '2025 - 05 - 18',
          score: 8,
        ),
        PatientAssessment(
          formName: 'Distress Thermometer',
          submitDate: '2025 - 05 - 14',
          score: 6,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: 'جميع المرضى',
        isHomeBar: false,
        widgets: [
          _AppBarActionButton(
            title: 'إضافة مريض جديد',
            icon: Icons.add,
            onTap: () {},
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF7FB),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.025,
            vertical: h * 0.035,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
_TopActionsBar(
                searchController: searchController,
                activeFiltersCount: activeFiltersCount,
                onSearchChanged: (value) {
                  setState(() => searchText = value ?? '');
                },
                onReset: resetFilters,
                onExport: exportPatientsToExcel,
              ),
              SizedBox(height: h * 0.025),
              _FiltersPanel(
                selectedDiseaseStatus: selectedDiseaseStatus,
                selectedTumorBiology: selectedTumorBiology,
                selectedSurgery: selectedSurgery,
                selectedChemotherapy: selectedChemotherapy,
                selectedRadiotherapy: selectedRadiotherapy,
                selectedHormonalTherapy: selectedHormonalTherapy,
                selectedTargetedTherapy: selectedTargetedTherapy,
                selectedImmunotherapy: selectedImmunotherapy,
                diseaseStatusOptions: diseaseStatusOptions,
                tumorBiologyOptions: tumorBiologyOptions,
                surgeryOptions: surgeryOptions,
                chemotherapyOptions: chemotherapyOptions,
                yesNoOptions: yesNoOptions,
                onDiseaseStatusChanged: (value) {
                  setState(() => selectedDiseaseStatus = value);
                },
                onTumorBiologyChanged: (value) {
                  setState(() => selectedTumorBiology = value);
                },
                onSurgeryChanged: (value) {
                  setState(() => selectedSurgery = value);
                },
                onChemotherapyChanged: (value) {
                  setState(() => selectedChemotherapy = value);
                },
                onRadiotherapyChanged: (value) {
                  setState(() => selectedRadiotherapy = value);
                },
                onHormonalTherapyChanged: (value) {
                  setState(() => selectedHormonalTherapy = value);
                },
                onTargetedTherapyChanged: (value) {
                  setState(() => selectedTargetedTherapy = value);
                },
                onImmunotherapyChanged: (value) {
                  setState(() => selectedImmunotherapy = value);
                },
              ),
              SizedBox(height: h * 0.03),
              _ResultsHeader(total: filteredPatients.length),
              SizedBox(height: h * 0.02),
              _PatientsGrid(
                patientsList: filteredPatients,
                onPatientTap: (patient, index) {
                  openPatientDetails(patient, index);
                },
              ),
              SizedBox(height: h * 0.03),
              const _PaginationBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopActionsBar extends StatelessWidget {
  final TextEditingController searchController;
  final int activeFiltersCount;
  final ValueChanged<String?> onSearchChanged;
  final VoidCallback onReset;
  final VoidCallback onExport;
  const _TopActionsBar({
    required this.searchController,
    required this.activeFiltersCount,
    required this.onSearchChanged,
    required this.onReset,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Row(
      children: [
        _ActionButton(
          title: 'إعادة تعيين',
          icon: Icons.refresh,
          onTap: onReset,
          isPrimary: false,
        ),
        const SizedBox(width: 14),
        _ActionButton(
          title: 'تصفية',
          icon: Icons.filter_alt_outlined,
          badgeCount: activeFiltersCount,
          onTap: () {},
          isPrimary: false,
        ),
        const SizedBox(width: 14),
        _ActionButton(
          title: 'تصدير Excel',
          icon: Icons.table_chart_outlined,
          onTap: onExport,
          isPrimary: false,
        ),
        const Spacer(),
        SizedBox(
          width: w * 0.25,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CustomFormTextField(
              controller: searchController,
              hintText: 'ابحث بالاسم أو رقم الملف...',
              autovalidateMode: AutovalidateMode.disabled,
              keyboardType: CustomTextFieldType.text,
              textDirection: TextDirection.rtl,
              suffixIcon: const Icon(Icons.search, color: Color(0xFF7A7890)),
              onChange: onSearchChanged,
              isSearch: true,
              isRequired: false,
              showInlineError: false,
              bordered: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  final String? selectedDiseaseStatus;
  final String? selectedTumorBiology;
  final String? selectedSurgery;
  final String? selectedChemotherapy;
  final String? selectedRadiotherapy;
  final String? selectedHormonalTherapy;
  final String? selectedTargetedTherapy;
  final String? selectedImmunotherapy;

  final List<String> diseaseStatusOptions;
  final List<String> tumorBiologyOptions;
  final List<String> surgeryOptions;
  final List<String> chemotherapyOptions;
  final List<String> yesNoOptions;

  final ValueChanged<String?> onDiseaseStatusChanged;
  final ValueChanged<String?> onTumorBiologyChanged;
  final ValueChanged<String?> onSurgeryChanged;
  final ValueChanged<String?> onChemotherapyChanged;
  final ValueChanged<String?> onRadiotherapyChanged;
  final ValueChanged<String?> onHormonalTherapyChanged;
  final ValueChanged<String?> onTargetedTherapyChanged;
  final ValueChanged<String?> onImmunotherapyChanged;

  const _FiltersPanel({
    required this.selectedDiseaseStatus,
    required this.selectedTumorBiology,
    required this.selectedSurgery,
    required this.selectedChemotherapy,
    required this.selectedRadiotherapy,
    required this.selectedHormonalTherapy,
    required this.selectedTargetedTherapy,
    required this.selectedImmunotherapy,
    required this.diseaseStatusOptions,
    required this.tumorBiologyOptions,
    required this.surgeryOptions,
    required this.chemotherapyOptions,
    required this.yesNoOptions,
    required this.onDiseaseStatusChanged,
    required this.onTumorBiologyChanged,
    required this.onSurgeryChanged,
    required this.onChemotherapyChanged,
    required this.onRadiotherapyChanged,
    required this.onHormonalTherapyChanged,
    required this.onTargetedTherapyChanged,
    required this.onImmunotherapyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 22,
        alignment: WrapAlignment.end,
        children: [
          _FilterDropdown(
            title: 'الحالة الحالية للمرض',
            value: selectedDiseaseStatus,
            hint: 'كل الحالات',
            items: diseaseStatusOptions,
            icon: Icons.medical_services_outlined,
            onChanged: onDiseaseStatusChanged,
          ),
          _FilterDropdown(
            title: 'البيولوجيا الورمية',
            value: selectedTumorBiology,
            hint: 'كل الأنواع',
            items: tumorBiologyOptions,
            icon: Icons.biotech_outlined,
            onChanged: onTumorBiologyChanged,
          ),
          _FilterDropdown(
            title: 'العملية الجراحية',
            value: selectedSurgery,
            hint: 'كل الأنواع',
            items: surgeryOptions,
            icon: Icons.local_hospital_outlined,
            onChanged: onSurgeryChanged,
          ),
          _FilterDropdown(
            title: 'العلاج الكيميائي',
            value: selectedChemotherapy,
            hint: 'كل الحالات',
            items: chemotherapyOptions,
            icon: Icons.science_outlined,
            onChanged: onChemotherapyChanged,
          ),
          _FilterDropdown(
            title: 'العلاج الإشعاعي',
            value: selectedRadiotherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.radio_button_checked,
            onChanged: onRadiotherapyChanged,
          ),
          _FilterDropdown(
            title: 'العلاج الهرموني',
            value: selectedHormonalTherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.medication_outlined,
            onChanged: onHormonalTherapyChanged,
          ),
          _FilterDropdown(
            title: 'العلاج الموجه إن وجد',
            value: selectedTargetedTherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.gps_fixed_rounded,
            onChanged: onTargetedTherapyChanged,
          ),
          _FilterDropdown(
            title: 'العلاج المناعي إن وجد',
            value: selectedImmunotherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.health_and_safety_outlined,
            onChanged: onImmunotherapyChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String title;
  final String? value;
  final String hint;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.title,
    required this.value,
    required this.hint,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(
            text: title,
            size: 14,
            color: const Color(0xFF2D244C),
            bold: true,
            isCenter: false,
          ),
          const SizedBox(height: 8),
          customDropdown(
            context: context,
            value: value,
            hint: hint,
            items: items,
            icon: icon,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final int total;

  const _ResultsHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        customText(
          text: 'عدد النتائج: $total مريض',
          size: 15,
          color: const Color(0xFF6B667A),
          bold: true,
          isCenter: false,
        ),
        const Spacer(),
        const _SortDropdown(),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown();

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Row(
      children: [
        SizedBox(
          width: w * 0.11,
          child: customDropdown(
            context: context,
            value: 'تاريخ التسجيل الأحدث',
            hint: 'ترتيب حسب',
            items: const ['تاريخ التسجيل الأحدث', 'الاسم', 'العمر'],
            icon: Icons.sort_rounded,
            onChanged: (_) {},
          ),
        ),
        const SizedBox(width: 10),
        customText(
          text: 'ترتيب حسب:',
          size: w * 0.008,
          color: const Color(0xFF6B667A),
          bold: true,
          isCenter: false,
        ),
      ],
    );
  }
}

class _PatientsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> patientsList;
  final void Function(Map<String, dynamic> patient, int index) onPatientTap;

  const _PatientsGrid({required this.patientsList, required this.onPatientTap});

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return GridView.builder(
      itemCount: patientsList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: h * 0.35,
        crossAxisSpacing: 15,
        mainAxisSpacing: 18,
      ),
      itemBuilder: (context, index) {
        final patient = patientsList[index];

        return _PatientCard(
          index: index,
          patient: patient,
          onTap: () => onPatientTap(patient, index),
        );
      },
    );
  }
}

class _PatientCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> patient;
  final VoidCallback onTap;

  const _PatientCard({
    required this.index,
    required this.patient,
    required this.onTap,
  });

  String get patientName => patient["name"].toString();

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    final fileNumber = 'PT-${2504 - index * 7}';
    final diseaseStatus =
        _demoDiseaseStatuses[index % _demoDiseaseStatuses.length];
    final tumorBiology =
        _demoTumorBiologies[index % _demoTumorBiologies.length];
    final surgery = _demoSurgeries[index % _demoSurgeries.length];
    final chemo = _demoChemotherapy[index % _demoChemotherapy.length];
    final registerDate = _demoDates[index % _demoDates.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFD3E8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE83E8C).withOpacity(0.10),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: const Color(0xFFFFE4F1),
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: const Color(0xFFE83E8C),
                        child: customText(
                          text: patientName.isNotEmpty ? patientName[0] : 'م',
                          size: w * 0.018,
                          color: Colors.white,
                          bold: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    customText(
                      text: fileNumber,
                      size: w * 0.0085,
                      color: const Color(0xFFE83E8C),
                      bold: true,
                      isEnglish: true,
                    ),
                    const SizedBox(height: 6),
                    customText(
                      text: patientName,
                      size: w * 0.011,
                      color: const Color(0xFF271648),
                      bold: true,
                    ),
                    const SizedBox(height: 10),
                    _StatusBadge(status: diseaseStatus),
                    const Spacer(),
                    Container(height: 1, color: const Color(0xFFFFC6DD)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: w * 0.012,
                          color: const Color(0xFFE83E8C),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            customText(
                              text: registerDate,
                              size: w * 0.0075,
                              color: const Color(0xFF271648),
                              bold: true,
                              isEnglish: true,
                            ),
                            customText(
                              text: 'تاريخ التسجيل',
                              size: w * 0.0068,
                              color: const Color(0xFF7A7890),
                              bold: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: const Color(0xFFFFC6DD).withOpacity(0.9),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _PatientInfoTile(
                      icon: Icons.assignment_outlined,
                      label: 'الحالة',
                      value: diseaseStatus,
                    ),
                    const SizedBox(height: 10),
                    _PatientInfoTile(
                      icon: Icons.biotech_outlined,
                      label: 'البيولوجيا الورمية',
                      value: tumorBiology,
                    ),
                    const SizedBox(height: 10),
                    _PatientInfoTile(
                      icon: Icons.medical_services_outlined,
                      label: 'الجراحة',
                      value: surgery,
                    ),
                    const SizedBox(height: 10),
                    _PatientInfoTile(
                      icon: Icons.science_outlined,
                      label: 'العلاج الكيميائي',
                      value: chemo,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // String _translateStatus(String status) {
  //   switch (status) {
  //     case 'Active treatment':
  //       return 'تحت علاج نشط';
  //     case 'Follow-up':
  //       return 'متابعة دورية';
  //     case 'Newly diagnosed':
  //       return 'حديث التشخيص';
  //     case 'Recurrence':
  //       return 'انتكاس';
  //     case 'Metastatic':
  //       return 'منتشر';
  //     default:
  //       return status;
  //   }
  // }
}

class _PatientInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PatientInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
final h = getScreenHeight(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF1E6EE)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFFFEAF4),
            child: Icon(icon, size: w * 0.011, color: const Color(0xFFE83E8C)),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: '$label:',
                  size: w * 0.0075,
                  color: const Color(0xFF6B667A),
                  bold: true,
                  isCenter: false,
                  maxLines: 1,
                ),
                const SizedBox(height: 5),
                customText(
                  text: value,
                  size: w * 0.008,
                  color: const Color(0xFF271648),
                  bold: true,
                  isCenter: false,
                  maxLines: 2,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          Container(
            width: 7,
            height: h * 0.05,
            decoration: const BoxDecoration(
              color: Color(0xFFE83E8C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAF4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customText(
            text: 'الحالة: ${_translateStatus(status)}',
            size: w * 0.0075,
            color: const Color(0xFFE83E8C),
            bold: true,
          ),
          const SizedBox(width: 7),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFE83E8C),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'Active treatment':
        return 'تحت علاج نشط';
      case 'Follow-up':
        return 'متابعة دورية';
      case 'Newly diagnosed':
        return 'حديث التشخيص';
      case 'Recurrence':
        return 'انتكاس';
      case 'Metastatic':
        return 'منتشر';
      default:
        return status;
    }
  }
}
class _PaginationBar extends StatelessWidget {
  const _PaginationBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        customText(
          text: 'عرض 1 إلى 12 من 248 مريض',
          size: 13,
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
        const Spacer(),
        const _PageButton(title: 'السابق'),
        const SizedBox(width: 8),
        const _PageNumber(title: '1', active: true),
        const _PageNumber(title: '2'),
        const _PageNumber(title: '3'),
        const _PageNumber(title: '21'),
        const SizedBox(width: 8),
        const _PageButton(title: 'التالي'),
        const Spacer(),
        customText(
          text: 'عرض لكل صفحة',
          size: 13,
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: customText(
            text: '12',
            size: 13,
            color: const Color(0xFF2D244C),
            bold: true,
            isCenter: true,
          ),
        ),
      ],
    );
  }
}

class _PageNumber extends StatelessWidget {
  final String title;
  final bool active;

  const _PageNumber({required this.title, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE83E8C) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? const Color(0xFFE83E8C) : Colors.grey.shade200,
        ),
      ),
      child: customText(
        text: title,
        size: 13,
        color: active ? Colors.white : const Color(0xFF6B667A),
        bold: true,
        isCenter: true,
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final String title;

  const _PageButton({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: customText(
        text: title,
        size: 13,
        color: const Color(0xFF6B667A),
        bold: true,
        isCenter: true,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final int? badgeCount;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 17),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFE83E8C) : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isPrimary ? const Color(0xFFE83E8C) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : const Color(0xFFE83E8C),
            ),
            const SizedBox(width: 8),
            customText(
              text: title,
              size: 13,
              color: isPrimary ? Colors.white : const Color(0xFF6B667A),
              bold: true,
              isCenter: false,
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: const Color(0xFFE83E8C),
                child: customText(
                  text: badgeCount.toString(),
                  size: 11,
                  color: Colors.white,
                  bold: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppBarActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFE83E8C)),
              const SizedBox(width: 8),
              customText(
                text: title,
                size: 13,
                color: const Color(0xFFE83E8C),
                bold: true,
                isCenter: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const List<String> _demoDiseaseStatuses = [
  'Active treatment',
  'Follow-up',
  'Follow-up',
  'Active treatment',
  'Active treatment',
  'Metastatic',
  'Follow-up',
  'Follow-up',
];

const List<String> _demoTumorBiologies = [
  'Luminal A',
  'Luminal B',
  'TNBC',
  'HER2-enriched',
  'Luminal A',
  'HER2-enriched',
  'Luminal B',
  'TNBC',
];

const List<String> _demoSurgeries = [
  'Breast Conservative surgery',
  'None',
  'Mastectomy',
  'Breast Conservative surgery',
  'None',
  'Mastectomy',
  'Breast Conservative surgery',
  'None',
];

const List<String> _demoChemotherapy = [
  'Adjuvant',
  'No',
  'Metastatic',
  'Neoadjuvant',
  'No',
  'Adjuvant',
  'No',
  'Neoadjuvant',
];

const List<String> _demoDates = [
  '2024 - 11 - 10',
  '2024 - 09 - 18',
  '2024 - 07 - 05',
  '2024 - 10 - 12',
  '2024 - 12 - 01',
  '2023 - 11 - 22',
  '2024 - 08 - 30',
  '2024 - 06 - 15',
];
