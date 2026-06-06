import 'package:bahya_website/helper/strings.dart';
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
  final AutovalidateMode autovalidateMode;
  final bool obscureText;
  final bool readOnly;
  final CustomTextFieldType keyboardType;
  final TextEditingController? controller;
  final TextDirection textDirection;
  final Icon? suffixIcon;
  final Icon? prefixIcon;
  final int maxLines;
  final VoidCallback? onTap;
  final Function(String)? onChange;
  final bool isSearch;
  final bool isRequired;
  final bool showInlineError;

  // يخلي hint/text في النص
  final bool centerHint;

  const CustomFormTextField({
    super.key,
    this.labelText,
    this.hintText,
    required this.autovalidateMode,
    required this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.controller,
    this.textDirection = TextDirection.rtl,
    this.suffixIcon,
    this.maxLines = 1,
    this.prefixIcon,
    this.onTap,
    this.onChange,
    this.isSearch = false,
    this.isRequired = true,
    this.showInlineError = true,
    this.centerHint = false,
  });

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  late bool _obscureText;
  String? floatingError;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
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

    if (widget.isRequired && text.isEmpty) {
      floatingError = widget.keyboardType == CustomTextFieldType.score
          ? 'هذا الحقل مطلوب'
          : null;

      return widget.keyboardType == CustomTextFieldType.score &&
              widget.showInlineError
          ? ''
          : 'هذا الحقل مطلوب';
    }

    if (!widget.isRequired && text.isEmpty) {
      floatingError = null;
      return null;
    }

    switch (widget.keyboardType) {
      case CustomTextFieldType.email:
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
        if (!emailRegex.hasMatch(text)) {
          return 'أدخل بريدًا إلكترونيًا صالحًا';
        }
        break;

      case CustomTextFieldType.name:
        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
          return 'أدخل اسمًا صالحًا';
        }
        break;

      case CustomTextFieldType.number:
        if (!RegExp(r'^\d+$').hasMatch(text)) {
          return 'أدخل أرقامًا فقط';
        }
        break;

      case CustomTextFieldType.phone:
        if (!RegExp(r'^\d{11}$').hasMatch(text)) {
          return 'أدخل رقم هاتف مكون من 11 رقمًا';
        }
        break;

      case CustomTextFieldType.password:
        final passwordRegex = RegExp(
          r'^[A-Za-z0-9!@#\$%^&*(),.?":{}|<>_+=/\\[\];`~\-]+$',
        );

        if (text.length < 8) {
          return 'Password must be at least 8 characters';
        }

        if (!passwordRegex.hasMatch(text)) {
          return 'Password can contain only English letters, numbers, and special characters';
        }
        break;

      case CustomTextFieldType.text:
        break;

      case CustomTextFieldType.date:
        if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(text)) {
          return 'أدخل تاريخًا صالحًا (mm/dd/yyyy)';
        }
        break;

      case CustomTextFieldType.title:
        if (text.length > 25) {
          return 'العنوان لا يمكن أن يتجاوز 25 حرفًا';
        }
        break;

      case CustomTextFieldType.score:
        final score = int.tryParse(text);

        if (score == null) {
          floatingError = 'أدخل أرقامًا فقط';
          return widget.showInlineError ? '' : floatingError;
        }

        if (score < 0 || score > 100) {
          floatingError = 'السكور يجب أن يكون من 0 إلى 100';
          return widget.showInlineError ? '' : floatingError;
        }

        floatingError = null;
        break;

      case CustomTextFieldType.diagnose:
        if (text.length > 50) {
          return 'التشخيص لا يمكن أن يتجاوز 50 حرف';
        }
        break;
    }

    return null;
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

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);
    final isScore = widget.keyboardType == CustomTextFieldType.score;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextFormField(
          onChanged: (value) {
            widget.onChange?.call(value);

            if (isScore) {
              setState(() {
                _validate(value);
              });
            }
          },
          keyboardType: _mapKeyboardType(widget.keyboardType),

          textAlign: widget.centerHint
              ? TextAlign.center
              : widget.textDirection == TextDirection.ltr
              ? TextAlign.left
              : TextAlign.right,

          controller: widget.controller,
          obscureText: _obscureText,
          validator: (value) {
            final result = _validate(value);

            if (isScore) {
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
          autovalidateMode: widget.autovalidateMode,
          textDirection: widget.textDirection,
          maxLines: widget.maxLines,
          minLines: 1,
          expands: false,
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.01,
            fontFamily: 'ArabicCustomFont',
          ),
          decoration: InputDecoration(
            alignLabelWithHint: true,
            counterText: '',
            suffixIcon: widget.obscureText
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.pink.shade100.withOpacity(0.5),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() => _obscureText = !_obscureText);
                        },
                        child: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.pink,
                          size: width * 0.015,
                        ),
                      ),
                    ),
                  )
                : widget.suffixIcon,
            suffixIconConstraints: const BoxConstraints(
              maxHeight: 100,
              maxWidth: 100,
            ),
            prefixIcon: widget.prefixIcon,
            hintText: widget.hintText,
            labelText: widget.labelText,
            hintTextDirection: widget.centerHint
                ? TextDirection.ltr
                : widget.textDirection,
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: width * 0.01,
              fontFamily: 'ArabicCustomFont',
            ),
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: width * 0.01,
              fontFamily: 'ArabicCustomFont',
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: widget.isSearch
                  ? BorderSide.none
                  : const BorderSide(color: Colors.grey, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.pink.shade300, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.pink, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.red.shade500, width: 1.5),
            ),
            errorStyle: TextStyle(
              fontFamily: 'ArabicCustomFont',
              fontSize: isScore && widget.showInlineError ? 0 : width * 0.01,
              height: isScore && widget.showInlineError ? 0 : null,
            ),
          ),
        ),

        if (isScore && widget.showInlineError && floatingError != null)
          Positioned(
            left: 0,
            top: -38,
            child: CustomPaint(
              painter: ErrorBubbleArrowPainter(),
              child: Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      floatingError!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'ArabicCustomFont',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ErrorBubbleArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red.shade500;

    final path = Path()
      ..moveTo(18, size.height - 7)
      ..lineTo(28, size.height - 7)
      ..lineTo(23, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
