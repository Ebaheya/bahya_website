import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestionnaireBody extends StatefulWidget {
  const QuestionnaireBody({
    super.key,
    required this.h,
    required this.w,
    required this.scoreController,
    required this.questionIndex,
    required this.onDeleteQuestion,
  });

  final double h;
  final double w;
  final TextEditingController scoreController;
  final int questionIndex;
  final VoidCallback onDeleteQuestion;

  @override
  State<QuestionnaireBody> createState() => _QuestionnaireBodyState();
}

class _QuestionnaireBodyState extends State<QuestionnaireBody> {
  static const int _maxAnswers = 10;

  late List<TextEditingController> _scoreControllers;

  @override
  void initState() {
    super.initState();
    _scoreControllers = [widget.scoreController];

    if (widget.scoreController.text.isEmpty) {
      widget.scoreController.text = '0';
    }
  }

  @override
  void dispose() {
    for (int i = 1; i < _scoreControllers.length; i++) {
      _scoreControllers[i].dispose();
    }
    super.dispose();
  }

  void _addAnswer() {
    if (_scoreControllers.length >= _maxAnswers) {
      return;
    }

    setState(() {
      _scoreControllers.add(TextEditingController(text: '0'));
    });
  }

  void _removeAnswer(int index) {
    if (_scoreControllers.length == 1) return;

    setState(() {
      if (index == 0) {
        _scoreControllers.removeAt(index);
      } else {
        _scoreControllers[index].dispose();
        _scoreControllers.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.h;
    final w = widget.w;

    return Container(
      padding: EdgeInsets.all(h * 0.02),
      decoration: BoxDecoration(
        color: const Color(0xFFF8E7F8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            spreadRadius: 1,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: widget.onDeleteQuestion,
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
              customText(
                text: "سؤال ${widget.questionIndex}",
                size: h * 0.02,
                color: const Color(0xFF831843),
                bold: true,
                isCenter: false,
              ),
            ],
          ),
          SizedBox(height: h * 0.02),

          Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: "نص السؤال",
                  size: h * 0.018,
                  color: Colors.black,
                  bold: true,
                  isCenter: false,
                ),
                SizedBox(height: h * 0.01),
                buildTextField(
                  keyboardType: CustomTextFieldType.text,
                  hintText: "ما هو شعورك اليوم؟",
                  labelText: "السؤال",
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                ),
                SizedBox(height: h * 0.02),
                customText(
                  text: "الاجابات مع السكور",
                  size: h * 0.018,
                  color: Colors.black,
                  bold: true,
                  isCenter: false,
                ),
                SizedBox(height: h * 0.01),

                ...List.generate(_scoreControllers.length, (index) {
                  return AnimatedAdd(
                    key: ValueKey(_scoreControllers[index]),
                    h: h,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _scoreControllers.length - 1
                            ? 0
                            : h * 0.02,
                      ),
                      child: answer(
                        h: h,
                        w: w,
                        controller: _scoreControllers[index],
                        onDelete: () => _removeAnswer(index),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          SizedBox(height: h * 0.01),

          CustomGlowButton(
            title: 'إضافة إجابة جديدة',
            onPressed: _addAnswer,
            width: w * 0.4,
          ),
        ],
      ),
    );
  }
}

class AnimatedAdd extends StatelessWidget {
  final double h;
  final Widget child;

  const AnimatedAdd({super.key, required this.h, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * h * 0.02),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class ScoreRow extends StatelessWidget {
  final double h;
  final double w;
  final TextEditingController controller;

  const ScoreRow({
    super.key,
    required this.h,
    required this.w,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.text.isEmpty ||
        int.tryParse(controller.text) == null ||
        int.parse(controller.text) < 0) {
      controller.text = "0";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        scoreCounter(
          height: h * 0.06,
          width: w * 0.13,
          controller: controller,
          h: h,
        ),
        SizedBox(width: w * 0.01),
        customText(
          text: "السكور",
          size: h * 0.02,
          color: Colors.black,
          bold: true,
          isCenter: false,
        ),
      ],
    );
  }
}

Widget answer({
  required double h,
  required double w,
  required TextEditingController controller,
  required VoidCallback onDelete,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
          SizedBox(width: w * 0.01),
          Expanded(
            child: buildTextField(
              keyboardType: CustomTextFieldType.text,
              hintText: "جيد جدا",
              labelText: "الإجابة",
              textDirection: TextDirection.rtl,
              maxLines: 2,
            ),
          ),
        ],
      ),
      SizedBox(height: h * 0.015),
      ScoreRow(h: h, w: w, controller: controller),
    ],
  );
}

Widget scoreCounter({
  required double width,
  required double h,
  required double height,
  required TextEditingController controller,
}) {
  final FocusNode focusNode = FocusNode();

  focusNode.addListener(() {
    if (!focusNode.hasFocus) {
      if (controller.text.trim().isEmpty) {
        controller.text = "0";
      }
    }
  });

  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(
        fontFamily: 'ArabicCustomFont',
        fontWeight: FontWeight.bold,
        fontSize: h * 0.02,
      ),
    ),
  );
}
