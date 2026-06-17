part of 'sidebar_panel.dart';

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final mainColor = widget.isSelected
        ? const Color(0xFFFF5FA2)
        : isHovered
        ? const Color(0xFFE83E8C)
        : textColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          scale: isHovered ? 1.035 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            margin: EdgeInsets.only(
              bottom: responsiveHeight(context, 0.018, min: 14, max: 22),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.014, min: 16, max: 22),
              vertical: responsiveHeight(context, 0.018, min: 14, max: 18),
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFFFFEEF7)
                  : isHovered
                  ? const Color(0xFFFFF6FB)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.018, min: 18, max: 22),
              ),
              boxShadow: widget.isSelected || isHovered
                  ? [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.12),
                        blurRadius: responsiveSize(
                          context,
                          0.016,
                          min: 14,
                          max: 18,
                        ),
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: widget.isSelected ? -16 : -28,
                  top: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: widget.isSelected ? 1 : 0,
                    child: Container(
                      width: responsiveSize(context, 0.004, min: 5, max: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5FA2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 220),
                      scale: widget.isSelected || isHovered ? 1.15 : 1,
                      child: Icon(
                        widget.icon,
                        color: mainColor,
                        size: responsiveSize(context, 0.014, min: 20, max: 26),
                      ),
                    ),
                    SizedBox(
                      width: responsiveSize(context, 0.018, min: 18, max: 28),
                    ),
                    Expanded(
                      child: customText(
                        text: widget.title,
                        size: responsiveSize(context, 0.01, min: 15, max: 19),
                        color: mainColor,
                        bold: widget.isSelected,
                        isCenter: false,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarWaveFooter extends StatefulWidget {
  const _SidebarWaveFooter();

  @override
  State<_SidebarWaveFooter> createState() => _SidebarWaveFooterState();
}

class _SidebarWaveFooterState extends State<_SidebarWaveFooter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: responsiveHeight(context, 0.14, min: 105, max: 145),
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ClipPath(
            clipper: _WaveClipper(animationValue: _controller.value),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8A2BE2).withValues(alpha: 0.75),
                    const Color(0xFFFF5FA2).withValues(alpha: 0.78),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            Positioned(
              left: -45,
              top: -25,
              child: CircleAvatar(
                radius: responsiveSize(context, 0.07, min: 80, max: 115),
                backgroundColor: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              right: responsiveSize(context, 0.026, min: 26, max: 34),
              bottom: responsiveHeight(context, 0.034, min: 28, max: 34),
              child: CircleAvatar(
                radius: responsiveSize(context, 0.004, min: 4, max: 5),
                backgroundColor: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double animationValue;

  _WaveClipper({required this.animationValue});

  @override
  Path getClip(Size size) {
    final path = Path();
    final double waveOffset = animationValue * 2 * math.pi;

    path.moveTo(0, size.height * 0.28 + math.sin(waveOffset) * 8);

    path.cubicTo(
      size.width * 0.25,
      size.height * 0.02 + math.sin(waveOffset + 1) * 12,
      size.width * 0.45,
      size.height * 0.62 + math.cos(waveOffset + 2) * 12,
      size.width * 0.72,
      size.height * 0.42 + math.sin(waveOffset + 3) * 10,
    );

    path.cubicTo(
      size.width * 0.88,
      size.height * 0.30 + math.cos(waveOffset + 4) * 8,
      size.width * 0.96,
      size.height * 0.15 + math.sin(waveOffset + 5) * 6,
      size.width,
      size.height * 0.22 + math.cos(waveOffset + 6) * 8,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) {
    return oldClipper.animationValue != animationValue;
  }
}

class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 16, max: 18),
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          scale: hover ? 1.025 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.014, min: 16, max: 22),
              vertical: responsiveHeight(context, 0.016, min: 13, max: 17),
            ),
            decoration: BoxDecoration(
              color: hover ? const Color(0xFFFFF2F2) : Colors.white,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.014, min: 16, max: 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: hover ? 0.12 : 0.08),
                  blurRadius: responsiveSize(context, 0.016, min: 14, max: 18),
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: responsiveSize(context, 0.014, min: 20, max: 26),
                ),
                SizedBox(
                  width: responsiveSize(context, 0.018, min: 18, max: 28),
                ),
                Expanded(
                  child: customText(
                    text: 'Log Out',
                    size: responsiveSize(context, 0.01, min: 15, max: 18),
                    color: Colors.red,
                    bold: true,
                    isCenter: false,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.red,
                  size: responsiveSize(context, 0.009, min: 13, max: 17),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
