import 'dart:math' as math;
import 'dart:ui';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/screens/patients/profile.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar({
  required BuildContext context,
  required String title,
  required String subTitle,
  bool isAdmin = false,
  IconData? icon,
  bool isArticle = false,
  GlobalKey<ScaffoldState>? scaffoldKey,
  bool isHome = true,
  void Function()? onIconPressed,
  List<Widget>? widgets,
  Size? preferredSize,
}) {
  final h = MediaQuery.of(context).size.height;
  return PreferredSize(
    preferredSize:
        preferredSize ?? Size.fromHeight(widgets != null ? h * 0.22 : h * 0.17),
    child: _AnimatedWaveAppBar(
      title: title,
      subTitle: subTitle,
      icon: icon,
      isArticle: isArticle,
      scaffoldKey: scaffoldKey,
      isAdmin: isAdmin,
      isHome: isHome,
      onIconPressed: onIconPressed,
      widgets: widgets,
    ),
  );
}

class _AnimatedWaveAppBar extends StatefulWidget {
  final String title;
  final String subTitle;
  final bool isAdmin;
  final IconData? icon;
  final bool isArticle;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool isHome;
  final void Function()? onIconPressed;
  final List<Widget>? widgets;

  const _AnimatedWaveAppBar({
    required this.title,
    required this.subTitle,
    this.isAdmin = false,
    this.icon,
    this.isArticle = false,
    this.scaffoldKey,
    this.isHome = true,
    this.onIconPressed,
    this.widgets,
  });

  @override
  State<_AnimatedWaveAppBar> createState() => _AnimatedWaveAppBarState();
}

class _AnimatedWaveAppBarState extends State<_AnimatedWaveAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final isArabic = context.l10n.isArabic;
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return ClipPath(
          clipper: AppBarWaveClipper(animationValue: _waveController.value),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 10,
                  bottom: 35,
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (widget.icon == null && widget.isHome == false)
                              ? const SizedBox.shrink()
                              : Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.15),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      if (widget.isHome) {
                                        showGeneralDialog(
                                          context: context,
                                          barrierLabel: "Profile",
                                          barrierDismissible: true,
                                          barrierColor: Colors.black
                                              .withOpacity(0.2),
                                          transitionDuration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          pageBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) {
                                                return const Profile();
                                              },
                                          transitionBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) {
                                                final curvedAnimation =
                                                    CurvedAnimation(
                                                      parent: animation,
                                                      curve: Curves.easeOutBack,
                                                    );
                                                return BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 8,
                                                    sigmaY: 8,
                                                  ),
                                                  child: SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(
                                                        0,
                                                        0.25,
                                                      ),
                                                      end: Offset.zero,
                                                    ).animate(curvedAnimation),
                                                    child: FadeTransition(
                                                      opacity: curvedAnimation,
                                                      child: child,
                                                    ),
                                                  ),
                                                );
                                              },
                                        );
                                      } else if (widget.onIconPressed != null) {
                                        widget.onIconPressed!();
                                      }
                                    },
                                    icon: Icon(
                                      widget.isHome
                                          ? Icons.person_2_outlined
                                          : widget.icon,
                                      color: Colors.white,
                                      size: w * 0.055,
                                    ),
                                  ),
                                ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!widget.isArticle)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    customText(
                                      text: widget.title,
                                      size: w * 0.048,
                                      bold: true,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 2),
                                    customText(
                                      text: widget.subTitle,
                                      size: w * 0.032,
                                      bold: true,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ],
                                ),
                              const SizedBox(width: 12),
                              if (!widget.isHome && !widget.isAdmin)
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.15),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      if (widget.widgets != null) ...[
                        SizedBox(height: h * 0.01),
                        ...widget.widgets!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppBarWaveClipper extends CustomClipper<Path> {
  final double animationValue;

  AppBarWaveClipper({required this.animationValue});

  @override
  Path getClip(Size size) {
    final path = Path();
    final baseHeight = size.height - 25;

    path.lineTo(0, baseHeight);

    final controlPoint1 = Offset(
      size.width * 0.25,
      baseHeight - (math.sin(animationValue * 2 * math.pi) * 10),
    );
    final endPoint1 = Offset(size.width * 0.5, baseHeight);

    final controlPoint2 = Offset(
      size.width * 0.75,
      baseHeight + (math.sin(animationValue * 2 * math.pi) * 10),
    );
    final endPoint2 = Offset(size.width, baseHeight);

    path.quadraticBezierTo(
      controlPoint1.dx,
      controlPoint1.dy,
      endPoint1.dx,
      endPoint1.dy,
    );
    path.quadraticBezierTo(
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint2.dx,
      endPoint2.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant AppBarWaveClipper oldClipper) {
    return oldClipper.animationValue != animationValue;
  }
}
