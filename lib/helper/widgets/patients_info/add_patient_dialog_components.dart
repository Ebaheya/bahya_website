part of '../../../screens/patients_info.dart';

class _PatientPreview extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController crnController;

  const _PatientPreview({
    required this.nameController,
    required this.crnController,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = _activeTextDirection == TextDirection.ltr;

    return AnimatedBuilder(
      animation: Listenable.merge([nameController, crnController]),
      builder: (context, _) {
        final name = nameController.text.trim().isEmpty
            ? 'اسم المريض'
            : nameController.text.trim();
        final crn = crnController.text.trim().isEmpty
            ? 'CRN'
            : crnController.text.trim();

        return Directionality(
          textDirection: _activeTextDirection,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE83E8C),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  child: customText(
                    text: name.isNotEmpty ? name[0] : 'P',
                    size: 22,
                    color: Colors.white,
                    bold: true,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: _activeCrossAxisStart,
                    children: [
                      customText(
                        text: name,
                        size: responsiveSize(context, 0.011, min: 16, max: 20),
                        color: Colors.white,
                        bold: true,
                        isCenter: false,
                        align: isEnglish ? TextAlign.left : TextAlign.right,
                        maxLines: 1,
                        isEnglish: isEnglish,
                      ),
                      const SizedBox(height: 4),
                      customText(
                        text: crn,
                        size: responsiveSize(context, 0.008, min: 12, max: 14),
                        color: Colors.white.withValues(alpha: 0.82),
                        bold: true,
                        isCenter: false,
                        align: isEnglish ? TextAlign.left : TextAlign.right,
                        isEnglish: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _DialogHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isEnglish = _activeTextDirection == TextDirection.ltr;

    return Directionality(
      textDirection: _activeTextDirection,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFFFEAF4),
              child: Icon(Icons.person_add_alt_1, color: Color(0xFFE83E8C)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: _activeCrossAxisStart,
                children: [
                  customText(
                    text: 'إضافة مريض جديد',
                    size: responsiveSize(context, 0.012, min: 18, max: 22),
                    color: const Color(0xFF271648),
                    bold: true,
                    isCenter: false,
                    align: isEnglish ? TextAlign.left : TextAlign.right,
                    isEnglish: isEnglish,
                  ),
                  customText(
                    text: 'بيانات المريض والحالة السريرية في مكان واحد',
                    size: responsiveSize(context, 0.0075, min: 12, max: 14),
                    color: const Color(0xFF7A7890),
                    bold: true,
                    isCenter: false,
                    align: isEnglish ? TextAlign.left : TextAlign.right,
                    maxLines: 1,
                    isEnglish: isEnglish,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, color: Color(0xFFE83E8C)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DialogSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final fieldWidth = w < 760 ? double.infinity : 310.0;
    final isEnglish = _activeTextDirection == TextDirection.ltr;

    return Directionality(
      textDirection: _activeTextDirection,
      child: Container(
        padding: EdgeInsets.all(
          responsiveSize(context, 0.012, min: 14, max: 18),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF7D6E6)),
        ),
        child: Column(
          crossAxisAlignment: _activeCrossAxisStart,
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
                    size: responsiveSize(context, 0.01, min: 15, max: 18),
                    color: const Color(0xFF271648),
                    bold: true,
                    isCenter: false,
                    align: isEnglish ? TextAlign.left : TextAlign.right,
                    isEnglish: isEnglish,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              textDirection: _activeTextDirection,
              spacing: 16,
              runSpacing: 16,
              alignment: isEnglish ? WrapAlignment.start : WrapAlignment.end,
              children: children.map((child) {
                final isFullWidth =
                    child is _TextDialogField && child.fullWidth;
                return SizedBox(
                  width: isFullWidth ? double.infinity : fieldWidth,
                  child: child,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextDialogField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hint;
  final CustomTextFieldType type;
  final bool obscure;
  final bool requiredField;
  final bool isEnglish;
  final int maxLines;
  final int minLines;
  final bool fullWidth;

  const _TextDialogField({
    required this.title,
    required this.controller,
    required this.hint,
    required this.type,
    this.obscure = false,
    this.requiredField = true,
    this.isEnglish = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogField(
      title: title,
      forceEnglish: isEnglish,
      child: Directionality(
        textDirection: isEnglish ? TextDirection.ltr : _activeTextDirection,
        child: CustomFormTextField(
          controller: controller,
          hintText: localizedText(context, hint),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: type,
          obscureText: obscure,
          isRequired: requiredField,
          showInlineError: true,
          maxLines: maxLines,
          minLines: minLines,
          textDirection: isEnglish ? TextDirection.ltr : _activeTextDirection,
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final String title;
  final Widget child;
  final bool forceEnglish;

  const _DialogField({
    required this.title,
    required this.child,
    this.forceEnglish = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = forceEnglish || _activeTextDirection == TextDirection.ltr;

    return Directionality(
      textDirection: forceEnglish ? TextDirection.ltr : _activeTextDirection,
      child: Column(
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
            align: isEnglish ? TextAlign.left : TextAlign.right,
            isEnglish: isEnglish,
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _GenderPicker extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const _GenderPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isEnglish = _activeTextDirection == TextDirection.ltr;

    const options = [
      _GenderOption(label: 'أنثى', value: 'FEMALE', icon: Icons.female),
      _GenderOption(label: 'ذكر', value: 'MALE', icon: Icons.male),
      _GenderOption(label: 'أخرى', value: 'OTHER', icon: Icons.person_outline),
    ];

    return _DialogField(
      title: 'الجنس',
      child: Wrap(
        textDirection: _activeTextDirection,
        alignment: isEnglish ? WrapAlignment.start : WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final selected = value == option.value;

          return InkWell(
            onTap: () => onChanged(option.value),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE83E8C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFE83E8C)
                      : const Color(0xFFF7CFE0),
                ),
              ),
              child: Row(
                textDirection: _activeTextDirection,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option.icon,
                    size: 18,
                    color: selected ? Colors.white : const Color(0xFFE83E8C),
                  ),
                  const SizedBox(width: 7),
                  customText(
                    text: option.label,
                    size: 13,
                    color: selected ? Colors.white : const Color(0xFFE83E8C),
                    bold: true,
                    isEnglish: isEnglish,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GenderOption {
  final String label;
  final String value;
  final IconData icon;

  const _GenderOption({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _DialogDropdown extends StatelessWidget {
  final String title;
  final String? value;
  final String hint;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DialogDropdown({
    required this.title,
    required this.value,
    required this.hint,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogField(
      title: title,
      child: Directionality(
        textDirection: _activeTextDirection,
        child: customDropdown(
          context: context,
          value: value,
          hint: hint,
          items: items,
          icon: icon,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _DialogFooter({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isPhone = getScreenWidth(context) < 620;
    final isEnglish = _activeTextDirection == TextDirection.ltr;

    final cancelButton = _DialogButton(
      title: 'إلغاء',
      icon: Icons.close,
      isPrimary: false,
      onTap: isSaving ? null : onCancel,
    );

    final saveButton = _DialogButton(
      title: isSaving ? 'جاري الحفظ...' : 'حفظ المريض',
      icon: Icons.check,
      isPrimary: true,
      isLoading: isSaving,
      onTap: isSaving ? null : onSave,
    );

    final buttons = isEnglish
        ? [cancelButton, saveButton]
        : [saveButton, cancelButton];

    return Directionality(
      textDirection: _activeTextDirection,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: isPhone
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buttons,
              )
            : Row(
                children: buttons
                    .map((button) => Expanded(child: button))
                    .toList(),
              ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback? onTap;

  const _DialogButton({
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = _activeTextDirection == TextDirection.ltr;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFFE83E8C) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary ? const Color(0xFFE83E8C) : Colors.grey.shade300,
            ),
          ),
          child: Row(
            textDirection: _activeTextDirection,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(width: 18, height: 18, child: customLoading())
              else
                Icon(
                  icon,
                  size: 18,
                  color: isPrimary ? Colors.white : const Color(0xFFE83E8C),
                ),
              const SizedBox(width: 8),
              customText(
                text: title,
                size: 13,
                color: isPrimary ? Colors.white : const Color(0xFFE83E8C),
                bold: true,
                isEnglish: isEnglish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
