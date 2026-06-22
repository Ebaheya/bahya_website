import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
part 'base_components.dart';

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

      String translatedText = localizedTextByLocaleCode(languageCode, text);

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
      final localizedHint = localizedTextByLocaleCode(languageCode, hintText);
      final localizedLabel = labelText == null
          ? null
          : localizedTextByLocaleCode(languageCode, labelText);

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomFormTextField(
          controller: controller,
          keyboardType: keyboardType,
        
          hintText: localizedHint,
          labelText: localizedLabel,
          obscureText: obscureText,
          textDirection: languageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
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
            color: Colors.black.withValues(alpha: 0.08),
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

class LanguageToggleButton extends StatefulWidget {
  final EdgeInsetsGeometry padding;

  const LanguageToggleButton({
    super.key,
    this.padding = const EdgeInsetsDirectional.only(start: 8),
  });

  @override
  State<LanguageToggleButton> createState() => _LanguageToggleButtonState();
}

class _LanguageToggleButtonState extends State<LanguageToggleButton> {
  bool isSwitching = false;

  Future<void> _toggleLanguageWithLoading() async {
    if (isSwitching) return;

    setState(() => isSwitching = true);
    final navigator = Navigator.of(context, rootNavigator: true);
    final languageCode =
        AppLanguageController.localeNotifier.value.languageCode;
    final loadingLabel = localizedTextByLocaleCode(
      languageCode,
      'Changing language',
    );

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: loadingLabel,
      barrierColor: const Color(0xFFFDF7FB).withValues(alpha: 0.94),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Center(child: customLoading()),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 3200));
    await AppLanguageController.toggle();
    await Future.delayed(const Duration(milliseconds: 350));

    if (navigator.canPop()) {
      navigator.pop();
    }

    if (mounted) {
      setState(() => isSwitching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';
        final tooltip = localizedTextByLocaleCode(
          locale.languageCode,
          isEnglish ? 'Switch to Arabic' : 'Switch to English',
        );
        final targetLanguage = isEnglish ? 'Arabic' : 'English';

        return Padding(
          padding: widget.padding,
          child: Tooltip(
            message: tooltip,
            child: Semantics(
              button: true,
              label: tooltip,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: _toggleLanguageWithLoading,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFFC7DD)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language,
                        color: Color(0xFFE83E8C),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      customText(
                        text: targetLanguage,
                        size: 12,
                        color: const Color(0xFFE83E8C),
                        bold: true,
                        isCenter: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
