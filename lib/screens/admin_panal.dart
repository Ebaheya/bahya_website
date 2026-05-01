import 'package:bahya_website/screens/dashboard_panel.dart';
import 'package:bahya_website/helper/admin_widgets/sidebar_panel.dart';
import 'package:bahya_website/screens/users_panel.dart';
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
        return const PatientsPage();
      case 3:
        return const TeamPage();
      case 4:
        return const ReportsPage();
      case 5:
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
                const TopBar(),
                Expanded(child: getCurrentPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// Top Bar
//////////////////////////////////////////////////////////////

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          const CircleAvatar(child: Text("AD")),
          const SizedBox(width: 10),
          const Text("Admin User"),
        ],
      ),
    );
  }
}



class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Patients Page"));
  }
}

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Team Page"));
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Reports Page"));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Settings Page"));
  }
}
