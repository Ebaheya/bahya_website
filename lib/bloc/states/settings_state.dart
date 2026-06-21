class SettingsState {
  final bool isLoading;
  final bool isChangingPassword;
  final bool passwordChanged;
  final String? errorMessage;

  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> logs;

  final int page;
  final int pageSize;
  final int total;
final Map<String, String> userNamesById;
  const SettingsState({
    this.isLoading = false,
this.userNamesById = const {},
    this.isChangingPassword = false,
    this.passwordChanged = false,
    this.errorMessage,
    this.user = const {},
    this.logs = const [],
    this.page = 1,
    this.pageSize = 10,
    this.total = 0,
  });

  SettingsState copyWith({
    bool? isLoading,
    bool? isChangingPassword,
    bool? passwordChanged,
    String? errorMessage,
    Map<String, dynamic>? user,
    List<Map<String, dynamic>>? logs,
    int? page,
    Map<String, String>? patientNamesByUserId,
    int? pageSize,
    int? total,
    Map<String, String>? userNamesById,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      passwordChanged: passwordChanged ?? this.passwordChanged,
      errorMessage: errorMessage,
      user: user ?? this.user,
      logs: logs ?? this.logs,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
    userNamesById: userNamesById ?? this.userNamesById,
    );
  }
}
