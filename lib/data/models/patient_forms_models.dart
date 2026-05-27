class MyAssignmentModel {
  final String id;
  final String target;
  final String status;
  final String? publishAt;
  final AssignmentTemplateModel template;

  MyAssignmentModel({
    required this.id,
    required this.target,
    required this.status,
    this.publishAt,
    required this.template,
  });

  factory MyAssignmentModel.fromJson(Map<String, dynamic> json) {
    return MyAssignmentModel(
      id: json['id'] ?? '',
      target: json['target'] ?? '',
      status: json['status'] ?? '',
      publishAt: json['publishAt'],
      template: AssignmentTemplateModel.fromJson(json['template'] ?? {}),
    );
  }
}

class AssignmentTemplateModel {
  final String id;
  final String key;
  final String name;

  AssignmentTemplateModel({
    required this.id,
    required this.key,
    required this.name,
  });

  factory AssignmentTemplateModel.fromJson(Map<String, dynamic> json) {
    return AssignmentTemplateModel(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class AssignmentDetailsModel {
  final String id;
  final String status;
  final AssignmentTemplateModel template;
  final AssignmentFormVersionModel formVersion;

  AssignmentDetailsModel({
    required this.id,
    required this.status,
    required this.template,
    required this.formVersion,
  });

  factory AssignmentDetailsModel.fromJson(Map<String, dynamic> json) {
    return AssignmentDetailsModel(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      template: AssignmentTemplateModel.fromJson(json['template'] ?? {}),
      formVersion: AssignmentFormVersionModel.fromJson(
        json['formVersion'] ?? {},
      ),
    );
  }
}

class AssignmentFormVersionModel {
  final int version;
  final List<FormQuestionModel> questions;

  AssignmentFormVersionModel({required this.version, required this.questions});

  factory AssignmentFormVersionModel.fromJson(Map<String, dynamic> json) {
    return AssignmentFormVersionModel(
      version: json['version'] ?? 0,
      questions: (json['questions'] as List? ?? [])
          .map((e) => FormQuestionModel.fromJson(e))
          .toList(),
    );
  }
}

class FormQuestionModel {
  final String id;
  final int order;
  final String text;
  final String type;
  final bool required;
  final int? scaleMin;
  final int? scaleMax;
  final int? scaleStep;
  final List<FormChoiceModel> choices;

  FormQuestionModel({
    required this.id,
    required this.order,
    required this.text,
    required this.type,
    required this.required,
    this.scaleMin,
    this.scaleMax,
    this.scaleStep,
    required this.choices,
  });

  factory FormQuestionModel.fromJson(Map<String, dynamic> json) {
    return FormQuestionModel(
      id: json['id'] ?? '',
      order: json['order'] ?? 0,
      text: json['text'] ?? '',
      type: json['type'] ?? '',
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
  final int order;
  final String label;

  FormChoiceModel({required this.id, required this.order, required this.label});

  factory FormChoiceModel.fromJson(Map<String, dynamic> json) {
    return FormChoiceModel(
      id: json['id'] ?? '',
      order: json['order'] ?? 0,
      label: json['label'] ?? '',
    );
  }
}

class SubmitFormResponseModel {
  final String submissionId;
  final String status;
  final String submittedAt;

  SubmitFormResponseModel({
    required this.submissionId,
    required this.status,
    required this.submittedAt,
  });

  factory SubmitFormResponseModel.fromJson(Map<String, dynamic> json) {
    return SubmitFormResponseModel(
      submissionId: json['submissionId'] ?? '',
      status: json['status'] ?? '',
      submittedAt: json['submittedAt'] ?? '',
    );
  }
}
