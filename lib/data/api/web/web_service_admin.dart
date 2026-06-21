part of 'web_service.dart';

extension WebServiceAdmin on WebService {
  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String fullName,
  }) async {
    final res = await dio.patch('/users/$userId', data: {"fullName": fullName});
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> changeUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    final res = await dio.patch(
      '/users/$userId/status',
      data: {"isActive": isActive},
    );
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> triggerUserReset({required String userId}) async {
    await dio.post('/users/$userId/trigger-reset');
  }

  Future<Map<String, dynamic>> updatePatientClinical({
    required String patientId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final requestBody = Map<String, dynamic>.from(body)
        ..removeWhere((key, value) => value == null);

      final res = await dio.patch('/patients/$patientId', data: requestBody);

      final data = res.data;
      if (data is Map && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data']);
      }

      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      debugPrint(
        "Update patient DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to update patient',
        ),
      );
    } catch (e) {
      debugPrint("Unexpected update patient error: $e");
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final res = await dio.get('/dashboard/summary');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get dashboard summary',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getDashboardActivity({int limit = 10}) async {
    try {
      final res = await dio.get(
        '/dashboard/activity',
        queryParameters: {'limit': limit},
      );
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get dashboard activity',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getReportsSummary() async {
    try {
      final res = await dio.get('/reports/summary');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get reports summary',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getReports({
    String? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final res = await dio.get(
        '/reports',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
          if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
          'page': page,
          'pageSize': pageSize,
        },
      );
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get reports',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getReportDetail(String reportId) async {
    try {
      final res = await dio.get('/reports/$reportId');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get report detail',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> changeReportStatus({
    required String reportId,
    required String status,
  }) async {
    try {
      final res = await dio.patch(
        '/reports/$reportId/status',
        data: {'status': status},
      );
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to change report status',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> fileReport({
    required String title,
    required String body,
  }) async {
    try {
      final res = await dio.post(
        '/reports',
        data: {'title': title, 'body': body},
      );
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to file report',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getAuditLogs({
    String? action,
    String? actorId,
    String? from,
    String? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final res = await dio.get(
        '/audit-logs',
        queryParameters: {
          if (action != null && action.isNotEmpty) 'action': action,
          if (actorId != null && actorId.isNotEmpty) 'actorId': actorId,
          if (from != null && from.isNotEmpty) 'from': from,
          if (to != null && to.isNotEmpty) 'to': to,
          'page': page,
          'pageSize': pageSize,
        },
      );
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get audit logs',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getAuditLogDetail(String auditId) async {
    try {
      final res = await dio.get('/audit-logs/$auditId');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get audit log detail',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final res = await dio.get('/users/$id');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get audit log detail',
        ),
      );
    }
  }
}
