import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/patient_forms_state.dart';

class PatientFormsCubit extends Cubit<PatientFormsState> {
  PatientFormsCubit(this.repo) : super(const PatientFormsState());

  final AppRepository repo;
  final Map<String, dynamic> answers = {};

  bool get _canEmit => !isClosed;

  void _safeEmit(PatientFormsState newState) {
    if (!_canEmit) return;
    emit(newState);
  }

  Future<void> loadMyAssignments() async {
    if (!_canEmit) return;

    _safeEmit(
      state.copyWith(isLoading: true, hasLoaded: false, clearError: true),
    );

    try {
      final assignments = await repo.getMyAssignments();
      if (!_canEmit) return;

      _safeEmit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          assignments: assignments,
        ),
      );
    } catch (_) {
      if (!_canEmit) return;

      _safeEmit(
        state.copyWith(
          isLoading: false,
          hasLoaded: true,
          assignments: const [],
          error: 'تعذر تحميل النموذج حالياً. حاول مرة أخرى لاحقاً.',
        ),
      );
    }
  }

  Future<void> loadAssignmentDetails(String assignmentId) async {
    if (!_canEmit) return;

    _safeEmit(state.copyWith(isLoadingDetails: true, clearError: true));

    try {
      final details = await repo.getAssignmentDetails(assignmentId);
      if (!_canEmit) return;

      _safeEmit(
        state.copyWith(isLoadingDetails: false, selectedAssignment: details),
      );
    } catch (_) {
      if (!_canEmit) return;

      _safeEmit(
        state.copyWith(
          isLoadingDetails: false,
          error: 'تعذر تحميل النموذج حالياً. حاول مرة أخرى لاحقاً.',
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

    _safeEmit(state.copyWith());
  }

  String? getSingleChoiceAnswer(String questionId) {
    final current = answers[questionId];
    if (current == null) return null;

    final choiceIds = List<String>.from(current['choiceIds'] ?? []);
    if (choiceIds.isEmpty) return null;

    return choiceIds.first;
  }

  void toggleMultiChoiceAnswer({
    required String questionId,
    required String choiceId,
  }) {
    final current = answers[questionId];

    final List<String> choiceIds = current == null
        ? []
        : List<String>.from(current['choiceIds'] ?? []);

    if (choiceIds.contains(choiceId)) {
      choiceIds.remove(choiceId);
    } else {
      choiceIds.add(choiceId);
    }

    answers[questionId] = {'questionId': questionId, 'choiceIds': choiceIds};

    _safeEmit(state.copyWith());
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

  void setScaleAnswer({required String questionId, required int value}) {
    answers[questionId] = {'questionId': questionId, 'value': value};

    _safeEmit(state.copyWith());
  }

  int? getScaleAnswer(String questionId) {
    final current = answers[questionId];
    if (current == null) return null;

    return current['value'];
  }

  Future<void> submitCurrentAssignment() async {
    final details = state.selectedAssignment;

    if (details == null) {
      _safeEmit(
        state.copyWith(
          error: 'تعذر تحميل النموذج حالياً. حاول مرة أخرى لاحقاً.',
        ),
      );
      return;
    }

    _safeEmit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final body = {'answers': answers.values.toList()};

      final response = await repo.submitAssignment(
        assignmentId: details.id,
        body: body,
      );
      if (!_canEmit) return;

      _safeEmit(state.copyWith(isSubmitting: false, submitResponse: response));
    } catch (_) {
      if (!_canEmit) return;

      _safeEmit(
        state.copyWith(
          isSubmitting: false,
          error: 'تعذر تحميل النموذج حالياً. حاول مرة أخرى لاحقاً.',
        ),
      );
    }
  }
}
