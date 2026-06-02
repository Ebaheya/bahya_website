import 'package:bahya_app/helper/constant.dart';
import 'package:flutter/material.dart';

Widget customLoading() {
  return const Padding(
    padding: EdgeInsets.all(20),
    child: Center(child: PulsingHeartLoader()),
  );
}

class PulsingHeartLoader extends StatefulWidget {
  const PulsingHeartLoader({super.key});

  @override
  State<PulsingHeartLoader> createState() => _PulsingHeartLoaderState();
}

class _PulsingHeartLoaderState extends State<PulsingHeartLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _blurAnimation = Tween<double>(
      begin: 15,
      end: 30,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 85,
            height: 85,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.6),
                  blurRadius: _blurAnimation.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        );
      },
    );
  }
}
