import 'package:bahya_app/data/models/service_models.dart';

class PatientServicesState {
  final bool isLoading;
  final bool hasLoaded;
  final bool isSubmitting;
  final List<PatientServiceModel> services;
  final List<ServiceCategoryModel> categories;
  final List<ServiceRequestModel> requests;
  final String? error;

  const PatientServicesState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.isSubmitting = false,
    this.services = const [],
    this.categories = const [],
    this.requests = const [],
    this.error,
  });

  PatientServicesState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    bool? isSubmitting,
    List<PatientServiceModel>? services,
    List<ServiceCategoryModel>? categories,
    List<ServiceRequestModel>? requests,
    String? error,
    bool clearError = false,
  }) {
    return PatientServicesState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      services: services ?? this.services,
      categories: categories ?? this.categories,
      requests: requests ?? this.requests,
      error: clearError ? null : error ?? this.error,
    );
  }

  PatientServicesState clearError() {
    return copyWith(clearError: true);
  }
}
