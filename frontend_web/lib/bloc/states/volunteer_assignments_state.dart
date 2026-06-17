class VolunteerAssignmentsState {
  final bool isLoading;
  final bool isLoadingDetails;
  final bool isSubmitting;
  final bool hasLoaded;
  final List<Map<String, dynamic>> assignments;
  final Map<String, dynamic>? selectedAssignment;
  final Map<String, dynamic>? selectedAssignmentDetails;
  final String? error;

  const VolunteerAssignmentsState({
    this.isLoading = false,
    this.isLoadingDetails = false,
    this.isSubmitting = false,
    this.hasLoaded = false,
    this.assignments = const [],
    this.selectedAssignment,
    this.selectedAssignmentDetails,
    this.error,
  });

  VolunteerAssignmentsState copyWith({
    bool? isLoading,
    bool? isLoadingDetails,
    bool? isSubmitting,
    bool? hasLoaded,
    List<Map<String, dynamic>>? assignments,
    Map<String, dynamic>? selectedAssignment,
    Map<String, dynamic>? selectedAssignmentDetails,
    String? error,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return VolunteerAssignmentsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      assignments: assignments ?? this.assignments,
      selectedAssignment: clearSelected
          ? null
          : selectedAssignment ?? this.selectedAssignment,
      selectedAssignmentDetails: clearSelected
          ? null
          : selectedAssignmentDetails ?? this.selectedAssignmentDetails,
      error: clearError ? null : error ?? this.error,
    );
  }
}
