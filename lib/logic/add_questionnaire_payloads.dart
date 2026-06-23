part of 'add_questionnaire_controller.dart';

extension AddQuestionnaireControllerPayloads on AddQuestionnaireController {
  int _minScore(List<int> scores) {
    return scores.reduce((a, b) => a < b ? a : b);
  }

  int _maxScore(List<int> scores) {
    return scores.reduce((a, b) => a > b ? a : b);
  }

  String _removeSpaces(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }

  bool _hasLetters(String text) {
    return RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(text);
  }

  bool _hasTooManyRepeatedCharacters(String text) {
    return RegExp(r'(.)\1{4,}').hasMatch(text);
  }

  String? _validateUsefulText({
    required String text,
    required String emptyMessage,
    required String shortMessage,
    required String lettersMessage,
    int minLength = 3,
  }) {
    final cleanText = _removeSpaces(text.trim());

    if (cleanText.isEmpty) return emptyMessage;

    if (cleanText.length < minLength) return shortMessage;

    if (!_hasLetters(text)) return lettersMessage;

    if (_hasTooManyRepeatedCharacters(text)) {
      return 'النص يحتوي على تكرار مبالغ فيه للحروف.';
    }

    return null;
  }

  String _normalizedLabel(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  String _buildCategory() {
    final category = categoryController.text.trim();

    if (category.isNotEmpty) return category;

    return 'general';
  }

  String _readableError(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '').trim();

    if (text.contains('FORM_SCALE_HAS_CHOICES')) {
      return 'سؤال Scale لا يجب أن يحتوي على choices.';
    }

    if (text.contains('Unrecognized key')) {
      return 'البيانات المرسلة تحتوي حقول غير مدعومة من السيرفر.';
    }

    if (text.contains('FORM_KEY_INVALID')) {
      return 'مشكلة في form key. حاول إنشاء الاستبيان من جديد.';
    }

    if (text.contains('String must contain at least 2 character')) {
      return 'اسم الاستبيان يجب أن يكون حرفين على الأقل.';
    }

    if (text.contains('category')) {
      return 'يجب تحديد تصنيف الاستبيان.';
    }

    if (text.isEmpty) return 'حدث خطأ غير متوقع.';

    return text;
  }


  ScoreBounds getCurrentScoreBoundsForAutoRanges() {
    int formMinScore = 0;
    int formMaxScore = 0;

    for (final questionItem in questions) {
      final state = questionItem.key.currentState;

      if (state == null) continue;

      final question = state.getQuestionData();

      if (question.questionType == QuestionType.scale) {
        final minValue = question.minValue ?? 0;
        final maxValue = question.maxValue ?? minValue;

        formMinScore += minValue;
        formMaxScore += maxValue;
        continue;
      }

      final scores = question.answers.map((answer) => answer.score).toList();
      final validScores = scores.where((score) => score >= 0).toList();

      if (validScores.isEmpty) continue;

      formMinScore += _minScore(validScores);
      formMaxScore += question.questionType == QuestionType.single
          ? _maxScore(validScores)
          : validScores.fold<int>(0, (sum, score) => sum + score);
    }

    if (formMaxScore < formMinScore) {
      return const ScoreBounds(minScore: 0, maxScore: 100);
    }

    return ScoreBounds(minScore: formMinScore, maxScore: formMaxScore);
  }

