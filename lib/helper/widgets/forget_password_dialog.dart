import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum ContactMethod { email, phone }

void forgetPasswordDialog(BuildContext context) {
  final BuildContext parentContext = context;
  final TextEditingController emailController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (dialogContext) {
      ContactMethod method = ContactMethod.email;

      return StatefulBuilder(
        builder: (context, setState) {
          final w = getScreenWidth(context);
          final h = getScreenHeight(context);
          final isMobile = w < 700;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.03, min: 18, max: 42),
              vertical: responsiveHeight(context, 0.03, min: 18, max: 36),
            ),
            child: Directionality(
              textDirection: Directionality.of(context),
              child: Container(
                width: isMobile ? w * 0.92 : 520.0,
                constraints: BoxConstraints(maxHeight: h * 0.92),
                padding: EdgeInsets.all(
                  responsiveSize(
                    context,
                    isMobile ? 0.04 : 0.026,
                    min: 16,
                    max: 30,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    responsiveSize(
                      context,
                      isMobile ? 0.05 : 0.03,
                      min: 22,
                      max: 30,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7A004C).withValues(alpha: 0.18),
                      blurRadius: 35,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(99),
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: Container(
                            width: responsiveSize(
                              context,
                              0.04,
                              min: 34,
                              max: 42,
                            ),
                            height: responsiveSize(
                              context,
                              0.04,
                              min: 34,
                              max: 42,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFC2DD),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFFE40070),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: responsiveSize(
                          context,
                          isMobile ? 0.16 : 0.075,
                          min: 58,
                          max: 82,
                        ),
                        height: responsiveSize(
                          context,
                          isMobile ? 0.16 : 0.075,
                          min: 58,
                          max: 82,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6AAE), Color(0xFFE40070)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFE40070,
                              ).withValues(alpha: 0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          color: Colors.white,
                          size: responsiveSize(
                            context,
                            isMobile ? 0.085 : 0.035,
                            min: 32,
                            max: 40,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.018,
                          min: 14,
                          max: 18,
                        ),
                      ),
                      customText(
                        text: 'استرجاع كلمة المرور',
                        size: responsiveHeight(
                          context,
                          0.032,
                          min: isMobile ? 22 : 24,
                          max: isMobile ? 26 : 32,
                        ),
                        color: const Color(0xFF7A004C),
                        bold: true,
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.008,
                          min: 6,
                          max: 8,
                        ),
                      ),
                      customText(
                        text:
                            'اكتب بريدك الإلكتروني واختر طريقة التواصل المفضلة',
                        size: responsiveHeight(
                          context,
                          0.018,
                          min: 13,
                          max: 17,
                        ),
                        color: const Color(0xFF9A315F),
                        bold: false,
                        maxLines: 2,
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.028,
                          min: 20,
                          max: 28,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(
                          responsiveSize(context, 0.014, min: 10, max: 14),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBFD),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFFB6D9)),
                        ),
                        child: buildTextField(
                          controller: emailController,
                          keyboardType: CustomTextFieldType.email,
                          hintText: localizedText(context, 'example@email.com'),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFFE40070),
                          ),
                          textDirection: Directionality.of(context),
                        ),
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.024,
                          min: 18,
                          max: 24,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: customText(
                          text: 'طريقة التواصل المفضلة',
                          size: responsiveHeight(
                            context,
                            0.019,
                            min: 14,
                            max: 18,
                          ),
                          color: const Color(0xFF2D142C),
                          bold: true,
                          isCenter: false,
                        ),
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.012,
                          min: 10,
                          max: 12,
                        ),
                      ),
                      _contactOption(
                        title: 'البريد الإلكتروني',
                        subtitle: 'استلام التعليمات عبر البريد',
                        icon: Icons.email_outlined,
                        value: ContactMethod.email,
                        groupValue: method,
                        onChanged: (v) => setState(() => method = v!),
                        context: context,
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.03,
                          min: 22,
                          max: 30,
                        ),
                      ),
                      isMobile
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: _confirmButton(
                                    parentContext,
                                    dialogContext,
                                    emailController,
                                  ),
                                ),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.012,
                                    min: 10,
                                    max: 12,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: _cancelButton(context),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _confirmButton(
                                    parentContext,
                                    dialogContext,
                                    emailController,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: _cancelButton(context)),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(emailController.dispose);
}

