import 'dart:developer';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/service/login_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

part 'web_service_users.dart';
part 'web_service_forms.dart';
part 'web_service_admin.dart';

enum UserRole { ADMIN, DOCTOR, VOLUNTEER, PATIENT, CALL_CENTER }

class WebService {
  final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

  WebService() {
    setupInterceptors(dio);
  }

  String _apiErrorMessage(Object? data, String fallback) {
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message is List && message.isNotEmpty) {
        return message.map((item) => item.toString()).join('\n');
      }
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (data is String && data.trim().isNotEmpty) return data;
    return fallback;
  }

  Map<String, dynamic> _sortPatientsResponseLocally({
    required Map<String, dynamic> responseData,
    String? sortBy,
    String? sortOrder,
  }) {
    if (sortBy == null || sortBy.trim().isEmpty) return responseData;

    final listKey = _findPatientsListKey(responseData);
    if (listKey == null) return responseData;

    final originalList = responseData[listKey];
    if (originalList is! List) return responseData;

    final sortedList = List<dynamic>.from(originalList);
    final descending = _isDescendingSort(sortOrder);

    sortedList.sort((a, b) {
      final aValue = _patientSortValue(a, sortBy);
      final bValue = _patientSortValue(b, sortBy);
      final result = _compareNullableValues(aValue, bValue);
      return descending ? -result : result;
    });

    return Map<String, dynamic>.from(responseData)..[listKey] = sortedList;
  }

  String? _findPatientsListKey(Map<String, dynamic> data) {
    const possibleKeys = [
      'data',
      'items',
      'patients',
      'results',
      'docs',
      'rows',
    ];

    for (final key in possibleKeys) {
      if (data[key] is List) return key;
    }

    return null;
  }

  bool _isDescendingSort(String? sortOrder) {
    final value = sortOrder?.trim().toLowerCase();
    return value == 'desc' ||
        value == 'descending' ||
        value == 'newest' ||
        value == 'latest' ||
        value == 'z_a';
  }

  dynamic _patientSortValue(dynamic patient, String sortBy) {
    if (patient is! Map) return null;

    final normalizedSortBy = sortBy.trim().toLowerCase();

    final candidates = <String>[
      sortBy,
      normalizedSortBy,
      _snakeToCamel(sortBy),
      ..._sortKeyAliases(normalizedSortBy),
    ];

    for (final key in candidates) {
      if (patient.containsKey(key) && patient[key] != null) {
        return patient[key];
      }
    }

    return null;
  }

  List<String> _sortKeyAliases(String sortBy) {
    switch (sortBy) {
      case 'name':
      case 'fullname':
      case 'full_name':
      case 'patientname':
      case 'patient_name':
        return ['fullName', 'name', 'patientName'];
      case 'crn':
      case 'filenumber':
      case 'file_number':
      case 'displaycrn':
      case 'display_crn':
        return ['crn', 'fileNumber', 'displayCrn'];
      case 'age':
        return ['age'];
      case 'createdat':
      case 'created_at':
      case 'registrationdate':
      case 'registration_date':
      case 'date':
        return ['createdAt', 'registrationDate', 'dateOfRegistration'];
      case 'diagnosisdate':
      case 'diagnosis_date':
      case 'dateofdiagnosis':
      case 'date_of_diagnosis':
        return ['dateOfDiagnosis', 'diagnosisDate'];
      case 'diseasestatus':
      case 'disease_status':
        return ['diseaseStatus'];
      case 'tumorbiology':
      case 'tumor_biology':
        return ['tumorBiology'];
      default:
        return const [];
    }
  }

  String _snakeToCamel(String value) {
    final parts = value.split('_');
    if (parts.length <= 1) return value;

    return parts.first +
        parts.skip(1).map((part) {
          if (part.isEmpty) return part;
          return part[0].toUpperCase() + part.substring(1);
        }).join();
  }

  int _compareNullableValues(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;

    final aDate = _tryParseDate(a);
    final bDate = _tryParseDate(b);
    if (aDate != null && bDate != null) {
      return aDate.compareTo(bDate);
    }

    final aNumber = _tryParseNumber(a);
    final bNumber = _tryParseNumber(b);
    if (aNumber != null && bNumber != null) {
      return aNumber.compareTo(bNumber);
    }

    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }

  DateTime? _tryParseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is! String) return null;
    return DateTime.tryParse(value.trim());
  }

  num? _tryParseNumber(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.trim());
    return null;
  }
}
