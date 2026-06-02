import 'dart:math' as math;

import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class PatientsListWidget extends StatefulWidget {
  final String selectedPatient;
  final Set<String> completedPatients;
  final ValueChanged<String> onSelect;
  const PatientsListWidget({
    super.key,
    required this.selectedPatient,
    required this.completedPatients,
    required this.onSelect,
  });

  @override
  State<PatientsListWidget> createState() => _PatientsListWidgetState();
}

class _PatientsListWidgetState extends State<PatientsListWidget> {
  int currentPage = 0;

  final List<String> patients = const [
    "أسماء محمد",
    "فاطمة علي",
    "منى حسين",
    "سارة أحمد",
    "هدى إبراهيم",
    "نور خالد",
    "مريم حسن",
    "آية محمود",
    "بسمة علي",
    "دينا أحمد",
    "ريم إبراهيم",
    "ملك سامي",
  ];

  int get itemsPerPage => 5;

  int get totalPages {
    if (patients.isEmpty) return 1;
    return (patients.length / itemsPerPage).ceil();
  }

  List<String> get visiblePatients {
    final start = currentPage * itemsPerPage;
    final end = math.min(start + itemsPerPage, patients.length);

    if (start >= patients.length) return [];
    return patients.sublist(start, end);
  }

  void _goToPage(int page) {
    if (page < 0 || page >= totalPages) return;

    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 700;

    final titleSize = responsiveHeight(context, 0.022, min: 16, max: 24);
    final textSize = responsiveHeight(context, 0.017, min: 13, max: 17);
    final subTextSize = responsiveHeight(context, 0.014, min: 11, max: 14);

    final padding = responsiveSize(context, 0.02, min: 14, max: 22);
    final radius = responsiveSize(context, 0.024, min: 20, max: 28);
    final gap = responsiveSize(context, 0.012, min: 8, max: 12);

    return Container(
      width: isMobile ? double.infinity : 330,
      height: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A004C).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: responsiveSize(context, 0.042, min: 42, max: 56),
                height: responsiveSize(context, 0.042, min: 42, max: 56),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAF5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: const Color(0xFFE40070),
                  size: responsiveSize(context, 0.026, min: 22, max: 28),
                ),
              ),
              const Spacer(),
              customText(
                text: "قائمة المرضى",
                size: titleSize,
                bold: true,
                color: const Color(0xFF7A004C),
                isCenter: false,
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.018, min: 14, max: 20)),

          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              height: responsiveHeight(context, 0.052, min: 44, max: 56),
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.016, min: 12, max: 16),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBFD),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF3D7EA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
                  SizedBox(width: gap),
                  Expanded(
                    child: customText(
                      text: "ابحث عن مريض...",
                      size: subTextSize,
                      color: const Color(0xFF9CA3AF),
                      bold: false,
                      isCenter: false,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 22)),

          Expanded(
            child: ListView.separated(
              itemCount: visiblePatients.length,
              separatorBuilder: (_, __) => SizedBox(height: gap),
              itemBuilder: (context, index) {
                final patient = visiblePatients[index];
                final isSelected = patient == widget.selectedPatient;
                final isDone = widget.completedPatients.contains(patient);

                return _patientItem(
                  context: context,
                  patient: patient,
                  isSelected: isSelected,
                  isDone: isDone,
                  textSize: textSize,
                  subTextSize: subTextSize,
                );
              },
            ),
          ),

          if (patients.length > itemsPerPage) ...[
            SizedBox(
              height: responsiveHeight(context, 0.016, min: 12, max: 16),
            ),
            _pagination(context),
          ],

          SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.014, min: 10, max: 14),
              vertical: responsiveHeight(context, 0.012, min: 8, max: 12),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBFD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3D7EA)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customText(
                  text: "${patients.length} مرضى",
                  size: subTextSize,
                  color: const Color(0xFF7A004C),
                  bold: true,
                ),
                SizedBox(width: gap),
                const Icon(
                  Icons.group_rounded,
                  color: Color(0xFFE40070),
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _patientItem({
    required BuildContext context,
    required String patient,
    required bool isSelected,
    required bool isDone,
    required double textSize,
    required double subTextSize,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => widget.onSelect(patient),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.014, min: 12, max: 16),
          vertical: responsiveHeight(context, 0.016, min: 12, max: 18),
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Color(0xFFFFEDF7), Color(0xFFFFF8FC)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF8FC5)
                : const Color(0xFFEFEAF1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF7A004C,
              ).withOpacity(isSelected ? 0.08 : 0.035),
              blurRadius: isSelected ? 16 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: responsiveSize(context, 0.04, min: 40, max: 52),
              height: responsiveSize(context, 0.04, min: 40, max: 52),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFF4F2F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check_circle_rounded : Icons.person_outline,
                color: isDone
                    ? Colors.green
                    : isSelected
                    ? const Color(0xFFE40070)
                    : const Color(0xFF6B7280),
                size: responsiveSize(context, 0.024, min: 22, max: 26),
              ),
            ),
            SizedBox(width: responsiveSize(context, 0.014, min: 10, max: 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  customText(
                    text: patient,
                    size: textSize,
                    bold: true,
                    color: isSelected
                        ? const Color(0xFF7A004C)
                        : const Color(0xFF111827),
                    isCenter: false,
                  ),
                  SizedBox(
                    height: responsiveHeight(context, 0.004, min: 3, max: 5),
                  ),
                  customText(
                    text: "العمر: ${_fakeAge(patient)} سنة",
                    size: subTextSize,
                    bold: false,
                    color: const Color(0xFF6B7280),
                    isCenter: false,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 4,
                height: responsiveHeight(context, 0.06, min: 46, max: 64),
                decoration: BoxDecoration(
                  color: const Color(0xFFE40070),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _fakeAge(String name) {
    final ages = {
      "أسماء محمد": 30,
      "فاطمة علي": 28,
      "منى حسين": 35,
      "سارة أحمد": 27,
      "هدى إبراهيم": 32,
      "نور خالد": 29,
      "مريم حسن": 34,
      "آية محمود": 26,
      "بسمة علي": 31,
      "دينا أحمد": 33,
      "ريم إبراهيم": 25,
      "ملك سامي": 36,
    };

    return ages[name] ?? 30;
  }

  Widget _pagination(BuildContext context) {
    final buttonSize = responsiveSize(context, 0.03, min: 28, max: 36);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageArrow(
          context: context,
          icon: Icons.keyboard_arrow_right_rounded,
          enabled: currentPage < totalPages - 1,
          size: buttonSize,
          onTap: () => _goToPage(currentPage + 1),
        ),
        SizedBox(width: responsiveSize(context, 0.008, min: 6, max: 10)),
        ...List.generate(totalPages, (index) {
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
                  size: responsiveHeight(context, 0.014, min: 11, max: 13),
                  bold: true,
                  color: active ? Colors.white : const Color(0xFF7A004C),
                ),
              ),
            ),
          );
        }),
        SizedBox(width: responsiveSize(context, 0.008, min: 6, max: 10)),
        _pageArrow(
          context: context,
          icon: Icons.keyboard_arrow_left_rounded,
          enabled: currentPage > 0,
          size: buttonSize,
          onTap: () => _goToPage(currentPage - 1),
        ),
      ],
    );
  }

  Widget _pageArrow({
    required BuildContext context,
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
