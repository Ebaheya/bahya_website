import 'dart:async';

import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/route.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lineController;
  late AnimationController _splitController;
  late AnimationController _pulseController;

  late Animation<double> _lineHeightAnimation;
  late Animation<double> _moveAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _pulseScaleAnimation;

  @override
  void initState() {
    super.initState();

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _splitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _lineHeightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.fastOutSlowIn),
    );

    _moveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _splitController, curve: Curves.easeInOutCubic),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splitController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimationAndLogic();
  }

  void _startAnimationAndLogic() {
    _lineController.forward().then((_) {
      if (!mounted) return;

      _splitController.forward().then((_) {
        if (!mounted) return;

        _pulseController.repeat(reverse: true);
        _decideNextScreen();
      });
    });
  }

  Future<void> _decideNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    await authNotifier.checkLogin();

    if (!mounted) return;

    await _reverseAnimation();

    if (!mounted) return;

    if (!authNotifier.isLoggedIn) {
      _goTo('/login');
      return;
    }

    _goTo('/authCheck');
  }

  Future<void> _reverseAnimation() async {
    _pulseController.stop();

    if (_splitController.status != AnimationStatus.dismissed) {
      await _splitController.reverse();
    }

    if (_lineController.status != AnimationStatus.dismissed) {
      await _lineController.reverse();
    }
  }

  void _goTo(String routeName) {
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  @override
  void dispose() {
    _lineController.dispose();
    _splitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double maxMove = screenSize.width * 0.38;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_splitController, _pulseController]),
              builder: (context, child) {
                final currentLogoPosition =
                    maxMove - (_moveAnimation.value * maxMove);

                return Transform.translate(
                  offset: Offset(currentLogoPosition, -20),
                  child: Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _splitController.value >= 1.0
                          ? _pulseScaleAnimation.value
                          : 1.0,
                      child: Image.asset(
                        'assets/pics/app_icon.png',
                        width: screenSize.width * 0.75,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: Listenable.merge([_lineController, _splitController]),
              builder: (context, child) {
                final currentLinePosition = _moveAnimation.value * maxMove;

                return Transform.translate(
                  offset: Offset(-currentLinePosition, -20),
                  child: Container(
                    width: 10.0,
                    height:
                        screenSize.height * 0.28 * _lineHeightAnimation.value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: gradientColors,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
