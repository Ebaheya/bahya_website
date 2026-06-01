import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final double? percentage;
  final bool hasPercentage;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.percentage,
    this.hasPercentage = true,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isPositive =
        widget.percentage != null && widget.percentage! >= 0;

    final scale = _pressed ? 0.97 : (_hover ? 1.035 : 1.0);
    final iconScale = _hover ? 1.14 : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(
              responsiveSize(context, 0.012, min: 14, max: 18),
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
                  color: Colors.black.withOpacity(_hover ? 0.11 : 0.055),
                  blurRadius: _hover
                      ? responsiveSize(context, 0.018, min: 22, max: 30)
                      : responsiveSize(context, 0.012, min: 12, max: 18),
                  offset: Offset(
                    0,
                    _hover
                        ? responsiveHeight(context, 0.016, min: 10, max: 14)
                        : responsiveHeight(context, 0.008, min: 4, max: 7),
                  ),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  right: _hover ? -18 : -35,
                  top: _hover ? -18 : -35,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: _hover ? 0.12 : 0.06,
                    child: Container(
                      width: responsiveSize(context, 0.07, min: 70, max: 115),
                      height: responsiveSize(context, 0.07, min: 70, max: 115),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedScale(
                          scale: iconScale,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            padding: EdgeInsets.all(
                              responsiveSize(context, 0.007, min: 8, max: 11),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradientColors),
                              borderRadius: BorderRadius.circular(
                                responsiveSize(
                                  context,
                                  0.008,
                                  min: 10,
                                  max: 14,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: buttonColor.withOpacity(0.22),
                                  blurRadius: responsiveSize(
                                    context,
                                    0.01,
                                    min: 10,
                                    max: 16,
                                  ),
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: responsiveSize(
                                context,
                                0.017,
                                min: 22,
                                max: 32,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        if (widget.hasPercentage)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: EdgeInsets.symmetric(
                              horizontal: responsiveSize(
                                context,
                                0.008,
                                min: 9,
                                max: 12,
                              ),
                              vertical: responsiveHeight(
                                context,
                                0.006,
                                min: 4,
                                max: 6,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: (isPositive ? Colors.green : Colors.red)
                                  .withOpacity(0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: customText(
                              text:
                                  "${isPositive ? "+" : ""}${widget.percentage?.toStringAsFixed(1)}%",
                              size: responsiveSize(
                                context,
                                0.008,
                                min: 11,
                                max: 14,
                              ),
                              color: isPositive ? Colors.green : Colors.red,
                              bold: true,
                              isEnglish: true,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.018,
                        min: 12,
                        max: 18,
                      ),
                    ),

                    customText(
                      text: widget.title,
                      size: responsiveSize(context, 0.0085, min: 12, max: 15),
                      color: Colors.grey,
                      isEnglish: true,
                      isCenter: false,
                      maxLines: 1,
                    ),

                    SizedBox(
                      height: responsiveHeight(context, 0.01, min: 6, max: 10),
                    ),

                    customText(
                      text: widget.value,
                      size: responsiveSize(context, 0.014, min: 18, max: 28),
                      color: const Color(0xFF7A004C),
                      bold: true,
                      isEnglish: true,
                      isCenter: false,
                      maxLines: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
