import 'package:bahya_website/bloc/states/volunteer_assignments_state.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VolunteerAssignmentsCubit extends Cubit<VolunteerAssignmentsState> {
  VolunteerAssignmentsCubit(this.web)
    : super(const VolunteerAssignmentsState());

  final WebService web;

  final Map<String, Map<String, dynamic>> answers = {};

  Future<void> loadAssignments() async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true, hasLoaded: false, clearError: true));

    try {
      final assignments = await web.getMyFormAssignments();

      final enrichedAssignments = <Map<String, dynamic>>[];

      for (final assignment in assignments) {
        final item = Map<String, dynamic>.from(assignment);
        final patientId = item['patientId']?.toString();

        if (patientId != null && patientId.isNotEmpty) {
          try {
            final patientDetails = await web.getPatientById(patientId);

            debugPrint('================ PATIENT DETAILS =================');
            debugPrint(patientDetails.toString());
            debugPrint('==================================================');

            item['patientDetails'] = patientDetails;
          } catch (e) {
            debugPrint('Failed to load patient details for $patientId => $e');
          }
        }

        enrichedAssignments.add(item);
      }

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          assignments: enrichedAssignments,
        ),
      );

      if (enrichedAssignments.isNotEmpty) {
        await selectAssignment(enrichedAssignments.first);
      }
    } catch (e) {
      if (isClosed) return;

      final text = e.toString();

      emit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          assignments: const [],
          error: text.contains('Insufficient role')
              ? 'هذه الشاشة مخصصة للمتطوع فقط.'
              : 'حدث خطأ أثناء تحميل الاستبيانات المسندة.',
        ),
      );
    }
  }

  Future<void> selectAssignment(Map<String, dynamic> assignment) async {
    final assignmentId = assignment['id']?.toString();

    if (assignmentId == null || assignmentId.isEmpty) return;
    if (isClosed) return;

    answers.clear();

    emit(
      state.copyWith(
        isLoadingDetails: true,
        selectedAssignment: assignment,
        selectedAssignmentDetails: null,
        clearError: true,
      ),
    );

    try {
      final details = await web.getFormAssignmentById(assignmentId);

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoadingDetails: false,
          selectedAssignmentDetails: details,
        ),
      );
    } catch (_) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoadingDetails: false,
          error: 'حدث خطأ أثناء تحميل تفاصيل الاستبيان.',
        ),
      );
    }
  }

  void setSingleChoiceAnswer({
    required String questionId,
    required String choiceId,
  }) {
    answers[questionId] = {
      'questionId': questionId,
      'choiceIds': [choiceId],
    };

    if (!isClosed) emit(state.copyWith());
  }

  void toggleMultiChoiceAnswer({
    required String questionId,
    required String choiceId,
  }) {
    final current = answers[questionId];

    final choiceIds = current == null
        ? <String>[]
        : List<String>.from(current['choiceIds'] ?? []);

    if (choiceIds.contains(choiceId)) {
      choiceIds.remove(choiceId);
    } else {
      choiceIds.add(choiceId);
    }

    answers[questionId] = {'questionId': questionId, 'choiceIds': choiceIds};

    if (!isClosed) emit(state.copyWith());
  }

  void setScaleAnswer({required String questionId, required int value}) {
    answers[questionId] = {'questionId': questionId, 'value': value};

    if (!isClosed) emit(state.copyWith());
  }

  bool isChoiceSelected({
    required String questionId,
    required String choiceId,
  }) {
    final current = answers[questionId];
    if (current == null) return false;

    final choiceIds = List<String>.from(current['choiceIds'] ?? []);
    return choiceIds.contains(choiceId);
  }

  int? getScaleAnswer(String questionId) {
    final current = answers[questionId];
    if (current == null) return null;

    return current['value'] is int ? current['value'] : null;
  }

  String? validateAnswers() {
    final details = state.selectedAssignmentDetails;
    if (details == null) return 'لا يوجد استبيان محدد.';

    final questions =
        details['formVersion']?['questions'] as List? ??
        details['questions'] as List? ??
        [];

    if (questions.isEmpty) return 'لا توجد أسئلة في هذا الاستبيان.';

    for (final q in questions) {
      final question = Map<String, dynamic>.from(q);
      final questionId = question['id']?.toString() ?? '';
      final required = question['required'] == true;
      final type =
          question['type']?.toString().toUpperCase() ?? 'SINGLE_SELECT';

      if (!required) continue;

      final answer = answers[questionId];

      if (answer == null) {
        return 'يجب الإجابة على كل الأسئلة المطلوبة.';
      }

      if (type == 'SCALE') {
        if (answer['value'] == null) {
          return 'يجب اختيار قيمة لكل سؤال Scale.';
        }
      } else {
        final choiceIds = List<String>.from(answer['choiceIds'] ?? []);
        if (choiceIds.isEmpty) {
          return 'يجب اختيار إجابة لكل سؤال.';
        }
      }
    }

    return null;
  }

  Future<bool> submitSelectedAssignment() async {
    final assignmentId =
        state.selectedAssignmentDetails?['id']?.toString() ??
        state.selectedAssignment?['id']?.toString();

    if (assignmentId == null || assignmentId.isEmpty) {
      if (!isClosed) {
        emit(state.copyWith(error: 'لا يوجد استبيان محدد.'));
      }
      return false;
    }

    final validationError = validateAnswers();

    if (validationError != null) {
      if (!isClosed) {
        emit(state.copyWith(error: validationError));
      }
      return false;
    }

    if (isClosed) return false;

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await web.submitFormAssignment(
        assignmentId: assignmentId,
        body: {'answers': answers.values.toList()},
      );

      if (isClosed) return false;

      emit(state.copyWith(isSubmitting: false));
      await loadAssignments();

      return true;
    } catch (_) {
      if (isClosed) return false;

      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'حدث خطأ أثناء حفظ الإجابات.',
        ),
      );

      return false;
    }
  }
}
