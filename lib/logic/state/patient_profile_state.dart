import 'package:bahya_app/data/models/patient_profile_model.dart';

class PatientProfileState {
  final bool isLoading;
  final PatientProfileModel? profile;
  final String? error;

  const PatientProfileState({this.isLoading = false, this.profile, this.error});

  PatientProfileState copyWith({
    bool? isLoading,
    PatientProfileModel? profile,
    String? error,
    bool clearError = false,
  }) {
    return PatientProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: clearError ? null : error ?? this.error,
    );
  }
}
