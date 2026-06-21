import 'dart:math' as math;

import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class PatientsListWidget extends StatefulWidget {
  const PatientsListWidget({
    super.key,
    required this.assignments,
    required this.selectedAssignmentId,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> assignments;
  final String? selectedAssignmentId;
  final ValueChanged<Map<String, dynamic>> onSelect;

  @override
  State<PatientsListWidget> createState() => _PatientsListWidgetState();
}

class _PatientsListWidgetState extends State<PatientsListWidget> {
  final TextEditingController searchController = TextEditingController();

  int currentPage = 0;
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _debugAssignments(widget.assignments);
  }

  @override
  void didUpdateWidget(covariant PatientsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.assignments != widget.assignments) {
      currentPage = 0;
      _debugAssignments(widget.assignments);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _debugAssignments(List<Map<String, dynamic>> assignments) {
    debugPrint('================ VOLUNTEER ASSIGNMENTS ================');
    debugPrint('Assignments Count: ${assignments.length}');

    for (int i = 0; i < assignments.length; i++) {
      final assignment = assignments[i];

      debugPrint('---------------- Assignment #${i + 1} ----------------');
      debugPrint(assignment.toString());

      assignment.forEach((key, value) {
        debugPrint('$key => $value');
      });

      debugPrint('Resolved patient name => ${_patientName(assignment)}');
      debugPrint('Resolved form name => ${_formName(assignment)}');
      debugPrint('Resolved status => ${_statusText(assignment)}');
    }

    debugPrint('========================================================');
  }

  List<Map<String, dynamic>> get _filteredAssignments {
    final q = searchController.text.trim().toLowerCase();

    if (q.isEmpty) return widget.assignments;

    return widget.assignments.where((assignment) {
      final patientName = _patientName(assignment).toLowerCase();
      final formName = _formName(assignment).toLowerCase();
      final crn = _patientCrn(assignment).toLowerCase();

      return patientName.contains(q) || formName.contains(q) || crn.contains(q);
    }).toList();
  }

  int get _totalPages {
    if (_filteredAssignments.isEmpty) return 1;
    return (_filteredAssignments.length / itemsPerPage).ceil();
  }

  List<Map<String, dynamic>> get _visibleAssignments {
    final list = _filteredAssignments;
    final start = currentPage * itemsPerPage;
    final end = math.min(start + itemsPerPage, list.length);

    if (start >= list.length) return [];
    return list.sublist(start, end);
  }

  String _valueFromMap(Map data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }

  String _patientName(Map<String, dynamic> assignment) {
    final direct = _valueFromMap(assignment, [
      'patientName',
      'patientFullName',
      'fullName',
      'name',
    ]);

    if (direct.isNotEmpty) return direct;

    final patient = assignment['patient'];
    if (patient is Map) {
      final fromPatient = _valueFromMap(patient, [
        'fullName',
        'name',
        'patientName',
        'displayName',
        'email',
      ]);

      if (fromPatient.isNotEmpty) return fromPatient;

      final user = patient['user'];
      if (user is Map) {
        final fromUser = _valueFromMap(user, [
          'fullName',
          'name',
          'displayName',
          'username',
          'email',
        ]);

        if (fromUser.isNotEmpty) return fromUser;
      }

      final appUser = patient['appUser'];
      if (appUser is Map) {
        final fromAppUser = _valueFromMap(appUser, [
          'fullName',
          'name',
          'displayName',
          'username',
          'email',
        ]);

        if (fromAppUser.isNotEmpty) return fromAppUser;
      }
    }

    final patientDetails = assignment['patientDetails'];
    if (patientDetails is Map) {
      final data = patientDetails['data'];

      if (data is Map) {
        final fromData = _valueFromMap(data, [
          'fullName',
          'name',
          'patientName',
          'displayName',
          'email',
        ]);

        if (fromData.isNotEmpty) return fromData;

        final user = data['user'];
        if (user is Map) {
          final fromUser = _valueFromMap(user, [
            'fullName',
            'name',
            'displayName',
            'username',
            'email',
          ]);

          if (fromUser.isNotEmpty) return fromUser;
        }

        final appUser = data['appUser'];
        if (appUser is Map) {
          final fromAppUser = _valueFromMap(appUser, [
            'fullName',
            'name',
            'displayName',
            'username',
            'email',
          ]);

          if (fromAppUser.isNotEmpty) return fromAppUser;
        }
      }

      final fromDetails = _valueFromMap(patientDetails, [
        'fullName',
        'name',
        'patientName',
        'displayName',
        'email',
      ]);

      if (fromDetails.isNotEmpty) return fromDetails;

      final user = patientDetails['user'];
      if (user is Map) {
        final fromUser = _valueFromMap(user, [
          'fullName',
          'name',
          'displayName',
          'username',
          'email',
        ]);

        if (fromUser.isNotEmpty) return fromUser;
      }

      final appUser = patientDetails['appUser'];
      if (appUser is Map) {
        final fromAppUser = _valueFromMap(appUser, [
          'fullName',
          'name',
          'displayName',
          'username',
          'email',
        ]);

        if (fromAppUser.isNotEmpty) return fromAppUser;
      }
    }

    return 'مريض بدون اسم';
  }

  String _patientCrn(Map<String, dynamic> assignment) {
    final direct = _valueFromMap(assignment, [
      'crn',
      'patientCrn',
      'fileNumber',
      'medicalNumber',
    ]);

    if (direct.isNotEmpty) return direct;

    final patientDetails = assignment['patientDetails'];
    if (patientDetails is Map) {
      final data = patientDetails['data'];

      if (data is Map) {
        final fromData = _valueFromMap(data, [
          'crn',
          'fileNumber',
          'medicalNumber',
          'displayCrn',
        ]);

        if (fromData.isNotEmpty) return fromData;
      }

      final fromDetails = _valueFromMap(patientDetails, [
        'crn',
        'fileNumber',
        'medicalNumber',
        'displayCrn',
      ]);

      if (fromDetails.isNotEmpty) return fromDetails;
    }

    final patient = assignment['patient'];
    if (patient is Map) {
      return _valueFromMap(patient, [
        'crn',
        'fileNumber',
        'medicalNumber',
        'displayCrn',
      ]);
    }

    return '';
  }

  String _formName(Map<String, dynamic> assignment) {
    final direct = _valueFromMap(assignment, [
      'formName',
      'templateName',
      'assessmentName',
      'name',
      'title',
    ]);

    if (direct.isNotEmpty) return direct;

    final template = assignment['template'];
    if (template is Map) {
      final value = _valueFromMap(template, ['name', 'title', 'key']);
      if (value.isNotEmpty) return value;
    }

    final form = assignment['form'];
    if (form is Map) {
      final value = _valueFromMap(form, ['name', 'title', 'key']);
      if (value.isNotEmpty) return value;
    }

    final formVersion = assignment['formVersion'];
    if (formVersion is Map) {
      final value = _valueFromMap(formVersion, ['name', 'title', 'key']);
      if (value.isNotEmpty) return value;
    }

    return 'استبيان';
  }

  String _statusText(Map<String, dynamic> assignment) {
    final status = assignment['status']?.toString().toUpperCase() ?? '';

    switch (status) {
      case 'PUBLISHED':
      case 'OPEN':
      case 'ASSIGNED':
      case 'SCHEDULED':
        return 'متاح';
      case 'SUBMITTED':
        return 'تم الحفظ';
      case 'REVIEWED':
        return 'تمت المراجعة';
      case 'CANCELLED':
        return 'ملغي';
      default:
        return status.isEmpty ? 'غير معروف' : status;
    }
  }

  bool _isDone(Map<String, dynamic> assignment) {
    final status = assignment['status']?.toString().toUpperCase() ?? '';
    return status == 'SUBMITTED' || status == 'REVIEWED';
  }

  Color _statusColor(Map<String, dynamic> assignment) {
    if (_isDone(assignment)) return const Color(0xFF16A34A);

    final status = assignment['status']?.toString().toUpperCase() ?? '';

    if (status == 'CANCELLED') return Colors.grey;

    return const Color(0xFFE40070);
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages) return;
    setState(() => currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 700;

    final titleSize = responsiveSize(context, 0.012, min: 18, max: 24);
    final countSize = responsiveSize(context, 0.009, min: 13, max: 16);
    final padding = responsiveSize(context, 0.018, min: 14, max: 22);
    final radius = responsiveSize(context, 0.022, min: 20, max: 28);
    final gap = responsiveHeight(context, 0.012, min: 10, max: 14);

    return Container(
      width: isMobile ? double.infinity : 370,
      height: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A004C).withOpacity(0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _header(titleSize, countSize),
            SizedBox(
              height: responsiveHeight(context, 0.022, min: 16, max: 22),
            ),
            _searchBar(),
            SizedBox(
              height: responsiveHeight(context, 0.022, min: 16, max: 22),
            ),
            Expanded(
              child: _visibleAssignments.isEmpty
                  ? _emptyResult()
                  : ListView.separated(
                      itemCount: _visibleAssignments.length,
                      separatorBuilder: (_, __) => SizedBox(height: gap),
                      itemBuilder: (context, index) {
                        final assignment = _visibleAssignments[index];
                        final id = assignment['id']?.toString();
                        final isSelected = id == widget.selectedAssignmentId;

                        return _patientCard(
                          assignment: assignment,
                          isSelected: isSelected,
                        );
                      },
                    ),
            ),
            if (_filteredAssignments.length > itemsPerPage) ...[
              SizedBox(
                height: responsiveHeight(context, 0.018, min: 12, max: 18),
              ),
              _pagination(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(double titleSize, double countSize) {
    return Row(
      children: [
        Container(
          width: responsiveSize(context, 0.044, min: 46, max: 58),
          height: responsiveSize(context, 0.044, min: 46, max: 58),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEAF5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.assignment_ind_rounded,
            color: Color(0xFFE40070),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            customText(
              text: "المرضى المسندين",
              size: titleSize,
              bold: true,
              color: const Color(0xFF7A004C),
              isCenter: false,
            ),
            SizedBox(height: responsiveHeight(context, 0.004, min: 3, max: 5)),
            customText(
              text: "${widget.assignments.length} تكليف",
              size: countSize,
              color: const Color(0xFFE40070),
              bold: true,
              isCenter: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _searchBar() {
    return CustomFormTextField(
      controller: searchController,
      keyboardType: CustomTextFieldType.name,
      hintText: 'ابحث عن مريض أو استبيان...',
      isSearch: true,
      bordered: true,
      centerHint: false,
      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFE40070)),
      onChange: (_) {
        setState(() => currentPage = 0);
      }, autovalidateMode: AutovalidateMode.disabled,
    );
  }

  Widget _emptyResult() {
    return Center(
      child: customText(
        text: "لا توجد نتائج",
        size: responsiveSize(context, 0.011, min: 15, max: 18),
        color: Colors.grey,
        bold: true,
      ),
    );
  }

  Widget _patientCard({
    required Map<String, dynamic> assignment,
    required bool isSelected,
  }) {
    final patientName = _patientName(assignment);
    final formName = _formName(assignment);
    final crn = _patientCrn(assignment);
    final status = _statusText(assignment);
    final statusColor = _statusColor(assignment);
    final isDone = _isDone(assignment);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        debugPrint('================ PATIENT CARD SELECTED ================');
        debugPrint(assignment.toString());
        debugPrint('Resolved patientName => $patientName');
        debugPrint('Resolved formName => $formName');
        debugPrint('Resolved crn => $crn');
        debugPrint('=======================================================');

        widget.onSelect(assignment);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.all(
          responsiveSize(context, 0.014, min: 12, max: 16),
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Color(0xFFFFEDF7), Color(0xFFFFFAFD)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF6BAE)
                : const Color(0xFFEFEAF1),
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF7A004C,
              ).withOpacity(isSelected ? 0.10 : 0.04),
              blurRadius: isSelected ? 18 : 12,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: responsiveSize(context, 0.048, min: 48, max: 60),
              height: responsiveSize(context, 0.048, min: 48, max: 60),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFF6F4F8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check_circle_rounded : Icons.person_outline,
                color: isDone
                    ? const Color(0xFF16A34A)
                    : isSelected
                    ? const Color(0xFFE40070)
                    : const Color(0xFF6B7280),
                size: responsiveSize(context, 0.025, min: 22, max: 28),
              ),
            ),
            SizedBox(width: responsiveSize(context, 0.014, min: 10, max: 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  customText(
                    text: patientName,
                    size: responsiveSize(context, 0.01, min: 14, max: 17),
                    bold: true,
                    color: isSelected
                        ? const Color(0xFF7A004C)
                        : const Color(0xFF111827),
                    isCenter: false,
                    maxLines: 1,
                  ),
                  SizedBox(
                    height: responsiveHeight(context, 0.005, min: 4, max: 6),
                  ),
                  customText(
                    text: formName,
                    size: responsiveSize(context, 0.0085, min: 12, max: 14),
                    color: const Color(0xFF6B7280),
                    isCenter: false,
                    maxLines: 1,
                  ),
                  if (crn.isNotEmpty) ...[
                    SizedBox(
                      height: responsiveHeight(context, 0.005, min: 4, max: 6),
                    ),
                    customText(
                      text: crn,
                      size: responsiveSize(context, 0.008, min: 11, max: 13),
                      color: const Color(0xFF9CA3AF),
                      isCenter: false,
                      maxLines: 1,
                    ),
                  ],
                  SizedBox(
                    height: responsiveHeight(context, 0.008, min: 6, max: 9),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveSize(
                          context,
                          0.012,
                          min: 9,
                          max: 12,
                        ),
                        vertical: responsiveHeight(
                          context,
                          0.005,
                          min: 4,
                          max: 6,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: customText(
                        text: status,
                        size: responsiveSize(context, 0.0075, min: 11, max: 12),
                        color: statusColor,
                        bold: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: responsiveSize(context, 0.012, min: 8, max: 12)),
              Container(
                width: 4,
                height: responsiveHeight(context, 0.065, min: 48, max: 68),
                decoration: BoxDecoration(
                  color: const Color(0xFFE40070),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pagination() {
    final buttonSize = responsiveSize(context, 0.032, min: 30, max: 38);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageArrow(
          icon: Icons.keyboard_arrow_right_rounded,
          enabled: currentPage < _totalPages - 1,
          size: buttonSize,
          onTap: () => _goToPage(currentPage + 1),
        ),
        SizedBox(width: responsiveSize(context, 0.008, min: 6, max: 10)),
        ...List.generate(_totalPages, (index) {
          final active = index == currentPage;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.004, min: 3, max: 5),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(99),
              onTap: () => _goToPage(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: buttonSize,
                height: buttonSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFFFF4D8D), Color(0xFFC0178B)],
                        )
                      : null,
                  color: active ? null : const Color(0xFFFFF0F8),
                  border: Border.all(
                    color: active
                        ? Colors.transparent
                        : const Color(0xFFFFC7DF),
                  ),
                ),
                child: customText(
                  text: "${index + 1}",
                  size: responsiveSize(context, 0.0075, min: 11, max: 13),
                  bold: true,
                  color: active ? Colors.white : const Color(0xFF7A004C),
                ),
              ),
            ),
          );
        }),
        SizedBox(width: responsiveSize(context, 0.008, min: 6, max: 10)),
        _pageArrow(
          icon: Icons.keyboard_arrow_left_rounded,
          enabled: currentPage > 0,
          size: buttonSize,
          onTap: () => _goToPage(currentPage - 1),
        ),
      ],
    );
  }

  Widget _pageArrow({
    required IconData icon,
    required bool enabled,
    required double size,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F8),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFC7DF)),
          ),
          child: Icon(icon, size: size * 0.8, color: const Color(0xFFE40070)),
        ),
      ),
    );
  }
}
