import 'package:bahya_app/data/models/service_models.dart';

class ServiceAdminState {
  final bool isLoading;
  final bool isSaving;
  final List<ServiceCategoryModel> categories;
  final List<PatientServiceModel> services;
  final List<ServiceRequestModel> requests;
  final Map<String, dynamic> summary;
  final ServiceCategoryModel? selectedCategory;
  final String? error;

  const ServiceAdminState({
    this.isLoading = false,
    this.isSaving = false,
    this.categories = const [],
    this.services = const [],
    this.requests = const [],
    this.summary = const {},
    this.selectedCategory,
    this.error,
  });

  ServiceAdminState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<ServiceCategoryModel>? categories,
    List<PatientServiceModel>? services,
    List<ServiceRequestModel>? requests,
    Map<String, dynamic>? summary,
    ServiceCategoryModel? selectedCategory,
    bool clearSelectedCategory = false,
    String? error,
    bool clearError = false,
  }) {
    return ServiceAdminState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      categories: categories ?? this.categories,
      services: services ?? this.services,
      requests: requests ?? this.requests,
      summary: summary ?? this.summary,
      selectedCategory: clearSelectedCategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      error: clearError ? null : error ?? this.error,
    );
  }
}
