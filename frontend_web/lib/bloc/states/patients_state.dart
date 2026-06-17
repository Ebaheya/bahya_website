import 'package:bahya_website/data/api/models/patient_model.dart';

enum PatientsStatus { initial, loading, success, failure }

class PatientsState {
  final PatientsStatus status;
  final List<PatientModel> patients;
  final String? errorMessage;
  final int page;
  final int pageSize;
  final int total;
  final String? loadingPatientId;
  final bool isCreatingPatient;

  const PatientsState({
    this.status = PatientsStatus.initial,
    this.patients = const [],
    this.errorMessage,
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.loadingPatientId,
    this.isCreatingPatient = false,
  });

  bool get isLoading => status == PatientsStatus.loading;
  bool get hasError => status == PatientsStatus.failure;

  PatientsState copyWith({
    PatientsStatus? status,
    List<PatientModel>? patients,
    String? errorMessage,
    bool clearError = false,
    int? page,
    int? pageSize,
    int? total,
    String? loadingPatientId,
    bool clearLoadingPatient = false,
    bool? isCreatingPatient,
  }) {
    return PatientsState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      loadingPatientId: clearLoadingPatient
          ? null
          : loadingPatientId ?? this.loadingPatientId,
      isCreatingPatient: isCreatingPatient ?? this.isCreatingPatient,
    );
  }
}
