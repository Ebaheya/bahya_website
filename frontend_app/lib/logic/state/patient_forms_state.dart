import 'package:bahya_app/data/models/patient_forms_models.dart';

class PatientFormsState {
  final bool isLoading;
  final bool isLoadingDetails;
  final bool isSubmitting;
  final bool hasLoaded;

  final List<MyAssignmentModel> assignments;
  final AssignmentDetailsModel? selectedAssignment;
  final SubmitFormResponseModel? submitResponse;

  final String? error;

  const PatientFormsState({
    this.isLoading = false,
    this.isLoadingDetails = false,
    this.isSubmitting = false,
    this.hasLoaded = false,
    this.assignments = const [],
    this.selectedAssignment,
    this.submitResponse,
    this.error,
  });

  PatientFormsState copyWith({
    bool? isLoading,
    bool? isLoadingDetails,
    bool? isSubmitting,
    bool? hasLoaded,
    List<MyAssignmentModel>? assignments,
    AssignmentDetailsModel? selectedAssignment,
    SubmitFormResponseModel? submitResponse,
    String? error,
    bool clearError = false,
    bool clearSubmitResponse = false,
  }) {
    return PatientFormsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      assignments: assignments ?? this.assignments,
      selectedAssignment: selectedAssignment ?? this.selectedAssignment,
      submitResponse: clearSubmitResponse
          ? null
          : submitResponse ?? this.submitResponse,
      error: clearError ? null : error ?? this.error,
    );
  }

  PatientFormsState clearError() {
    return copyWith(clearError: true);
  }
}
