import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientAssessmentReviewState {
  final bool isLoading;
  final bool isSaving;
  final List<Map<String, dynamic>> submissions;
  final String? error;

  const PatientAssessmentReviewState({
    this.isLoading = false,
    this.isSaving = false,
    this.submissions = const [],
    this.error,
  });

  PatientAssessmentReviewState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<Map<String, dynamic>>? submissions,
    String? error,
    bool clearError = false,
  }) {
    return PatientAssessmentReviewState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      submissions: submissions ?? this.submissions,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class PatientAssessmentReviewCubit extends Cubit<PatientAssessmentReviewState> {
  PatientAssessmentReviewCubit(this.repo)
    : super(const PatientAssessmentReviewState());

  final AppRepository repo;

Future<void> loadPatientPendingSubmissions(String patientId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final all = await repo.getPendingSubmissions();

      final patientSubmissions = all.where((item) {
        final directPatientId = item['patientId']?.toString();

        final patient = item['patient'];
        final patientMapId = patient is Map ? patient['id']?.toString() : null;

        final assignment = item['assignment'];
        final assignmentPatientId = assignment is Map
            ? assignment['patientId']?.toString()
            : null;

        final assignmentPatient = assignment is Map
            ? assignment['patient']
            : null;
        final assignmentPatientMapId = assignmentPatient is Map
            ? assignmentPatient['id']?.toString()
            : null;

        return directPatientId == patientId ||
            patientMapId == patientId ||
            assignmentPatientId == patientId ||
            assignmentPatientMapId == patientId;
      }).toList();

      final detailedSubmissions = <Map<String, dynamic>>[];

      for (final item in patientSubmissions) {
        final id = item['id']?.toString();

        if (id == null || id.isEmpty) {
          detailedSubmissions.add(item);
          continue;
        }

        try {
          final details = await repo.getSubmissionDetails(id);

          debugPrint('========== SUBMISSION DETAILS ==========');
          debugPrint(details.toString());
          debugPrint('========================================');

          detailedSubmissions.add({...item, ...details});
        } catch (_) {
          detailedSubmissions.add(item);
        }
      }

      emit(state.copyWith(isLoading: false, submissions: detailedSubmissions));
    } catch (e) {
      debugPrint('Pending submissions error => $e');

      emit(
        state.copyWith(
          isLoading: false,
          error: 'حدث خطأ أثناء تحميل التقييمات المعلقة.',
        ),
      );
    }
  }
  Future<bool> approveSubmission({
    required String patientId,
    required Map<String, dynamic> submission,
    required String status,
    String? doctorNote,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      final submissionId = submission['id']?.toString() ?? '';

      final assignment = submission['assignment'];
      final template = assignment is Map ? assignment['template'] : null;

      final templateKey = template is Map
          ? template['key']?.toString() ?? ''
          : '';

      if (submissionId.isEmpty || templateKey.isEmpty) {
        emit(
          state.copyWith(isSaving: false, error: 'بيانات التقييم غير مكتملة.'),
        );
        return false;
      }

      await repo.createOfficialAssessment(
        patientId: patientId,
        submissionId: submissionId,
        templateKey: templateKey,
        status: status,
        doctorNote: doctorNote,
      );

      final updated = state.submissions
          .where((item) => item['id']?.toString() != submissionId)
          .toList();

      emit(state.copyWith(isSaving: false, submissions: updated));

      return true;
    } catch (e) {
      emit(
        state.copyWith(isSaving: false, error: 'حدث خطأ أثناء اعتماد التقييم.'),
      );
      return false;
    }
  }
}
