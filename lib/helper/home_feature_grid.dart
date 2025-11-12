import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class FeatureCard extends StatelessWidget {
  final FeatureItem item;
  const FeatureCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: h * 0.02,
            vertical: h * 0.02,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Container(
                width: h * 0.07,
                height: h * 0.07,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB388FF), Color(0xFFFF7BB0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(item.icon, color: Colors.white, size: h * 0.04),
              ),
              SizedBox(height: h * 0.015),
              arabicText(
                text: item.title,
                size: h * 0.016,
                bold: true,
                color: const Color(0xFF7A004C),
              ),
              SizedBox(height: h * 0.006),
              arabicText(
                text: item.subtitle,
                size: h * 0.012,
                color: const Color(0xFFE91E63),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomLeft,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Image.asset(
                    'assets/icons/breastCancerIcon.png',
                    height: h * 0.03,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class HomeFeaturesGrid extends StatelessWidget {
  const HomeFeaturesGrid({
    super.key,
    this.maxTileWidth = 360,
    this.aspectRatio = 1.35, 
    this.spacing = 24,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
  });

  final double maxTileWidth;
  final double aspectRatio;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final items = homeFeatures(context);

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxTileWidth, 
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: aspectRatio, 
      ),
      itemBuilder: (_, i) => FeatureCard(item: items[i]),
    );
  }
}
