part of '../../../screens/patients_info.dart';

class _PatientReadonlySummary extends StatelessWidget {
  final PatientModel patient;

  const _PatientReadonlySummary({required this.patient});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryInfoItem(
        icon: Icons.badge_outlined,
        label: 'رقم الملف',
        value: patient.displayCrn,
      ),
      _SummaryInfoItem(
        icon: Icons.phone_outlined,
        label: 'الهاتف',
        value: patient.phone,
      ),
      _SummaryInfoItem(
        icon: Icons.cake_outlined,
        label: 'العمر',
        value: patient.age.toString(),
      ),
      _SummaryInfoItem(
        icon: Icons.event_available_outlined,
        label: 'تاريخ التسجيل',
        value: patient.displayRegistrationDate,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD6EA)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) => item).toList(),
      ),
    );
  }
}

class _SummaryInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cleanValue = value.trim().isEmpty ? '-' : value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1E6EE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFE83E8C), size: 17),
          const SizedBox(width: 7),
          customText(
            text: '$label: ',
            size: 12,
            color: const Color(0xFF7A7890),
            bold: true,
            isCenter: false,
          ),
          customText(
            text: cleanValue,
            size: 12,
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
          ),
        ],
      ),
    );
  }
}

class _EditDialogSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_EditFieldWrapper> children;

  const _EditDialogSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = getScreenWidth(context) < 760;
    final fieldWidth = isSmall ? double.infinity : 350.0;
    final isEnglish = Directionality.of(context) == TextDirection.ltr;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 14, max: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD6EA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE83E8C).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isEnglish
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFFEAF4),
                child: Icon(icon, color: const Color(0xFFE83E8C), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: customText(
                  text: title,
                  size: responsiveSize(context, 0.010, min: 15, max: 18),
                  color: const Color(0xFF271648),
                  bold: true,
                  isEnglish: true,
                  isCenter: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: children.map((item) {
              return SizedBox(
                width: item.fullWidth ? double.infinity : fieldWidth,
                child: item,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EditFieldWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final bool fullWidth;

  const _EditFieldWrapper({
    required this.title,
    required this.child,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = Directionality.of(context) == TextDirection.ltr;

    return Column(
      crossAxisAlignment: isEnglish
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.0075, min: 12, max: 14),
          color: const Color(0xFF2D244C),
          bold: true,
          isCenter: false,
          isEnglish: isEnglish,
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _EditPatientDialogFooter extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _EditPatientDialogFooter({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isPhone = getScreenWidth(context) < 620;
    final saveButton = _EditPatientDialogButton(
      title: isSaving ? 'جاري الحفظ...' : 'حفظ التعديلات',
      icon: Icons.check_rounded,
      isPrimary: true,
      isLoading: isSaving,
      onTap: isSaving ? null : onSave,
    );
    final cancelButton = _EditPatientDialogButton(
      title: 'إلغاء',
      icon: Icons.close_rounded,
      isPrimary: false,
      onTap: isSaving ? null : onCancel,
    );

    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 14, max: 18)),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFFFD6EA))),
      ),
      child: isPhone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [saveButton, const SizedBox(height: 10), cancelButton],
            )
          : Row(
              children: [
                Expanded(child: cancelButton),
                const SizedBox(width: 12),
                Expanded(child: saveButton),
              ],
            ),
    );
  }
}

class _EditPatientDialogButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback? onTap;

  const _EditPatientDialogButton({
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? const Color(0xFFE83E8C) : Colors.white;
    final textColor = isPrimary ? Colors.white : const Color(0xFFE83E8C);
    final borderColor = isPrimary
        ? const Color(0xFFE83E8C)
        : const Color(0xFFFF9BD0);

    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: onTap == null ? color.withOpacity(0.45) : color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: onTap == null
                  ? borderColor.withOpacity(0.45)
                  : borderColor,
            ),
            boxShadow: isPrimary && onTap != null
                ? [
                    BoxShadow(
                      color: const Color(0xFFE83E8C).withOpacity(0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(width: 22, height: 22, child: customLoading())
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      customText(
                        text: title,
                        size: 14,
                        color: textColor,
                        bold: true,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
