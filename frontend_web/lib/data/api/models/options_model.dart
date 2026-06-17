class OptionUserModel {
  final String id;
  final String fullName;

  OptionUserModel({required this.id, required this.fullName});

  factory OptionUserModel.fromJson(Map<String, dynamic> json) {
    return OptionUserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }
}

class OptionsResponseModel {
  final List<OptionUserModel> data;
  final int page;
  final int pageSize;
  final int total;

  OptionsResponseModel({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory OptionsResponseModel.fromJson(Map<String, dynamic> json) {
    return OptionsResponseModel(
      data: (json['data'] as List? ?? [])
          .map((e) => OptionUserModel.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}
