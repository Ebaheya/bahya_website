import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
part 'schedule_form_header.dart';
part 'search_select_user_field.dart';
part 'selected_users_chips.dart';

String _translate(BuildContext context, String text) {
  final languageCode = AppLanguageController.localeNotifier.value.languageCode;
  return localizedTextByLocaleCode(languageCode, text);
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
                    glowColor: Colors.pinkAccent.withValues(alpha: 0.6),
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
                    glowColor: Colors.pinkAccent.withValues(alpha: 0.6),
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
