import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String _translate(BuildContext context, String text) {
  final languageCode = AppLanguageController.localeNotifier.value.languageCode;
  return AppLocalizations.translateByLocaleCode(languageCode, text);
}

Widget scheduleLabel({required BuildContext context, required String title}) {
  return ValueListenableBuilder<Locale>(
    valueListenable: AppLanguageController.localeNotifier,
    builder: (context, locale, _) {
      final isEnglish = locale.languageCode == 'en';

      return Row(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: isEnglish
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
                    if (isEnglish) ...[
          
            Container(
              width: responsiveSize(context, 0.008, min: 8, max: 12),
              height: responsiveSize(context, 0.008, min: 8, max: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFE5007D),
                shape: BoxShape.circle,
              ),
            ),
              SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 8)),
                    ],
          Flexible(
            child: customText(
              text: title,
              size: responsiveSize(context, 0.012, min: 14, max: 24),
              bold: true,
              color: const Color(0xFF2B2B2B),
              maxLines: 2,
              isCenter: false,
              align: isEnglish ? TextAlign.end : TextAlign.start,
              isEnglish: isEnglish,
            ),
          ),
          if (!isEnglish) ...[
            SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 8)),
            Container(
              width: responsiveSize(context, 0.008, min: 8, max: 12),
              height: responsiveSize(context, 0.008, min: 8, max: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFE5007D),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      );
    },
  );
}

