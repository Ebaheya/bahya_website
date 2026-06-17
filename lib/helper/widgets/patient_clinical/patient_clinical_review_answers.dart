part of '../../../screens/patient_clinical_details.dart';

class _ReviewAnswersTable extends StatelessWidget {
  const _ReviewAnswersTable({required this.answers});

  final List<_ReviewAnswerItem> answers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.012, min: 12, max: 16),
              vertical: responsiveHeight(context, 0.014, min: 12, max: 15),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              textDirection: _activeTextDirection,
              children: [
                SizedBox(
                  width: 50,
                  child: customText(text: '#', size: 13, bold: true),
                ),
                Expanded(
                  flex: 4,
                  child: customText(
                    text: 'السؤال',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: const Color(0xFF271648),
                    bold: true,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: customText(
                    text: 'الإجابة',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: const Color(0xFF271648),
                    bold: true,
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: customText(
                    text: 'الاسكور',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: const Color(0xFF271648),
                    bold: true,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(answers.length, (index) {
            final item = answers[index];

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.012, min: 12, max: 16),
                vertical: responsiveHeight(context, 0.014, min: 12, max: 15),
              ),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : const Color(0xFFFFFAFD),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                textDirection: _activeTextDirection,
                children: [
                  SizedBox(
                    width: 50,
                    child: customText(
                      text: '${index + 1}',
                      size: 13,
                      color: const Color(0xFF271648),
                      bold: true,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: customText(
                      text: item.question,
                      size: responsiveSize(context, 0.0075, min: 12, max: 14),
                      color: const Color(0xFF4B445C),
                      bold: true,
                      isCenter: false,
                      maxLines: 3,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: _activeCenterStart,
                      child: _AnswerBadge(answer: item.answer),
                    ),
                  ),
                  SizedBox(width: 90, child: _ScoreBadge(score: item.score)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReviewAnswerMobileCard extends StatelessWidget {
  const _ReviewAnswerMobileCard({required this.index, required this.item});

  final int index;
  final _ReviewAnswerItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.012, min: 10, max: 14),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 12, max: 16)),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFFFAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        crossAxisAlignment: _activeCrossAxisStart,
        children: [
          customText(
            text: '${index + 1}. ${item.question}',
            size: responsiveSize(context, 0.0085, min: 13, max: 16),
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          Wrap(
            textDirection: _activeTextDirection,
            spacing: 10,
            runSpacing: 10,
            children: [
              _AnswerBadge(answer: item.answer),
              _ScoreBadge(score: item.score),
              if (item.type.isNotEmpty)
                _AnswerBadge(
                  answer: item.type == 'SCALE' ? 'Scale' : item.type,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewAnswerItem {
  const _ReviewAnswerItem({
    required this.question,
    required this.answer,
    required this.score,
    required this.type,
  });

  final String question;
  final String answer;
  final int score;
  final String type;

  static List<_ReviewAnswerItem> fromSubmission(
    Map<String, dynamic> submission,
  ) {
    final dynamic rawAnswers =
        submission['answers'] ??
        submission['response'] ??
        submission['responses'] ??
        submission['items'];

    if (rawAnswers is! List) return [];

    final questions = _extractQuestions(submission);

    return rawAnswers.map<_ReviewAnswerItem>((raw) {
      if (raw is! Map) {
        return const _ReviewAnswerItem(
          question: 'سؤال غير معروف',
          answer: '-',
          score: 0,
          type: '',
        );
      }

      final answerMap = Map<String, dynamic>.from(raw);
      final questionId = answerMap['questionId']?.toString();

      final questionMap = questionId == null ? null : questions[questionId];

      final questionText = questionMap == null
          ? _readQuestion(answerMap)
          : _readQuestion(questionMap);

      final type = questionMap == null
          ? _readType(answerMap)
          : _readType(questionMap);

      final answerText = questionMap == null
          ? _readAnswer(answerMap, type)
          : _readAnswerFromQuestion(answerMap, questionMap, type);

      final score = questionMap == null
          ? _readScore(answerMap)
          : _readScoreFromQuestion(answerMap, questionMap, type);

      return _ReviewAnswerItem(
        question: questionText,
        answer: answerText,
        score: score,
        type: type,
      );
    }).toList();
  }

  static Map<String, Map<String, dynamic>> _extractQuestions(
    Map<String, dynamic> submission,
  ) {
    final questionsById = <String, Map<String, dynamic>>{};

    final formVersion = submission['formVersion'];
    final dynamic rawQuestions = formVersion is Map
        ? formVersion['questions']
        : null;

    if (rawQuestions is List) {
      for (final rawQuestion in rawQuestions) {
        if (rawQuestion is Map) {
          final question = Map<String, dynamic>.from(rawQuestion);
          final id = question['id']?.toString();

          if (id != null && id.isNotEmpty) {
            questionsById[id] = question;
          }
        }
      }
    }

    return questionsById;
  }

  static String _readAnswerFromQuestion(
    Map<String, dynamic> answerMap,
    Map<String, dynamic> questionMap,
    String type,
  ) {
    if (type == 'SCALE') {
      final value =
          answerMap['value'] ??
          answerMap['scaleValue'] ??
          answerMap['answerValue'] ??
          answerMap['numericValue'];

      return value == null ? '-' : value.toString();
    }

    final choiceIds = _extractChoiceIds(answerMap);

    if (choiceIds.isEmpty) {
      return _readAnswer(answerMap, type);
    }

    final choices = questionMap['choices'];

    if (choices is! List) return '-';

    final labels = <String>[];

    for (final choice in choices) {
      if (choice is! Map) continue;

      final choiceId = choice['id']?.toString();

      if (choiceId != null && choiceIds.contains(choiceId)) {
        final label =
            choice['label'] ??
            choice['text'] ??
            choice['title'] ??
            choice['value'];

        if (label != null && label.toString().trim().isNotEmpty) {
          labels.add(label.toString());
        }
      }
    }

    return labels.isEmpty ? '-' : labels.join('، ');
  }

  static int _readScoreFromQuestion(
    Map<String, dynamic> answerMap,
    Map<String, dynamic> questionMap,
    String type,
  ) {
    if (type == 'SCALE') {
      final value =
          answerMap['value'] ??
          answerMap['scaleValue'] ??
          answerMap['answerValue'] ??
          answerMap['numericValue'];

      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final choiceIds = _extractChoiceIds(answerMap);

    if (choiceIds.isEmpty) {
      return _readScore(answerMap);
    }

    final choices = questionMap['choices'];

    if (choices is! List) return 0;

    int total = 0;

    for (final choice in choices) {
      if (choice is! Map) continue;

      final choiceId = choice['id']?.toString();

      if (choiceId != null && choiceIds.contains(choiceId)) {
        final score = choice['score'];
        total += int.tryParse(score?.toString() ?? '') ?? 0;
      }
    }

    return total;
  }

  static List<String> _extractChoiceIds(Map<String, dynamic> answerMap) {
    final dynamic rawChoiceIds =
        answerMap['choiceIds'] ??
        answerMap['selectedChoiceIds'] ??
        answerMap['choices'];

    if (rawChoiceIds is List) {
      return rawChoiceIds.map((e) => e.toString()).toList();
    }

    final dynamic singleChoiceId =
        answerMap['choiceId'] ?? answerMap['selectedChoiceId'];

    if (singleChoiceId != null && singleChoiceId.toString().trim().isNotEmpty) {
      return [singleChoiceId.toString()];
    }

    return [];
  }

  static String _readQuestion(Map<String, dynamic> map) {
    final direct =
        map['questionText'] ??
        map['questionTitle'] ??
        map['text'] ??
        map['title'] ??
        map['label'];

    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString();
    }

    final question = map['question'];
    if (question is Map) {
      final text =
          question['text'] ??
          question['title'] ??
          question['label'] ??
          question['body'] ??
          question['questionText'];

      if (text != null && text.toString().trim().isNotEmpty) {
        return text.toString();
      }
    }

    final item = map['item'];
    if (item is Map) {
      final text = item['text'] ?? item['title'] ?? item['label'];
      if (text != null && text.toString().trim().isNotEmpty) {
        return text.toString();
      }
    }

    return 'سؤال غير معروف';
  }

  static String _readType(Map<String, dynamic> map) {
    final type = map['type'] ?? map['questionType'];

    if (type != null && type.toString().trim().isNotEmpty) {
      return type.toString().toUpperCase();
    }

    final question = map['question'];
    if (question is Map && question['type'] != null) {
      return question['type'].toString().toUpperCase();
    }

    if (map.containsKey('value') || map.containsKey('scaleValue')) {
      return 'SCALE';
    }

    return '';
  }

  static String _readAnswer(Map<String, dynamic> map, String type) {
    if (type == 'SCALE') {
      final value =
          map['value'] ??
          map['scaleValue'] ??
          map['answerValue'] ??
          map['numericValue'];

      return value == null ? '-' : value.toString();
    }

    final answerText =
        map['answerText'] ??
        map['answerLabel'] ??
        map['label'] ??
        map['answer'] ??
        map['value'];

    if (answerText != null && answerText.toString().trim().isNotEmpty) {
      return answerText.toString();
    }

    final choice = map['choice'] ?? map['selectedChoice'];
    if (choice is Map) {
      final label =
          choice['label'] ??
          choice['text'] ??
          choice['title'] ??
          choice['value'];

      if (label != null && label.toString().trim().isNotEmpty) {
        return label.toString();
      }
    }

    final choices =
        map['choices'] ?? map['selectedChoices'] ?? map['choiceIds'];
    if (choices is List && choices.isNotEmpty) {
      return choices
          .map((choice) {
            if (choice is Map) {
              return choice['label'] ??
                  choice['text'] ??
                  choice['title'] ??
                  choice['value'] ??
                  '';
            }

            return choice.toString();
          })
          .where((e) => e.toString().trim().isNotEmpty)
          .join('، ');
    }

    return '-';
  }

  static int _readScore(Map<String, dynamic> map) {
    final directScore = map['score'] ?? map['answerScore'];
    final parsedDirect = int.tryParse(directScore?.toString() ?? '');
    if (parsedDirect != null) return parsedDirect;

    final choice = map['choice'];
    if (choice is Map) {
      final parsed = int.tryParse(choice['score']?.toString() ?? '');
      if (parsed != null) return parsed;
    }

    final choices = map['choices'];
    if (choices is List) {
      int total = 0;
      for (final choice in choices) {
        if (choice is Map) {
          total += int.tryParse(choice['score']?.toString() ?? '') ?? 0;
        }
      }
      return total;
    }

    final selectedChoices = map['selectedChoices'];
    if (selectedChoices is List) {
      int total = 0;
      for (final choice in selectedChoices) {
        if (choice is Map) {
          total += int.tryParse(choice['score']?.toString() ?? '') ?? 0;
        }
      }
      return total;
    }

    final value = map['value'] ?? map['scaleValue'];
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
