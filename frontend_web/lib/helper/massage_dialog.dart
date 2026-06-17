import 'dart:ui';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void customDialog({
  required BuildContext context,
  required String title,
  required String message,
  bool isSuccess = false,
  bool isError = false,
  bool isInfo = false,
  void Function()? onClose,
}) {
  final localizedTitle = localizedText(context, title);
  final localizedMessage = localizedText(context, message);

  final bool showSuccess = isSuccess && !isError && !isInfo;
  final bool showError = isError && !isSuccess && !isInfo;
  final IconData icon = showSuccess
      ? Icons.check_rounded
      : showError
      ? Icons.close_rounded
      : Icons.info_outline_rounded;

  final List<Color> iconColors = showSuccess
      ? const [Color(0xFFFF4F93), Color(0xFFB02CFF)]
      : showError
      ? const [Color(0xFFFF4F6D), Color(0xFFFF8A8A)]
      : const [Color(0xFF8E3FD1), Color(0xFFFF7BB0)];

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withValues(alpha: .55),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, __, ___) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 420,
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .96),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFFF7BB0).withValues(alpha: .45),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4F93).withValues(alpha: .25),
                      blurRadius: 35,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          onClose != null
                              ? onClose()
                              : Navigator.of(dialogContext).pop();
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7BB0).withValues(alpha: .09),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(
                                0xFFFF7BB0,
                              ).withValues(alpha: .25),
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFFFF4F93),
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 82,
                      height: 82,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: iconColors),
                        boxShadow: [
                          BoxShadow(
                            color: iconColors.first.withValues(alpha: .28),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: iconColors,
                            ).createShader(bounds);
                          },
                          child: Icon(icon, color: Colors.white, size: 45),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    customText(
                      text: localizedTitle,
                      size: 28,
                      bold: true,
                      color: const Color(0xFF3B1038),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    customText(
                      text: localizedMessage,
                      size: 15,
                      maxLines: 3,
                      bold: true,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: iconColors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: iconColors.first.withValues(alpha: .25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            onClose != null
                                ? onClose()
                                : Navigator.of(dialogContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: customText(
                            text: 'OK',
                            size: 16,
                            bold: true,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) {
      return Transform.scale(
        scale: .92 + animation.value * .08,
        child: Opacity(opacity: animation.value, child: child),
      );
    },
  );
}