Widget schedulePickerField({
  required BuildContext context,
  required String text,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return ValueListenableBuilder<Locale>(
    valueListenable: AppLanguageController.localeNotifier,
    builder: (context, locale, _) {
      final isEnglish = locale.languageCode == 'en';

      return InkWell(
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 14, max: 16),
        ),
        onTap: onTap,
        child: Container(
          height: responsiveHeight(context, 0.07, min: 52, max: 62),
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.012, min: 12, max: 18),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.014, min: 14, max: 16),
            ),
            border: Border.all(color: const Color(0xFFF2C9E0)),
          ),
          child: Row(
            textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
            children: [
              Icon(
                icon,
                color: const Color(0xFF7B1FA2),
                size: responsiveSize(context, 0.014, min: 18, max: 24),
              ),
              const Spacer(),
              customText(
                text: text,
                size: responsiveSize(context, 0.01, min: 13, max: 18),
                color: Colors.black45,
                isEnglish: isEnglish,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget scheduleSingleLineInput({
  required BuildContext context,
  required TextEditingController controller,
  required String hint,
  required IconData icon,
}) {
  return ValueListenableBuilder<Locale>(
    valueListenable: AppLanguageController.localeNotifier,
    builder: (context, locale, _) {
      final isEnglish = locale.languageCode == 'en';

      return Directionality(
        textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
        child: Container(
          height: responsiveHeight(context, 0.06, min: 48, max: 58),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.014, min: 14, max: 16),
            ),
            border: Border.all(color: const Color(0xFFF2C9E0)),
          ),
          child: Center(
            child: CustomFormTextField(
              bordered: false,
              isRequired: false,
              showInlineError: false,
              autovalidateMode: AutovalidateMode.disabled,
              keyboardType: CustomTextFieldType.number,
              controller: controller,
              hintText: hint,
              prefixIcon: Icon(
                icon,
                color: Colors.purple,
                size: responsiveSize(context, 0.012, min: 18, max: 22),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget scheduleCodeInputSection({
  required BuildContext context,
  required String title,
  bool showAddButton = true,
  required String hint,
  required TextEditingController controller,
  required List<String> codes,
  required VoidCallback onAdd,
  required void Function(String code) onRemove,
}) {
  final isMobile = getScreenWidth(context) < 650;

  return ValueListenableBuilder<Locale>(
    valueListenable: AppLanguageController.localeNotifier,
    builder: (context, locale, _) {
      final isEnglish = locale.languageCode == 'en';

      return Column(
        crossAxisAlignment: isEnglish
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          scheduleLabel(context: context, title: title),
          SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 20)),

          if (isMobile)
            Column(
              crossAxisAlignment: isEnglish
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                scheduleSingleLineInput(
                  context: context,
                  controller: controller,
                  hint: hint,
                  icon: Icons.badge_outlined,
                ),
                if (showAddButton) ...[
                  SizedBox(
                    height: responsiveHeight(context, 0.015, min: 12, max: 16),
                  ),
                  CustomGlowButton(
                    title: _translate(context, "إضافة"),
                    onPressed: onAdd,
                    icon: Icons.add_rounded,
                    textColor: Colors.white,
                    backgroundColor: Colors.pinkAccent,
                    glowColor: Colors.pinkAccent.withOpacity(0.6),
                    width: double.infinity,
                    height: responsiveHeight(context, 0.055, min: 44, max: 52),
                    textSize: responsiveSize(context, 0.009, min: 13, max: 16),
                  ),
                ],
              ],
            )
          else
            Row(
              textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
              children: [
                Expanded(
                  child: scheduleSingleLineInput(
                    context: context,
                    controller: controller,
                    hint: hint,
                    icon: Icons.badge_outlined,
                  ),
                ),
                if (showAddButton) ...[
                  SizedBox(
                    width: responsiveSize(context, 0.012, min: 12, max: 16),
                  ),
                  CustomGlowButton(
                    title: _translate(context, "إضافة"),
                    onPressed: onAdd,
                    icon: Icons.add_rounded,
                    textColor: Colors.white,
                    backgroundColor: Colors.pinkAccent,
                    glowColor: Colors.pinkAccent.withOpacity(0.6),
                    width: responsiveSize(context, 0.09, min: 110, max: 180),
                    height: responsiveHeight(context, 0.055, min: 44, max: 52),
                    textSize: responsiveSize(context, 0.009, min: 13, max: 16),
                  ),
                ],
              ],
            ),

          if (codes.isNotEmpty) ...[
            SizedBox(
              height: responsiveHeight(context, 0.018, min: 14, max: 18),
            ),
            Align(
              alignment: isEnglish
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Wrap(
                textDirection: isEnglish
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                alignment: isEnglish ? WrapAlignment.start : WrapAlignment.end,
                spacing: responsiveSize(context, 0.008, min: 8, max: 10),
                runSpacing: responsiveHeight(context, 0.012, min: 8, max: 10),
                children: codes.map((code) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveSize(
                        context,
                        0.012,
                        min: 12,
                        max: 14,
                      ),
                      vertical: responsiveHeight(
                        context,
                        0.01,
                        min: 8,
                        max: 10,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEF4),
                      borderRadius: BorderRadius.circular(
                        responsiveSize(context, 0.012, min: 12, max: 14),
                      ),
                      border: Border.all(color: const Color(0xFFFFBCD4)),
                    ),
                    child: Row(
                      textDirection: isEnglish
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        customText(
                          text: code,
                          size: responsiveSize(
                            context,
                            0.0085,
                            min: 12,
                            max: 16,
                          ),
                          bold: true,
                          color: const Color(0xFF7B1FA2),
                          isEnglish: true,
                        ),
                        SizedBox(
                          width: responsiveSize(context, 0.006, min: 6, max: 8),
                        ),
                        InkWell(
                          onTap: () => onRemove(code),
                          child: Icon(
                            Icons.close_rounded,
                            size: responsiveSize(
                              context,
                              0.012,
                              min: 16,
                              max: 18,
                            ),
                            color: const Color(0xFFE5007D),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      );
    },
  );
}

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        return Column(
          children: [
            Icon(
              Icons.publish_rounded,
              color: const Color(0xFFE40070),
              size: responsiveSize(context, 0.04, min: 34, max: 56),
            ),
            SizedBox(height: responsiveHeight(context, 0.02, min: 12, max: 20)),
            customText(
              text: "نشر النموذج",
              size: responsiveSize(context, 0.025, min: 22, max: 34),
              bold: true,
              color: textColor,
              isEnglish: locale.languageCode == 'en',
            ),
          ],
        );
      },
    );
  }
}

class ScheduleDateTimeRow extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const ScheduleDateTimeRow({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        final timeField = Column(
          crossAxisAlignment: isEnglish
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            scheduleLabel(context: context, title: "وقت النشر"),
            SizedBox(height: responsiveHeight(context, 0.02, min: 12, max: 20)),
            schedulePickerField(
              context: context,
              text: selectedTime == null
                  ? "اختياري"
                  : selectedTime!.format(context),
              icon: Icons.access_time_rounded,
              onTap: onPickTime,
            ),
          ],
        );

        final dateField = Column(
          crossAxisAlignment: isEnglish
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            scheduleLabel(context: context, title: "تاريخ النشر"),
            SizedBox(height: responsiveHeight(context, 0.02, min: 12, max: 20)),
            schedulePickerField(
              context: context,
              text: selectedDate == null
                  ? "اختياري"
                  : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
              icon: Icons.calendar_month_rounded,
              onTap: onPickDate,
            ),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: isEnglish
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              timeField,
              SizedBox(
                height: responsiveHeight(context, 0.025, min: 18, max: 24),
              ),
              dateField,
            ],
          );
        }

        return Row(
          textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
          children: [
            Expanded(child: timeField),
            SizedBox(width: responsiveSize(context, 0.045, min: 28, max: 70)),
            Expanded(child: dateField),
          ],
        );
      },
    );
  }
}

class SearchSelectUserField extends StatefulWidget {
  final String title;
  final String hint;
  final String noResultsText;
  final TextEditingController controller;
  final List<OptionUserModel> options;
  final bool isLoading;
  final void Function(String value) onSearch;
  final void Function(OptionUserModel user) onSelect;

  const SearchSelectUserField({
    super.key,
    required this.title,
    required this.hint,
    required this.noResultsText,
    required this.controller,
    required this.options,
    required this.isLoading,
    required this.onSearch,
    required this.onSelect,
  });

  @override
  State<SearchSelectUserField> createState() => _SearchSelectUserFieldState();
}

class _SearchSelectUserFieldState extends State<SearchSelectUserField> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final languageCode = locale.languageCode;
        final isEnglish = languageCode == 'en';

        final translatedHint = AppLocalizations.translateByLocaleCode(
          languageCode,
          widget.hint,
        );

        final translatedNoResults = AppLocalizations.translateByLocaleCode(
          languageCode,
          widget.noResultsText,
        );

        final hasSearchText = widget.controller.text.trim().isNotEmpty;
        final showNoResults =
            hasSearchText && !widget.isLoading && widget.options.isEmpty;

        return Directionality(
          textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
          child: Column(
            crossAxisAlignment: isEnglish
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              scheduleLabel(context: context, title: widget.title),
              SizedBox(
                height: responsiveHeight(context, 0.016, min: 12, max: 16),
              ),

              TextField(
                controller: widget.controller,
                textDirection: isEnglish
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                textAlign: isEnglish ? TextAlign.left : TextAlign.right,
                onChanged: (value) {
                  setState(() {});
                  widget.onSearch(value);
                },
                style: TextStyle(
                  fontFamily: "ArabicCustomFont",
                  fontSize: responsiveSize(context, 0.009, min: 13, max: 17),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B2B2B),
                ),
                decoration: InputDecoration(
                  hintText: translatedHint,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(
                      context,
                      0.012,
                      min: 12,
                      max: 16,
                    ),
                    vertical: responsiveHeight(
                      context,
                      0.015,
                      min: 12,
                      max: 16,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF7B1FA2),
                    size: responsiveSize(context, 0.016, min: 20, max: 24),
                  ),
                  suffixIcon: widget.isLoading
                      ? Padding(
                          padding: EdgeInsets.all(
                            responsiveSize(context, 0.008, min: 10, max: 12),
                          ),
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: const Color(0xFFE5007D),
                            size: responsiveSize(
                              context,
                              0.014,
                              min: 18,
                              max: 22,
                            ),
                          ),
                          onPressed: () {
                            setState(() => widget.controller.clear());
                            widget.onSearch("");
                          },
                        )
                      : null,
                  hintStyle: TextStyle(
                    fontFamily: "ArabicCustomFont",
                    fontSize: responsiveSize(context, 0.0085, min: 12, max: 16),
                    color: Colors.black38,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: _inputBorder(context, const Color(0xFFF2C9E0)),
                  enabledBorder: _inputBorder(context, const Color(0xFFF2C9E0)),
                  focusedBorder: _inputBorder(context, const Color(0xFFE5007D)),
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: scheduleSwitcherTransition,
                child: widget.options.isNotEmpty
                    ? _OptionsList(
                        key: ValueKey(
                          "options_${languageCode}_${widget.title}_${widget.options.length}",
                        ),
                        options: widget.options,
                        onSelect: widget.onSelect,
                      )
                    : showNoResults
                    ? _NoResultsBox(
                        key: ValueKey(
                          "no_results_${languageCode}_${widget.title}",
                        ),
                        text: translatedNoResults,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  OutlineInputBorder _inputBorder(BuildContext context, Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.014, min: 14, max: 16),
      ),
      borderSide: BorderSide(color: color),
    );
  }
}

class _OptionsList extends StatelessWidget {
  final List<OptionUserModel> options;
  final void Function(OptionUserModel user) onSelect;

  const _OptionsList({
    super.key,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        return Directionality(
          textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
          child: Container(
            margin: EdgeInsets.only(
              top: responsiveHeight(context, 0.012, min: 8, max: 10),
            ),
            constraints: BoxConstraints(
              maxHeight: responsiveHeight(context, 0.24, min: 150, max: 220),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.014, min: 14, max: 16),
              ),
              border: Border.all(color: const Color(0xFFF2C9E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = options[index];

                return ListTile(
                  minLeadingWidth: responsiveSize(
                    context,
                    0.02,
                    min: 28,
                    max: 36,
                  ),
                  leading: Icon(
                    Icons.person_rounded,
                    color: const Color(0xFFE5007D),
                    size: responsiveSize(context, 0.016, min: 20, max: 24),
                  ),
                  title: customText(
                    text: user.fullName,
                    size: responsiveSize(context, 0.009, min: 13, max: 17),
                    bold: true,
                    color: const Color(0xFF2B2B2B),
                    isCenter: false,
                    align: isEnglish ? TextAlign.start : TextAlign.end,
                    isEnglish: isEnglish,
                  ),
                  onTap: () => onSelect(user),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _NoResultsBox extends StatelessWidget {
  final String text;

  const _NoResultsBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        return Align(
          alignment: isEnglish ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(
              top: responsiveHeight(context, 0.012, min: 8, max: 10),
            ),
            width: double.infinity,
            padding: EdgeInsets.all(
              responsiveSize(context, 0.012, min: 12, max: 16),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F8),
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.014, min: 14, max: 16),
              ),
              border: Border.all(color: const Color(0xFFF2C9E0)),
            ),
            child: customText(
              text: text,
              size: responsiveSize(context, 0.0085, min: 12, max: 16),
              bold: true,
              color: const Color(0xFFE5007D),
              isCenter: false,
              align: isEnglish ? TextAlign.start : TextAlign.end,
              isEnglish: isEnglish,
            ),
          ),
        );
      },
    );
  }
}

class SelectedUsersChips extends StatelessWidget {
  final List<OptionUserModel> users;
  final void Function(OptionUserModel user) onRemove;

  const SelectedUsersChips({
    super.key,
    required this.users,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: scheduleSwitcherTransition,
          child: users.isEmpty
              ? const SizedBox.shrink(key: ValueKey("empty_chips"))
              : Padding(
                  key: ValueKey(
                    "${locale.languageCode}_${users.map((e) => e.id).join(",")}",
                  ),
                  padding: EdgeInsets.only(
                    top: responsiveHeight(context, 0.016, min: 12, max: 16),
                  ),
                  child: Align(
                    alignment: isEnglish
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Wrap(
                      textDirection: isEnglish
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      alignment: isEnglish
                          ? WrapAlignment.start
                          : WrapAlignment.end,
                      spacing: responsiveSize(context, 0.008, min: 8, max: 10),
                      runSpacing: responsiveHeight(
                        context,
                        0.012,
                        min: 8,
                        max: 10,
                      ),
                      children: users.map((user) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.85, end: 1),
                          duration: const Duration(milliseconds: 250),
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsiveSize(
                                context,
                                0.012,
                                min: 12,
                                max: 14,
                              ),
                              vertical: responsiveHeight(
                                context,
                                0.01,
                                min: 8,
                                max: 10,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEEF4),
                              borderRadius: BorderRadius.circular(
                                responsiveSize(
                                  context,
                                  0.012,
                                  min: 12,
                                  max: 14,
                                ),
                              ),
                              border: Border.all(
                                color: const Color(0xFFFFBCD4),
                              ),
                            ),
                            child: Row(
                              textDirection: isEnglish
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                customText(
                                  text: user.fullName,
                                  size: responsiveSize(
                                    context,
                                    0.0085,
                                    min: 12,
                                    max: 16,
                                  ),
                                  bold: true,
                                  color: const Color(0xFF7B1FA2),
                                  isEnglish: isEnglish,
                                ),
                                SizedBox(
                                  width: responsiveSize(
                                    context,
                                    0.006,
                                    min: 6,
                                    max: 8,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => onRemove(user),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: responsiveSize(
                                      context,
                                      0.012,
                                      min: 16,
                                      max: 18,
                                    ),
                                    color: const Color(0xFFE5007D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

Widget scheduleSwitcherTransition(Widget child, Animation<double> animation) {
  return FadeTransition(
    opacity: animation,
    child: SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: child,
    ),
  );
}
