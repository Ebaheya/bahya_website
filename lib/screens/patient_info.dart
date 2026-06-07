import 'dart:typed_data';

import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_dropDown.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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

  int _gridCount(double w) {
    if (w >= 1350) return 3;
    if (w >= 900) return 2;
    return 1;
  }

  double _gridExtent(BuildContext context) {
    final w = getScreenWidth(context);
    if (w >= 1350) return responsiveHeight(context, 0.42, min: 360, max: 440);
    if (w >= 900) return responsiveHeight(context, 0.42, min: 350, max: 430);
    return responsiveHeight(context, 0.50, min: 420, max: 520);
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    void showAddPatientDialog(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AddPatientDialog(
          diseaseStatusOptions: diseaseStatusOptions,
          tumorBiologyOptions: tumorBiologyOptions,
          surgeryOptions: surgeryOptions,
          chemotherapyOptions: chemotherapyOptions,
          yesNoOptions: yesNoOptions,
          onSave: (patient) {
            debugPrint('New patient: ${patient.name}');
          },
        ),
      );
    }

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: 'جميع المرضى',
        isHomeBar: false,
        widgets: [
          _AppBarActionButton(
            title: 'إضافة مريض جديد',
            icon: Icons.add,
            onTap: () {
              showAddPatientDialog(context);
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF7FB),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.025, min: 16, max: 42),
            vertical: responsiveHeight(context, 0.035, min: 20, max: 38),
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
              SizedBox(
                height: responsiveHeight(context, 0.025, min: 18, max: 28),
              ),
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
              SizedBox(
                height: responsiveHeight(context, 0.03, min: 20, max: 34),
              ),
              _ResultsHeader(total: filteredPatients.length),
              SizedBox(
                height: responsiveHeight(context, 0.02, min: 14, max: 24),
              ),
              _PatientsGrid(
                patientsList: filteredPatients,
                crossAxisCount: _gridCount(w),
                mainAxisExtent: _gridExtent(context),
                onPatientTap: (patient, index) {
                  openPatientDetails(patient, index);
                },
              ),
              SizedBox(
                height: responsiveHeight(context, 0.03, min: 20, max: 34),
              ),
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

    if (w < 900) {
      return Column(
        children: [
          CustomFormTextField(
            controller: searchController,
            hintText: localizedText(context, 'ابحث بالاسم أو رقم الملف...'),
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionButton(
                title: 'إعادة تعيين',
                icon: Icons.refresh,
                onTap: onReset,
                isPrimary: false,
              ),
              _ActionButton(
                title: 'تصفية',
                icon: Icons.filter_alt_outlined,
                badgeCount: activeFiltersCount,
                onTap: () {},
                isPrimary: false,
              ),
              _ActionButton(
                title: 'تصدير Excel',
                icon: Icons.table_chart_outlined,
                onTap: onExport,
                isPrimary: false,
              ),
            ],
          ),
        ],
      );
    }

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
          width: (w * 0.25).clamp(300.0, 430.0),
          child: Container(
            padding: EdgeInsets.all(
              responsiveSize(context, 0.008, min: 10, max: 14),
            ),
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
              hintText: localizedText(context, 'ابحث بالاسم أو رقم الملف...'),
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
    final w = getScreenWidth(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.014, min: 16, max: 24),
        vertical: responsiveHeight(context, 0.025, min: 18, max: 28),
      ),
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
        spacing: responsiveSize(context, 0.012, min: 12, max: 18),
        runSpacing: responsiveHeight(context, 0.025, min: 14, max: 22),
        alignment: WrapAlignment.end,
        children: [
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'الحالة الحالية للمرض',
            value: selectedDiseaseStatus,
            hint: 'كل الحالات',
            items: diseaseStatusOptions,
            icon: Icons.medical_services_outlined,
            onChanged: onDiseaseStatusChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'البيولوجيا الورمية',
            value: selectedTumorBiology,
            hint: 'كل الأنواع',
            items: tumorBiologyOptions,
            icon: Icons.biotech_outlined,
            onChanged: onTumorBiologyChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العملية الجراحية',
            value: selectedSurgery,
            hint: 'كل الأنواع',
            items: surgeryOptions,
            icon: Icons.local_hospital_outlined,
            onChanged: onSurgeryChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العلاج الكيميائي',
            value: selectedChemotherapy,
            hint: 'كل الحالات',
            items: chemotherapyOptions,
            icon: Icons.science_outlined,
            onChanged: onChemotherapyChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العلاج الإشعاعي',
            value: selectedRadiotherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.radio_button_checked,
            onChanged: onRadiotherapyChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العلاج الهرموني',
            value: selectedHormonalTherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.medication_outlined,
            onChanged: onHormonalTherapyChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العلاج الموجه إن وجد',
            value: selectedTargetedTherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.gps_fixed_rounded,
            onChanged: onTargetedTherapyChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
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
  final double width;
  final String title;
  final String? value;
  final String hint;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.width,
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
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(
            text: title,
            size: responsiveSize(context, 0.0075, min: 12, max: 14),
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
    final w = getScreenWidth(context);

    if (w < 700) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(
            text: 'عدد النتائج: $total مريض',
            size: responsiveSize(context, 0.008, min: 13, max: 15),
            color: const Color(0xFF6B667A),
            bold: true,
            isCenter: false,
          ),
          const SizedBox(height: 12),
          const _SortDropdown(),
        ],
      );
    }

    return Row(
      children: [
        customText(
          text: 'عدد النتائج: $total مريض',
          size: responsiveSize(context, 0.008, min: 13, max: 15),
          color: const Color(0xFF6B667A),
          bold: true,
          isCenter: false,
        ),
        Spacer(),
        _SortDropdown(),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: w < 700 ? 220 : (w * 0.11).clamp(180.0, 230.0),
          child: customDropdown(
            context: context,
            value: 'تاريخ التسجيل الأحدث',
            hint: 'ترتيب حسب',
            items: ['تاريخ التسجيل الأحدث', 'الاسم', 'العمر'],
            icon: Icons.sort_rounded,
            onChanged: (_) {},
          ),
        ),
        const SizedBox(width: 10),
        customText(
          text: 'ترتيب حسب:',
          size: responsiveSize(context, 0.008, min: 12, max: 14),
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
  final int crossAxisCount;
  final double mainAxisExtent;
  final void Function(Map<String, dynamic> patient, int index) onPatientTap;

  const _PatientsGrid({
    required this.patientsList,
    required this.crossAxisCount,
    required this.mainAxisExtent,
    required this.onPatientTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: patientsList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: mainAxisExtent,
        crossAxisSpacing: responsiveSize(context, 0.01, min: 12, max: 18),
        mainAxisSpacing: responsiveHeight(context, 0.02, min: 14, max: 20),
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
    final isSmall = w < 700;

    final fileNumber = 'PT-${2504 - index * 7}';
    final diseaseStatus =
        _demoDiseaseStatuses[index % _demoDiseaseStatuses.length];
    final tumorBiology =
        _demoTumorBiologies[index % _demoTumorBiologies.length];
    final surgery = _demoSurgeries[index % _demoSurgeries.length];
    final chemo = _demoChemotherapy[index % _demoChemotherapy.length];
    final registerDate = _demoDates[index % _demoDates.length];

    final profile = _PatientCardProfile(
      patientName: patientName,
      fileNumber: fileNumber,
      diseaseStatus: diseaseStatus,
      registerDate: registerDate,
    );

    final details = Column(
      children: [
        _PatientInfoTile(
          icon: Icons.assignment_outlined,
          label: 'الحالة',
          value: diseaseStatus,
        ),
        SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 10)),
        _PatientInfoTile(
          icon: Icons.biotech_outlined,
          label: 'البيولوجيا الورمية',
          value: tumorBiology,
        ),
        SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 10)),
        _PatientInfoTile(
          icon: Icons.medical_services_outlined,
          label: 'الجراحة',
          value: surgery,
        ),
        SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 10)),
        _PatientInfoTile(
          icon: Icons.science_outlined,
          label: 'العلاج الكيميائي',
          value: chemo,
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: EdgeInsets.all(
          responsiveSize(context, 0.012, min: 14, max: 18),
        ),
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
          textDirection: Directionality.of(context),
          child: isSmall
              ? Column(
                  children: [
                    profile,
                    const SizedBox(height: 16),
                    Container(height: 1, color: const Color(0xFFFFC6DD)),
                    const SizedBox(height: 16),
                    details,
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 5, child: profile),
                    Container(
                      width: 1,
                      margin: EdgeInsets.symmetric(
                        horizontal: responsiveSize(
                          context,
                          0.012,
                          min: 14,
                          max: 18,
                        ),
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: const Color(0xFFFFC6DD).withOpacity(0.9),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    Expanded(flex: 6, child: details),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PatientCardProfile extends StatelessWidget {
  final String patientName;
  final String fileNumber;
  final String diseaseStatus;
  final String registerDate;

  const _PatientCardProfile({
    required this.patientName,
    required this.fileNumber,
    required this.diseaseStatus,
    required this.registerDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: responsiveSize(context, 0.035, min: 38, max: 52),
          backgroundColor: const Color(0xFFFFE4F1),
          child: CircleAvatar(
            radius: responsiveSize(context, 0.029, min: 30, max: 42),
            backgroundColor: const Color(0xFFE83E8C),
            child: customText(
              text: patientName.isNotEmpty ? patientName[0] : 'م',
              size: responsiveSize(context, 0.018, min: 22, max: 30),
              color: Colors.white,
              bold: true,
            ),
          ),
        ),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
        customText(
          text: fileNumber,
          size: responsiveSize(context, 0.0085, min: 12, max: 15),
          color: const Color(0xFFE83E8C),
          bold: true,
          isEnglish: true,
        ),
        const SizedBox(height: 6),
        customText(
          text: patientName,
          size: responsiveSize(context, 0.011, min: 16, max: 22),
          color: const Color(0xFF271648),
          bold: true,
          maxLines: 1,
        ),
        SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
        _StatusBadge(status: diseaseStatus),
        const Spacer(),
        Container(height: 1, color: const Color(0xFFFFC6DD)),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: responsiveSize(context, 0.012, min: 15, max: 20),
              color: const Color(0xFFE83E8C),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                customText(
                  text: registerDate,
                  size: responsiveSize(context, 0.0075, min: 12, max: 14),
                  color: const Color(0xFF271648),
                  bold: true,
                  isEnglish: true,
                ),
                customText(
                  text: 'تاريخ التسجيل',
                  size: responsiveSize(context, 0.0068, min: 11, max: 13),
                  color: const Color(0xFF7A7890),
                  bold: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.008, min: 10, max: 12),
        vertical: responsiveHeight(context, 0.012, min: 8, max: 10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF1E6EE)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          CircleAvatar(
            radius: responsiveSize(context, 0.012, min: 16, max: 18),
            backgroundColor: const Color(0xFFFFEAF4),
            child: Icon(
              icon,
              size: responsiveSize(context, 0.011, min: 14, max: 18),
              color: const Color(0xFFE83E8C),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: '$label:',
                  size: responsiveSize(context, 0.0075, min: 12, max: 14),
                  color: const Color(0xFF6B667A),
                  bold: true,
                  isCenter: false,
                  maxLines: 1,
                ),
                const SizedBox(height: 5),
                customText(
                  text: value,
                  size: responsiveSize(context, 0.008, min: 12, max: 15),
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
            width: responsiveSize(context, 0.004, min: 5, max: 7),
            height: responsiveHeight(context, 0.05, min: 34, max: 45),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.009, min: 12, max: 14),
        vertical: responsiveHeight(context, 0.008, min: 6, max: 8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAF4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customText(
            text: 'الحالة: ${_translateStatus(status)}',
            size: responsiveSize(context, 0.0075, min: 11, max: 13),
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
    final w = getScreenWidth(context);

    if (w < 800) {
      return Column(
        children: [
          customText(
            text: 'عرض 1 إلى 12 من 248 مريض',
            size: responsiveSize(context, 0.0075, min: 12, max: 13),
            color: const Color(0xFF7A7890),
            bold: true,
            isCenter: true,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _PageButton(title: 'السابق'),
              _PageNumber(title: '1', active: true),
              _PageNumber(title: '2'),
              _PageNumber(title: '3'),
              _PageNumber(title: '21'),
              _PageButton(title: 'التالي'),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        customText(
          text: 'عرض 1 إلى 12 من 248 مريض',
          size: responsiveSize(context, 0.0075, min: 12, max: 13),
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
        Spacer(),
        _PageButton(title: 'السابق'),
        SizedBox(width: 8),
        _PageNumber(title: '1', active: true),
        _PageNumber(title: '2'),
        _PageNumber(title: '3'),
        _PageNumber(title: '21'),
        SizedBox(width: 8),
        _PageButton(title: 'التالي'),
        Spacer(),
        customText(
          text: 'عرض لكل صفحة',
          size: responsiveSize(context, 0.0075, min: 12, max: 13),
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
            size: responsiveSize(context, 0.0075, min: 12, max: 13),
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
      width: responsiveSize(context, 0.022, min: 32, max: 34),
      height: responsiveSize(context, 0.022, min: 32, max: 34),
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
        size: responsiveSize(context, 0.0075, min: 12, max: 13),
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
      height: responsiveSize(context, 0.022, min: 32, max: 34),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: customText(
        text: title,
        size: responsiveSize(context, 0.0075, min: 12, max: 13),
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
        height: responsiveSize(context, 0.028, min: 38, max: 44),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.011, min: 14, max: 17),
        ),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFE83E8C) : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isPrimary ? const Color(0xFFE83E8C) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: responsiveSize(context, 0.01, min: 16, max: 18),
              color: isPrimary ? Colors.white : const Color(0xFFE83E8C),
            ),
            const SizedBox(width: 8),
            customText(
              text: title,
              size: responsiveSize(context, 0.0075, min: 12, max: 13),
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
          height: responsiveSize(context, 0.026, min: 34, max: 38),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: responsiveSize(context, 0.01, min: 15, max: 18),
                color: textColor,
              ),
              const SizedBox(width: 8),
              customText(
                text: title,
                size: responsiveSize(context, 0.0085, min: 12, max: 14),
                color: textColor,
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

class AddPatientDialog extends StatefulWidget {
  final List<String> diseaseStatusOptions;
  final List<String> tumorBiologyOptions;
  final List<String> surgeryOptions;
  final List<String> chemotherapyOptions;
  final List<String> yesNoOptions;
  final ValueChanged<NewPatientData> onSave;

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

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final emergencyNameController = TextEditingController();
  final emergencyPhoneController = TextEditingController();
  final registrationDateController = TextEditingController();
  final comorbiditiesController = TextEditingController();
  final bmiController = TextEditingController();
  final familyHistoryController = TextEditingController();
  final menopausalStatusController = TextEditingController();
  final diagnosisDateController = TextEditingController();
  final stageController = TextEditingController();
  final drugsController = TextEditingController();

  String? diseaseStatus;
  String? tumorBiology;
  String? surgery;
  String? chemotherapy;
  String? radiotherapy;
  String? hormonalTherapy;
  String? targetedTherapy;
  String? immunotherapy;

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
    registrationDateController.dispose();
    comorbiditiesController.dispose();
    bmiController.dispose();
    familyHistoryController.dispose();
    menopausalStatusController.dispose();
    diagnosisDateController.dispose();
    stageController.dispose();
    drugsController.dispose();
    super.dispose();
  }

  void savePatient() {
    if (!formKey.currentState!.validate()) return;

    if (diseaseStatus == null ||
        tumorBiology == null ||
        surgery == null ||
        chemotherapy == null ||
        radiotherapy == null ||
        hormonalTherapy == null ||
        targetedTherapy == null ||
        immunotherapy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: customText(
            text: 'من فضلك كمّل كل الاختيارات',
            size: 14,
            color: Colors.white,
          ),
          backgroundColor: Color(0xFFE83E8C),
        ),
      );
      return;
    }

    widget.onSave(
      NewPatientData(
        name: nameController.text.trim(),
        age: int.tryParse(ageController.text.trim()) ?? 0,
        phone: phoneController.text.trim(),
        emergencyContactName: emergencyNameController.text.trim(),
        emergencyContactPhone: emergencyPhoneController.text.trim(),
        registrationDate: registrationDateController.text.trim(),
        comorbidities: comorbiditiesController.text.trim(),
        bmi: bmiController.text.trim(),
        familyHistory: familyHistoryController.text.trim(),
        menopausalStatus: menopausalStatusController.text.trim(),
        diagnosisDate: diagnosisDateController.text.trim(),
        stageAtDiagnosis: stageController.text.trim(),
        diseaseStatus: diseaseStatus!,
        tumorBiology: tumorBiology!,
        surgery: surgery!,
        chemotherapy: chemotherapy!,
        radiotherapy: radiotherapy!,
        hormonalTherapy: hormonalTherapy!,
        targetedTherapy: targetedTherapy!,
        immunotherapy: immunotherapy!,
        drugs: drugsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final dialogWidth = w < 900 ? w * 0.92 : w * 0.72;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 760),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7FB),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              _DialogHeader(onClose: () => Navigator.pop(context)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _DialogSection(
                          title: 'البيانات الأساسية',
                          icon: Icons.person_outline,
                          children: [
                            _DialogField(
                              title: 'اسم المريض',
                              child: CustomFormTextField(
                                controller: nameController,
                                hintText: localizedText(
                                  context,
                                  'ادخل اسم المريض',
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.text,
                              ),
                            ),
                            _DialogField(
                              title: 'العمر',
                              child: CustomFormTextField(
                                controller: ageController,
                                hintText: localizedText(context, 'ادخل العمر'),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.number,
                              ),
                            ),
                            _DialogField(
                              title: 'رقم الهاتف',
                              child: CustomFormTextField(
                                controller: phoneController,
                                hintText: localizedText(
                                  context,
                                  'ادخل رقم الهاتف',
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.phone,
                              ),
                            ),
                            _DialogField(
                              title: 'تاريخ التسجيل',
                              child: CustomFormTextField(
                                controller: registrationDateController,
                                hintText: localizedText(
                                  context,
                                  '2025 - 05 - 20',
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _DialogSection(
                          title: 'بيانات الطوارئ',
                          icon: Icons.contact_emergency_outlined,
                          children: [
                            _DialogField(
                              title: 'جهة اتصال الطوارئ',
                              child: CustomFormTextField(
                                controller: emergencyNameController,
                                hintText: localizedText(
                                  context,
                                  'اسم جهة الاتصال',
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.text,
                              ),
                            ),
                            _DialogField(
                              title: 'رقم الطوارئ',
                              child: CustomFormTextField(
                                controller: emergencyPhoneController,
                                hintText: localizedText(context, 'رقم الطوارئ'),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _DialogSection(
                          title: 'البيانات السريرية',
                          icon: Icons.medical_information_outlined,
                          children: [
                            _DialogField(
                              title: 'الأمراض المصاحبة',
                              child: CustomFormTextField(
                                controller: comorbiditiesController,
                                hintText: localizedText(
                                  context,
                                  'مثال: السكري، ضغط الدم',
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.text,
                              ),
                            ),
                            _DialogField(
                              title: 'BMI',
                              child: CustomFormTextField(
                                controller: bmiController,
                                hintText: localizedText(context, 'مثال: 27.4'),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.text,
                              ),
                            ),
                            _DialogField(
                              title: 'التاريخ العائلي',
                              child: CustomFormTextField(
                                controller: familyHistoryController,
                                hintText: localizedText(
                                  context,
                                  'مثال: نعم - سرطان الثدي',
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.text,
                              ),
                            ),
                            _DialogField(
                              title: 'حالة سن اليأس',
                              child: CustomFormTextField(
                                controller: menopausalStatusController,
                                hintText: localizedText(
                                  context,
                                  'قبل / بعد سن اليأس',
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.text,
                              ),
                            ),
                            _DialogField(
                              title: 'تاريخ التشخيص',
                              child: CustomFormTextField(
                                controller: diagnosisDateController,
                                hintText: localizedText(
                                  context,
                                  '2024 - 11 - 10',
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.text,
                              ),
                            ),
                            _DialogField(
                              title: 'المرحلة عند التشخيص',
                              child: CustomFormTextField(
                                controller: stageController,
                                hintText: localizedText(
                                  context,
                                  'مثال: المرحلة الثانية',
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _DialogSection(
                          title: 'العلاج',
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
                            _DialogField(
                              title: 'الأدوية',
                              child: CustomFormTextField(
                                controller: drugsController,
                                hintText: localizedText(
                                  context,
                                  'افصل بين الأدوية بفاصلة',
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: CustomTextFieldType.text,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _DialogFooter(
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

class _DialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _DialogHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(10),
            child: const Icon(Icons.close, color: Color(0xFFE83E8C)),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              customText(
                text: 'إضافة مريض جديد',
                size: responsiveSize(context, 0.012, min: 18, max: 22),
                color: const Color(0xFF271648),
                bold: true,
                isCenter: false,
              ),
              customText(
                text: 'أدخل البيانات الأساسية والسريرية للمريض',
                size: responsiveSize(context, 0.0075, min: 12, max: 14),
                color: const Color(0xFF7A7890),
                bold: true,
                isCenter: false,
              ),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            backgroundColor: Color(0xFFFFEAF4),
            child: Icon(Icons.person_add_alt_1, color: Color(0xFFE83E8C)),
          ),
        ],
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DialogSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.012, min: 14, max: 18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFFEAF4),
                child: Icon(icon, color: const Color(0xFFE83E8C), size: 20),
              ),
              const SizedBox(width: 10),
              customText(
                text: title,
                size: responsiveSize(context, 0.01, min: 15, max: 18),
                color: const Color(0xFF271648),
                bold: true,
                isCenter: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.end,
            children: children.map((child) {
              return SizedBox(
                width: w < 850 ? double.infinity : 300,
                child: child,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final String title;
  final Widget child;

  const _DialogField({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.0075, min: 12, max: 14),
          color: const Color(0xFF2D244C),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DialogDropdown extends StatelessWidget {
  final String title;
  final String? value;
  final String hint;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DialogDropdown({
    required this.title,
    required this.value,
    required this.hint,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogField(
      title: title,
      child: customDropdown(
        context: context,
        value: value,
        hint: hint,
        items: items,
        icon: icon,
        onChanged: onChanged,
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _DialogFooter({required this.onCancel, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Row(
        children: [
          _DialogButton(
            title: 'إلغاء',
            icon: Icons.close,
            isPrimary: false,
            onTap: onCancel,
          ),
          const SizedBox(width: 12),
          _DialogButton(
            title: 'حفظ المريض',
            icon: Icons.check,
            isPrimary: true,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _DialogButton({
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFE83E8C) : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isPrimary ? const Color(0xFFE83E8C) : Colors.grey.shade300,
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
              color: isPrimary ? Colors.white : const Color(0xFFE83E8C),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class NewPatientData {
  final String name;
  final int age;
  final String phone;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String registrationDate;
  final String comorbidities;
  final String bmi;
  final String familyHistory;
  final String menopausalStatus;
  final String diagnosisDate;
  final String stageAtDiagnosis;
  final String diseaseStatus;
  final String tumorBiology;
  final String surgery;
  final String chemotherapy;
  final String radiotherapy;
  final String hormonalTherapy;
  final String targetedTherapy;
  final String immunotherapy;
  final List<String> drugs;

  const NewPatientData({
    required this.name,
    required this.age,
    required this.phone,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.registrationDate,
    required this.comorbidities,
    required this.bmi,
    required this.familyHistory,
    required this.menopausalStatus,
    required this.diagnosisDate,
    required this.stageAtDiagnosis,
    required this.diseaseStatus,
    required this.tumorBiology,
    required this.surgery,
    required this.chemotherapy,
    required this.radiotherapy,
    required this.hormonalTherapy,
    required this.targetedTherapy,
    required this.immunotherapy,
    required this.drugs,
  });
}
