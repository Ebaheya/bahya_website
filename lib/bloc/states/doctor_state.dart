import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';

class DoctorFormsState {
  final bool isLoadingForms;
  final bool isLoadingFormDetails;
  final bool isSearchingPatients;
  final bool isSubmittingAssessment;
  final bool isUpdatingForm;

  final List<FormModel> forms;
  final FormModel? selectedForm;

  final List<OptionUserModel> patientOptions;
  final OptionUserModel? selectedPatient;

  final String selectedStatus;

  final List<String> completedPatientIds;
  final String? patientAlreadyFilledMessage;

  final Map<String, dynamic>? createdAssessment;
  final String? error;

  const DoctorFormsState({
    this.isLoadingForms = false,
    this.isLoadingFormDetails = false,
    this.isSearchingPatients = false,
    this.isSubmittingAssessment = false,
    this.isUpdatingForm = false,
    this.forms = const [],
    this.selectedForm,
    this.patientOptions = const [],
    this.selectedPatient,
    this.selectedStatus = "NORMAL",
    this.completedPatientIds = const [],
    this.patientAlreadyFilledMessage,
    this.createdAssessment,
    this.error,
  });

  DoctorFormsState copyWith({
    bool? isLoadingForms,
    bool? isLoadingFormDetails,
    bool? isSearchingPatients,
    bool? isSubmittingAssessment,
    bool? isUpdatingForm,
    List<FormModel>? forms,
    FormModel? selectedForm,
    List<OptionUserModel>? patientOptions,
    OptionUserModel? selectedPatient,
    String? selectedStatus,
    List<String>? completedPatientIds,
    String? patientAlreadyFilledMessage,
    Map<String, dynamic>? createdAssessment,
    String? error,
    bool clearSelectedForm = false,
    bool clearSelectedPatient = false,
    bool clearCreatedAssessment = false,
    bool clearPatientAlreadyFilledMessage = false,
    bool clearError = false,
  }) {
    return DoctorFormsState(
      isLoadingForms: isLoadingForms ?? this.isLoadingForms,
      isLoadingFormDetails: isLoadingFormDetails ?? this.isLoadingFormDetails,
      isSearchingPatients: isSearchingPatients ?? this.isSearchingPatients,
      isSubmittingAssessment:
          isSubmittingAssessment ?? this.isSubmittingAssessment,
      isUpdatingForm: isUpdatingForm ?? this.isUpdatingForm,
      forms: forms ?? this.forms,
      selectedForm: clearSelectedForm
          ? null
          : selectedForm ?? this.selectedForm,
      patientOptions: patientOptions ?? this.patientOptions,
      selectedPatient: clearSelectedPatient
          ? null
          : selectedPatient ?? this.selectedPatient,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      completedPatientIds: completedPatientIds ?? this.completedPatientIds,
      patientAlreadyFilledMessage: clearPatientAlreadyFilledMessage
          ? null
          : patientAlreadyFilledMessage ?? this.patientAlreadyFilledMessage,
      createdAssessment: clearCreatedAssessment
          ? null
          : createdAssessment ?? this.createdAssessment,
      error: clearError ? null : error ?? this.error,
    );
  }
}
