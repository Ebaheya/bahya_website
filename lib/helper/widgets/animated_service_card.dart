import 'dart:math';

import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AnimatedServiceCard extends StatefulWidget {
  final Widget child;
  final Color strokeColor;
  final double borderRadius;
  final double strokeWidth;
  final Duration duration;

  const AnimatedServiceCard({
    super.key,
    required this.child,
    required this.strokeColor,
    this.borderRadius = 24.0,
    this.strokeWidth = 3.5,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<AnimatedServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _NeonBorderPainter(
            animationValue: _controller.value,
            strokeColor: widget.strokeColor,
            borderRadius: widget.borderRadius,
            strokeWidth: widget.strokeWidth,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _NeonBorderPainter extends CustomPainter {
  final double animationValue;
  final Color strokeColor;
  final double borderRadius;
  final double strokeWidth;

  _NeonBorderPainter({
    required this.animationValue,
    required this.strokeColor,
    required this.borderRadius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rrect);

    final glowPaint = Paint()
      ..strokeWidth = strokeWidth * 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final corePaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gradient = SweepGradient(
      colors: [
        strokeColor.withOpacity(0.0),
        strokeColor.withOpacity(0.2),
        strokeColor,
        strokeColor.withOpacity(0.2),
        strokeColor.withOpacity(0.0),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      transform: GradientRotation(animationValue * 2 * pi),
    );

    final shader = gradient.createShader(rect);
    glowPaint.shader = shader;
    corePaint.shader = shader;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, corePaint);
  }

  @override
  bool shouldRepaint(covariant _NeonBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.strokeColor != strokeColor;
  }
}

Widget serviceInfo({
  required double w,
  required double h,
  required String title,
  required String date,
  required String time,
  required String location,
  bool forAdmin = false,
  double? availableSeats,
  bool isAccepted = false,
  bool isUnderReview = false,
  bool isRejected = false,
  bool isCancelled = false,
  bool isSupport = false,
  String? meetingPlace,
  String? departureTime,
  String? endDate,
  bool isTravel = false,
  bool isRequested = false,
  VoidCallback? onJoinPressed,
  VoidCallback? onCancelPressed,
  Color? categoryColor,
  IconData? categoryIcon,
}) {
  final Color mainColor =
      categoryColor ??
      (isTravel
          ? Colors.blue[600]!
          : (isSupport ? Colors.purple[600]! : Colors.green[700]!));

  final Color lightColor = mainColor.withOpacity(0.12);

  final IconData mainIcon =
      categoryIcon ??
      (isTravel
          ? Icons.directions_bus_rounded
          : (isSupport ? Icons.groups_rounded : Icons.menu_book_rounded));

  String localizedText(String text) =>
      AppLocalizations(localeNotifier.locale).t(text);

  String statusText() {
    if (isAccepted) {
      return forAdmin ? 'تمت الموافقة على الطلب' : 'تمت الموافقة على طلبك';
    }
    if (isUnderReview) {
      return forAdmin ? 'الطلب قيد المراجعة' : 'طلبك قيد المراجعة';
    }
    if (isRejected) {
      return forAdmin ? 'تم رفض الطلب' : 'تم رفض طلبك';
    }
    if (isCancelled) {
      return forAdmin ? 'تم إلغاء الطلب' : 'تم إلغاء طلبك';
    }
    return forAdmin ? 'حالة الطلب غير محددة' : 'حالة طلبك غير محددة';
  }

  Color statusColor() {
    if (isAccepted) return Colors.green;
    if (isUnderReview) return Colors.orange;
    if (isRejected) return Colors.red;
    if (isCancelled) return Colors.grey;
    return Colors.grey;
  }

  Widget statusChip() {
    return Container(
      width: forAdmin ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: w * 0.035, vertical: h * 0.01),
      decoration: BoxDecoration(
        color: statusColor().withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: customText(
        text: statusText(),
        size: w * 0.031,
        color: statusColor(),
        bold: true,
        maxLines: 1,
      ),
    );
  }

  Widget infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.01),
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.012),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mainColor.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: h * 0.04,
            height: h * 0.04,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: mainColor, size: w * 0.045),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: localizedText(label),
                    style: TextStyle(
                      fontSize: w * 0.034,
                      color: Colors.grey[700],
                      fontFamily: 'ArabicCustomFont',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value.trim().isEmpty
                        ? localizedText('غير محدد')
                        : value,
                    style: TextStyle(
                      fontSize: w * 0.034,
                      color: mainColor,
                      fontFamily: 'ArabicCustomFont',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: AnimatedServiceCard(
      strokeColor: mainColor,
      borderRadius: 24,
      strokeWidth: 3.0,
      child: Container(
        padding: EdgeInsets.all(w * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: h * 0.075,
                  height: h * 0.075,
                  decoration: BoxDecoration(
                    color: lightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(mainIcon, color: mainColor, size: w * 0.075),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: customText(
                    text: title,
                    size: w * 0.043,
                    bold: true,
                    color: const Color(0xff14213D),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
            if (forAdmin) ...[SizedBox(height: h * 0.014), statusChip()],
            SizedBox(height: h * 0.018),
            infoRow(
              icon: Icons.calendar_month_rounded,
              label: isTravel ? 'تاريخ البداية: ' : 'التاريخ: ',
              value: date,
            ),
            if (isTravel && endDate != null && endDate.trim().isNotEmpty)
              infoRow(
                icon: Icons.event_available_rounded,
                label: 'تاريخ النهاية: ',
                value: endDate,
              ),
            infoRow(
              icon: Icons.access_time_rounded,
              label: isTravel ? 'وقت البداية: ' : 'الوقت: ',
              value: time,
            ),
            if (isTravel &&
                departureTime != null &&
                departureTime.trim().isNotEmpty)
              infoRow(
                icon: Icons.directions_bus_rounded,
                label: 'وقت الانطلاق: ',
                value: departureTime,
              ),
            infoRow(
              icon: Icons.location_on_rounded,
              label: 'الفرع: ',
              value: location,
            ),
            if (isTravel &&
                meetingPlace != null &&
                meetingPlace.trim().isNotEmpty)
              infoRow(
                icon: Icons.pin_drop_rounded,
                label: 'مكان التجمع: ',
                value: meetingPlace,
              ),
            if (!forAdmin) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: h * 0.008),
                child: Divider(
                  color: Colors.grey.withOpacity(0.25),
                  thickness: 1,
                  height: 1,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isRequested
                      ? statusColor().withOpacity(0.10)
                      : lightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isRequested
                    ? customText(
                        text: statusText(),
                        size: w * 0.033,
                        color: statusColor(),
                        bold: true,
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            color: mainColor,
                            size: w * 0.045,
                          ),
                          Expanded(
                            child: customText(
                              text: localeNotifier.isArabic
                                  ? 'متاح ${availableSeats?.toStringAsFixed(0) ?? '0'} مقعد'
                                  : '${availableSeats?.toStringAsFixed(0) ?? '0'} seats available',
                              size: w * 0.033,
                              color: mainColor,
                              bold: true,
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: h * 0.012),
              if (isRequested && isUnderReview)
                CustomGlowButton(
                  title: 'إلغاء الطلب',
                  width: double.infinity,
                  height: h * 0.052,
                  textSize: w * 0.035,
                  glowColor: Colors.red.withOpacity(0.35),
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  borderRadius: 10,
                  onPressed: onCancelPressed ?? () {},
                )
              else if (!isRequested)
                CustomGlowButton(
                  title: 'الانضمام الآن',
                  width: double.infinity,
                  height: h * 0.052,
                  textSize: w * 0.035,
                  glowColor: mainColor.withOpacity(0.45),
                  backgroundColor: mainColor,
                  textColor: Colors.white,
                  borderRadius: 10,
                  onPressed: onJoinPressed ?? () {},
                ),
            ],
          ],
        ),
      ),
    ),
  );
}
