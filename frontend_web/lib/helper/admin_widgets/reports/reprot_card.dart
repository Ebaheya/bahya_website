import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class ReportCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final double value;

  const ReportCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    final scale = _pressed ? 0.98 : (_hover ? 1.025 : 1.0);
    final iconScale = _hover ? 1.12 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: EdgeInsets.all(
              responsiveSize(context, 0.012, min: 12, max: 18),
            ),
            decoration: BoxDecoration(
              color: _hover ? const Color(0xFFFFF8FC) : Colors.white,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.014, min: 16, max: 22),
              ),
              border: Border.all(
                color: _hover ? const Color(0xFFFFC6DD) : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hover ? 0.12 : 0.06),
                  blurRadius: responsiveSize(
                    context,
                    _hover ? 0.02 : 0.012,
                    min: 12,
                    max: 28,
                  ),
                  offset: Offset(
                    0,
                    responsiveHeight(
                      context,
                      _hover ? 0.016 : 0.008,
                      min: 5,
                      max: 14,
                    ),
                  ),
                ),
              ],
            ),
            child: isMobile
                ? _mobileContent(context, iconScale)
                : _desktopContent(context, iconScale),
          ),
        ),
      ),
    );
  }

  Widget _desktopContent(BuildContext context, double iconScale) {
    return Row(
      children: [
        _IconBox(icon: widget.icon, scale: iconScale),
        SizedBox(width: responsiveSize(context, 0.01, min: 10, max: 16)),
        Expanded(
          child: _TextContent(
            title: widget.title,
            value: widget.value,
            center: false,
          ),
        ),
      ],
    );
  }

  Widget _mobileContent(BuildContext context, double iconScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBox(icon: widget.icon, scale: iconScale),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
        _TextContent(title: widget.title, value: widget.value, center: false),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final double scale;

  const _IconBox({required this.icon, required this.scale});

  @override
  Widget build(BuildContext context) {
    final size = responsiveSize(context, 0.038, min: 42, max: 58);

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 180),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.01, min: 12, max: 16),
          ),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.18),
              blurRadius: responsiveSize(context, 0.01, min: 10, max: 14),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: responsiveSize(context, 0.018, min: 22, max: 30),
        ),
      ),
    );
  }
}

class _TextContent extends StatelessWidget {
  final String title;
  final double value;
  final bool center;

  const _TextContent({
    required this.title,
    required this.value,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.009, min: 12, max: 15),
          color: Colors.grey,
          isEnglish: true,
          isCenter: center,
          maxLines: 2,
        ),
        SizedBox(height: responsiveHeight(context, 0.006, min: 5, max: 8)),
        customText(
          text: widgetValueText(value),
          size: responsiveSize(context, 0.012, min: 16, max: 22),
          color: const Color(0xFF7A004C),
          bold: true,
          isEnglish: true,
          isCenter: center,
          maxLines: 1,
        ),
      ],
    );
  }

  String widgetValueText(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
