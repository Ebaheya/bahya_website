import 'dart:math' as math;
import 'package:bahya_app/services/internet_connection_service.dart';
import 'package:flutter/material.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with TickerProviderStateMixin {
  bool _checking = false;
  final GlobalKey _iconKey = GlobalKey();

  late final AnimationController _networkSignalController;
  late final AnimationController _contentController;
  late final AnimationController _pulseController;
  late final AnimationController _buttonHoverController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    _networkSignalController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _buttonHoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _buttonHoverController, curve: Curves.easeInOut),
    );

    _contentController.forward();
  }

  @override
  void dispose() {
    _networkSignalController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    _buttonHoverController.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    if (_checking) return;

    await _buttonHoverController.forward();
    await _buttonHoverController.reverse();

    setState(() => _checking = true);

    final hasInternet = await InternetConnectionService.instance.hasInternet();

    if (!mounted) return;

    setState(() => _checking = false);

    if (hasInternet) {
      Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAF5FF),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _networkSignalController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScreenWavesPainter(
                    animationValue: _networkSignalController.value,
                    iconKey: _iconKey,
                    context: context,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              key: _iconKey,
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xff8A2BE2).withOpacity(
                                  0.05 + (0.03 * _pulseController.value),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xffFF69B4).withOpacity(
                                      0.03 * (1.0 - _pulseController.value),
                                    ),
                                    blurRadius:
                                        15 + (10 * _pulseController.value),
                                    spreadRadius:
                                        2 + (4 * _pulseController.value),
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF8A2BE2), Color(0xFFFF69B4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.wifi_off_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'لا يوجد اتصال بالإنترنت',
                        style: TextStyle(
                          fontFamily: 'ArabicCustomFont',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2A1B3D),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'تأكدي من اتصالك بالإنترنت ثم حاولي مرة أخرى.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'ArabicCustomFont',
                            fontSize: 15,
                            color: Color(0xff6A5B7B),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: GestureDetector(
                          onTapDown: (_) => _checking
                              ? null
                              : _buttonHoverController.forward(),
                          onTapUp: (_) => _checking
                              ? null
                              : _buttonHoverController.reverse(),
                          onTapCancel: () => _checking
                              ? null
                              : _buttonHoverController.reverse(),
                          child: AnimatedBuilder(
                            animation: _buttonScaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _buttonScaleAnimation.value,
                                child: child,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: _checking ? 80 : 210,
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  _checking ? 27 : 16,
                                ),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8A2BE2),
                                    Color(0xFFFF69B4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xff8A2BE2,
                                    ).withOpacity(_checking ? 0.2 : 0.35),
                                    blurRadius: _checking ? 10 : 20,
                                    offset: Offset(0, _checking ? 4 : 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _checking ? null : _retry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      _checking ? 27 : 16,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder:
                                      (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                  child: _checking
                                      ? const SizedBox(
                                          key: ValueKey('progress'),
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          key: ValueKey('retry_text'),
                                          children: [
                                            Icon(
                                              Icons.refresh_rounded,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'إعادة المحاولة',
                                              style: TextStyle(
                                                fontFamily: 'ArabicCustomFont',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
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
          ),
        ],
      ),
    );
  }
}

class ScreenWavesPainter extends CustomPainter {
  final double animationValue;
  final GlobalKey iconKey;
  final BuildContext context;

  ScreenWavesPainter({
    required this.animationValue,
    required this.iconKey,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height * 0.32);

    final RenderBox? renderBox =
        iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      center = Offset(
        position.dx + renderBox.size.width / 2,
        position.dy + renderBox.size.height / 2,
      );
    }

    final maxRadius = math.max(size.width, size.height) * 1.2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 5; i++) {
      double progress = (animationValue + (i / 5)) % 1.0;
      double radius = 70 + (maxRadius - 70) * progress;

      paint.color = Color.lerp(
        const Color(0xFF8A2BE2),
        const Color(0xFFFF69B4),
        progress,
      )!.withOpacity((1.0 - progress) * 0.08);

      canvas.drawCircle(center, radius, paint);
    }

    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 3; i++) {
      double progress = (animationValue + (i / 3) + 0.5) % 1.0;
      double radius = 100 + (maxRadius * 0.6 - 100) * progress;

      dashPaint.color = Color.lerp(
        const Color(0xFFFF69B4),
        const Color(0xFF8A2BE2),
        progress,
      )!.withOpacity((1.0 - progress) * 0.04);

      _drawDashedCircle(canvas, center, radius, dashPaint);
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    const int dashCount = 24;
    final double dashAngle = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      double startAngle = i * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle * 0.3,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScreenWavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
