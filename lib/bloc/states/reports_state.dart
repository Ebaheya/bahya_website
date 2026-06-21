class ReportsState {
  final bool isLoading;
  final bool isChangingStatus;
  final String? errorMessage;

  final List<Map<String, dynamic>> reports;

  final int pending;
  final int investigating;
  final int resolved;

  final int page;
  final int pageSize;
  final int total;

  final String selectedStatus;
  final String search;

  const ReportsState({
    this.isLoading = false,
    this.isChangingStatus = false,
    this.errorMessage,
    this.reports = const [],
    this.pending = 0,
    this.investigating = 0,
    this.resolved = 0,
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.selectedStatus = "All Status",
    this.search = "",
  });

  ReportsState copyWith({
    bool? isLoading,
    bool? isChangingStatus,
    String? errorMessage,
    List<Map<String, dynamic>>? reports,
    int? pending,
    int? investigating,
    int? resolved,
    int? page,
    int? pageSize,
    int? total,
    String? selectedStatus,
    String? search,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      isChangingStatus: isChangingStatus ?? this.isChangingStatus,
      errorMessage: errorMessage,
      reports: reports ?? this.reports,
      pending: pending ?? this.pending,
      investigating: investigating ?? this.investigating,
      resolved: resolved ?? this.resolved,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      search: search ?? this.search,
    );
  }
}
