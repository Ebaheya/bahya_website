import 'dart:async';
import 'dart:typed_data';

import 'package:bahya_website/bloc/cubit/patients_cubit.dart';
import 'package:bahya_website/bloc/states/patients_state.dart';
import 'package:bahya_website/data/api/models/patient_model.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/admin_widgets/custom_date_picker.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_date_picker.dart';
import 'package:bahya_website/helper/custom_dropdown.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/animated_home_background.dart';
import 'package:bahya_website/helper/widgets/doctor_page_header.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:bahya_website/screens/doctor/patient_clinical_details.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part '../../helper/widgets/patients_info/patients_info_actions.dart';
part '../../helper/widgets/patients_info/patients_info_cards.dart';
part '../../helper/widgets/patients_info/patients_info_pagination.dart';
part '../../helper/widgets/patients_info/add_patient_dialog_components.dart';
part '../../helper/widgets/patients_info/add_patient_dialog.dart';
part '../../helper/widgets/patients_info/add_patient_data.dart';
part '../../helper/widgets/patients_info/patient_card_components.dart';
part '../../helper/widgets/patients_info/patients_info_models.dart';
part '../../helper/widgets/patients_info/patients_info_helpers.dart';
part '../../helper/widgets/patients_info/patients_info_mobile_widgets.dart';
part '../../helper/widgets/patients_info/edit_patient_clinical_dialog.dart';
part '../../helper/widgets/patients_info/edit_patient_dialog_widgets.dart';
part '../../helper/widgets/patients_info/patients_info_screen_shell.dart';

