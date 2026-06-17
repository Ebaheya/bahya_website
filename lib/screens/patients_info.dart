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
part '../helper/widgets/patients_info/patient_card_components.dart';
part '../helper/widgets/patients_info/patients_info_models.dart';
part '../helper/widgets/patients_info/patients_info_helpers.dart';
part '../helper/widgets/patients_info/patients_info_mobile_widgets.dart';
part '../helper/widgets/patients_info/edit_patient_clinical_dialog.dart';
part '../helper/widgets/patients_info/edit_patient_dialog_widgets.dart';
part '../helper/widgets/patients_info/patients_info_screen_shell.dart';

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
                        activeFiltersCount: activePatientFiltersCount(
                          selectedDiseaseStatus,
                          selectedTumorBiology,
                          selectedSurgery,
                          selectedChemotherapy,
                          selectedRadiotherapy,
                          selectedHormonalTherapy,
                          selectedTargetedTherapy,
                          selectedImmunotherapy,
                        ),
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
                                        loadingPatientId:
                                            state.loadingPatientId,
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
                                        loadingPatientId:
                                            state.loadingPatientId,
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
