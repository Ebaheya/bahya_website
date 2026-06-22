part of 'patients_list.dart';

extension _PatientsListContent on _PatientsListWidgetState {
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
      hintText: context.l10n.searchForPatientOrQuestionnaire,
      isSearch: true,
      bordered: true,
      centerHint: false,
      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFE40070)),
      onChange: (_) {
        _updateState(() => currentPage = 0);
      },
     
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
              ).withValues(alpha: isSelected ? 0.10 : 0.04),
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
                        color: statusColor.withValues(alpha: 0.10),
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
