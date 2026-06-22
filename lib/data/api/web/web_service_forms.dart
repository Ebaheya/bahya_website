part of 'web_service.dart';

extension WebServiceForms on WebService {
  Future<void> createForm({required Map<String, dynamic> body}) async {
    try {
      final res = await dio.post('/forms', data: body);

      if (res.statusCode == 201 || res.statusCode == 200) {
        log("Form created successfully: ${res.data}");
        return;
      }

      throw Exception('Failed to create form');
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to create form',
        ),
      );
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error');
    }
  }

  Future<Map<String, dynamic>> getForms() async {
    try {
      return await dio.get('/forms').then((res) => res.data);
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to get all user info');
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Unexpected error');
    }
  }

  Future<void> publishFormVersion({required String formId}) async {
    try {
      await dio.post('/forms/$formId/publish-version');
    } on DioException catch (e) {
      debugPrint(
        "Publish version DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(e.response?.data ?? 'Failed to publish form version');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<void> publishForm({
    required String formId,
    required Map<String, dynamic> body,
  }) async {
    try {
      await dio.post('/forms/$formId/publish', data: body);
    } on DioException catch (e) {
      debugPrint("Publish DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to publish form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getPatient({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await dio.get(
      '/patients/options',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
        'page': page,
        'pageSize': pageSize,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getPatients({
    String? search,
    String? diseaseStatus,
    String? tumorBiology,
    String? surgery,
    String? chemotherapy,
    bool? radiotherapy,
    bool? hormonalTherapy,
    bool? targetedTherapy,
    bool? immunotherapy,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        '/patients',
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
          if (diseaseStatus != null) 'diseaseStatus': diseaseStatus,
          if (tumorBiology != null) 'tumorBiology': tumorBiology,
          if (surgery != null) 'surgery': surgery,
          if (chemotherapy != null) 'chemotherapy': chemotherapy,
          if (radiotherapy != null) 'radiotherapy': radiotherapy,
          if (hormonalTherapy != null) 'hormonalTherapy': hormonalTherapy,
          if (targetedTherapy != null) 'targetedTherapy': targetedTherapy,
          if (immunotherapy != null) 'immunotherapy': immunotherapy,
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = Map<String, dynamic>.from(response.data);

      return _sortPatientsResponseLocally(
        responseData: data,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } on DioException catch (e) {
      debugPrint("Patients DioException: ${e.response?.data ?? e.message}");
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get patients',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getVolunteer({
    String? search,
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final response = await dio.get(
        '/volunteers',
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
          'page': page,
          'pageSize': pageSize,
        },
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint("Publish DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to publish form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getFormAssignments({
    required String formId,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await dio.get(
        '/forms/$formId/assignments',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      return response.data;
    } on DioException catch (e) {
      debugPrint("Publish DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to publish form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getPatientById(String patientId) async {
    try {
      final response = await dio.get('/patients/$patientId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      debugPrint(
        "Patient detail DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get patient',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getFormById(String formId) async {
    try {
      final response = await dio.get('/forms/$formId');
      return response.data;
    } on DioException catch (e) {
      debugPrint("Get form DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to get form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> updateForm({
    required String formId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.put('/forms/$formId', data: body);
      return response.data;
    } on DioException catch (e) {
      debugPrint("Update form DioException: ${e.response?.data ?? e.message}");
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to update form',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> createAssessment({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.post('/assessments', data: body);
      return response.data;
    } on DioException catch (e) {
      debugPrint(
        "Create assessment DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(e.response?.data ?? 'Failed to create assessment');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<dynamic> getPendingSubmissions() async {
    try {
      final response = await dio.get('/assessments/submissions/pending');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get pending submissions',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getSubmissionById(String submissionId) async {
    try {
      final response = await dio.get('/assessments/submissions/$submissionId');
      return response.data;
    } on DioException catch (e) {
      debugPrint("Submission DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to get submission');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<dynamic> getPatientAssessments(String patientId) async {
    try {
      final response = await dio.get('/assessments/patient/$patientId');
      return response.data;
    } on DioException catch (e) {
      debugPrint(
        "Patient assessments DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(e.response?.data ?? 'Failed to get patient assessments');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getAssessmentById(String assessmentId) async {
    try {
      final response = await dio.get('/assessments/$assessmentId');
      return response.data;
    } on DioException catch (e) {
      debugPrint("Assessment DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to get assessment');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<void> deleteForm({required String formId}) async {
    try {
      await dio.delete('/forms/$formId');
    } on DioException catch (e) {
      debugPrint("Delete Form DioException: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data ?? 'Failed to delete form');
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<void> changeFormStatus({
    required String formId,
    required bool isActive,
  }) async {
    await dio.patch('/forms/$formId/status', data: {"isActive": isActive});
  }

  Future<List<Map<String, dynamic>>> getMyFormAssignments() async {
    try {
      final response = await dio.get('/form-assignments/my');

      final data = response.data;

      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint(
        "My assignments DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get assignments',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> getFormAssignmentById(
    String assignmentId,
  ) async {
    try {
      final response = await dio.get('/form-assignments/$assignmentId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      debugPrint(
        "Assignment detail DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get assignment',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<Map<String, dynamic>> submitFormAssignment({
    required String assignmentId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.post(
        '/form-assignments/$assignmentId/submit',
        data: body,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      debugPrint(
        "Submit assignment DioException: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to submit assignment',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<dynamic> getSubmissionDetails(String submissionId) async {
    try {
      final response = await dio.get('/assessments/submissions/$submissionId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to get submission details',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<dynamic> createOfficialAssessment({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await dio.post('/assessments', data: body);
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to create official assessment',
        ),
      );
    } catch (e) {
      throw Exception('Unexpected error : $e');
    }
  }

  Future<void> cancelFormAssignment({required String assignmentId}) async {
    try {
      final response = await dio.patch(
        '/form-assignments/$assignmentId/cancel',
      );

      debugPrint("Cancel assignment success: ${response.data}");
    } on DioException catch (e) {
      debugPrint(
        "Cancel assignment DioException: ${e.response?.data ?? e.message}",
      );

      throw Exception(
        _apiErrorMessage(
          e.response?.data ?? e.message,
          'Failed to cancel assignment',
        ),
      );
    } catch (e) {
      debugPrint("Cancel assignment unexpected error: $e");
      throw Exception('Unexpected error : $e');
    }
  }
}