Widget _confirmButton(
  BuildContext parentContext,
  BuildContext dialogContext,
  TextEditingController emailController,
) {
  return CustomGlowButton(
    title: 'تأكيد',
    backgroundColor: const Color(0xFFFF6AAE),
    glowColor: const Color(0xFFFF6AAE),
    textColor: Colors.white,
    onPressed: () async {
      final email = emailController.text.trim();

      if (email.isEmpty) {
        customDialog(
          context: parentContext,
          title: 'خطأ',
          isError: true,
          message: 'يرجى إدخال البريد الإلكتروني',
        );
        return;
      }

      try {
        await WebService().forgetPassword(email: email);

        if (!parentContext.mounted) return;
        if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
          Navigator.of(dialogContext, rootNavigator: true).pop();
        }

        await Future<void>.delayed(const Duration(milliseconds: 120));

        if (!parentContext.mounted) return;
        customDialog(
          context: parentContext,
          isSuccess: true,
          title: 'نجاح',
          message: 'تم إرسال تعليمات استرجاع كلمة المرور إلى بريدك الإلكتروني',
        );
      } catch (error) {
        if (!parentContext.mounted) return;
        customDialog(
          context: parentContext,
          title: 'خطأ',
          isError: true,
          message: error.toString().replaceFirst('Exception: ', ''),
        );
      }
    },
  );
}

Widget _cancelButton(BuildContext context) {
  return CustomGlowButton(
    title: 'إلغاء',
    backgroundColor: Colors.white,
    glowColor: const Color(0xFFFFD6E9),
    textColor: const Color(0xFFE40070),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );
}

Widget _contactOption({
  required String title,
  required String subtitle,
  required IconData icon,
  required ContactMethod value,
  required ContactMethod groupValue,
  required ValueChanged<ContactMethod?> onChanged,
  required BuildContext context,
}) {
  final selected = value == groupValue;
  final isMobile = getScreenWidth(context) < 700;

  final iconBoxSize = responsiveSize(
    context,
    isMobile ? 0.095 : 0.04,
    min: 38,
    max: isMobile ? 44 : 46,
  );

  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () => onChanged(value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(
          context,
          isMobile ? 0.03 : 0.018,
          min: 12,
          max: 18,
        ),
        vertical: responsiveHeight(
          context,
          isMobile ? 0.014 : 0.016,
          min: 12,
          max: 16,
        ),
      ),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF0F7) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFFE40070) : const Color(0xFFE9E2E8),
          width: selected ? 1.5 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFFE40070).withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Radio<ContactMethod>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: const Color(0xFFE40070),
            visualDensity: isMobile
                ? const VisualDensity(horizontal: -4, vertical: -4)
                : VisualDensity.standard,
          ),
          SizedBox(
            width: responsiveSize(
              context,
              isMobile ? 0.012 : 0.02,
              min: 8,
              max: 18,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                customText(
                  text: title,
                  size: responsiveHeight(
                    context,
                    0.017,
                    min: isMobile ? 12 : 13,
                    max: 17,
                  ),
                  color: selected
                      ? const Color(0xFFE40070)
                      : const Color(0xFF333333),
                  bold: true,
                  isCenter: false,
                  align: TextAlign.right,
                  maxLines: 1,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.004, min: 3, max: 5),
                ),
                customText(
                  text: subtitle,
                  size: responsiveHeight(
                    context,
                    0.014,
                    min: isMobile ? 10 : 11,
                    max: 14,
                  ),
                  color: const Color(0xFF777777),
                  bold: false,
                  isCenter: false,
                  align: TextAlign.right,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          SizedBox(
            width: responsiveSize(
              context,
              isMobile ? 0.012 : 0.02,
              min: 8,
              max: 12,
            ),
          ),
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFE40070)
                  : const Color(0xFFFFF0F7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFFE40070),
              size: responsiveSize(
                context,
                isMobile ? 0.052 : 0.022,
                min: 19,
                max: 24,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
