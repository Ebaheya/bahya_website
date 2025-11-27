import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/DiagnosisRangeWidget.dart';
import 'package:bahya_website/helper/widgets/questionnaire_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddQuestionnaire extends StatefulWidget {
  const AddQuestionnaire({super.key});

  @override
  State<AddQuestionnaire> createState() => _AddQuestionnaireState();
}

class _AddQuestionnaireState extends State<AddQuestionnaire> {
  static const int _maxQuestions = 20;

  final FocusNode _keyboardFocusNode = FocusNode();
  late List<TextEditingController> _scoreControllers;

  String? _selectedDiagnosis;

  @override
  void initState() {
    super.initState();

    _scoreControllers = [TextEditingController(text: "0")];
    _selectedDiagnosis = diagnosisCategories.first;
  }

  @override
  void dispose() {
    for (final c in _scoreControllers) {
      c.dispose();
    }
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _addQuestion() {
    if (_scoreControllers.length >= _maxQuestions) {
      customDialog(
        context: context,
        title: 'تنبيه',
        message:
            'لا يمكن إضافة أكثر من $_maxQuestions سؤالاً في الاستبيان الواحد.',
      );
      return;
    }

    setState(() {
      _scoreControllers.add(TextEditingController(text: "0"));
    });
  }

  void _removeQuestion(int index) {
    if (_scoreControllers.length == 1) {
      customDialog(
        context: context,
        title: 'تنبيه',
        message: 'يجب أن يحتوي الاستبيان على سؤال واحد على الأقل.',
      );
      return;
    }

    setState(() {
      _scoreControllers[index].dispose();
      _scoreControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: 'إضافة استبيان جديد',
        isHomebar: false,
      ),

      body: RawKeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKey: (event) {
          if (event is! RawKeyDownEvent) return;
          if (_scoreControllers.isEmpty) return;

          int current = int.tryParse(_scoreControllers.first.text) ?? 0;

          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            setState(() {
              _scoreControllers.first.text = (current + 1).toString();
            });
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            setState(() {
              _scoreControllers.first.text = (current - 1).toString();
            });
          }
        },
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(h * 0.05),
              child: Container(
                padding: EdgeInsets.all(h * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                width: w * 0.95,
                child: Column(
                  children: [
                    Column(
                      children: [
                        arabicText(
                          text: "إنشاء استبيان جديد",
                          size: h * 0.025,
                          color: const Color(0xFF831843),
                          bold: true,
                          isCenter: false,
                        ),
                        SizedBox(height: h * 0.03),
                        arabicText(
                          text: "قم بإضافة الأسئلة والإجابات",
                          size: h * 0.02,
                          color: const Color(0xFFED4EA1),
                          bold: true,
                          isCenter: false,
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.03),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          arabicText(
                            text: "عنوان الاستبيان",
                            size: h * 0.018,
                            color: Colors.black,
                            bold: true,
                            isCenter: false,
                          ),
                          SizedBox(height: h * 0.01),
                          buildTextField(
                            keyboardType: CustomTextFieldType.text,
                            hintText: "مثال استبيان الصحة النفسية",
                            labelText: "اسم النموذج",
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.03),

                    ...List.generate(_scoreControllers.length, (index) {
                      return AnimatedAdd(
                        key: ValueKey(_scoreControllers[index]),
                        h: h,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _scoreControllers.length - 1
                                ? h * 0.03
                                : h * 0.02,
                          ),
                          child: QuestionnaireBody(
                            h: h,
                            w: w,
                            scoreController: _scoreControllers[index],
                            questionIndex: index + 1,
                            onDeleteQuestion: () => _removeQuestion(index),
                          ),
                        ),
                      );
                    }),

                    CustomGlowButton(
                      width: w * 0.7,
                      title: 'إنشاء سؤال جديد',
                      onPressed: _addQuestion,
                    ),

                    SizedBox(height: h * 0.04),

                    DiagnosisRangeWidget(h: h, w: w, onDelete: () {}),
                    SizedBox(height: h * 0.04),
                    CustomGlowButton(
                      width: w,
                      title: 'حفظ الاستبيان',
                      onPressed: () {
                        customDialog(
                          context: context,
                          title: 'تم الحفظ',
                          message: 'تم حفظ الاستبيان بنجاح.',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
