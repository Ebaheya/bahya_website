import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

Widget customText({
  required String text,
  required double size,
  bool isGradient = false,
  bool isEnglish = false,
  bool isCenter = true,
  Color? color,
  bool bold = true,
  TextAlign? align,
  int maxLines = 1,
  Map<String, String>? namedArgs,
}) {
  return ValueListenableBuilder<Locale>(
    valueListenable: AppLanguageController.localeNotifier,
    builder: (context, locale, _) {
      final languageCode = locale.languageCode;

      String translatedText = AppLocalizations.translateByLocaleCode(
        languageCode,
        text,
      );

      if (namedArgs != null) {
        namedArgs.forEach((key, value) {
          translatedText = translatedText.replaceAll('{$key}', value);
        });
      }

      final isEnglishLocale = languageCode == 'en';

      return Text(
        translatedText,
        textAlign: align ?? (isCenter ? TextAlign.center : TextAlign.start),
        textDirection: isEnglish || isEnglishLocale
            ? TextDirection.ltr
            : TextDirection.rtl,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: size,
          fontFamily: 'ArabicCustomFont',
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: isGradient ? null : (color ?? Colors.black),
          foreground: isGradient
              ? (Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFFFF69B4)],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)))
              : null,
        ),
      );
    },
  );
}

String webProxy(String url) =>
    'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}'; // CORS OK

Widget netImg(String url) {
  final proxied = kIsWeb ? webProxy(url) : url;
  return Image.network(
    proxied,
    width: 50,
    height: 50,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Image.asset(
      'assets/images/placeholder.png',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    ),
  );
}

Widget buildTextField({
  required CustomTextFieldType keyboardType,
  required String hintText,
  String? labelText,
  int maxLines = 1,
  Icon? suffixIcon,
  Icon? prefixIcon,
  bool obscureText = false,
  TextDirection textDirection = TextDirection.ltr,
  TextEditingController? controller,
  bool? bordered,
}) {
  return ValueListenableBuilder<Locale>(
    valueListenable: AppLanguageController.localeNotifier,
    builder: (context, locale, _) {
      final languageCode = locale.languageCode;
      final localizedHint = AppLocalizations.translateByLocaleCode(
        languageCode,
        hintText,
      );
      final localizedLabel = labelText == null
          ? null
          : AppLocalizations.translateByLocaleCode(
              languageCode,
              labelText!,
            );

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomFormTextField(
          controller: controller,
          keyboardType: keyboardType,
          autovalidateMode: AutovalidateMode.disabled,
          hintText: localizedHint,
          labelText: localizedLabel,
          obscureText: obscureText,
          textDirection: languageCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
          maxLines: maxLines,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          bordered: bordered ?? true,
        ),
      );
    },
  );
}

Widget appIcon({double size = 170}) {
  return Center(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/pics/app_icon.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    ),
  );
}

PreferredSizeWidget customAppBar({
  required BuildContext context,
  required String title,
  bool isHomeBar = true,
  GlobalKey<ScaffoldState>? scaffoldKey,
  List<Widget>? widgets,
}) {
  final h = getScreenHeight(context);
  final w = getScreenWidth(context);

  return PreferredSize(
    preferredSize: Size.fromHeight(h * 0.1),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isHomeBar
                  ? Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            scaffoldKey?.currentState?.openDrawer();
                          },
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const _LanguageToggleButton(),
                        // GestureDetector(
                        //   onTap: () {
                        //     scaffoldKey?.currentState?.openDrawer();
                        //   },
                        //   child: const Icon(
                        //     Icons.menu,
                        //     color: Colors.white,
                        //     size: 28,
                        //   ),
                        //   // child: CircleAvatar(
                        //   //   radius: h * 0.023,
                        //   //   backgroundColor: Colors.white,
                        //   //   child: const Icon(
                        //   //     Icons.person,
                        //   //     color: Colors.pinkAccent,
                        //   //   ),
                        //   // ),
                        // ),
                        SizedBox(width: w * 0.02),
                      ],
                    )
                  : widgets != null
                  ? Row(children: widgets)
                  : const SizedBox(),

              Row(
                children: [
                  customText(
                    text: title,
                    size: h * 0.02,
                    bold: true,
                    color: Colors.white,
                  ),
                  SizedBox(width: w * 0.015),
                  CircleAvatar(
                    radius: h * 0.02,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  if (!isHomeBar)
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _LanguageToggleButton extends StatelessWidget {
  const _LanguageToggleButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: AppLanguageController.toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.32)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    isEnglish ? 'AR' : 'EN',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget sectionCard({
  required BuildContext context,
  required String title,
  required Widget child,
  bool? isShadow = true,
}) {
  return Container(
    width: getScreenWidth(context) * 0.95,
    margin: const EdgeInsets.only(bottom: 16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        isShadow == true
            ? BoxShadow(
                color: Colors.black26,
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            : const BoxShadow(
                color: Colors.transparent,
                spreadRadius: 0,
                blurRadius: 0,
                offset: Offset(0, 0),
              ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          height: getScreenHeight(context) * 0.10,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              customText(
                text: title,
                size: getScreenHeight(context) * 0.02,
                bold: true,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        child,
      ],
    ),
  );
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        customText(
          text: label,
          size: getScreenHeight(context) * 0.015,
          color: const Color(0xFF313131),
        ),
      ],
    );
  }
}

Widget customLoading() {
  return Padding(
    padding: const EdgeInsets.all(20),

    child: Center(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1),

          duration: const Duration(milliseconds: 5000),

          curve: Curves.easeInOut,

          builder: (context, value, child) {
            return Transform.scale(
              scale: value,

              child: Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(colors: gradientColors),

                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.35),

                      blurRadius: 25,

                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: const SizedBox(
                  width: 40,

                  height: 40,

                  child: CircularProgressIndicator(
                    strokeWidth: 5,

                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),

                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> customSnackBar({
  required BuildContext context,
  required String message,
}) {
  final w = getScreenWidth(context);
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: buttonColor,
      animation: const AlwaysStoppedAnimation(1),
      showCloseIcon: true,
      content: customText(text: message, size: w * 0.01, color: Colors.white),
    ),
  );
}

Widget modernInputBox({required IconData icon, required Widget child}) {
  return Container(
    height: 62,
    padding: const EdgeInsets.only(left: 14, right: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.withOpacity(0.14)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: 14,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: buttonColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: buttonColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    ),
  );
}

class ScheduleInfoBlock extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final bool isTime;

  const ScheduleInfoBlock({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    this.isTime = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.01, min: 12, max: 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            text: title,
            size: h * 0.018,
            color: Colors.grey.shade600,
            bold: true,
            isCenter: false,
          ),
          SizedBox(height: h * 0.007),
          customText(
            text: value,
            size: isTime ? h * 0.032 : h * 0.018,
            bold: true,
            color: isTime ? const Color(0xFF8A0057) : const Color(0xFF333333),
            isCenter: false,
          ),
          if (subValue != null) ...[
            SizedBox(height: h * 0.003),
            customText(
              text: subValue!,
              size: h * 0.017,
              bold: true,
              color: const Color(0xFFE5005F),
              isCenter: false,
            ),
          ],
        ],
      ),
    );
  }
}
