import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/saved_filler.dart';
import 'package:flutter/material.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  String selectedForm = "تقييم القلق العام";

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFCEFFE),

      appBar: customAppBar(
        context: context,
        title: "ملء الاستبيانات",
        isHomeBar: false,
      ),

      body: Center(
        child: Container(
          width: w * 0.95,
          padding: const EdgeInsets.all(20),

          child: isMobile
              ? Column(
                  children: [
                    SavedFormsWidget(
                      selectedForm: selectedForm,
                      onSelect: (f) => setState(() => selectedForm = f),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(30),
                        child: DynamicFormFillerWidget(formData: anxietyForm)

                      ),
                    ),
                  ],
                )              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(30),
                        child: DynamicFormFillerWidget(formData: anxietyForm)
                      ),
                    ),

                    const SizedBox(width: 30),

                    SavedFormsWidget(
                      selectedForm: selectedForm,
                      onSelect: (f) => setState(() => selectedForm = f),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
 