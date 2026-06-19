import 'package:bahya_app/helper/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeartPullRefreshScrollView extends StatelessWidget {
  const HeartPullRefreshScrollView({
    super.key,
    required this.onRefresh,
    required this.slivers,
    this.refreshTriggerPullDistance = 100,
    this.refreshIndicatorExtent = 75,
    this.physics = const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
  });

  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: physics,
      slivers: [
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: refreshTriggerPullDistance,
          refreshIndicatorExtent: refreshIndicatorExtent,
          onRefresh: onRefresh,
          builder: (
            context,
            refreshState,
            pulledExtent,
            refreshTriggerPullDistance,
            refreshIndicatorExtent,
          ) {
            return HeartBeatingRefreshIndicator(
              refreshState: refreshState,
              pulledExtent: pulledExtent,
              refreshTriggerPullDistance: refreshTriggerPullDistance,
            );
          },
        ),
        ...slivers,
      ],
    );
  }
}

class HeartBeatingRefreshIndicator extends StatefulWidget {
  const HeartBeatingRefreshIndicator({
    super.key,
    required this.refreshState,
    required this.pulledExtent,
    required this.refreshTriggerPullDistance,
  });

  final RefreshIndicatorMode refreshState;
  final double pulledExtent;
  final double refreshTriggerPullDistance;

  @override
  State<HeartBeatingRefreshIndicator> createState() =>
      _HeartBeatingRefreshIndicatorState();
}

class _HeartBeatingRefreshIndicatorState
    extends State<HeartBeatingRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController heartController;
  late final Animation<double> heartAnimation;

  @override
  void initState() {
    super.initState();

    heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    heartAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.25).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.18).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 25,
      ),
    ]).animate(heartController);
  }

  @override
  void didUpdateWidget(covariant HeartBeatingRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.refreshState == RefreshIndicatorMode.refresh) {
      if (!heartController.isAnimating) {
        heartController.repeat();
      }
    } else {
      heartController.stop();
      heartController.value = 0.0;
    }
  }

  @override
  void dispose() {
    heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dragPercentage =
        (widget.pulledExtent / widget.refreshTriggerPullDistance).clamp(
      0.0,
      1.0,
    );

    return Container(
      height: widget.pulledExtent,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: AnimatedBuilder(
        animation: heartAnimation,
        builder: (context, child) {
          final scale = widget.refreshState == RefreshIndicatorMode.refresh
              ? heartAnimation.value
              : dragPercentage;

          return Opacity(
            opacity: dragPercentage,
            child: Transform.scale(
              scale: scale,
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: responsiveSize(context, 0.09, min: 34, max: 42),
              ),
            ),
          );
        },
      ),
    );
  }
}
