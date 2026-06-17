import 'dart:async';
import 'dart:typed_data';
import 'package:bahya_website/data/api/models/patient_model.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/admin_widgets/custom_date_picker.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_dropDown.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:bahya_website/bloc/cubit/patients_cubit.dart';
import 'package:bahya_website/bloc/states/patients_state.dart';
import 'package:bahya_website/screens/patient_clinical_details.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../helper/widgets/patients_info/patients_info_actions.dart';
part '../helper/widgets/patients_info/patients_info_cards.dart';
part '../helper/widgets/patients_info/patients_info_pagination.dart';
part '../helper/widgets/patients_info/add_patient_dialog_components.dart';
part '../helper/widgets/patients_info/add_patient_dialog.dart';
part '../helper/widgets/patients_info/add_patient_data.dart';

enum _PatientsSortOption {
  newest('تاريخ التسجيل الأحدث', 'createdAt', 'desc'),
  oldest('تاريخ التسجيل الأقدم', 'createdAt', 'asc'),
  nameAsc('الاسم من أ إلى ي', 'fullName', 'asc'),
  nameDesc('الاسم من ي إلى أ', 'fullName', 'desc'),
  ageAsc('العمر الأصغر', 'dateOfBirth', 'desc'),
  ageDesc('العمر الأكبر', 'dateOfBirth', 'asc');

  final String label;
  final String apiField;
  final String apiOrder;

  const _PatientsSortOption(this.label, this.apiField, this.apiOrder);
}

class PatientInfo extends StatefulWidget {
  const PatientInfo({super.key});

  @override
  State<PatientInfo> createState() => _PatientInfoState();
}

class _PatientInfoState extends State<PatientInfo> {
  final TextEditingController searchController = TextEditingController();
  late final PatientsCubit patientsCubit;
  Timer? searchDebounce;

  String searchText = '';

  String? selectedDiseaseStatus;
  String? selectedTumorBiology;
  String? selectedSurgery;
  String? selectedChemotherapy;
  String? selectedRadiotherapy;
  String? selectedHormonalTherapy;
  String? selectedTargetedTherapy;
  String? selectedImmunotherapy;
  _PatientsSortOption selectedSort = _PatientsSortOption.newest;
  int selectedPageSize = 20;

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
  void initState() {
    super.initState();
    patientsCubit = PatientsCubit()..loadPatients(pageSize: selectedPageSize);
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    patientsCubit.close();
    searchController.dispose();
    super.dispose();
  }