  String? validateFormForSubmit() {
    final formName = surveyTitleController.text.trim();
    final category = _buildCategory();

    final formNameError = _validateUsefulText(
      text: formName,
      emptyMessage: 'اكتب اسم الاستبيان أولاً.',
      shortMessage: 'اسم الاستبيان يجب أن يكون 3 حروف مفيدة على الأقل.',
      lettersMessage: 'اسم الاستبيان يجب أن يحتوي على حروف وليس رموز فقط.',
      minLength: 3,
    );

    if (formNameError != null) return formNameError;

    if (isEditMode && (editingFormKey == null || editingFormKey!.isEmpty)) {
      return 'لا يمكن تعديل الاستبيان لأن key القديم غير موجود.';
    }

    if (category.isEmpty) {
      return 'اكتب category / التشخيص قبل الحفظ.';
    }

    if (questions.isEmpty) {
      return 'يجب إضافة سؤال واحد على الأقل.';
    }

    int formMinScore = 0;
    int formMaxScore = 0;

    for (int i = 0; i < questions.length; i++) {
      final state = questions[i].key.currentState;

      if (state == null) {
        return 'حدث خطأ أثناء قراءة بيانات السؤال ${i + 1}.';
      }

      final question = state.getQuestionData();

      final questionTextError = _validateUsefulText(
        text: question.questionText,
        emptyMessage: 'اكتب نص السؤال رقم ${i + 1}.',
        shortMessage: 'نص السؤال رقم ${i + 1} يجب أن يكون 3 حروف مفيدة على الأقل.',
        lettersMessage: 'نص السؤال رقم ${i + 1} يجب أن يحتوي على حروف وليس رموز فقط.',
      );

      if (questionTextError != null) return questionTextError;

      if (question.questionType == QuestionType.scale) {
        final minValue = question.minValue;
        final maxValue = question.maxValue;

        if (minValue == null || maxValue == null) {
          return 'سؤال Scale رقم ${i + 1} يجب أن يحتوي minValue و maxValue.';
        }

        if (maxValue <= minValue) {
          return 'في سؤال Scale رقم ${i + 1}، maxValue يجب أن يكون أكبر من minValue.';
        }

        if ((maxValue - minValue) > 20) {
          return 'سؤال Scale رقم ${i + 1} لا يمكن أن يزيد عن 20 درجة.';
        }

        formMinScore += minValue;
        formMaxScore += maxValue;
        continue;
      }

      if (question.answers.length < 2) {
        return 'السؤال رقم ${i + 1} يجب أن يحتوي على اختيارين على الأقل.';
      }

      final scores = <int>[];
      final answerLabels = <String>{};

      for (int j = 0; j < question.answers.length; j++) {
        final answer = question.answers[j];
        final scoreText = state.answers[j].scoreController.text.trim();

        final answerTextError = _validateUsefulText(
          text: answer.answerText,
          emptyMessage: 'اكتب label الاختيار رقم ${j + 1} في السؤال رقم ${i + 1}.',
          shortMessage: 'label الاختيار رقم ${j + 1} في السؤال رقم ${i + 1} يجب أن يكون 2 حرف مفيد على الأقل.',
          lettersMessage: 'label الاختيار رقم ${j + 1} في السؤال رقم ${i + 1} يجب أن يحتوي على حروف وليس رموز فقط.',
          minLength: 2,
        );

        if (answerTextError != null) return answerTextError;

        final normalizedAnswer = _normalizedLabel(answer.answerText);

        if (answerLabels.contains(normalizedAnswer)) {
          return 'label الاختيار "${answer.answerText}" مكرر في السؤال رقم ${i + 1}.';
        }

        answerLabels.add(normalizedAnswer);

        final score = int.tryParse(scoreText);

        if (scoreText.isEmpty || score == null) {
          return 'score الاختيار رقم ${j + 1} في السؤال رقم ${i + 1} يجب أن يكون رقم.';
        }

        if (score < 0 || score > 100) {
          return 'score الاختيار رقم ${j + 1} في السؤال رقم ${i + 1} يجب أن يكون من 0 إلى 100.';
        }

        scores.add(score);
      }

      formMinScore += _minScore(scores);
      formMaxScore += question.questionType == QuestionType.single
          ? _maxScore(scores)
          : scores.fold<int>(0, (sum, score) => sum + score);
    }

    final diagnosisState = diagnosisKey.currentState;

    if (diagnosisState == null) {
      return 'حدث خطأ أثناء قراءة بيانات التشخيص.';
    }

    final ranges = diagnosisState.getDiagnosisRanges();

    if (ranges.length < 2) {
      return 'يجب إضافة تشخيصين على الأقل حتى يتم تقسيم السكور بشكل صحيح.';
    }

    final diagnosisLabels = <String>{};

    for (int i = 0; i < ranges.length; i++) {
      final range = ranges[i];
      final item = diagnosisState.diagnosisItems[i];

      final diagnosisTextError = _validateUsefulText(
        text: range.diagnosis,
        emptyMessage: 'اكتب اسم التشخيص رقم ${i + 1}.',
        shortMessage: 'اسم التشخيص رقم ${i + 1} يجب أن يكون 3 حروف مفيدة على الأقل.',
        lettersMessage: 'اسم التشخيص رقم ${i + 1} يجب أن يحتوي على حروف وليس رموز فقط.',
      );

      if (diagnosisTextError != null) return diagnosisTextError;

      final normalizedDiagnosis = _normalizedLabel(range.diagnosis);

      if (diagnosisLabels.contains(normalizedDiagnosis)) {
        return 'اسم التشخيص "${range.diagnosis}" مكرر. يجب أن يكون كل تشخيص مختلف.';
      }

      diagnosisLabels.add(normalizedDiagnosis);

      final fromText = item.fromController.text.trim();
      final toText = item.toController.text.trim();

      if (fromText.isEmpty ||
          toText.isEmpty ||
          int.tryParse(fromText) == null ||
          int.tryParse(toText) == null) {
        return 'minScore و maxScore في التشخيص رقم ${i + 1} يجب أن يكونا أرقام.';
      }

      if (range.from > range.to) {
        return 'في التشخيص رقم ${i + 1}، maxScore يجب أن يكون أكبر من أو يساوي minScore.';
      }

      if ((range.to - range.from + 1) < DiagnosisSectionState.minimumDiagnosisRangeSize) {
        return 'كل تشخيص يجب أن يغطي ${DiagnosisSectionState.minimumDiagnosisRangeSize} درجات على الأقل. راجع التشخيص رقم ${i + 1}.';
      }
    }

    ranges.sort((a, b) => a.from.compareTo(b.from));

    if (ranges.first.from != formMinScore) {
      return 'أول تشخيص يجب أن يبدأ من أقل score ممكن للفورم وهو $formMinScore.';
    }

    if (ranges.last.to != formMaxScore) {
      return 'آخر تشخيص يجب أن ينتهي عند أكبر score ممكن للفورم وهو $formMaxScore.';
    }

    for (int i = 0; i < ranges.length - 1; i++) {
      final current = ranges[i];
      final next = ranges[i + 1];

      if (current.to >= next.from) {
        return 'يوجد overlap بين "${current.diagnosis}" و "${next.diagnosis}".';
      }

      if (current.to + 1 != next.from) {
        return 'يوجد gap بين ranges من ${current.to + 1} إلى ${next.from - 1}.';
      }
    }

    return null;
  }

