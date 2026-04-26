import 'package:bahya_website/helper/base.dart';
import 'package:flutter/material.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: const [
                TopBar(),
                Expanded(child: Dashboard()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// Sidebar
//////////////////////////////////////////////////////////////

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color.fromARGB(255, 254, 239, 249),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 10),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // color: const Color.fromARGB(255, 246, 176, 213),
                  // gradient: LinearGradient(
                  //   colors: [Color(0xFFFF7BB0), Color(0xFFE6B3FF)],
                  // ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/icons/breastCancerIcon.png',
                    height: 30,
                  ),
                ),
              ),
              SizedBox(width: 12),
              arabicText(text: "لوحه التحكم", size: 14),
            ],
          ),
          const SizedBox(height: 30),

          sidebarItem(Icons.dashboard, "Dashboard"),
          sidebarItem(Icons.people, "Users"),
          sidebarItem(Icons.local_hospital, "Patients"),
          sidebarItem(Icons.group, "Team"),
          sidebarItem(Icons.bar_chart, "Reports"),
          sidebarItem(Icons.settings, "Settings"),

          const Spacer(),
          sidebarItem(Icons.logout, "Logout"),
        ],
      ),
    );
  }

  Widget sidebarItem(IconData icon, String title) {
    return ListTile(leading: Icon(icon), title: Text(title));
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

//////////////////////////////////////////////////////////////
/// Dashboard Content
//////////////////////////////////////////////////////////////

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Overview",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: const [
              StatCard("Total Users", "1247"),
              StatCard("Patients", "892"),
              StatCard("Doctors", "45"),
              StatCard("Staff", "310"),
              StatCard("Active Users", "1189"),
              StatCard("Inactive Users", "58"),
              StatCard("Failed Logins", "23"),
              StatCard("Reports", "12"),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(child: SystemHealthCard()),
              const SizedBox(width: 20),
              Expanded(child: ActivityCard()),
            ],
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// Cards
//////////////////////////////////////////////////////////////

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// System Health
//////////////////////////////////////////////////////////////

class SystemHealthCard extends StatelessWidget {
  const SystemHealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("System Health", style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("API Status: Healthy"),
          Text("Database: Connected"),
          Text("Server: 99.9%"),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// Activity
//////////////////////////////////////////////////////////////

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Recent Activity", style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("• User created"),
          Text("• Patient updated"),
          Text("• Login failed"),
        ],
      ),
    );
  }
}