  Future<void> exportPatientsToExcel() async {
    final currentPatients = patientsCubit.state.patients;
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

    for (final patient in currentPatients) {
      sheet.appendRow([
        TextCellValue(patient.displayCrn),
        TextCellValue(patient.fullName),
        TextCellValue(patient.age.toString()),
        TextCellValue(patient.displayRegistrationDate),
        TextCellValue(patient.diseaseStatus ?? ''),
        TextCellValue(patient.tumorBiology ?? ''),
        TextCellValue(patient.surgery ?? ''),
        TextCellValue(patient.chemotherapy ?? ''),
        TextCellValue(_yesNoFromBool(patient.radiotherapy)),
        TextCellValue(_yesNoFromBool(patient.hormonalTherapy)),
        TextCellValue(_yesNoFromBool(patient.targetedTherapy)),
        TextCellValue(_yesNoFromBool(patient.immunotherapy)),
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
    _loadPatients();
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

  void onSearchChanged(String? value) {
    setState(() => searchText = value ?? '');
    searchDebounce?.cancel();
    searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _loadPatients(page: 1),
    );
  }

  void _loadPatients({int? page, int? pageSize}) {
    final nextPageSize = pageSize ?? selectedPageSize;
    if (nextPageSize != selectedPageSize) {
      selectedPageSize = nextPageSize;
    }

    patientsCubit.loadPatients(
      search: searchText,
      diseaseStatus: _toPatientApiValue(selectedDiseaseStatus),
      tumorBiology: _toPatientApiValue(selectedTumorBiology),
      surgery: _toPatientApiValue(selectedSurgery),
      chemotherapy: _toPatientApiValue(selectedChemotherapy),
      radiotherapy: _yesNoToBool(selectedRadiotherapy),
      hormonalTherapy: _yesNoToBool(selectedHormonalTherapy),
      targetedTherapy: _yesNoToBool(selectedTargetedTherapy),
      immunotherapy: _yesNoToBool(selectedImmunotherapy),
      sortBy: selectedSort.apiField,
      sortOrder: selectedSort.apiOrder,
      page: page ?? 1,
      pageSize: selectedPageSize,
    );
  }

  void _onSortChanged(_PatientsSortOption? value) {
    if (value == null || value == selectedSort) return;
    setState(() => selectedSort = value);
    _loadPatients(page: 1);
  }

  void _goToPage(int page) {
    final total = patientsCubit.state.total;
    final totalPages = total <= 0 ? 1 : (total / selectedPageSize).ceil();
    final nextPage = page.clamp(1, totalPages).toInt();
    if (nextPage == patientsCubit.state.page) return;
    _loadPatients(page: nextPage);
  }

  void _onPageSizeChanged(int? value) {
    if (value == null || value == selectedPageSize) return;
    setState(() => selectedPageSize = value);
    _loadPatients(page: 1, pageSize: value);
  }

  Future<void> openPatientDetails(PatientModel patient) async {
    final detailedPatient = await patientsCubit.loadPatientDetails(patient.id);
    if (!mounted) return;
    if (detailedPatient == null) {
      customSnackBar(
        context: context,
        message: patientsCubit.state.errorMessage ?? 'Failed to load patient',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientClinicalDetails(
          patient: buildClinicalPatient(detailedPatient),
        ),
      ),
    );
  }
Future<void> openPatientEditDialog(PatientModel patient) async {
    final detailedPatient = await patientsCubit.loadPatientDetails(patient.id);

    if (!mounted) return;

    if (detailedPatient == null) {
      customSnackBar(
        context: context,
        message: patientsCubit.state.errorMessage ?? 'Failed to load patient',
      );
      return;
    }

    final updated = await _showEditPatientClinicalDialog(
      context: context,
      patient: detailedPatient,
    );

    if (updated == true) {
      _loadPatients(page: patientsCubit.state.page);

      if (!mounted) return;

      customSnackBar(
        context: context,
        message: 'تم تعديل البيانات الطبية بنجاح',
      );
    }
  }

  Future<bool?> _showEditPatientClinicalDialog({
    required BuildContext context,
    required PatientModel patient,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit patient clinical data',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _EditPatientClinicalDialog(
          patient: patient,
          diseaseStatusOptions: diseaseStatusOptions,
          tumorBiologyOptions: tumorBiologyOptions,
          surgeryOptions: surgeryOptions,
          chemotherapyOptions: chemotherapyOptions,
          yesNoOptions: yesNoOptions,
          toApiValue: _toPatientApiValue,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.90, end: 1).animate(curvedAnimation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          ),
        );
      },
    );
  }
  ClinicalPatient buildClinicalPatient(PatientModel patient) {
    return ClinicalPatient(
      id: patient.id,
      fileNumber: patient.displayCrn,
      name: patient.fullName,
      age: patient.age,
      phone: patient.phone,
      emergencyContactName: patient.emergencyContactName ?? '',
      emergencyContactPhone: patient.emergencyContactPhone ?? '',
      registrationDate: patient.displayRegistrationDate,
      comorbidities: patient.comorbidities.join(', '),
      bmi: patient.bmi?.toString() ?? '',
      familyHistory: patient.familyHistory,
      menopausalStatus: readablePatientValue(patient.menopausalStatus),
      diagnosisDate: patient.displayDateOfDiagnosis,
      stageAtDiagnosis: readablePatientValue(patient.stageAtDiagnosis),
      diseaseStatus: readablePatientValue(patient.diseaseStatus),
      tumorBiology: readablePatientValue(patient.tumorBiology),
      surgery: readablePatientValue(patient.surgery),
      chemotherapy: readablePatientValue(patient.chemotherapy),
      radiotherapy: _yesNoFromBool(patient.radiotherapy),
      hormonalTherapy: _yesNoFromBool(patient.hormonalTherapy),
      targetedTherapy: _yesNoFromBool(patient.targetedTherapy),
      immunotherapy: _yesNoFromBool(patient.immunotherapy),
      drugs: patient.drugs,
      assessments: patient.latestAssessments
          .map(
            (assessment) => PatientAssessment(
              formName: assessment.templateKey,
              submitDate: formatPatientDate(assessment.createdAt),
              score: assessment.score,
            ),
          )
          .toList(),
    );
  }

