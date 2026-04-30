import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

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
    return Container(
      width: getScreenWidth(context) * 0.15,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          customText(
            text: 'Admin Panel',
            size: getScreenWidth(context) * 0.02,
            bold: true,
            isGradient: true,
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  sidebarItem(0, Icons.dashboard, "Dashboard"),
                  sidebarItem(1, Icons.people, "Users"),
                  sidebarItem(2, Icons.local_hospital, "Patients"),
                  sidebarItem(3, Icons.group, "Team"),
                  sidebarItem(4, Icons.bar_chart, "Reports"),
                  sidebarItem(5, Icons.settings, "Settings"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sidebarItem(int index, IconData icon, String title) {
    return SidebarItemWidget(
      index: index,
      icon: icon,
      title: title,
      isSelected: selectedIndex == index,
      onTap: () => onItemSelected(index),
    );
  }
}

class SidebarItemWidget extends StatefulWidget {
  final int index;
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarItemWidget({
    super.key,
    required this.index,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<SidebarItemWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: widget.isSelected
            ? Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFFFF69B4)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  onTap: widget.onTap,
                  leading: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: getScreenWidth(context) * 0.015,
                  ),
                  title: customText(
                    text: widget.title,
                    isEnglish: true,
                    size: getScreenWidth(context) * 0.01,
                    color: Colors.white,
                    bold: true,
                  ),
                ),
              )
            : AnimatedContainer(
                duration: const Duration(),
                decoration: BoxDecoration(
                  color: isHovered ? Colors.grey[300] : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  onTap: widget.onTap,
                  leading: Icon(
                    widget.icon,
                    color: textColor,
                    size: getScreenWidth(context) * 0.015,
                  ),
                  title: customText(
                    text: widget.title,
                    isEnglish: true,
                    size: getScreenWidth(context) * 0.01,
                    color: textColor,
                  ),
                ),
              ),
      ),
    );
  }
}
