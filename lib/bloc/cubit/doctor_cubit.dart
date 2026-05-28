import 'package:bahya_website/bloc/states/doctor_state.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorFormsCubit extends Cubit<DoctorFormsState> {
  final AppRepository repo;

  DoctorFormsCubit(this.repo) : super(const DoctorFormsState());

  final Map<String, dynamic> answers = {};

  void clearCreatedAssessment() {
    emit(state.copyWith(clearCreatedAssessment: true));
  }

  void changeStatus(String status) {
    emit(state.copyWith(selectedStatus: status, clearError: true));
  }

  String getArabicStatus(String status) {
    switch (status) {
      case "NORMAL":
        return "طبيعي";
      case "MILD":
        return "بسيط";
      case "MODERATE":
        return "متوسط";
      case "SEVERE":
        return "شديد";
      case "CRITICAL":
        return "حرج";
      default:
        return "غير محدد";
    }
  }

  Future<void> loadForms() async {
    emit(state.copyWith(isLoadingForms: true, clearError: true));

    try {
      final response = await repo.getForms();

      emit(state.copyWith(isLoadingForms: false, forms: response.data));

      if (response.data.isNotEmpty) {
        await selectForm(response.data.first.id);
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingForms: false,
          error: "حدث خطأ أثناء تحميل النماذج.",
        ),
      );
    }
  }

  Future<void> selectForm(String formId) async {
    emit(
      state.copyWith(
        isLoadingFormDetails: true,
        clearError: true,
        clearCreatedAssessment: true,
        clearSelectedPatient: true,
        patientOptions: [],
        selectedStatus: "NORMAL",
        clearPatientAlreadyFilledMessage: true,
      ),
    );

    try {
      answers.clear();

      final form = await repo.getFormById(formId);

      emit(
        state.copyWith(
          isLoadingFormDetails: false,
          selectedForm: form,
          selectedStatus: "NORMAL",
          completedPatientIds: [],
          clearSelectedPatient: true,
          patientOptions: [],
          clearPatientAlreadyFilledMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingFormDetails: false,
          error: "حدث خطأ أثناء تحميل تفاصيل النموذج.",
        ),
      );
    }
  }

  Future<void> searchPatients(String search) async {
    if (search.trim().isEmpty) {
      emit(
        state.copyWith(
          patientOptions: [],
          clearPatientAlreadyFilledMessage: true,
        ),
      );
      return;
    }

    if (state.selectedForm == null) {
      emit(state.copyWith(error: "اختر النموذج أولاً."));
      return;
    }

    emit(
      state.copyWith(
        isSearchingPatients: true,
        clearError: true,
        clearPatientAlreadyFilledMessage: true,
      ),
    );

    try {
      final response = await repo.getPatient(search: search);

      final availablePatients = <OptionUserModel>[];
      bool foundButAlreadyFilled = false;

      for (final patient in response.data) {
        final hasFilled = await _patientFilledThisForm(patientId: patient.id);

        if (hasFilled) {
          foundButAlreadyFilled = true;
        } else {
          availablePatients.add(patient);
        }
      }

      emit(
        state.copyWith(
          isSearchingPatients: false,
          patientOptions: availablePatients,
          patientAlreadyFilledMessage: foundButAlreadyFilled
              ? "المريض ده ملأ هذا النموذج من قبل، لذلك لن يظهر في الاختيارات."
              : null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSearchingPatients: false,
          error: "حدث خطأ أثناء البحث عن المرضى.",
        ),
      );
    }
  }

  Future<bool> _patientFilledThisForm({required String patientId}) async {
    final form = state.selectedForm;
    if (form == null) return false;

    try {
      final assessments = await repo.getPatientAssessments(patientId);

      return assessments.any((assessment) {
        final key = assessment["templateKey"]?.toString();
        return key == form.key;
      });
    } catch (_) {
      return false;
    }
  }

  Future<void> selectPatient(OptionUserModel patient) async {
    final form = state.selectedForm;

    if (form == null) {
      emit(state.copyWith(error: "اختر النموذج أولاً."));
      return;
    }

    final hasFilled = await _patientFilledThisForm(patientId: patient.id);

    if (hasFilled) {
      emit(
        state.copyWith(
          clearSelectedPatient: true,
          patientOptions: [],
          patientAlreadyFilledMessage:
              "هذا المريض ملأ هذا النموذج من قبل، لا يمكن اختيار هذا المريض لهذا النموذج.",
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedPatient: patient,
        patientOptions: [],
        clearError: true,
        clearPatientAlreadyFilledMessage: true,
      ),
    );
  }

  void clearSelectedPatient() {
    emit(
      state.copyWith(
        clearSelectedPatient: true,
        clearPatientAlreadyFilledMessage: true,
      ),
    );
  }

  void setScaleAnswer({
    required String questionId,
    required int value,
    int score = 0,
  }) {
    answers[questionId] = {
      "questionId": questionId,
      "value": value,
      "score": score,
    };

    emit(state.copyWith(clearError: true));
  }

  void setSingleChoiceAnswer({
    required String questionId,
    required String choiceId,
    int score = 0,
  }) {
    answers[questionId] = {
      "questionId": questionId,
      "choiceIds": [choiceId],
      "score": score,
    };

    emit(state.copyWith(clearError: true));
  }

  void toggleMultiChoiceAnswer({
    required String questionId,
    required String choiceId,
    int score = 0,
  }) {
    final current = answers[questionId];

    final List<String> choiceIds = current == null
        ? []
        : List<String>.from(current["choiceIds"] ?? []);

    final List<int> scores = current == null
        ? []
        : List<int>.from(current["scores"] ?? []);

    if (choiceIds.contains(choiceId)) {
      final index = choiceIds.indexOf(choiceId);
      choiceIds.removeAt(index);

      if (index < scores.length) {
        scores.removeAt(index);
      }
    } else {
      choiceIds.add(choiceId);
      scores.add(score);
    }

    answers[questionId] = {
      "questionId": questionId,
      "choiceIds": choiceIds,
      "scores": scores,
    };

    emit(state.copyWith(clearError: true));
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

  String? getSingleChoiceAnswer(String questionId) {
    final current = answers[questionId];
    if (current == null) return null;

    final choiceIds = List<String>.from(current["choiceIds"] ?? []);
    return choiceIds.isEmpty ? null : choiceIds.first;
  }

  int? getScaleAnswer(String questionId) {
    final current = answers[questionId];
    if (current == null) return null;

    return current["value"];
  }

  int calculateScore() {
    int total = 0;

    for (final answer in answers.values) {
      if (answer["score"] is int) {
        total += answer["score"] as int;
      }

      if (answer["scores"] is List) {
        total += List<int>.from(
          answer["scores"],
        ).fold<int>(0, (sum, item) => sum + item);
      }
    }

    return total;
  }

  String calculateDiagnosis() {
    final score = calculateScore();
    final ranges = state.selectedForm?.currentVersion?.scoreRanges ?? [];

    for (final range in ranges) {
      final min = range.minScore ?? 0;
      final max = range.maxScore ?? 0;

      if (score >= min && score <= max) {
        return range.label ?? "غير محدد";
      }
    }

    return "غير محدد";
  }

  bool validateRequiredAnswers() {
    final questions = state.selectedForm?.currentVersion?.questions ?? [];

    for (final question in questions) {
      if (question.required != true) continue;

      final answer = answers[question.id];

      if (answer == null) return false;

      if (question.type == "SCALE") {
        if (answer["value"] == null) return false;
      } else {
        final choiceIds = List<String>.from(answer["choiceIds"] ?? []);
        if (choiceIds.isEmpty) return false;
      }
    }

    return true;
  }

  Future<void> submitManualAssessment({String? doctorNote}) async {
    final form = state.selectedForm;
    final patient = state.selectedPatient;

    if (form == null) {
      emit(state.copyWith(error: "اختر النموذج أولاً."));
      return;
    }

    if (patient == null) {
      emit(state.copyWith(error: "اختر المريض أولاً."));
      return;
    }

    if (!validateRequiredAnswers()) {
      emit(state.copyWith(error: "برجاء الإجابة على كل الأسئلة المطلوبة."));
      return;
    }

    emit(
      state.copyWith(
        isSubmittingAssessment: true,
        clearError: true,
        clearCreatedAssessment: true,
      ),
    );

    try {
      final score = calculateScore();
      final diagnosis = calculateDiagnosis();
      final patientStatus = state.selectedStatus;

      final body = {
        "patientId": patient.id,
        "submissionId": null,
        "templateKey": form.key,
        "score": score,
        "status": patientStatus,
        "doctorNote": doctorNote ?? "",
      };

      debugPrint("CREATE ASSESSMENT BODY: $body");

      final response = await repo.createAssessment(body: body);

      debugPrint("CREATE ASSESSMENT RESPONSE: $response");

      answers.clear();

      emit(
        state.copyWith(
          isSubmittingAssessment: false,
          createdAssessment: {
            ...response,
            "score": score,
            "diagnosis": diagnosis,
            "patientStatus": getArabicStatus(patientStatus),
          },
          clearSelectedPatient: true,
          patientOptions: [],
          clearPatientAlreadyFilledMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmittingAssessment: false,
          error: "حدث خطأ أثناء حفظ التقييم.",
        ),
      );
    }
  }
}