  List<Map<String, dynamic>> buildQuestionsBody() {
    final questionsBody = <Map<String, dynamic>>[];

    for (int i = 0; i < questions.length; i++) {
      final state = questions[i].key.currentState;

      if (state == null) continue;

      final question = state.getQuestionData();

      if (question.questionType == QuestionType.scale) {
        final minValue = question.minValue ?? 0;
        final maxValue = question.maxValue ?? 10;

        questionsBody.add({
          "order": i + 1,
          "text": question.questionText.trim(),
          "type": QuestionType.scale.apiValue,
          "subscale": null,
          "required": true,
          "scaleMin": minValue,
          "scaleMax": maxValue,
          "scaleStep": 1,
        });

        continue;
      }

      questionsBody.add({
        "order": i + 1,
        "text": question.questionText.trim(),
        "type": question.questionType.apiValue,
        "subscale": null,
        "required": true,
        "choices": List.generate(question.answers.length, (answerIndex) {
          final answer = question.answers[answerIndex];

          return {
            "order": answerIndex + 1,
            "label": answer.answerText.trim(),
            "score": answer.score,
          };
        }),
      });
    }

    return questionsBody;
  }

  List<Map<String, dynamic>> buildScoreRangesBody() {
    final diagnosisState = diagnosisKey.currentState;

    if (diagnosisState == null) return [];

    final ranges = diagnosisState.getDiagnosisRanges()
      ..sort((a, b) => a.from.compareTo(b.from));

    return ranges.map((range) {
      return {
        "subscale": null,
        "label": range.diagnosis.trim(),
        "minScore": range.from,
        "maxScore": range.to,
      };
    }).toList();
  }

  Map<String, dynamic> buildFormBody() {
    final body = <String, dynamic>{
      "name": surveyTitleController.text.trim(),
      "category": _buildCategory(),
      "scoringType": scoringTypeController.text.trim().isEmpty
          ? "SUM"
          : scoringTypeController.text.trim(),
      "interpretationMode": interpretationModeController.text.trim().isEmpty
          ? "RANGE"
          : interpretationModeController.text.trim(),
      "questions": buildQuestionsBody(),
      "scoreRanges": buildScoreRangesBody(),
    };

    if (isEditMode && editingFormKey != null && editingFormKey!.isNotEmpty) {
      body["key"] = editingFormKey;
    }

    return body;
  }
}
