import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

class FeatureCard extends StatefulWidget {
  final FeatureItem item;
  const FeatureCard({super.key, required this.item});

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _hover = false;
  bool _pressed = false;

  void _setHover(bool v) => setState(() => _hover = v);
  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final scale = _pressed ? 0.98 : (_hover ? 1.04 : 1.0);
    final iconScale = _hover ? 1.15 : 1.0;
    final bgColor = _hover ? Colors.purple[50] : Colors.white;
    final shadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: _hover ? 0.12 : 0.06),
        blurRadius: _hover ? 28 : 18,
        offset: Offset(0, _hover ? 14 : 10),
      ),
    ];

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: () {
          context.push(widget.item.route);
        },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: shadow,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: h * 0.02,
                vertical: h * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  AnimatedScale(
                    scale: iconScale,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: Container(
                      width: h * 0.07,
                      height: h * 0.07,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB388FF), Color(0xFFFF7BB0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        widget.item.icon,
                        color: Colors.white,
                        size: h * 0.045,
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.015),
                  customText(
                    text: widget.item.title,
                    size: h * 0.016,
                    bold: true,
                    color: const Color(0xFF7A004C),
                    maxLines: 2,
                  ),
                  SizedBox(height: h * 0.006),
                  customText(
                    text: widget.item.subtitle,
                    size: h * 0.012,
                    color: const Color(0xFFE91E63),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
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