  bool? _yesNoToBool(String? value) {
    if (value == 'Yes') return true;
    if (value == 'No') return false;
    return null;
  }

  String _yesNoFromBool(bool? value) {
    if (value == null) return '';
    return value ? 'Yes' : 'No';
  }

  String? _toPatientApiValue(String? value) {
    switch (value) {
      case 'Newly diagnosed':
        return 'NEWLY_DIAGNOSED';
      case 'Active treatment':
        return 'ACTIVE_TREATMENT';
      case 'Follow-up':
        return 'FOLLOW_UP';
      case 'Recurrence':
        return 'RECURRENCE';
      case 'Metastatic':
        return 'METASTATIC';
      case 'Luminal A':
        return 'LUMINAL_A';
      case 'Luminal B':
        return 'LUMINAL_B';
      case 'HER2-enriched':
        return 'HER2_ENRICHED';
      case 'TNBC':
        return 'TNBC';
      case 'None':
        return 'NONE';
      case 'Breast Conservative surgery':
        return 'BREAST_CONSERVATIVE';
      case 'Mastectomy':
        return 'MASTECTOMY';
      case 'No':
        return 'NO';
      case 'Neoadjuvant':
        return 'NEOADJUVANT';
      case 'Adjuvant':
        return 'ADJUVANT';
      default:
        return value;
    }
  }

