part of 'base.dart';

Widget sectionCard({
  required BuildContext context,
  required String title,
  required Widget child,
  bool? isShadow = true,
}) {
  return Container(
    width: getScreenWidth(context) * 0.95,
    margin: const EdgeInsets.only(bottom: 16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        isShadow == true
            ? BoxShadow(
                color: Colors.black26,
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            : const BoxShadow(
                color: Colors.transparent,
                spreadRadius: 0,
                blurRadius: 0,
                offset: Offset(0, 0),
              ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          height: getScreenHeight(context) * 0.10,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              customText(
                text: title,
                size: getScreenHeight(context) * 0.02,
                bold: true,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        child,
      ],
    ),
  );
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        customText(
          text: label,
          size: getScreenHeight(context) * 0.015,
          color: const Color(0xFF313131),
        ),
      ],
    );
  }
}

Widget customLoading() {
  return Padding(
    padding: const EdgeInsets.all(20),

    child: Center(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1),

          duration: const Duration(milliseconds: 5000),

          curve: Curves.easeInOut,

          builder: (context, value, child) {
            return Transform.scale(
              scale: value,

              child: Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(colors: gradientColors),

                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.35),

                      blurRadius: 25,

                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: const SizedBox(
                  width: 40,

                  height: 40,

                  child: CircularProgressIndicator(
                    strokeWidth: 5,

                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),

                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> customSnackBar({
  required BuildContext context,
  required String message,
}) {
  final w = getScreenWidth(context);
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: buttonColor,
      animation: const AlwaysStoppedAnimation(1),
      showCloseIcon: true,
      content: customText(text: message, size: w * 0.01, color: Colors.white),
    ),
  );
}

Widget modernInputBox({required IconData icon, required Widget child}) {
  return Container(
    height: 62,
    padding: const EdgeInsets.only(left: 14, right: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.withValues(alpha: 0.14)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 14,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: buttonColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: buttonColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    ),
  );
}

class ScheduleInfoBlock extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final bool isTime;

  const ScheduleInfoBlock({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    this.isTime = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.01, min: 12, max: 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            text: title,
            size: h * 0.018,
            color: Colors.grey.shade600,
            bold: true,
            isCenter: false,
          ),
          SizedBox(height: h * 0.007),
          customText(
            text: value,
            size: isTime ? h * 0.032 : h * 0.018,
            bold: true,
            color: isTime ? const Color(0xFF8A0057) : const Color(0xFF333333),
            isCenter: false,
          ),
          if (subValue != null) ...[
            SizedBox(height: h * 0.003),
            customText(
              text: subValue!,
              size: h * 0.017,
              bold: true,
              color: const Color(0xFFE5005F),
              isCenter: false,
            ),
          ],
        ],
      ),
    );
  }
}