class _PatientInfoState extends State<PatientInfo>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  late final PatientsCubit patientsCubit;
  late final AnimationController _pageController;
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
  int selectedPageSize = 6;

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
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    _pageController.dispose();
    patientsCubit.close();
    searchController.dispose();
    super.dispose();
  }

  Widget _animatedItem({required int index, required Widget child}) {
    final animation = CurvedAnimation(
      parent: _pageController,
      curve: Interval(
        (index * 0.10).clamp(0.0, 0.75),
        1,
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
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
      barrierColor: Colors.black.withValues(alpha: 0.35),
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
    final h = getScreenHeight(context);
    final isMobile = w < 650;

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
            backgroundColor: const Color(0xFFFDF7FB),
            body: AnimatedHomeBackground(
              child: Directionality(
                textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : w * 0.035,
                    vertical: h < 750 ? 18 : h * 0.035,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1360),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _animatedItem(
                            index: 0,
                            child: animatedPageHeader(
                              context: context,
                              title: 'جميع المرضى',
                              subtitle: 'إدارة بيانات المرضى والملفات الطبية',
                              icon: Icons.groups_rounded,
                              showBack: true,
                              onBackTap: () => context.go('/home'),
                            ),
                          ),
                          SizedBox(height: isMobile ? 18 : 24),
                          _animatedItem(
                            index: 1,
                            child: Center(
                              child: _CenteredAddPatientCard(
                                onTap: () => showAddPatientDialog(context),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 22 : 30),
                          _animatedItem(
                            index: 2,
                            child: _PatientsModernSection(
                              title: 'البحث والتصفية',
                              subtitle: 'ابحث عن مريض أو فلتر النتائج حسب الحالة الطبية',
                              icon: Icons.manage_search_rounded,
                              child: Column(
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
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 22 : 30),
                          _animatedItem(
                            index: 3,
                            child: _PatientsModernSection(
                              title: 'قائمة المرضى',
                              subtitle: 'عرض وتعديل البيانات الطبية المسجلة',
                              icon: Icons.people_alt_rounded,
                              child: BlocBuilder<PatientsCubit, PatientsState>(
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
                                                onPatientEdit:
                                                    openPatientEditDialog,
                                              )
                                            : _PatientsGrid(
                                                key: ValueKey(
                                                  'grid_${searchText}_${selectedSort.name}_${state.page}_${state.patients.map((p) => p.id).join('_')}',
                                                ),
                                                patientsList: state.patients,
                                                crossAxisCount: _gridCount(w),
                                                mainAxisExtent:
                                                    _gridExtent(context),
                                                loadingPatientId:
                                                    state.loadingPatientId,
                                                onPatientTap: openPatientDetails,
                                                onPatientEdit:
                                                    openPatientEditDialog,
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
                                        pageSize: 6,
                                        total: state.total,
                                        onPrevious: () => _goToPage(state.page - 1),
                                        onNext: () => _goToPage(state.page + 1),
                                    
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
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

class _CenteredAddPatientCard extends StatefulWidget {
  final VoidCallback onTap;

  const _CenteredAddPatientCard({required this.onTap});

  @override
  State<_CenteredAddPatientCard> createState() => _CenteredAddPatientCardState();
}

class _CenteredAddPatientCardState extends State<_CenteredAddPatientCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!isMobile) setState(() => _hover = false);
      },
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.020, min: 24, max: 30),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          width: isMobile ? double.infinity : 520,
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.020, min: 18, max: 28),
            vertical: responsiveHeight(context, 0.022, min: 18, max: 24),
          ),
          transform: Matrix4.identity()
            ..translate(0.0, _hover && !isMobile ? -5.0 : 0.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFEFBFD),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.020, min: 24, max: 30),
            ),
            border: Border.all(
              color: _hover
                  ? const Color(0xFFE7549B).withValues(alpha: 0.45)
                  : const Color(0xFFE7549B).withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF831843).withValues(
                  alpha: _hover ? 0.16 : 0.09,
                ),
                blurRadius: _hover ? 30 : 22,
                offset: Offset(0, _hover ? 14 : 9),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: responsiveSize(context, 0.052, min: 52, max: 62),
                height: responsiveSize(context, 0.052, min: 52, max: 62),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.016, min: 18, max: 22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE7549B).withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: responsiveSize(context, 0.026, min: 26, max: 32),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.022, min: 14, max: 20)),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: 'إضافة مريض جديد',
                      size: responsiveSize(context, 0.038, min: 16, max: 19),
                      color: const Color(0xFF14213D),
                      bold: true,
                      isCenter: false,
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: responsiveHeight(context, 0.006, min: 4, max: 7),
                    ),
                    customText(
                      text: 'إدخال بيانات مريض وملفه الطبي',
                      size: responsiveSize(context, 0.030, min: 12, max: 14),
                      color: Colors.grey.shade600,
                      isCenter: false,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add,
                color: const Color(0xFFE7549B),
                size: responsiveSize(context, 0.030, min: 30, max: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientsModernSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _PatientsModernSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_PatientsModernSection> createState() => _PatientsModernSectionState();
}

class _PatientsModernSectionState extends State<_PatientsModernSection> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!isMobile) setState(() => _hover = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        width: double.infinity,
        transform: Matrix4.identity()
          ..translate(0.0, _hover && !isMobile ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 26, max: 34),
          ),
          border: Border.all(
            color: _hover
                ? const Color(0xFFE7549B).withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14213D).withValues(
                alpha: _hover ? 0.14 : 0.08,
              ),
              blurRadius: _hover ? 34 : 24,
              offset: Offset(0, _hover ? 18 : 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 26, max: 34),
          ),
          child: Column(
            children: [
              _PatientsSectionHeader(
                title: widget.title,
                subtitle: widget.subtitle,
                icon: widget.icon,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  responsiveSize(context, 0.018, min: 16, max: 26),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientsSectionHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PatientsSectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<_PatientsSectionHeader> createState() => _PatientsSectionHeaderState();
}

class _PatientsSectionHeaderState extends State<_PatientsSectionHeader>
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
    final isMobile = getScreenWidth(context) < 650;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final value = _animation.value;

        return Container(
          height: isMobile ? 86 : 96,
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.020, min: 18, max: 28),
            vertical: responsiveHeight(context, 0.014, min: 14, max: 18),
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
                width: responsiveSize(context, 0.052, min: 46, max: 54),
                height: responsiveSize(context, 0.052, min: 46, max: 54),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.016, min: 15, max: 18),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: responsiveSize(context, 0.026, min: 24, max: 28),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.018, min: 12, max: 16)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(
                      text: widget.title,
                      size: responsiveSize(context, 0.042, min: 18, max: 20),
                      color: Colors.white,
                      bold: true,
                      isCenter: false,
                      maxLines: isMobile ? 2 : 1,
                    ),
                    SizedBox(
                      height: responsiveHeight(context, 0.005, min: 4, max: 6),
                    ),
                    customText(
                      text: widget.subtitle,
                      size: responsiveSize(context, 0.030, min: 12, max: 13),
                      color: Colors.white.withValues(alpha: 0.78),
                      isCenter: false,
                      maxLines: isMobile ? 2 : 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
