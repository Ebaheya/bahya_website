import 'package:bahya_app/data/models/patient_profile_model.dart';
import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:bahya_app/logic/state/patient_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientProfileCubit extends Cubit<PatientProfileState> {
  PatientProfileCubit(this.webService) : super(const PatientProfileState());

  final WebService webService;

  Future<void> loadProfile() async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await webService.get('/auth/me');
      final data = Map<String, dynamic>.from(response.data);

      final profile = PatientProfileModel.fromJson(data);

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          profile: profile,
        ),
      );
    } catch (_) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          error: 'حدث خطأ أثناء تحميل بيانات الحساب.',
        ),
      );
    }
  }

  Future<void> logout() async {
    await webService.logout();
  }
}