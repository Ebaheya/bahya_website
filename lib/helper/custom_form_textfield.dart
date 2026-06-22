import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomTextFieldType {
  email,
  name,
  password,
  number,
  phone,
  text,
  date,
  title,
  score,
  diagnose,
}

class CustomFormTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final bool readOnly;
  final CustomTextFieldType keyboardType;
  final TextEditingController? controller;
  final TextDirection textDirection;
  final Icon? suffixIcon;
  final Icon? prefixIcon;
  final int maxLines;
  final int minLines;
  final VoidCallback? onTap;
  final Function(String)? onChange;
  final bool isSearch;
  final bool isRequired;
  final bool showInlineError;
  final bool bordered;
  final bool centerHint;

  const CustomFormTextField({
    super.key,
    this.labelText,
    this.hintText,
    required this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.controller,
    this.textDirection = TextDirection.rtl,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines = 1,
    this.prefixIcon,
    this.onTap,
    this.onChange,
    this.isSearch = false,
    this.isRequired = true,
    this.showInlineError = true,
    this.centerHint = false,
    this.bordered = true,
  });

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  late bool _obscureText;
  String? floatingError;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  String _localized(String text) {
    return localizedTextByLocaleCode(
      Localizations.localeOf(context).languageCode,
      text,
    );
  }

  TextInputType _mapKeyboardType(CustomTextFieldType type) {
    switch (type) {
      case CustomTextFieldType.email:
        return TextInputType.emailAddress;
      case CustomTextFieldType.name:
        return TextInputType.name;
      case CustomTextFieldType.number:
      case CustomTextFieldType.score:
        return TextInputType.number;
      case CustomTextFieldType.phone:
        return TextInputType.phone;
      case CustomTextFieldType.password:
        return TextInputType.visiblePassword;
      case CustomTextFieldType.text:
      case CustomTextFieldType.title:
      case CustomTextFieldType.diagnose:
        return TextInputType.text;
      case CustomTextFieldType.date:
        return TextInputType.datetime;
    }
  }

  String? _validate(String? value) {
    final text = value?.trim() ?? '';
    String? errorKey;

    if (widget.isRequired && text.isEmpty) {
      errorKey = 'This field is required';
    } else if (!widget.isRequired && text.isEmpty) {
      floatingError = null;
      return null;
    } else {
      switch (widget.keyboardType) {
        case CustomTextFieldType.email:
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(text)) {
            errorKey = 'Enter a valid email address';
          }
          break;
        case CustomTextFieldType.name:
          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
            errorKey = 'Enter a valid name';
          }
          break;
        case CustomTextFieldType.number:
          if (!RegExp(r'^\d+$').hasMatch(text)) {
            errorKey = 'Enter numbers only';
          }
          break;
        case CustomTextFieldType.phone:
          if (!RegExp(r'^\d{11}$').hasMatch(text)) {
            errorKey = 'Enter an 11-digit phone number';
          }
          break;
        case CustomTextFieldType.password:
          final passwordRegex = RegExp(
            r'^[A-Za-z0-9!@#\$%^&*(),.?":{}|<>_+=/\\[\];`~\-]+$',
          );

          if (text.length < 8) {
            errorKey = 'Password must be at least 8 characters';
          } else if (!passwordRegex.hasMatch(text)) {
            errorKey =
                'Password can contain only English letters, numbers, and special characters';
          }
          break;
        case CustomTextFieldType.date:
          if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(text)) {
            errorKey = 'Enter a valid date (mm/dd/yyyy)';
          }
          break;
        case CustomTextFieldType.title:
          if (text.length > 25) {
            errorKey = 'The title cannot exceed 25 characters';
          }
          break;
        case CustomTextFieldType.score:
          final score = int.tryParse(text);

          if (score == null) {
            errorKey = 'Enter numbers only';
          } else if (score < 0 || score > 100) {
            errorKey = 'The score must be between 0 and 100';
          }
          break;
        case CustomTextFieldType.diagnose:
          if (text.length > 50) {
            errorKey = 'The diagnosis cannot exceed 50 characters';
          }
          break;
        case CustomTextFieldType.text:
          break;
      }
    }

    floatingError = errorKey == null ? null : _localized(errorKey);

    if (errorKey == null) return null;
    return widget.showInlineError ? '' : floatingError;
  }

  List<TextInputFormatter> _inputFormatters() {
    if (widget.keyboardType == CustomTextFieldType.phone) {
      return [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ];
    }

    if (widget.keyboardType == CustomTextFieldType.number) {
      return [FilteringTextInputFormatter.digitsOnly];
    }

    if (widget.keyboardType == CustomTextFieldType.score) {
      return [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ];
    }

    if (widget.keyboardType == CustomTextFieldType.email) {
      return [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]'))];
    }

    if (widget.keyboardType == CustomTextFieldType.password) {
      return [
        FilteringTextInputFormatter.allow(
          RegExp(r'[A-Za-z0-9!@#\$%^&*(),.?":{}|<>_+=/\[\];`~\\-]'),
        ),
      ];
    }

    if (widget.keyboardType == CustomTextFieldType.title) {
      return [LengthLimitingTextInputFormatter(25)];
    }

    if (widget.keyboardType == CustomTextFieldType.diagnose) {
      return [LengthLimitingTextInputFormatter(50)];
    }

    return [];
  }

  Widget? _iconWithPadding(BuildContext context, Icon? icon, bool isPrefix) {
    if (icon == null) return null;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: responsiveSize(context, 0.005, min: isPrefix ? 8 : 5, max: 10),
        end: responsiveSize(context, 0.005, min: isPrefix ? 5 : 8, max: 10),
      ),
      child: Center(child: icon),
    );
  }

  Widget _passwordToggle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(responsiveSize(context, 0.005, min: 6, max: 8)),
      child: Container(
        width: responsiveSize(context, 0.02, min: 28, max: 34),
        height: responsiveSize(context, 0.02, min: 28, max: 34),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.pink.shade100.withValues(alpha: 0.5),
        ),
        child: InkWell(
          onTap: () {
            setState(() => _obscureText = !_obscureText);
          },
          borderRadius: BorderRadius.circular(50),
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.pink,
            size: responsiveSize(context, 0.014, min: 18, max: 24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglishLocale =
        Localizations.localeOf(context).languageCode == 'en';
    final effectiveDirection = isEnglishLocale
        ? TextDirection.ltr
        : widget.textDirection;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(
            widget.bordered
                ? responsiveSize(context, 0.004, min: 4, max: 6)
                : 0,
          ),
          decoration: BoxDecoration(
            color: widget.bordered
                ? const Color(0xFFFEFBFD)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.014, min: 16, max: 22),
            ),
            border: widget.bordered
                ? Border.all(
                    color: _focused
                        ? const Color(0xFFE7549B).withValues(alpha: 0.42)
                        : const Color(0xFFE7549B).withValues(alpha: 0.12),
                    width: _focused ? 1.4 : 1,
                  )
                : null,
           
          ),
          child: Focus(
            onFocusChange: (value) {
              setState(() => _focused = value);
            },
            child: TextFormField(
              onChanged: (value) {
                widget.onChange?.call(value);

                if (widget.showInlineError) {
                  setState(() {
                    _validate(value);
                  });
                }
              },
              keyboardType: _mapKeyboardType(widget.keyboardType),
              textAlign: widget.centerHint
                  ? TextAlign.center
                  : effectiveDirection == TextDirection.ltr
                  ? TextAlign.left
                  : TextAlign.right,
              controller: widget.controller,
              obscureText: _obscureText,
              validator: (value) {
                final result = _validate(value);

                if (widget.showInlineError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() {});
                  });
                }

                return result;
              },
              onTap: widget.onTap,
              readOnly: widget.readOnly,
              inputFormatters: _inputFormatters(),
              obscuringCharacter: '•',
              autovalidateMode: AutovalidateMode.disabled,
              textDirection: effectiveDirection,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              expands: false,
              style: TextStyle(
                color: Colors.black,
                fontSize: responsiveSize(context, 0.0075, min: 12, max: 15),
                fontFamily: 'ArabicCustomFont',
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: widget.bordered
                    ? Colors.white.withValues(alpha: 0.82)
                    : Colors.transparent,
                alignLabelWithHint: true,
                counterText: '',
                suffixIcon: widget.obscureText
                    ? _passwordToggle(context)
                    : _iconWithPadding(context, widget.suffixIcon, false),
                suffixIconConstraints: BoxConstraints(
                  maxHeight: responsiveHeight(context, 0.08, min: 50, max: 100),
                  maxWidth: responsiveSize(context, 0.06, min: 50, max: 100),
                ),
                prefixIcon: _iconWithPadding(context, widget.prefixIcon, true),
                prefixIconConstraints: BoxConstraints(
                  maxHeight: responsiveHeight(context, 0.08, min: 50, max: 100),
                  maxWidth: responsiveSize(context, 0.06, min: 50, max: 100),
                ),
                hintText: widget.hintText == null
                    ? null
                    : localizedTextByLocaleCode(
                        Localizations.localeOf(context).languageCode,
                        widget.hintText!,
                      ),
                labelText: widget.labelText == null
                    ? null
                    : localizedTextByLocaleCode(
                        Localizations.localeOf(context).languageCode,
                        widget.labelText!,
                      ),
                hintTextDirection: widget.centerHint
                    ? TextDirection.ltr
                    : effectiveDirection,
                labelStyle: TextStyle(
                  color: _focused ? const Color(0xFFE7549B) : Colors.black87,
                  fontSize: responsiveSize(context, 0.008, min: 12, max: 16),
                  fontFamily: 'ArabicCustomFont',
                  fontWeight: FontWeight.w600,
                ),
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: responsiveSize(context, 0.008, min: 12, max: 16),
                  fontFamily: 'ArabicCustomFont',
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: responsiveHeight(context, 0.015, min: 12, max: 16),
                  horizontal: responsiveSize(context, 0.010, min: 12, max: 16),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.010, min: 12, max: 16),
                  ),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.010, min: 12, max: 16),
                  ),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.010, min: 12, max: 16),
                  ),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.010, min: 12, max: 16),
                  ),
                  borderSide: BorderSide.none,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.010, min: 12, max: 16),
                  ),
                  borderSide: BorderSide.none,
                ),
                errorStyle: const TextStyle(fontSize: 0, height: 0),
                errorMaxLines: 1,
              ),
            ),
          ),
        ),
        if (widget.showInlineError && floatingError != null)
          PositionedDirectional(
            start: 0,
            top: -responsiveHeight(context, 0.045, min: 34, max: 42),
            child: CustomPaint(
              painter: ErrorBubbleArrowPainter(
                textDirection: effectiveDirection,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: responsiveSize(context, 0.32, min: 220, max: 360),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(
                      context,
                      0.008,
                      min: 10,
                      max: 12,
                    ),
                    vertical: responsiveHeight(context, 0.008, min: 6, max: 8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    borderRadius: BorderRadius.circular(
                      responsiveSize(context, 0.007, min: 8, max: 10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    textDirection: effectiveDirection,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.white,
                        size: responsiveSize(context, 0.01, min: 14, max: 16),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          floatingError!,
                          textDirection: effectiveDirection,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'ArabicCustomFont',
                            fontWeight: FontWeight.bold,
                            fontSize: responsiveSize(
                              context,
                              0.0068,
                              min: 10,
                              max: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ErrorBubbleArrowPainter extends CustomPainter {
  final TextDirection textDirection;

  ErrorBubbleArrowPainter({this.textDirection = TextDirection.ltr});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red.shade500;
    final arrowStart = textDirection == TextDirection.rtl
        ? size.width - 28
        : 18.0;
    final arrowEnd = textDirection == TextDirection.rtl
        ? size.width - 18
        : 28.0;
    final arrowTip = textDirection == TextDirection.rtl
        ? size.width - 23
        : 23.0;

    final path = Path()
      ..moveTo(arrowStart, size.height - 7)
      ..lineTo(arrowEnd, size.height - 7)
      ..lineTo(arrowTip, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ErrorBubbleArrowPainter oldDelegate) {
    return oldDelegate.textDirection != textDirection;
  }
}
