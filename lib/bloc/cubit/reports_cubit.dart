import 'package:bahya_website/bloc/states/reports_state.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this.repo) : super(const ReportsState());

  final AppRepository repo;

  Future<void> loadReports({
    String status = "All Status",
    String search = "",
    int page = 1,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final summary = await repo.getReportsSummary();
      final reportsResponse = await repo.getReports(
        status: _apiStatus(status),
        search: search,
        page: page,
        pageSize: state.pageSize,
      );

      emit(
        state.copyWith(
          isLoading: false,
          reports: List<Map<String, dynamic>>.from(
            (reportsResponse['data'] ?? []).map(
              (e) => Map<String, dynamic>.from(e),
            ),
          ),
          pending: summary['pending'] ?? 0,
          investigating: summary['investigating'] ?? 0,
          resolved: summary['resolved'] ?? 0,
          total: reportsResponse['total'] ?? 0,
          page: reportsResponse['page'] ?? page,
          selectedStatus: status,
          search: search,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> changeStatus({
    required String reportId,
    required String status,
  }) async {
    emit(state.copyWith(isChangingStatus: true, errorMessage: null));

    try {
      await repo.changeReportStatus(
        reportId: reportId,
        status: _apiStatus(status) ?? status,
      );

      await loadReports(
        status: state.selectedStatus,
        search: state.search,
        page: state.page,
      );
    } catch (e) {
      emit(state.copyWith(isChangingStatus: false, errorMessage: e.toString()));
    }
  }

  String? _apiStatus(String status) {
    switch (status) {
      case "Pending":
        return "PENDING";
      case "Investigating":
        return "INVESTIGATING";
      case "Resolved":
        return "RESOLVED";
      case "All Status":
        return null;
      default:
        return status;
    }
  }
}
