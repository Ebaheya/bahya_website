part of '../../../screens/doctor/patients_info.dart';

bool get _isEnglishLocale =>
    AppLanguageController.localeNotifier.value.languageCode == 'en';

TextDirection get _activeTextDirection =>
    _isEnglishLocale ? TextDirection.ltr : TextDirection.rtl;

CrossAxisAlignment get _activeCrossAxisStart => CrossAxisAlignment.start;

class _TopActionsBar extends StatelessWidget {
  final TextEditingController searchController;
  final int activeFiltersCount;
  final ValueChanged<String?> onSearchChanged;
  final VoidCallback onReset;
  final VoidCallback onExport;

  const _TopActionsBar({
    required this.searchController,
    required this.activeFiltersCount,
    required this.onSearchChanged,
    required this.onReset,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    if (w < 900) {
      return Column(
        children: [
          CustomFormTextField(
            controller: searchController,
            hintText: localizedText(context, 'ابحث بالاسم أو رقم الملف...'),
           
            keyboardType: CustomTextFieldType.text,
            textDirection: _activeTextDirection,
            suffixIcon: const Icon(Icons.search, color: Color(0xFF7A7890)),
            onChange: onSearchChanged,
            isSearch: true,
            isRequired: false,
            showInlineError: false,
            bordered: false,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionButton(
                title: 'إعادة تعيين',
                icon: Icons.refresh,
                onTap: onReset,
                isPrimary: false,
              ),
              _ActionButton(
                title: 'تصفية',
                icon: Icons.filter_alt_outlined,
                badgeCount: activeFiltersCount,
                onTap: () {},
                isPrimary: false,
              ),
              _ActionButton(
                title: 'تصدير Excel',
                icon: Icons.table_chart_outlined,
                onTap: onExport,
                isPrimary: false,
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        _ActionButton(
          title: 'إعادة تعيين',
          icon: Icons.refresh,
          onTap: onReset,
          isPrimary: false,
        ),
        const SizedBox(width: 14),
        _ActionButton(
          title: 'تصفية',
          icon: Icons.filter_alt_outlined,
          badgeCount: activeFiltersCount,
          onTap: () {},
          isPrimary: false,
        ),
        const SizedBox(width: 14),
        _ActionButton(
          title: 'تصدير Excel',
          icon: Icons.table_chart_outlined,
          onTap: onExport,
          isPrimary: false,
        ),
        const Spacer(),
        SizedBox(
          width: (w * 0.25).clamp(300.0, 430.0),
          child: Container(
            padding: EdgeInsets.all(
              responsiveSize(context, 0.008, min: 10, max: 14),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CustomFormTextField(
              controller: searchController,
              hintText: localizedText(context, 'ابحث بالاسم أو رقم الملف...'),
              keyboardType: CustomTextFieldType.text,
              textDirection: _activeTextDirection,
              suffixIcon: const Icon(Icons.search, color: Color(0xFF7A7890)),
              onChange: onSearchChanged,
              isSearch: true,
              isRequired: false,
              showInlineError: false,
              bordered: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  final String? selectedDiseaseStatus;
  final String? selectedTumorBiology;
  final String? selectedSurgery;
  final String? selectedChemotherapy;
  final String? selectedRadiotherapy;
  final String? selectedHormonalTherapy;
  final String? selectedTargetedTherapy;
  final String? selectedImmunotherapy;

  final List<String> diseaseStatusOptions;
  final List<String> tumorBiologyOptions;
  final List<String> surgeryOptions;
  final List<String> chemotherapyOptions;
  final List<String> yesNoOptions;

  final ValueChanged<String?> onDiseaseStatusChanged;
  final ValueChanged<String?> onTumorBiologyChanged;
  final ValueChanged<String?> onSurgeryChanged;
  final ValueChanged<String?> onChemotherapyChanged;
  final ValueChanged<String?> onRadiotherapyChanged;
  final ValueChanged<String?> onHormonalTherapyChanged;
  final ValueChanged<String?> onTargetedTherapyChanged;
  final ValueChanged<String?> onImmunotherapyChanged;

  const _FiltersPanel({
    required this.selectedDiseaseStatus,
    required this.selectedTumorBiology,
    required this.selectedSurgery,
    required this.selectedChemotherapy,
    required this.selectedRadiotherapy,
    required this.selectedHormonalTherapy,
    required this.selectedTargetedTherapy,
    required this.selectedImmunotherapy,
    required this.diseaseStatusOptions,
    required this.tumorBiologyOptions,
    required this.surgeryOptions,
    required this.chemotherapyOptions,
    required this.yesNoOptions,
    required this.onDiseaseStatusChanged,
    required this.onTumorBiologyChanged,
    required this.onSurgeryChanged,
    required this.onChemotherapyChanged,
    required this.onRadiotherapyChanged,
    required this.onHormonalTherapyChanged,
    required this.onTargetedTherapyChanged,
    required this.onImmunotherapyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.014, min: 16, max: 24),
        vertical: responsiveHeight(context, 0.025, min: 18, max: 28),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: responsiveSize(context, 0.012, min: 12, max: 18),
        runSpacing: responsiveHeight(context, 0.025, min: 14, max: 22),
        alignment: WrapAlignment.end,
        children: [
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'الحالة الحالية للمرض',
            value: selectedDiseaseStatus,
            hint: 'كل الحالات',
            items: diseaseStatusOptions,
            icon: Icons.medical_services_outlined,
            onChanged: onDiseaseStatusChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'البيولوجيا الورمية',
            value: selectedTumorBiology,
            hint: 'كل الأنواع',
            items: tumorBiologyOptions,
            icon: Icons.biotech_outlined,
            onChanged: onTumorBiologyChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العملية الجراحية',
            value: selectedSurgery,
            hint: 'كل الأنواع',
            items: surgeryOptions,
            icon: Icons.local_hospital_outlined,
            onChanged: onSurgeryChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العلاج الكيميائي',
            value: selectedChemotherapy,
            hint: 'كل الحالات',
            items: chemotherapyOptions,
            icon: Icons.science_outlined,
            onChanged: onChemotherapyChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العلاج الإشعاعي',
            value: selectedRadiotherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.radio_button_checked,
            onChanged: onRadiotherapyChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العلاج الهرموني',
            value: selectedHormonalTherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.medication_outlined,
            onChanged: onHormonalTherapyChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العلاج الموجه إن وجد',
            value: selectedTargetedTherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.gps_fixed_rounded,
            onChanged: onTargetedTherapyChanged,
          ),
          _FilterDropdown(
            width: w < 700 ? double.infinity : 260,
            title: 'العلاج المناعي إن وجد',
            value: selectedImmunotherapy,
            hint: 'كل الحالات',
            items: yesNoOptions,
            icon: Icons.health_and_safety_outlined,
            onChanged: onImmunotherapyChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final double width;
  final String title;
  final String? value;
  final String hint;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.width,
    required this.title,
    required this.value,
    required this.hint,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: _activeCrossAxisStart,
        children: [
          customText(
            text: title,
            size: responsiveSize(context, 0.0075, min: 12, max: 14),
            color: const Color(0xFF2D244C),
            bold: true,
            isCenter: false,
          ),
          const SizedBox(height: 8),
          customDropdown(
            context: context,
            value: value,
            hint: hint,
            items: items,
            icon: icon,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final int total;
  final _PatientsSortOption selectedSort;
  final ValueChanged<_PatientsSortOption?> onSortChanged;

  const _ResultsHeader({
    required this.total,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    if (w < 700) {
      return Column(
        crossAxisAlignment: _activeCrossAxisStart,
        children: [
          customText(
            text: 'عدد النتائج: $total مريض',
            size: responsiveSize(context, 0.008, min: 13, max: 15),
            color: const Color(0xFF6B667A),
            bold: true,
            isCenter: false,
          ),
          const SizedBox(height: 12),
          _SortDropdown(value: selectedSort, onChanged: onSortChanged),
        ],
      );
    }

    return Row(
      children: [
        _SortDropdown(value: selectedSort, onChanged: onSortChanged),
        Spacer(),
        customText(
          text: 'عدد النتائج: $total مريض',
          size: responsiveSize(context, 0.008, min: 13, max: 15),
          color: const Color(0xFF6B667A),
          bold: true,
          isCenter: false,
        ),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final _PatientsSortOption value;
  final ValueChanged<_PatientsSortOption?> onChanged;

  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        customText(
          text: 'ترتيب حسب:',
          size: responsiveSize(context, 0.008, min: 12, max: 14),
          color: const Color(0xFF6B667A),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: w < 700 ? 220 : (w * 0.11).clamp(180.0, 230.0),
          child: _SortSelect(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _SortSelect extends StatelessWidget {
  final _PatientsSortOption value;
  final ValueChanged<_PatientsSortOption?> onChanged;

  const _SortSelect({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: responsiveHeight(context, 0.065, min: 48, max: 58),
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 14, max: 16),
        ),
        border: Border.all(color: const Color(0xFFF2C9E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_PatientsSortOption>(
          value: value,
          isExpanded: true,
          alignment: Alignment.center,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black54,
          ),
          selectedItemBuilder: (context) {
            return _PatientsSortOption.values.map((option) {
              return Center(
                child: customText(
                  text: option.label,
                  size: responsiveSize(context, 0.0075, min: 12, max: 14),
                  bold: true,
                  color: const Color(0xFF2B2B2B),
                  maxLines: 1,
                ),
              );
            }).toList();
          },
          items: _PatientsSortOption.values.map((option) {
            return DropdownMenuItem<_PatientsSortOption>(
              value: option,
              alignment: Alignment.center,
              child: customText(
                text: option.label,
                size: responsiveSize(context, 0.0075, min: 12, max: 14),
                color: const Color(0xFF2B2B2B),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
