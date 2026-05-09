import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomTextFieldType { email, name, password, number, phone, text, date }

class CustomFormTextField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final AutovalidateMode autovalidateMode;
  final bool obscureText;
  final bool readOnly;
  final CustomTextFieldType keyboardType;
  final TextEditingController? controller;
  final TextDirection textDirection;
  final Icon? suffixIcon;
  final int maxLines;
  final VoidCallback? onTap;
  final Function(String)? onChange;
  final bool isSearch;
  final bool isRequired;
  const CustomFormTextField({
    super.key,
    required this.labelText,
     this.hintText,
    required this.autovalidateMode,
    required this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.controller,
    this.textDirection = TextDirection.rtl,
    this.suffixIcon,
    this.maxLines = 1,
    this.onTap,
    this.onChange,
    this.isSearch = false,
    this.isRequired = true,
  });

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  late bool _obscureText;

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
        return TextInputType.number;

      case CustomTextFieldType.phone:
        return TextInputType.phone;

      case CustomTextFieldType.password:
        return TextInputType.visiblePassword;

      case CustomTextFieldType.text:
        return TextInputType.text;
      case CustomTextFieldType.date:
        return TextInputType.datetime;
    }
  }

String? _validate(String? value) {
    final text = value?.trim() ?? '';

    if (widget.isRequired && text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }

    if (!widget.isRequired && text.isEmpty) {
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
          r'^[A-Za-z0-9!@#\$%^&*(),.?":{}|<>_\-+=/\\[\];`~]+$',
        );

        if (text.length < 6) {
          return 'Password must be at least 6 characters';
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
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = getScreenWidth(context);
    return TextFormField(
      onChanged: widget.onChange,
      keyboardType: _mapKeyboardType(widget.keyboardType),

      controller: widget.controller,

      obscureText: _obscureText,

      validator: _validate,

      onTap: widget.onTap,

      readOnly: widget.readOnly,

      inputFormatters: [
        if (widget.keyboardType == CustomTextFieldType.phone) ...[
          FilteringTextInputFormatter.digitsOnly,

          LengthLimitingTextInputFormatter(11),
        ] else if (widget.keyboardType == CustomTextFieldType.number) ...[
          FilteringTextInputFormatter.digitsOnly,
        ] else if (widget.keyboardType == CustomTextFieldType.email) ...[
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
        ] else if (widget.keyboardType == CustomTextFieldType.password) ...[
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9#@&%$!]')),
        ],
      ],

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

        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },

                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,

                  color: Colors.grey,
                ),
              )
            : widget.suffixIcon,

        hintText: widget.hintText,

        labelText: widget.labelText,

        hintTextDirection: widget.textDirection,

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
              :  BorderSide(color: Colors.grey, width: 1.2),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),

          borderSide: const BorderSide(color: Colors.grey, width: 1.2),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),

          borderSide: const BorderSide(color: Color(0xFFFF7BB0), width: 1.5),
        ),

        errorStyle: TextStyle(
          fontFamily: 'ArabicCustomFont',
          fontSize: width * 0.01,
        ),
      ),
    );
  }
}
