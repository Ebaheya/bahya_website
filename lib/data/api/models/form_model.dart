class FormsResponseModel {
  final List<FormModel> data;
  final int total;
  final int page;
  final int pageSize;

  FormsResponseModel({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory FormsResponseModel.fromJson(Map<String, dynamic> json) {
    return FormsResponseModel(
      data: (json['data'] as List? ?? [])
          .map((e) => FormModel.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
    );
  }
}

class FormModel {
  final String id;
  final String key;
  final String name;
  final bool isDefault;
  final bool isActive;
  final String currentVersionId;
  final String createdById;
  final String createdAt;
  final String updatedAt;
  final FormVersionModel? currentVersion;

  FormModel({
    required this.id,
    required this.key,
    required this.name,
    required this.isDefault,
    required this.isActive,
    required this.currentVersionId,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.currentVersion,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? false,
      currentVersionId: json['currentVersionId'] ?? '',
      createdById: json['createdById'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      currentVersion: json['currentVersion'] == null
          ? null
          : FormVersionModel.fromJson(json['currentVersion']),
    );
  }
}

class FormVersionModel {
  final String id;
  final String templateId;
  final int version;
  final String status;
  final String? publishedAt;
  final String createdAt;
  final List<FormQuestionModel> questions;
  final List<FormScoreRangeModel> scoreRanges;

  FormVersionModel({
    required this.id,
    required this.templateId,
    required this.version,
    required this.status,
    this.publishedAt,
    required this.createdAt,
    required this.questions,
    required this.scoreRanges,
  });

  factory FormVersionModel.fromJson(Map<String, dynamic> json) {
    return FormVersionModel(
      id: json['id'] ?? '',
      templateId: json['templateId'] ?? '',
      version: json['version'] ?? 0,
      status: json['status'] ?? '',
      publishedAt: json['publishedAt'],
      createdAt: json['createdAt'] ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((e) => FormQuestionModel.fromJson(e))
          .toList(),
      scoreRanges: (json['scoreRanges'] as List? ?? [])
          .map((e) => FormScoreRangeModel.fromJson(e))
          .toList(),
    );
  }
}

class FormQuestionModel {
  final String id;
  final String versionId;
  final int order;
  final String text;
  final String type;
  final String? subscale;
  final bool required;
  final int? scaleMin;
  final int? scaleMax;
  final int? scaleStep;
  final List<FormChoiceModel> choices;

  FormQuestionModel({
    required this.id,
    required this.versionId,
    required this.order,
    required this.text,
    required this.type,
    this.subscale,
    required this.required,
    this.scaleMin,
    this.scaleMax,
    this.scaleStep,
    required this.choices,
  });

  factory FormQuestionModel.fromJson(Map<String, dynamic> json) {
    return FormQuestionModel(
      id: json['id'] ?? '',
      versionId: json['versionId'] ?? '',
      order: json['order'] ?? 0,
      text: json['text'] ?? '',
      type: json['type'] ?? '',
      subscale: json['subscale'],
      required: json['required'] ?? false,
      scaleMin: json['scaleMin'],
      scaleMax: json['scaleMax'],
      scaleStep: json['scaleStep'],
      choices: (json['choices'] as List? ?? [])
          .map((e) => FormChoiceModel.fromJson(e))
          .toList(),
    );
  }
}

class FormChoiceModel {
  final String id;
  final String questionId;
  final int order;
  final String label;
  final int score;

  FormChoiceModel({
    required this.id,
    required this.questionId,
    required this.order,
    required this.label,
    required this.score,
  });

  factory FormChoiceModel.fromJson(Map<String, dynamic> json) {
    return FormChoiceModel(
      id: json['id'] ?? '',
      questionId: json['questionId'] ?? '',
      order: json['order'] ?? 0,
      label: json['label'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}

class FormScoreRangeModel {
  final String id;
  final String versionId;
  final String? subscale;
  final String label;
  final int minScore;
  final int maxScore;
  final String? note;

  FormScoreRangeModel({
    required this.id,
    required this.versionId,
    this.subscale,
    required this.label,
    required this.minScore,
    required this.maxScore,
    this.note,
  });

  factory FormScoreRangeModel.fromJson(Map<String, dynamic> json) {
    return FormScoreRangeModel(
      id: json['id'] ?? '',
      versionId: json['versionId'] ?? '',
      subscale: json['subscale'],
      label: json['label'] ?? '',
      minScore: json['minScore'] ?? 0,
      maxScore: json['maxScore'] ?? 0,
      note: json['note'],
    );
  }
}
