import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:flutter/material.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: customAppBar(
        context: context,
        title: 'دروس محو الأمية',
        subTitle: 'اختاري ما يناسبك وانضمي الآن',
        icon: Icons.menu_book,
        isHome: false,
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              serviceCards(
                w: w,
                h: h,
                title: 'دروس القراءة والكتابة - المستوى الأول',
                date: 'السبت والاثنين والأربعاء',
                time: '5:00 مساءً - 6:30 مساءً',
                location: 'بهيه - الشيخ زايد',
                availableSeats: 20,
              ),
              serviceCards(
                w: w,
                h: h,
                title: 'دروس القراءة والكتابة - المستوى الثاني',
                date: 'الأحد والثلاثاء والخميس',
                time: '5:00 مساءً - 6:30 مساءً',
                location: 'الفرع: بهيه - الشيخ زايد',
                availableSeats: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

