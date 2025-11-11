import 'package:bahya_website/helper/diagnosis_chart.dart';
import 'package:flutter/material.dart';

// double getScreenWidth(BuildContext context) {
//   return MediaQuery.of(context).size.width;
// }
// double getScreenHeight(BuildContext context) {
//   return MediaQuery.of(context).size.height;
// }
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
