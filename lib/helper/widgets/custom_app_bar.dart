import 'dart:ui';

import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/screens/patients/profile.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar({
  required BuildContext context,
  required String title,
  required String subTitle,
  IconData? icon,
  bool isArticle = false,
  GlobalKey<ScaffoldState>? scaffoldKey,
  isHome = true,
  void Function()? onIconPressed,
  List<Widget>? widgets,
  Size? preferredSize,
}) {
  final h = getScreenHeight(context);
  final w = getScreenWidth(context);

  return PreferredSize(
    preferredSize: preferredSize ?? Size.fromHeight(h * 0.13),
    child: ClipPath(
      clipper: AppBarWaveClipper(),
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
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (icon == null && isHome == false)
                        ? const SizedBox.shrink()
                        : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                isHome
                                    ? showGeneralDialog(
                                        context: context,
                                        barrierLabel: "Profile",
                                        barrierDismissible: true,
                                        barrierColor: Colors.black.withOpacity(
                                          0.2,
                                        ),
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
                                      )
                                    : onIconPressed != null
                                    ? onIconPressed()
                                    : null;
                              },
                              icon: Icon(
                                isHome ? Icons.person_2_outlined : icon,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    Row(
                      children: [
                        isArticle
                            ? SizedBox.shrink()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  customText(
                                    text: title,
                                    size: w * 0.05,
                                    bold: true,
                                    color: Colors.white,
                                  ),
                                  customText(
                                    text: subTitle,
                                    size: w * 0.03,
                                    bold: true,
                                    color: Colors.white,
                                  ),
                                ],
                              ),

                        const SizedBox(width: 10),

                        isHome
                            ? const SizedBox.shrink()
                            : widgets != null
                            ? const SizedBox.shrink()
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
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

                SizedBox(height: h * 0.02),

                if (widgets != null) ...widgets,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class AppBarWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 35);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.50,
      size.height - 20,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 40,
      size.width,
      size.height - 20,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
