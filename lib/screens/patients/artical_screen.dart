import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
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
        preferredSize: Size.fromHeight(
          responsiveHeight(context, 0.12, min: 92, max: 110),
        ),
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: context.appTextDirection,
          child: Column(
            children: [
              SizedBox(height: responsiveHeight(context, 0.14, min: 112, max: 132)),
              Padding(
                padding: EdgeInsets.all(responsiveSize(context, 0.018, min: 8, max: 12)),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    responsiveSize(context, 0.055, min: 20, max: 28),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      responsiveSize(context, 0.065, min: 22, max: 28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.08),
                        blurRadius: responsiveSize(context, 0.05, min: 18, max: 22),
                        offset: Offset(
                          0,
                          responsiveHeight(context, 0.012, min: 8, max: 10),
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      customText(
                        text: title,
                        size: responsiveSize(context, 0.045, min: 18, max: 22),
                        bold: true,
                        color: const Color(0xff8A1745),
                        maxLines: 3,
                      ),
                      SizedBox(height: responsiveHeight(context, 0.025, min: 18, max: 24)),
                      articleSectionTitle(context: context, title: 'مقدمة'),
                      articleParagraph(context: context, text: introduction),
                      articleDivider(context),
                      articleQuestion(
                        context: context,
                        number: '01',
                        question: firstQuestion,
                        answer: firstAnswer,
                      ),
                      articleQuestion(
                        context: context,
                        number: '02',
                        question: secondQuestion,
                        answer: secondAnswer,
                      ),
                      articleQuestion(
                        context: context,
                        number: '03',
                        question: thirdQuestion,
                        answer: thirdAnswer,
                      ),
                      articleQuestion(
                        context: context,
                        number: '04',
                        question: fourthQuestion,
                        answer: fourthAnswer,
                        isLast: true,
                      ),
                      articleSectionTitle(context: context, title: 'خاتمة'),
                      articleParagraph(context: context, text: conclusion),
                    ],
                  ),
                ),
              ),
              SizedBox(height: responsiveHeight(context, 0.024, min: 16, max: 22)),
            ],
          ),
        ),
      ),
    );
  }

  Widget articleSectionTitle({
    required BuildContext context,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: responsiveSize(context, 0.01, min: 4, max: 5),
          height: responsiveHeight(context, 0.03, min: 22, max: 26),
          decoration: BoxDecoration(
            color: const Color(0xffEA4C89),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.018, min: 7, max: 9)),
        customText(
          text: title,
          size: responsiveSize(context, 0.038, min: 15, max: 18),
          isCenter: false,
          bold: true,
          color: const Color(0xffEA4C89),
        ),
      ],
    );
  }

  Widget articleParagraph({
    required BuildContext context,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: responsiveHeight(context, 0.014, min: 10, max: 14),
      ),
      child: Text(
        context.tr(text),
        textAlign: localeNotifier.isArabic ? TextAlign.right : TextAlign.left,
        textDirection: context.appTextDirection,
        style: TextStyle(
          height: 1.8,
          fontSize: responsiveSize(context, 0.034, min: 14, max: 16),
          color: Colors.grey[700],
          fontFamily: 'ArabicCustomFont',
        ),
      ),
    );
  }

  Widget articleQuestion({
    required BuildContext context,
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
            customText(
              text: number,
              size: responsiveSize(context, 0.05, min: 18, max: 22),
              bold: true,
            ),
            SizedBox(width: responsiveSize(context, 0.018, min: 6, max: 8)),
            Container(
              width: responsiveSize(context, 0.028, min: 10, max: 12),
              height: responsiveSize(context, 0.028, min: 10, max: 12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: responsiveSize(context, 0.018, min: 6, max: 8)),
            Expanded(
              child: customText(
                text: question,
                size: responsiveSize(context, 0.033, min: 14, max: 16),
                isCenter: false,
                bold: true,
                maxLines: 3,
              ),
            ),
          ],
        ),
        articleParagraph(context: context, text: answer),
        articleDivider(context, isDashed: !isLast),
      ],
    );
  }

  Widget articleDivider(BuildContext context, {bool isDashed = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: responsiveHeight(context, 0.012, min: 8, max: 10),
      ),
      child: Divider(
        color: isDashed
            ? const Color(0xffEA4C89).withOpacity(0.18)
            : Colors.grey.withOpacity(0.18),
        thickness: 1,
      ),
    );
  }
}
