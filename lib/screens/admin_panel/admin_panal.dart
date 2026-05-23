import 'package:bahya_website/screens/admin_panel/dashboard_panel.dart';
import 'package:bahya_website/helper/admin_widgets/sidebar_panel.dart';
import 'package:bahya_website/screens/admin_panel/report_panel.dart';
import 'package:bahya_website/screens/admin_panel/settings_panel.dart';
import 'package:bahya_website/screens/admin_panel/users_panel.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          Expanded(
            child: Column(
              children: [
                // const TopBar(),
                Expanded(child: getCurrentPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


