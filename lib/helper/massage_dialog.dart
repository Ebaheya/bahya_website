import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:flutter/material.dart';

void customDialog({
  required BuildContext context,
  required String title,
  required String message,
  void Function()? onClose,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB3D9), Color(0xFFFF7BB0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customText(
                    text: title,
                    size: 24,
                    bold: true,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  customText(text: message, size: 16, color: Colors.white),
                  const SizedBox(height: 24),
                  CustomGlowButton(
                    title: 'حسناً',
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