  int _gridCount(double w) {
    if (w >= 1350) return 3;
    if (w >= 900) return 2;
    return 1;
  }

double _gridExtent(BuildContext context) {
    final w = getScreenWidth(context);

    if (w >= 1350) {
      return responsiveHeight(context, 0.47, min: 420, max: 480);
    }

    if (w >= 900) {
      return responsiveHeight(context, 0.47, min: 400, max: 470);
    }

    return responsiveHeight(context, 0.56, min: 470, max: 560);
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
          onSave: (patient) async {
            final createdPatient = await patientsCubit.createPatient(
              patient.toApiBody(_toPatientApiValue),
            );
            if (!context.mounted) return false;

            if (createdPatient == null) {
              customSnackBar(
                context: context,
                message:
                    patientsCubit.state.errorMessage ??
                    'Failed to create patient',
              );
              return false;
            }

            customSnackBar(context: context, message: 'تم إضافة المريض بنجاح');
            _loadPatients();
            return true;
          },
        ),
      );
    }

    return BlocProvider.value(
      value: patientsCubit,
      child: ValueListenableBuilder<Locale>(
        valueListenable: AppLanguageController.localeNotifier,
        builder: (context, locale, _) {
          final isEnglish = locale.languageCode == 'en';

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
            body: Directionality(
              textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(
                      context,
                      0.025,
                      min: 16,
                      max: 42,
                    ),
                    vertical: responsiveHeight(
                      context,
                      0.035,
                      min: 20,
                      max: 38,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopActionsBar(
                        searchController: searchController,
                        activeFiltersCount: activeFiltersCount,
                        onSearchChanged: onSearchChanged,
                        onReset: resetFilters,
                        onExport: exportPatientsToExcel,
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.025,
                          min: 18,
                          max: 28,
                        ),
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
                          _loadPatients();
                        },
                        onTumorBiologyChanged: (value) {
                          setState(() => selectedTumorBiology = value);
                          _loadPatients();
                        },
                        onSurgeryChanged: (value) {
                          setState(() => selectedSurgery = value);
                          _loadPatients();
                        },
                        onChemotherapyChanged: (value) {
                          setState(() => selectedChemotherapy = value);
                          _loadPatients();
                        },
                        onRadiotherapyChanged: (value) {
                          setState(() => selectedRadiotherapy = value);
                          _loadPatients();
                        },
                        onHormonalTherapyChanged: (value) {
                          setState(() => selectedHormonalTherapy = value);
                          _loadPatients();
                        },
                        onTargetedTherapyChanged: (value) {
                          setState(() => selectedTargetedTherapy = value);
                          _loadPatients();
                        },
                        onImmunotherapyChanged: (value) {
                          setState(() => selectedImmunotherapy = value);
                          _loadPatients();
                        },
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.03,
                          min: 20,
                          max: 34,
                        ),
                      ),
                      BlocBuilder<PatientsCubit, PatientsState>(
                        builder: (context, state) {
                          if (state.isLoading && state.patients.isEmpty) {
                            return SizedBox(
                              height: responsiveHeight(
                                context,
                                0.35,
                                min: 260,
                                max: 360,
                              ),
                              child: customLoading(),
                            );
                          }

                          if (state.hasError && state.patients.isEmpty) {
                            return _PatientsStateMessage(
                              icon: Icons.error_outline,
                              title:
                                  state.errorMessage ??
                                  'Failed to load patients',
                              actionText: 'Retry',
                              onAction: _loadPatients,
                            );
                          }

                          if (state.patients.isEmpty) {
                            return _PatientsStateMessage(
                              icon: Icons.person_search_outlined,
                              title: 'No patients found',
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ResultsHeader(
                                total: state.total,
                                selectedSort: selectedSort,
                                onSortChanged: _onSortChanged,
                              ),
                              SizedBox(
                                height: responsiveHeight(
                                  context,
                                  0.02,
                                  min: 14,
                                  max: 24,
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  final slide = Tween<Offset>(
                                    begin: const Offset(0, 0.025),
                                    end: Offset.zero,
                                  ).animate(animation);

                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: slide,
                                      child: child,
                                    ),
                                  );
                                },
                                child: w < 700
                                    ? _MobilePatientsListForInfo(
                                        key: ValueKey(
                                          'mobile_${searchText}_${selectedSort.name}_${state.page}_${state.patients.map((p) => p.id).join('_')}',
                                        ),
                                        patientsList: state.patients,
                                        loadingPatientId: state.loadingPatientId,
                                        onPatientTap: openPatientDetails,
                                        onPatientEdit: openPatientEditDialog,
                                      )
                                    : _PatientsGrid(
                                        key: ValueKey(
                                          'grid_${searchText}_${selectedSort.name}_${state.page}_${state.patients.map((p) => p.id).join('_')}',
                                        ),
                                        patientsList: state.patients,
                                        crossAxisCount: _gridCount(w),
                                        mainAxisExtent: _gridExtent(context),
                                        loadingPatientId: state.loadingPatientId,
                                        onPatientTap: openPatientDetails,
                                        onPatientEdit: openPatientEditDialog,
                                      ),
                              ),
                              SizedBox(
                                height: responsiveHeight(
                                  context,
                                  0.03,
                                  min: 20,
                                  max: 34,
                                ),
                              ),
                              _PaginationBar(
                                page: state.page,
                                pageSize: state.pageSize,
                                total: state.total,
                                onPrevious: () => _goToPage(state.page - 1),
                                onNext: () => _goToPage(state.page + 1),
                                onPageSizeChanged: _onPageSizeChanged,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PatientsStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _PatientsStateMessage({
    required this.icon,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.018, min: 18, max: 28),
        vertical: responsiveHeight(context, 0.08, min: 70, max: 120),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE83E8C),
            size: responsiveSize(context, 0.03, min: 34, max: 48),
          ),
          const SizedBox(height: 14),
          customText(
            text: title,
            size: responsiveSize(context, 0.01, min: 14, max: 18),
            color: const Color(0xFF271648),
            bold: true,
            maxLines: 3,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 16),
            _ActionButton(
              title: actionText!,
              icon: Icons.refresh,
              onTap: onAction!,
              isPrimary: false,
            ),
          ],
        ],
      ),
    );
  }
}



