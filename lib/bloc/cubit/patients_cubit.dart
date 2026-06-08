import 'package:bahya_website/data/api/models/patient_model.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/bloc/states/patients_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientsCubit extends Cubit<PatientsState> {
  final AppRepository repository;

  PatientsCubit({AppRepository? repository})
    : repository = repository ?? AppRepository(),
      super(const PatientsState());

  Future<void> loadPatients({
    String? search,
    String? diseaseStatus,
    String? tumorBiology,
    String? surgery,
    String? chemotherapy,
    bool? radiotherapy,
    bool? hormonalTherapy,
    bool? targetedTherapy,
    bool? immunotherapy,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int pageSize = 20,
  }) async {
    emit(
      state.copyWith(
        status: PatientsStatus.loading,
        errorMessage: null,
        clearError: true,
        page: page,
        pageSize: pageSize,
      ),
    );

    try {
      final response = await repository.getPatients(
        search: search,
        diseaseStatus: diseaseStatus,
        tumorBiology: tumorBiology,
        surgery: surgery,
        chemotherapy: chemotherapy,
        radiotherapy: radiotherapy,
        hormonalTherapy: hormonalTherapy,
        targetedTherapy: targetedTherapy,
        immunotherapy: immunotherapy,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        pageSize: pageSize,
      );

      emit(
        state.copyWith(
          status: PatientsStatus.success,
          patients: response.data,
          page: response.page,
          pageSize: response.pageSize,
          total: response.total,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PatientsStatus.failure,
          errorMessage: _readableError(e),
        ),
      );
    }
  }

  Future<PatientModel?> loadPatientDetails(String patientId) async {
    emit(state.copyWith(loadingPatientId: patientId, clearError: true));

    try {
      final patient = await repository.getPatientDetails(patientId);
      emit(state.copyWith(clearLoadingPatient: true, clearError: true));
      return patient;
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: _readableError(e),
          clearLoadingPatient: true,
        ),
      );
      return null;
    }
  }

  Future<PatientModel?> createPatient(Map<String, dynamic> body) async {
    emit(
      state.copyWith(
        isCreatingPatient: true,
        errorMessage: null,
        clearError: true,
      ),
    );

    try {
      final patient = await repository.createPatient(body: body);
      emit(state.copyWith(isCreatingPatient: false, clearError: true));
      return patient;
    } catch (e) {
      emit(
        state.copyWith(
          isCreatingPatient: false,
          errorMessage: _readableError(e),
        ),
      );
      return null;
    }
  }

  String _readableError(Object error) {
    final text = error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Unexpected error : Exception: ', '')
        .trim();
    if (text.trim().isEmpty) return 'Something went wrong';
    return text;
  }
}
