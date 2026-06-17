import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/widgets/patient/patient_home_widgets.dart';
import 'package:flutter/material.dart';

class _ArticleData {
  const _ArticleData({required this.key, required this.icon, required this.color});

  final String key;
  final IconData icon;
  final Color color;

  String get cardTitle => 'article.$key.cardTitle';
  String get cardSubtitle => 'article.$key.cardSubtitle';

  Map<String, dynamic> get routeArguments => {
    'title': 'article.$key.title',
    'introduction': 'article.$key.introduction',
    'firstQuestion': 'article.$key.q1',
    'firstAnswer': 'article.$key.a1',
    'secondQuestion': 'article.$key.q2',
    'secondAnswer': 'article.$key.a2',
    'thirdQuestion': 'article.$key.q3',
    'thirdAnswer': 'article.$key.a3',
    'fourthQuestion': 'article.$key.q4',
    'fourthAnswer': 'article.$key.a4',
    'conclusion': 'article.$key.conclusion',
  };
}

const List<_ArticleData> _articles = [
  _ArticleData(
    key: 'psychiatrist',
    icon: Icons.favorite_rounded,
    color: Colors.pink,
  ),
  _ArticleData(
    key: 'light',
    icon: Icons.light_mode_rounded,
    color: Colors.green,
  ),
  _ArticleData(
    key: 'exercise',
    icon: Icons.fitness_center_rounded,
    color: Colors.teal,
  ),
  _ArticleData(
    key: 'social',
    icon: Icons.people_alt_rounded,
    color: Colors.purple,
  ),
  _ArticleData(
    key: 'kindness',
    icon: Icons.favorite_rounded,
    color: Colors.pink,
  ),
  _ArticleData(
    key: 'psychotherapy',
    icon: Icons.psychology_rounded,
    color: Colors.teal,
  ),
  _ArticleData(
    key: 'awarenessAcceptance',
    icon: Icons.self_improvement_rounded,
    color: Colors.orange,
  ),
  _ArticleData(
    key: 'toxicPositivity',
    icon: Icons.balance_rounded,
    color: Colors.indigo,
  ),
  _ArticleData(
    key: 'acceptFeelings',
    icon: Icons.favorite_border_rounded,
    color: Colors.deepPurple,
  ),
  _ArticleData(
    key: 'emotionRegulation',
    icon: Icons.health_and_safety_rounded,
    color: Colors.cyan,
  ),
  _ArticleData(
    key: 'mindHeart',
    icon: Icons.psychology_alt_rounded,
    color: Colors.redAccent,
  ),
  _ArticleData(
    key: 'nonJudgment',
    icon: Icons.spa_rounded,
    color: Colors.lightBlue,
  ),
];

Widget articles({required double w, required BuildContext context}) {
  return Column(
    children: [
      for (final article in _articles) ...[
        articleCard(
          context: context,
          w: w,
          icon: article.icon,
          topic: article.cardTitle,
          subTopic: article.cardSubtitle,
          color: article.color,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/articleDetails',
              arguments: article.routeArguments,
            );
          },
        ),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
      ],
    ],
  );
}
