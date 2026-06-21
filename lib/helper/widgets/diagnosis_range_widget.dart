import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body.dart';
import 'package:flutter/material.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';

class DiagnosisRangeWidget extends StatefulWidget {
  final double h;
  final double w;
  final VoidCallback onDelete;

  const DiagnosisRangeWidget({
    super.key,
    required this.h,
    required this.w,
    required this.onDelete,
  });

  @override
  State<DiagnosisRangeWidget> createState() => _DiagnosisRangeWidgetState();
}

class _DiagnosisRangeWidgetState extends State<DiagnosisRangeWidget> {
  List<_DiagnosisItem> diagnosisList = [];

  static const int _maxDiagnosis = 15;

  @override
  void initState() {
    super.initState();
    diagnosisList.add(_DiagnosisItem());
  }

  void _addDiagnosis() {
    if (diagnosisList.length >= _maxDiagnosis) {
      customDialog(
        context: context,
        title: "تنبيه",
        message: "لا يمكن إضافة أكثر من $_maxDiagnosis تشخيص.",
      );
      return;
    }

    setState(() {
      diagnosisList.add(_DiagnosisItem());
    });
  }

  void _startRemoveDiagnosis(_DiagnosisItem item) {
    if (diagnosisList.length == 1) {
      customDialog(
        context: context,
        title: "تنبيه",
        message: "يجب أن يكون هناك تشخيص واحد على الأقل.",
      );
      return;
    }

    setState(() {
      item.isRemoving = true;
    });
  }

  void _finishRemoveDiagnosis(_DiagnosisItem item) {
    if (!mounted) return;
    setState(() {
      diagnosisList.remove(item);
    });
    item.dispose();
  }

  @override
  void dispose() {
    for (final item in diagnosisList) {
      item.dispose();
    }
    super.dispose();
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
            color: Colors.black.withValues(alpha: 0.10),
            spreadRadius: 1,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      width: w * 0.7,
      child: Column(
        children: [
          customText(
            text: "إعداد التشخيص الكلي للفورم",
            size: h * 0.022,
            color: const Color(0xFF831843),
            bold: true,
          ),
          customText(
            text: "حدد نطاقات السكور الكلي مع التشخيص المقابل لكل نطاق",
            size: h * 0.018,
            color: const Color(0xFFED4EA1),
          ),

          SizedBox(height: h * 0.03),

          Column(
            children: diagnosisList.map((item) {
              return AnimatedDiagnosis(
                key: ValueKey(item),
                h: h,
                isRemoving: item.isRemoving,
                onRemoveDone: () => _finishRemoveDiagnosis(item),
                child: Padding(
                  padding: EdgeInsets.only(bottom: h * 0.025),
                  child: _DiagnosisScoreRow(
                    h: h,
                    w: w,
                    item: item,
                    onDelete: () => _startRemoveDiagnosis(item),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: h * 0.02),

          CustomGlowButton(
            width: w * 0.6,
            title: 'إنشاء تشخيص جديد',
            onPressed: _addDiagnosis,
          ),
        ],
      ),
    );
  }
}

class _DiagnosisItem {
  String diagnosis = diagnosisCategories.first;
  final TextEditingController from = TextEditingController(text: "0");
  final TextEditingController to = TextEditingController(text: "0");
  bool isRemoving = false;

  void dispose() {
    from.dispose();
    to.dispose();
  }
}

class _DiagnosisScoreRow extends StatelessWidget {
  final double h;
  final double w;
  final _DiagnosisItem item;
  final VoidCallback onDelete;

  const _DiagnosisScoreRow({
    required this.h,
    required this.w,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                customText(text: "إلى", size: h * 0.018, bold: true),
                SizedBox(height: h * 0.01),
                scoreCounter(
                  height: h * 0.06,
                  width: w * 0.13,
                  h: h,
                  controller: item.to,
                ),
              ],
            ),

            SizedBox(width: w * 0.02),

            Column(
              children: [
                customText(text: "من", size: h * 0.018, bold: true),
                SizedBox(height: h * 0.01),
                scoreCounter(
                  height: h * 0.06,
                  width: w * 0.13,
                  h: h,
                  controller: item.from,
                ),
              ],
            ),

            SizedBox(width: w * 0.02),

            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
        SizedBox(height: h * 0.03),
        Column(
          children: [
            customText(
              text: "التشخيص",
              size: h * 0.018,
              bold: true,
              color: const Color(0xFFEA298C),
            ),
            SizedBox(height: h * 0.02),
            SizedBox(
              width: w * 0.54,
              child: DropdownButtonFormField<String>(
                initialValue: item.diagnosis,
                dropdownColor: Colors.white,
                style: TextStyle(
                  fontSize: h * 0.016,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEA298C),
                  fontFamily: 'ArabicCustomFont',
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: diagnosisCategories
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: customText(
                          text: d,
                          size: h * 0.016,
                          color: const Color(0xFF831843),
                          isCenter: false,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  item.diagnosis = v!;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AnimatedDiagnosis extends StatelessWidget {
  final double h;
  final Widget child;
  final bool isRemoving;
  final VoidCallback onRemoveDone;

  const AnimatedDiagnosis({
    super.key,
    required this.h,
    required this.child,
    required this.isRemoving,
    required this.onRemoveDone,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: isRemoving ? 1 : 0, end: isRemoving ? 0 : 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      onEnd: () {
        if (isRemoving) {
          onRemoveDone();
        }
      },
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * h * 0.03),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
