
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
  final bool bordered;
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
    this.bordered = true,
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
    String? error;

    if (widget.isRequired && text.isEmpty) {
      error = 'هذا الحقل مطلوب';
    } else if (!widget.isRequired && text.isEmpty) {
      floatingError = null;
      return null;
    } else {
      switch (widget.keyboardType) {
        case CustomTextFieldType.email:
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(text)) {
            error = 'أدخل بريدًا إلكترونيًا صالحًا';
          }
          break;

        case CustomTextFieldType.name:
          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
            error = 'أدخل اسمًا صالحًا';
          }
          break;

        case CustomTextFieldType.number:
          if (!RegExp(r'^\d+$').hasMatch(text)) {
            error = 'أدخل أرقامًا فقط';
          }
          break;

        case CustomTextFieldType.phone:
          if (!RegExp(r'^\d{11}$').hasMatch(text)) {
            error = 'أدخل رقم هاتف مكون من 11 رقمًا';
          }
          break;

        case CustomTextFieldType.password:
          final passwordRegex = RegExp(
            r'^[A-Za-z0-9!@#\$%^&*(),.?":{}|<>_+=/\\[\];`~\-]+$',
          );

          if (text.length < 8) {
            error = 'Password must be at least 8 characters';
          } else if (!passwordRegex.hasMatch(text)) {
            error =
                'Password can contain only English letters, numbers, and special characters';
          }
          break;

        case CustomTextFieldType.date:
          if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(text)) {
            error = 'أدخل تاريخًا صالحًا (mm/dd/yyyy)';
          }
          break;

        case CustomTextFieldType.title:
          if (text.length > 25) {
            error = 'العنوان لا يمكن أن يتجاوز 25 حرفًا';
          }
          break;

        case CustomTextFieldType.score:
          final score = int.tryParse(text);

          if (score == null) {
            error = 'أدخل أرقامًا فقط';
          } else if (score < 0 || score > 100) {
            error = 'السكور يجب أن يكون من 0 إلى 100';
          }
          break;

        case CustomTextFieldType.diagnose:
          if (text.length > 50) {
            error = 'التشخيص لا يمكن أن يتجاوز 50 حرف';
          }
          break;

        case CustomTextFieldType.text:
          break;
      }
    }

    floatingError = error;

    if (error == null) return null;
    return widget.showInlineError ? '' : error;
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
            fontSize: responsiveSize(context, 0.0075, min: 12, max: 15),
            fontFamily: 'ArabicCustomFont',
          ),
          decoration: InputDecoration(
            alignLabelWithHint: true,
            counterText: '',
            suffixIcon: widget.obscureText
                ? Padding(
                    padding: EdgeInsets.all(
                      responsiveSize(context, 0.005, min: 6, max: 8),
                    ),
                    child: Container(
                      width: responsiveSize(context, 0.02, min: 28, max: 34),
                      height: responsiveSize(context, 0.02, min: 28, max: 34),
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
                          size: responsiveSize(
                            context,
                            0.014,
                            min: 18,
                            max: 24,
                          ),
                        ),
                      ),
                    ),
                  )
                : widget.suffixIcon,
            suffixIconConstraints: BoxConstraints(
              maxHeight: responsiveHeight(context, 0.08, min: 50, max: 100),
              maxWidth: responsiveSize(context, 0.06, min: 50, max: 100),
            ),
            prefixIcon: Padding(
                  padding: EdgeInsets.all(
                      responsiveSize(context, 0.005, min: 6, max: 8),
                    ),
                  child: widget.prefixIcon,
                ),
            prefixIconConstraints: BoxConstraints(
              maxHeight: responsiveHeight(context, 0.08, min: 50, max: 100),
              maxWidth: responsiveSize(context, 0.06, min: 50, max: 100),
            ),
            hintText: widget.hintText,
            labelText: widget.labelText,
            hintTextDirection: widget.centerHint
                ? TextDirection.ltr
                : widget.textDirection,
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: responsiveSize(context, 0.008, min: 12, max: 16),
              fontFamily: 'ArabicCustomFont',
            ),
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: responsiveSize(context, 0.008, min: 12, max: 16),
              fontFamily: 'ArabicCustomFont',
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: responsiveHeight(context, 0.015, min: 12, max: 16),
              horizontal: responsiveSize(context, 0.008, min: 10, max: 14),
            ),
            border: widget.bordered
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      responsiveSize(context, 0.006, min: 8, max: 12),
                    ),
                    borderSide: BorderSide.none,
                  )
                : InputBorder.none,
            enabledBorder: widget.bordered
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      responsiveSize(context, 0.006, min: 8, max: 12),
                    ),
                    borderSide: BorderSide(
                      color: Colors.pink.shade300,
                      width: 1.2,
                    ),
                  )
                : InputBorder.none,
            focusedBorder: widget.bordered
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      responsiveSize(context, 0.006, min: 8, max: 12),
                    ),
                    borderSide: const BorderSide(
                      color: Colors.pink,
                      width: 1.5,
                    ),
                  )
                : InputBorder.none,
            errorBorder: widget.bordered
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      responsiveSize(context, 0.006, min: 8, max: 12),
                    ),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1.2,
                    ),
                  )
                : InputBorder.none,
            focusedErrorBorder: widget.bordered
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      responsiveSize(context, 0.006, min: 8, max: 12),
                    ),
                    borderSide: BorderSide(
                      color: Colors.red.shade500,
                      width: 1.5,
                    ),
                  )
                : InputBorder.none,
            errorStyle: TextStyle(
              fontFamily: 'ArabicCustomFont',
              fontSize: isScore && widget.showInlineError
                  ? 0
                  : responsiveSize(context, 0.0075, min: 11, max: 14),
              height: isScore && widget.showInlineError ? 0 : null,
            ),
          ),
        ),

        if (isScore && widget.showInlineError && floatingError != null)
          Positioned(
            left: 0,
            top: -responsiveHeight(context, 0.045, min: 34, max: 42),
            child: CustomPaint(
              painter: ErrorBubbleArrowPainter(),
              child: Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveSize(context, 0.008, min: 10, max: 12),
                  vertical: responsiveHeight(context, 0.008, min: 6, max: 8),
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.007, min: 8, max: 10),
                  ),
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
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: responsiveSize(context, 0.01, min: 14, max: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      floatingError!,
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
