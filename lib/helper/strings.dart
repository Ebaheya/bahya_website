import 'package:bahya_website/helper/diagnosis_chart.dart';
import 'package:bahya_website/helper/home_feature_grid.dart';
import 'package:bahya_website/helper/state_card.dart';
import 'package:flutter/material.dart';

get getScreenWidth =>
    (BuildContext context) => MediaQuery.of(context).size.width;

get getScreenHeight =>
    (BuildContext context) => MediaQuery.of(context).size.height;

Color? backgroundColor = Colors.grey[200];
Color? salesBackgroundColor = Colors.deepPurple;

final List<DiagnosisPoint> chartData = <DiagnosisPoint>[
  DiagnosisPoint('الاكتئاب', 27, 6),
  DiagnosisPoint('القلق', 25, 5),
  DiagnosisPoint('اضطراب نفسي', 20, 4),
  DiagnosisPoint('طبيعي', 26, 7),
  DiagnosisPoint('طبيعي', 26, 7),
  DiagnosisPoint('طبيعي', 26, 7),
  DiagnosisPoint('الاكتئاب', 27, 6),
  DiagnosisPoint('القلق', 25, 5),
  DiagnosisPoint('اضطراب نفسي', 20, 4),
  DiagnosisPoint('الاكتئاب', 27, 6),
  DiagnosisPoint('القلق', 25, 5),
  DiagnosisPoint('اضطراب نفسي', 20, 4),
  DiagnosisPoint('طبيعي', 26, 7),
  DiagnosisPoint('طبيعي', 26, 7),
  DiagnosisPoint('طبيعي', 26, 7),
  DiagnosisPoint('الاكتئاب', 27, 6),
  DiagnosisPoint('القلق', 25, 5),
  DiagnosisPoint('اضطراب نفسي', 20, 4),
  DiagnosisPoint('الاكتئاب', 27, 6),
  DiagnosisPoint('القلق', 25, 5),
  DiagnosisPoint('اضطراب نفسي', 20, 4),
  DiagnosisPoint('طبيعي', 26, 7),
  DiagnosisPoint('طبيعي', 26, 7),
  DiagnosisPoint('طبيعي', 26, 7),
  DiagnosisPoint('الاكتئاب', 27, 6),
  DiagnosisPoint('القلق', 25, 5),
  DiagnosisPoint('اضطراب نفسي', 20, 4),
];

List<FeatureItem> homeFeatures(BuildContext context) => [
  FeatureItem(
    title: 'نشر الأسئلة',
    subtitle: 'جدولة ونشر النماذج',
    icon: Icons.event_note,
    onTap: () {},
  ),
  FeatureItem(
    title: 'إضافة أسئلة',
    subtitle: 'إنشاء نماذج أسئلة',
    icon: Icons.edit_note,
    onTap: () {},
  ),
  FeatureItem(
    title: 'بيانات المرضى',
    subtitle: 'عرض وإدارة بيانات',
    icon: Icons.people_alt,
    onTap: () {},
  ),
  FeatureItem(
    title: 'نتائج تخزين الأسئلة',
    subtitle: 'عرض النتائج المحفوظة',
    icon: Icons.assignment,
    onTap: () {},
  ),
  FeatureItem(
    title: 'تخزين الأسئلة',
    subtitle: 'الوصول للنماذج المحفوظة',
    icon: Icons.folder_open,
    onTap: () {},
  ),
];


List<StatCard> getStatCards(BuildContext context) {
  return const [
    StatCard(
      title: "حالات طبيعية",
      percent: .27,
      color: Colors.green,
      icon: Icons.emoji_emotions,
    ),
    StatCard(
      title: "اضطراب نفسي عام",
      percent: .20,
      color: Colors.blue,
      icon: Icons.monitor_heart,
    ),
    StatCard(
      title: "القلق",
      percent: .27,
      color: Colors.purple,
      icon: Icons.psychology,
    ),
    StatCard(
      title: "الاكتئاب",
      percent: .27,
      color: Colors.pink,
      icon: Icons.favorite,
    ),
    StatCard(
      title: "حالات طبيعية",
      percent: .27,
      color: Colors.green,
      icon: Icons.emoji_emotions,
    ),
    StatCard(
      title: "اضطراب نفسي عام",
      percent: .20,
      color: Colors.blue,
      icon: Icons.monitor_heart,
    ),
    StatCard(
      title: "القلق",
      percent: .27,
      color: Colors.purple,
      icon: Icons.psychology,
    ),
    StatCard(
      title: "الاكتئاب",
      percent: .27,
      color: Colors.pink,
      icon: Icons.favorite,
    ),
  ];
}
