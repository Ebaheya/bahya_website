import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final String title;
  final String introduction;
  final String firstQuestion;
  final String firstAnswer;
  final String secondQuestion;
  final String secondAnswer;
  final String thirdQuestion;
  final String thirdAnswer;
  final String fourthQuestion;
  final String fourthAnswer;
  final String conclusion;

  const ArticleDetailsScreen({
    super.key,
    required this.title,
    required this.introduction,
    required this.firstQuestion,
    required this.firstAnswer,
    required this.secondQuestion,
    required this.secondAnswer,
    required this.thirdQuestion,
    required this.thirdAnswer,
    required this.fourthQuestion,
    required this.fourthAnswer,
    required this.conclusion,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: customAppBar(
        context: context,
        title: 'مقالة',
        subTitle: 'تعرفي على المزيد من المعلومات المفيدة',
        isHome: false,
        isArticle: true,
        preferredSize: Size.fromHeight(h * 0.12),
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              SizedBox(height: h * 0.14),
              Padding(
                padding: EdgeInsets.all(8),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(w * 0.055),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        customText(
                          text: title,
                          size: w * 0.045,
                          bold: true,
                          color: const Color(0xff8A1745),
                          maxLines: 3,
                        ),

                        SizedBox(height: h * 0.025),

                        articleSectionTitle(w: w, title: "مقدمة"),

                        articleParagraph(w: w, text: introduction),

                        articleDivider(),

                        articleQuestion(
                          w: w,
                          number: "01",
                          question: firstQuestion,
                          answer: firstAnswer,
                        ),

                        articleQuestion(
                          w: w,
                          number: "02",
                          question: secondQuestion,
                          answer: secondAnswer,
                        ),

                        articleQuestion(
                          w: w,
                          number: "03",
                          question: thirdQuestion,
                          answer: thirdAnswer,
                        ),

                        articleQuestion(
                          w: w,
                          number: "04",
                          question: fourthQuestion,
                          answer: fourthAnswer,
                          isLast: true,
                        ),

                        articleSectionTitle(w: w, title: "خاتمة"),

                        articleParagraph(w: w, text: conclusion),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget articleSectionTitle({required double w, required String title}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xffEA4C89),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        customText(
          text: title,
          size: w * 0.038,
          isCenter: false,
          bold: true,
          color: const Color(0xffEA4C89),
        ),
      ],
    );
  }

  Widget articleParagraph({required double w, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          height: 1.8,
          fontSize: w * 0.034,
          color: Colors.grey[700],
          fontFamily: 'ArabicCustomFont',
        ),
      ),
    );
  }

  Widget articleQuestion({
    required double w,
    required String number,
    required String question,
    required String answer,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            customText(text: number, size: w * 0.05, bold: true),
            const SizedBox(width: 8),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: customText(
                text: question,
                size: w * 0.033,
                isCenter: false,
                bold: true,
                maxLines: 2,
              ),
            ),
          ],
        ),
        articleParagraph(w: w, text: answer),
        articleDivider(isDashed: !isLast),
      ],
    );
  }

  Widget articleDivider({bool isDashed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        color: isDashed
            ? const Color(0xffEA4C89).withOpacity(0.18)
            : Colors.grey.withOpacity(0.18),
        thickness: 1,
      ),
    );
  }
}

class ArticleWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 35);

    path.quadraticBezierTo(
      size.width * 0.30,
      size.height,
      size.width * 0.55,
      size.height - 25,
    );

    path.quadraticBezierTo(
      size.width * 0.80,
      size.height - 50,
      size.width,
      size.height - 25,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