class _MobilePatientsListForInfo extends StatelessWidget {
  final List<PatientModel> patientsList;
  final String? loadingPatientId;
  final ValueChanged<PatientModel> onPatientTap;
  final ValueChanged<PatientModel> onPatientEdit;

  const _MobilePatientsListForInfo({
    super.key,
    required this.patientsList,
    required this.loadingPatientId,
    required this.onPatientTap,
    required this.onPatientEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: patientsList.map((patient) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: responsiveHeight(context, 0.018, min: 14, max: 18),
          ),
          child: _MobilePatientClinicalCard(
            patient: patient,
            isLoading: loadingPatientId == patient.id,
            onTap: () => onPatientTap(patient),
            onEdit: () => onPatientEdit(patient),
          ),
        );
      }).toList(),
    );
  }
}

class _MobilePatientClinicalCard extends StatelessWidget {
  final PatientModel patient;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _MobilePatientClinicalCard({
    required this.patient,
    required this.isLoading,
    required this.onTap,
    required this.onEdit,
  });

  String _safeValue(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final diseaseStatus = readablePatientValue(patient.diseaseStatus);
    final tumorBiology = readablePatientValue(patient.tumorBiology);
    final surgery = readablePatientValue(patient.surgery);
    final chemo = readablePatientValue(patient.chemotherapy);

    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: isLoading ? 0.985 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              responsiveSize(context, 0.018, min: 16, max: 20),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD3E8)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE83E8C).withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedOpacity(
                  opacity: isLoading ? 0.30 : 1,
                  duration: const Duration(milliseconds: 220),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE83E8C), Color(0xFFFF7BB0)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE83E8C).withOpacity(0.18),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: customText(
                                text: patient.fullName.trim().isEmpty
                                    ? 'P'
                                    : patient.fullName.trim()[0].toUpperCase(),
                                size: 22,
                                color: Colors.white,
                                bold: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                customText(
                                  text: _safeValue(patient.fullName),
                                  size: responsiveSize(context, 0.012, min: 17, max: 20),
                                  color: const Color(0xFF271648),
                                  bold: true,
                                  isCenter: false,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _MobilePatientChip(
                                      icon: Icons.badge_outlined,
                                      text: _safeValue(patient.displayCrn),
                                    ),
                                    _MobilePatientChip(
                                      icon: Icons.event_available_outlined,
                                      text: _safeValue(patient.displayRegistrationDate),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: const Color(0xFFE83E8C).withOpacity(0.75),
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: const Color(0xFFFFD6EA),
                      ),
                      const SizedBox(height: 14),
                      _MobilePatientInfoLine(
                        icon: Icons.assignment_outlined,
                        label: 'الحالة',
                        value: diseaseStatus,
                      ),
                      const SizedBox(height: 10),
                      _MobilePatientInfoLine(
                        icon: Icons.biotech_outlined,
                        label: 'البيولوجيا الورمية',
                        value: tumorBiology,
                      ),
                      const SizedBox(height: 10),
                      _MobilePatientInfoLine(
                        icon: Icons.medical_services_outlined,
                        label: 'الجراحة',
                        value: surgery,
                      ),
                      const SizedBox(height: 10),
                      _MobilePatientInfoLine(
                        icon: Icons.science_outlined,
                        label: 'العلاج الكيميائي',
                        value: chemo,
                      ),
                      const SizedBox(height: 16),
                      _MobileEditClinicalButton(
                        isLoading: isLoading,
                        onTap: onEdit,
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Transform.scale(
                          scale: 0.65,
                          child: customLoading(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobilePatientChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MobilePatientChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD6EA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFE83E8C), size: 15),
          const SizedBox(width: 6),
          customText(
            text: text,
            size: 11,
            color: const Color(0xFF7A104F),
            bold: true,
            isCenter: false,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _MobilePatientInfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MobilePatientInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  String get cleanValue {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0EF)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE83E8C), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: customText(
              text: label,
              size: 12,
              color: const Color(0xFF7A7890),
              bold: true,
              isCenter: false,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: customText(
              text: cleanValue,
              size: 12,
              color: const Color(0xFF271648),
              bold: true,
              isCenter: false,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileEditClinicalButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _MobileEditClinicalButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_MobileEditClinicalButton> createState() =>
      _MobileEditClinicalButtonState();
}

class _MobileEditClinicalButtonState extends State<_MobileEditClinicalButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isLoading
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            gradient: hover
                ? const LinearGradient(
                    colors: [Color(0xFFE83E8C), Color(0xFFFF7BB0)],
                  )
                : null,
            color: hover ? null : const Color(0xFFFFEAF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hover
                  ? const Color(0xFFE83E8C)
                  : const Color(0xFFFFC6DD),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: hover ? Colors.white : const Color(0xFFE83E8C),
                size: 20,
              ),
              const SizedBox(width: 8),
              customText(
                text: 'تعديل البيانات الطبية',
                size: 13,
                color: hover ? Colors.white : const Color(0xFFE83E8C),
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
              color: const Color(0xFF7A004C).withOpacity(0.18),
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
                        title: 'Clinical Data',
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
                        title: 'Medical History',
                        icon: Icons.history_edu_rounded,
                        children: [
                          _EditFieldWrapper(
                            title: 'Family History',
                            fullWidth: true,
                            child: CustomFormTextField(
                              controller: familyHistoryController,
                              hintText: 'Family History',
                              keyboardType: CustomTextFieldType.text,
                              textDirection: Directionality.of(context),
                              isRequired: false,
                              bordered: true,
                              autovalidateMode: AutovalidateMode.disabled,
                            ),
                          ),
                          _EditFieldWrapper(
                            title: 'Drugs',
                            fullWidth: true,
                            child: CustomFormTextField(
                              controller: drugsController,
                              hintText: 'اكتب الأدوية وافصل بينهم بفاصلة',
                              keyboardType: CustomTextFieldType.text,
                              textDirection: Directionality.of(context),
                              isRequired: false,
                              bordered: true,
                              autovalidateMode: AutovalidateMode.disabled,
                            ),
                          ),
                          _EditFieldWrapper(
                            title: 'Notes',
                            fullWidth: true,
                            child: CustomFormTextField(
                              controller: notesController,
                              hintText: 'Notes',
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
      padding: EdgeInsets.all(
        responsiveSize(context, 0.016, min: 16, max: 24),
      ),
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
              color: Colors.white.withOpacity(0.18),
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
              crossAxisAlignment:
                  isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
                  color: Colors.white.withOpacity(0.86),
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
                color: Colors.white.withOpacity(0.18),
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

class _PatientReadonlySummary extends StatelessWidget {
  final PatientModel patient;

  const _PatientReadonlySummary({required this.patient});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryInfoItem(
        icon: Icons.badge_outlined,
        label: 'رقم الملف',
        value: patient.displayCrn,
      ),
      _SummaryInfoItem(
        icon: Icons.phone_outlined,
        label: 'الهاتف',
        value: patient.phone,
      ),
      _SummaryInfoItem(
        icon: Icons.cake_outlined,
        label: 'العمر',
        value: patient.age.toString(),
      ),
      _SummaryInfoItem(
        icon: Icons.event_available_outlined,
        label: 'تاريخ التسجيل',
        value: patient.displayRegistrationDate,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD6EA)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) => item).toList(),
      ),
    );
  }
}

class _SummaryInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cleanValue = value.trim().isEmpty ? '-' : value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1E6EE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFE83E8C), size: 17),
          const SizedBox(width: 7),
          customText(
            text: '$label: ',
            size: 12,
            color: const Color(0xFF7A7890),
            bold: true,
            isCenter: false,
          ),
          customText(
            text: cleanValue,
            size: 12,
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
          ),
        ],
      ),
    );
  }
}

