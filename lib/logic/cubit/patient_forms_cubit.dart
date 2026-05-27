import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'patient_forms_state.dart';

class PatientFormsCubit extends Cubit<PatientFormsState> {
  final AppRepository repo;
final Map<String, dynamic> answers = {};
  PatientFormsCubit(this.repo) : super(const PatientFormsState());

  Future<void> loadMyAssignments() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final assignments = await repo.getMyAssignments();

      emit(state.copyWith(isLoading: false, assignments: assignments));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: "حدث خطأ أثناء تحميل النماذج."),
      );
    }
  }

  Future<void> loadAssignmentDetails(String assignmentId) async {
    emit(state.copyWith(isLoadingDetails: true, clearError: true));

    try {
      final details = await repo.getAssignmentDetails(assignmentId);

      emit(
        state.copyWith(isLoadingDetails: false, selectedAssignment: details),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingDetails: false,
          error: "حدث خطأ أثناء تحميل النموذج.",
        ),
      );
    }
  }
  void setSingleChoiceAnswer({
    required String questionId,
    required String choiceId,
  }) {
    answers[questionId] = {
      "questionId": questionId,
      "choiceIds": [choiceId],
    };

    emit(state.copyWith());
  }

  String? getSingleChoiceAnswer(String questionId) {
    final current = answers[questionId];

    if (current == null) return null;

    final choiceIds = List<String>.from(current["choiceIds"] ?? []);

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
        : List<String>.from(current["choiceIds"] ?? []);

    if (choiceIds.contains(choiceId)) {
      choiceIds.remove(choiceId);
    } else {
      choiceIds.add(choiceId);
    }

    answers[questionId] = {"questionId": questionId, "choiceIds": choiceIds};

    emit(state.copyWith());
  }

  bool isChoiceSelected({
    required String questionId,
    required String choiceId,
  }) {
    final current = answers[questionId];

    if (current == null) return false;

    final choiceIds = List<String>.from(current["choiceIds"] ?? []);

    return choiceIds.contains(choiceId);
  }

  void setScaleAnswer({required String questionId, required int value}) {
    answers[questionId] = {"questionId": questionId, "value": value};

    emit(state.copyWith());
  }

  int? getScaleAnswer(String questionId) {
    final current = answers[questionId];

    if (current == null) return null;

    return current["value"];
  }
   Future<void> submitCurrentAssignment() async {
    final details = state.selectedAssignment;

    if (details == null) {
      emit(state.copyWith(error: "لا يوجد نموذج محدد."));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final body = {"answers": answers.values.toList()};

      final response = await repo.submitAssignment(
        assignmentId: details.id,
        body: body,
      );

      emit(state.copyWith(isSubmitting: false, submitResponse: response));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          error: "حدث خطأ أثناء إرسال النموذج.",
        ),
      );
    }
  }
}
