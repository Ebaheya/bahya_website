part of '../../../screens/patients_info.dart';

enum _PatientsSortOption {
  newest('تاريخ التسجيل الأحدث', 'createdAt', 'desc'),
  oldest('تاريخ التسجيل الأقدم', 'createdAt', 'asc'),
  nameAsc('الاسم من أ إلى ي', 'fullName', 'asc'),
  nameDesc('الاسم من ي إلى أ', 'fullName', 'desc'),
  ageAsc('العمر الأصغر', 'dateOfBirth', 'desc'),
  ageDesc('العمر الأكبر', 'dateOfBirth', 'asc');

  final String label;
  final String apiField;
  final String apiOrder;

  const _PatientsSortOption(this.label, this.apiField, this.apiOrder);
}
