import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class CustomGlowButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const CustomGlowButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: getScreenWidth(context) * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF7BB0).withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFFFF7BB0),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: onPressed,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'ArabicCustomFont',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