class _EditDialogSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_EditFieldWrapper> children;

  const _EditDialogSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = getScreenWidth(context) < 760;
    final fieldWidth = isSmall ? double.infinity : 350.0;
    final isEnglish = Directionality.of(context) == TextDirection.ltr;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsiveSize(context, 0.014, min: 14, max: 20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD6EA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE83E8C).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFFEAF4),
                child: Icon(icon, color: const Color(0xFFE83E8C), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: customText(
                  text: title,
                  size: responsiveSize(context, 0.010, min: 15, max: 18),
                  color: const Color(0xFF271648),
                  bold: true,
                  isEnglish: true,
                  isCenter: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: children.map((item) {
              return SizedBox(
                width: item.fullWidth ? double.infinity : fieldWidth,
                child: item,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EditFieldWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final bool fullWidth;

  const _EditFieldWrapper({
    required this.title,
    required this.child,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = Directionality.of(context) == TextDirection.ltr;

    return Column(
      crossAxisAlignment:
          isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.0075, min: 12, max: 14),
          color: const Color(0xFF2D244C),
          bold: true,
          isCenter: false,
          isEnglish: isEnglish,
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _EditPatientDialogFooter extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _EditPatientDialogFooter({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isPhone = getScreenWidth(context) < 620;
    final saveButton = _EditPatientDialogButton(
      title: isSaving ? 'جاري الحفظ...' : 'حفظ التعديلات',
      icon: Icons.check_rounded,
      isPrimary: true,
      isLoading: isSaving,
      onTap: isSaving ? null : onSave,
    );
    final cancelButton = _EditPatientDialogButton(
      title: 'إلغاء',
      icon: Icons.close_rounded,
      isPrimary: false,
      onTap: isSaving ? null : onCancel,
    );

    return Container(
      padding: EdgeInsets.all(
        responsiveSize(context, 0.014, min: 14, max: 18),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFFFD6EA)),
        ),
      ),
      child: isPhone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                saveButton,
                const SizedBox(height: 10),
                cancelButton,
              ],
            )
          : Row(
              children: [
                Expanded(child: cancelButton),
                const SizedBox(width: 12),
                Expanded(child: saveButton),
              ],
            ),
    );
  }
}

class _EditPatientDialogButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback? onTap;

  const _EditPatientDialogButton({
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? const Color(0xFFE83E8C) : Colors.white;
    final textColor = isPrimary ? Colors.white : const Color(0xFFE83E8C);
    final borderColor =
        isPrimary ? const Color(0xFFE83E8C) : const Color(0xFFFF9BD0);

    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: onTap == null ? color.withOpacity(0.45) : color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: onTap == null ? borderColor.withOpacity(0.45) : borderColor,
            ),
            boxShadow: isPrimary && onTap != null
                ? [
                    BoxShadow(
                      color: const Color(0xFFE83E8C).withOpacity(0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(width: 22, height: 22, child: customLoading())
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      customText(
                        text: title,
                        size: 14,
                        color: textColor,
                        bold: true,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
