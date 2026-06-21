import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/screens/admin/dashboard_panel.dart';
import 'package:bahya_website/helper/admin_widgets/sidebar_panel.dart';
import 'package:bahya_website/screens/admin/report_panel.dart';
import 'package:bahya_website/screens/admin/settings_panel.dart';
import 'package:bahya_website/screens/admin/users_panel.dart';
import 'package:flutter/material.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int selectedIndex = 0;

  Widget getCurrentPage() {
    switch (selectedIndex) {
      case 0:
        return const Dashboard();
      case 1:
        return const UsersPage();
      case 2:
        return const ReportsPage();
      case 3:
        return const SettingsPage();
      default:
        return const Dashboard();
    }
  }

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 750;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: isMobile ? _mobileLayout() : _desktopLayout(),
    );
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        Sidebar(selectedIndex: selectedIndex, onItemSelected: changePage),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey(selectedIndex),
              child: getCurrentPage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout() {
    return SafeArea(
      child: Column(
        children: [
          // Padding(
          //   padding: EdgeInsets.fromLTRB(
          //     responsiveSize(context, 0.014, min: 14, max: 18),
          //     responsiveHeight(context, 0.012, min: 10, max: 14),
          //     responsiveSize(context, 0.014, min: 14, max: 18),
          //     0,
          //   ),
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Row(
          //       children: [
          //         customText(
          //           text: 'Admin Panel',
          //           size: responsiveSize(context, 0.014, min: 18, max: 22),
          //           color: textColor,
          //           bold: true,
          //           isEnglish: true,
          //         ),
          //         const Spacer(),
          //         const LanguageToggleButton(padding: EdgeInsets.zero),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(selectedIndex),
                child: getCurrentPage(),
              ),
            ),
          ),
          AdminBottomNavigation(
            selectedIndex: selectedIndex,
            onItemSelected: changePage,
          ),
        ],
      ),
    );
  }
}
