import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/diagnosis_patients_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StatCard extends StatefulWidget {
  final String title;
  final double percent;
  final Color color;
  final IconData icon;
  final List<PatientDiagnosisItem> demoPatients;
  const StatCard({
    super.key,
    required this.title,
    required this.percent,
    required this.color,
    required this.icon,
    required this.demoPatients,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  bool _pressed = false;

  late final AnimationController _badgeController;
  late final Animation<Offset> _badgeOffset;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _badgeOffset = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _badgeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  void _setHover(bool v) {
    setState(() => _hover = v);
    if (v) {
      _badgeController.forward();
    } else {
      _badgeController.reverse();
    }
  }

  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.98 : (_hover ? 1.04 : 1.0);
    final iconScale = _hover ? 1.15 : 1.0;

    final shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(_hover ? 0.12 : 0.06),
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
        child: InkWell(
          onTap: () => showDiagnosisPatientsDialog(
            context: context,
            diagnosisTitle: "المريضات المصابات بحالات طبيعية",
            patients: widget.demoPatients,
            averageAge: 31,
          ),
          borderRadius: BorderRadius.circular(20),
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  width: double.infinity,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: shadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedScale(
                        scale: iconScale,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: widget.color.withOpacity(.15),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 26,
                          ),
                        ),
                      ),
                      CircularPercentIndicator(
                        radius: 50,
                        lineWidth: 8,
                        animation: true,
                        percent: widget.percent,
                        center: customText(
                          text: "${(widget.percent * 100).toStringAsFixed(0)}%",
                          size: 18,
                          bold: true,
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        animateFromLastPercent: true,
                        animateToInitialPercent: true,
                        backgroundColor: Colors.grey.shade200,
                        progressColor: widget.color,
                      ),
                      Column(
                        children: [
                          customText(
                            text: widget.title,
                            size: 18,
                            bold: true,
                            color: const Color(0xFF7A004C),
                          ),
                          const SizedBox(height: 4),
                          customText(
                            text: "من إجمالي المرضى",
                            size: 13,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 10,
                  left: 10,
                  child: FadeTransition(
                    opacity: _badgeController,
                    child: SlideTransition(
                      position: _badgeOffset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F7),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: customText(
                          text: "انقر للتفاصيل",
                          size: 10,
                          color: const Color(0xFFE91E63),
                          bold: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatsHorizontalGrid extends StatelessWidget {
  final List<StatCard> items;
  const StatsHorizontalGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
     final h = getScreenHeight(context);
     final w = getScreenWidth(context);
    return SizedBox(
     
      height: h * 0.35,
      // width: w * 0.02,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
          },
        ),
        child: GridView.builder(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          primary: false,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }
}
