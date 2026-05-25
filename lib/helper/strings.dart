import 'package:bahya_website/helper/widgets/diagnosis_chart.dart';
import 'package:bahya_website/helper/widgets/diagnosis_patients_dialog.dart';
import 'package:bahya_website/helper/widgets/home_feature_grid.dart';
import 'package:bahya_website/helper/widgets/state_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const String baseUrl = "http://127.0.0.1:3000/api/v1";
get getScreenWidth =>
    (BuildContext context) => MediaQuery.of(context).size.width;

get getScreenHeight =>
    (BuildContext context) => MediaQuery.of(context).size.height;

Color? backgroundColor = const Color(0xFFFFF7FD);
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
    onTap: () {
      context.push('/publish_schedule');
    },
  ),
  FeatureItem(
    title: 'إضافة أسئلة',
    subtitle: 'إنشاء نماذج أسئلة',
    icon: Icons.edit_note,
    onTap: () {
      context.push('/add_questionnaire');
    },
  ),
  FeatureItem(
    title: 'بيانات المرضى',
    subtitle: 'عرض وإدارة بيانات',
    icon: Icons.people_alt,
    onTap: () {
      context.push('/patient_info');
    },
  ),
  FeatureItem(
    title: 'تخزين الأسئلة',
    subtitle: 'الوصول للنماذج المحفوظة',
    icon: Icons.folder_open,
    onTap: () {
      context.push('/questionnaire_filler');
    },
  ),
];

final demoPatients = <PatientDiagnosisItem>[
  PatientDiagnosisItem(name: "آمنة سالم", age: 27, phq9: 10, phq4: 8),
  PatientDiagnosisItem(name: "حليمة يوسف", age: 36, phq9: 11, phq4: 9),
  PatientDiagnosisItem(name: "رقية عمر", age: 30, phq9: 9, phq4: 7),
];
List<StatCard> getStatCards(BuildContext context) {
  return [
    StatCard(
      title: "حالات طبيعية",
      percent: .27,
      color: Colors.green,
      icon: Icons.emoji_emotions,
      demoPatients: demoPatients,
    ),
    StatCard(
      title: "اضطراب نفسي عام",
      percent: .20,
      color: Colors.blue,
      icon: Icons.monitor_heart,
      demoPatients: demoPatients,
    ),
    StatCard(
      title: "القلق",
      percent: .27,
      color: Colors.purple,
      icon: Icons.psychology,
      demoPatients: demoPatients,
    ),
    StatCard(
      title: "الاكتئاب",
      percent: .27,
      color: Colors.pink,
      icon: Icons.favorite,
      demoPatients: demoPatients,
    ),
  ];
}

final List<Map<String, dynamic>> patients = [
  {
    "name": "مريم أحمد",
    "age": 28,
    "address": "الرياض، حي الياسمين",
    "phq9": 12,
    "phq4": 8,
    "diag": "قلق متوسط مع أعراض اكتئاب خفيفة",
    "hasAnswers": true,
  },
  {
    "name": "فاطمة علي",
    "age": 35,
    "address": "جدة، حي الروضة",
    "phq9": 7,
    "phq4": 5,
    "diag": "حالة طبيعية مع قلق خفيف",
    "hasAnswers": false,
  },
  {
    "name": "سارة خالد",
    "age": 42,
    "address": "الدمام، حي الفيصلية",
    "phq9": 18,
    "phq4": 11,
    "diag": "اكتئاب متوسط الشدة",
    "hasAnswers": true,
  },
  {
    "name": "هند عبدالله",
    "age": 31,
    "address": "مكة المكرمة، العزيزية",
    "phq9": 4,
    "phq4": 3,
    "diag": "حالة طبيعية",
    "hasAnswers": false, // مثال: لم تُجب على أي استبيان
  },
  {
    "name": "نورة سعيد",
    "age": 26,
    "address": "المدينة المنورة، العيون",
    "phq9": 14,
    "phq4": 9,
    "diag": "قلق متوسط مع اكتئاب متوسط",
    "hasAnswers": true,
  },
  {
    "name": "مريم أحمد",
    "age": 28,
    "address": "الرياض، حي الياسمين",
    "phq9": 12,
    "phq4": 8,
    "diag": "قلق متوسط مع أعراض اكتئاب خفيفة",
    "hasAnswers": true,
  },
  {
    "name": "فاطمة علي",
    "age": 35,
    "address": "جدة، حي الروضة",
    "phq9": 7,
    "phq4": 5,
    "diag": "حالة طبيعية مع قلق خفيف",
    "hasAnswers": false,
  },
  {
    "name": "سارة خالد",
    "age": 42,
    "address": "الدمام، حي الفيصلية",
    "phq9": 18,
    "phq4": 11,
    "diag": "اكتئاب متوسط الشدة",
    "hasAnswers": true,
  },
  {
    "name": "هند عبدالله",
    "age": 31,
    "address": "مكة المكرمة، العزيزية",
    "phq9": 4,
    "phq4": 3,
    "diag": "حالة طبيعية",
    "hasAnswers": false, // مثال: لم تُجب على أي استبيان
  },
  {
    "name": "نورة سعيد",
    "age": 26,
    "address": "المدينة المنورة، العيون",
    "phq9": 14,
    "phq4": 9,
    "diag": "قلق متوسط مع اكتئاب متوسط",
    "hasAnswers": true,
  },
];

final List<String> diagnosisCategories = const [
  'حالة طبيعية',
  'اكتئاب بسيط',
  'اكتئاب متوسط',
  'اكتئاب شديد',
  'قلق بسيط',
  'قلق متوسط',
  'قلق شديد',
  'حالة تحتاج تقييم متخصص',
];

final formsList = [
  "استبيان PHQ-9",
  "استبيان GAD-7",
  "استبيان النوم",
  "استبيان القلق",
];

final List<Map<String, String>> scheduled = const [
  {"form": "PHQ-9", "date": "2025-10-25", "repeat": "يومي", "hour": "10:00 AM"},
  {
    "form": "GAD-7",
    "date": "2025-11-01",
    "repeat": "أسبوعي",
    "hour": "02:00 PM",
  },
  {
    "form": "BDI-II",
    "date": "2025-12-15",
    "repeat": "شهري",
    "hour": "09:00 AM",
  },
];

final Map<String, dynamic> anxietyForm = {
  "title": "تقييم القلق العام",
  "subtitle": "قم بتعبئة النموذج للمريض",

  "fields": [
    {"label": "اسم المريضة", "hint": "أدخل اسم المريضة", "type": "text"},
  ],

  "questions": [
    {
      "q": "هل تجد صعوبة في السيطرة على القلق؟",
      "options": [
        {"text": "لا", "points": 0},
        {"text": "أحياناً", "points": 2},
        {"text": "نعم", "points": 3},
      ],
    },
    {
      "q": "هل تشعر بالتوتر أو العصبية؟",
      "options": [
        {"text": "أبداً", "points": 0},
        {"text": "أحياناً", "points": 1},
        {"text": "مراراً", "points": 2},
        {"text": "دائماً", "points": 3},
      ],
    },
  ],
};

Color textColor = const Color(0xFF831843);
List<Color> gradientColors = const [Color(0xFF8A2BE2), Color(0xFFFF69B4)];
Color iconColor = Color(0xFFE91E63);
Color buttonColor = Color(0xFFFF7BB0);
