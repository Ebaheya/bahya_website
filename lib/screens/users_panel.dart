import 'package:bahya_website/helper/admin_widgets/user_table.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          /// Header
          pageHeader(
            width: getScreenWidth(context),
            title: "Users Management",
            subtitle: 'Manage and monitor all platform users',
            widgets: [
              CustomGlowButton(
                title: "Add User",
                onPressed: () {},
                textSize: getScreenWidth(context) * 0.011,
                textColor: textColor,
                glowColor: Colors.white,
                width: getScreenWidth(context) * 0.1,
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Table
          const UsersTable(),
        ],
      ),
    );
  }
}
