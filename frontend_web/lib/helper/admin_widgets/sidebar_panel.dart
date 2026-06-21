import 'dart:math' as math;

import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 750;

    if (isMobile) {
      return AdminBottomNavigation(
        selectedIndex: selectedIndex,
        onItemSelected: onItemSelected,
      );
    }

    return AdminSidebarContainer(
      selectedIndex: selectedIndex,
      onItemSelected: onItemSelected,
    );
  }
}

class AdminSidebarContainer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebarContainer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final sidebarWidth = (w * 0.18).clamp(230.0, 310.0);

    return Container(
      width: sidebarWidth,
      margin: EdgeInsets.all(responsiveSize(context, 0.012, min: 14, max: 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.02, min: 24, max: 34),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.08),
            blurRadius: responsiveSize(context, 0.028, min: 28, max: 35),
            offset: Offset(
              0,
              responsiveHeight(context, 0.016, min: 10, max: 14),
            ),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            children: [
              const _SidebarHeader(),
              SizedBox(
                height: responsiveHeight(context, 0.03, min: 20, max: 34),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(
                      context,
                      0.012,
                      min: 14,
                      max: 22,
                    ),
                  ),
                  child: Column(
                    children: [
                      _SidebarItem(
                        icon: Icons.dashboard_rounded,
                        title: 'Dashboard',
                        isSelected: selectedIndex == 0,
                        onTap: () => onItemSelected(0),
                      ),
                      _SidebarItem(
                        icon: Icons.people_alt_rounded,
                        title: 'Users',
                        isSelected: selectedIndex == 1,
                        onTap: () => onItemSelected(1),
                      ),
                      _SidebarItem(
                        icon: Icons.description_rounded,
                        title: 'Reports',
                        isSelected: selectedIndex == 2,
                        onTap: () => onItemSelected(2),
                      ),
                      _SidebarItem(
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        isSelected: selectedIndex == 3,
                        onTap: () => onItemSelected(3),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: responsiveHeight(context, 0.17, min: 135, max: 160),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const _SidebarWaveFooter(),
          ),
          Positioned(
            left: responsiveSize(context, 0.012, min: 14, max: 22),
            right: responsiveSize(context, 0.012, min: 14, max: 22),
            bottom: responsiveHeight(context, 0.105, min: 88, max: 105),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(color: Colors.pink.withValues(alpha: 0.25)),
                SizedBox(
                  height: responsiveHeight(context, 0.018, min: 10, max: 16),
                ),
               _LogoutButton(
                  onTap: () async {
                    await authNotifier.logout();

                    if (!context.mounted) return;

                    context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: responsiveHeight(context, 0.082, min: 78, max: 92),
      margin: EdgeInsets.all(responsiveSize(context, 0.012, min: 12, max: 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 22, max: 28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: const _SidebarWaveFooter()),

          Positioned.fill(
            child: Container(color: Colors.white.withValues(alpha: 0.72)),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.012, min: 10, max: 14),
              vertical: responsiveHeight(context, 0.008, min: 7, max: 9),
            ),
            child: Row(
              children: [
                _BottomNavItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                ),
                _BottomNavItem(
                  icon: Icons.people_alt_rounded,
                  title: 'Users',
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                ),
                _BottomNavItem(
                  icon: Icons.description_rounded,
                  title: 'Reports',
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                ),
                _BottomNavItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFFF5FA2) : textColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            vertical: responsiveHeight(context, 0.01, min: 8, max: 10),
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFEEF7) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1,
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  icon,
                  color: color,
                  size: responsiveSize(context, 0.018, min: 21, max: 25),
                ),
              ),
              SizedBox(
                height: responsiveHeight(context, 0.004, min: 3, max: 5),
              ),
              SizedBox(
                width: double.infinity,
                height: responsiveHeight(context, 0.018, min: 14, max: 18),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: customText(
                    text: title,
                    size: responsiveSize(context, 0.0075, min: 11, max: 13),
                    color: color,
                    bold: isSelected,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: responsiveHeight(context, 0.045, min: 32, max: 55),
        left: responsiveSize(context, 0.014, min: 18, max: 24),
        right: responsiveSize(context, 0.014, min: 18, max: 24),
      ),
      child: Column(
        children: [
          Container(
            width: responsiveSize(context, 0.048, min: 58, max: 74),
            height: responsiveSize(context, 0.048, min: 58, max: 74),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withValues(alpha: 0.25),
                  blurRadius: responsiveSize(context, 0.018, min: 18, max: 22),
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: responsiveSize(context, 0.025, min: 30, max: 40),
            ),
          ),
          SizedBox(height: responsiveHeight(context, 0.025, min: 18, max: 26)),
          customText(
            text: 'Admin Panel',
            size: responsiveSize(context, 0.016, min: 22, max: 30),
            bold: true,
            isGradient: true,
            isEnglish: true,
          ),
          SizedBox(height: responsiveHeight(context, 0.008, min: 6, max: 10)),
          customText(
            text: 'System Administration',
            size: responsiveSize(context, 0.009, min: 13, max: 16),
            color: Colors.grey.shade600,
            isEnglish: true,
          ),
          SizedBox(height: responsiveHeight(context, 0.016, min: 12, max: 18)),
          const LanguageToggleButton(padding: EdgeInsets.zero),
          SizedBox(height: responsiveHeight(context, 0.025, min: 20, max: 30)),
          Row(
            children: [
              Expanded(
                child: Divider(color: Colors.pink.withValues(alpha: 0.35)),
              ),
              Container(
                width: responsiveSize(context, 0.006, min: 8, max: 9),
                height: responsiveSize(context, 0.006, min: 8, max: 9),
                margin: EdgeInsets.symmetric(
                  horizontal: responsiveSize(context, 0.008, min: 8, max: 10),
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5FA2),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Divider(color: Colors.pink.withValues(alpha: 0.35)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
