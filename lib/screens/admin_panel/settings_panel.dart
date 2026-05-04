import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = getScreenWidth(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          pageHeader(
            width: width,
            title: "Settings",
            subtitle: "Manage system and account settings",
          ),

          const SizedBox(height: 20),

          /// Account
          SettingsOptions(
            icon: Icons.settings_outlined,
            title: "Account Settings",
            subtitle: "Manage your account information and preferences",
            info_1: "Profile Name",
            info_2: "Email",
            info_3: "Role",
            value_1: "Bahya Admin",
            value_2: "admin@platform.com",
            value_3: "System Administrator",
          ),

          const SizedBox(height: 20),

          SettingsOptions(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            subtitle: "Configure notification preferences",
            info_1: "Push Notifications",
            info_2: "Email Notifications",
            info_3: "SMS Notifications",
            value_1: "Enabled",
            value_2: "Enabled",
            value_3: "Disabled",
            isSwitch_1: true,
            isSwitch_2: true,
            isSwitch_3: true,
          ),

          const SizedBox(height: 20),

          SettingsOptions(
            icon: Icons.security_outlined,
            title: "Security",
            subtitle: "Manage security and privacy settings",
            info_1: "Two-Factor Authentication",
            info_2: "Session Timeout",
            info_3: "IP Whitelist",
            value_1: "Enabled",
            value_2: "30 minutes",
            value_3: "Configured",
            isSwitch_1: true,
          ),

          const SizedBox(height: 20),

          SettingsOptions(
            icon: Icons.storage,
            title: "Data Management",
            subtitle: "Control data storage and backup settings",
            info_1: "Auto Backup",
            info_2: "Data Retention",
            info_3: "Export Format",
            value_1: "Daily at 2:00 AM",
            value_2: "90 days",
            value_3: "CSV, JSON",
          ),
          const SizedBox(height: 20),

          DangerZoneCard(),
        ],
      ),
    );
  }
}

class SettingsOptions extends StatelessWidget {
  final String title;
  final String subtitle;

  final String info_1;
  final String info_2;
  final String info_3;

  final String value_1;
  final String value_2;
  final String value_3;

  final bool isSwitch_1;
  final bool isSwitch_2;
  final bool isSwitch_3;

  final IconData icon;

  const SettingsOptions({
    super.key,
    required this.title,
    required this.subtitle,
    required this.info_1,
    required this.info_2,
    required this.info_3,
    required this.value_1,
    required this.value_2,
    required this.value_3,
    required this.icon,
    this.isSwitch_1 = false,
    this.isSwitch_2 = false,
    this.isSwitch_3 = false,
  });

  @override
  Widget build(BuildContext context) {
    double width = getScreenWidth(context);
    double height = getScreenHeight(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: width * 0.02),
              ),

              SizedBox(width: width * 0.01),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(text: title, size: width * 0.009),
                  customText(
                    text: subtitle,
                    size: width * 0.0075,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          SettingsRowItem(
            width: width,
            height: height,
            title: info_1,
            value: value_1,
            isSwitch: isSwitch_1,
          ),

          const SizedBox(height: 15),

          SettingsRowItem(
            width: width,
            height: height,
            title: info_2,
            value: value_2,
            isSwitch: isSwitch_2,
          ),

          const SizedBox(height: 15),

          SettingsRowItem(
            width: width,
            height: height,
            title: info_3,
            value: value_3,
            isSwitch: isSwitch_3,
          ),
        ],
      ),
    );
  }
}

class SettingsRowItem extends StatefulWidget {
  final double width;
  final double height;
  final String title;
  final String value;
  final bool isSwitch;

  const SettingsRowItem({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    required this.value,
    required this.isSwitch,
  });

  @override
  State<SettingsRowItem> createState() => _SettingsRowItemState();
}

class _SettingsRowItemState extends State<SettingsRowItem> {
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        customText(
          color: textColor,
          text: widget.title,
          size: widget.width * 0.0075,
        ),

        const Spacer(),

        customText(
          text: widget.value,
          size: widget.width * 0.0075,
          color: Colors.grey[600],
        ),

        const SizedBox(width: 10),

        widget.isSwitch
            ? Switch(
                value: switchValue,
                onChanged: (val) {
                  setState(() {
                    switchValue = val;
                  });
                },
                activeColor: const Color(0xFF8A2BE2),
              )
            : CustomGlowButton(
                borderRadius: 10,
                isGradient: true,
                title: "Edit",
                textColor: textColor,
                height: widget.height * 0.03,
                onPressed: () {},
                textSize: widget.width * 0.005,
                width: widget.width * 0.03,
              ),
      ],
    );
  }
}

class DangerZoneCard extends StatelessWidget {
  const DangerZoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mail_outline, color: Colors.pink),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: "Danger Zone",
                    size: width * 0.009,
                    bold: true,
                    color: Colors.red,
                    isEnglish: true,
                  ),

                  customText(
                    text: "Irreversible actions",
                    size: width * 0.007,
                    color: Colors.grey,
                    isEnglish: true,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          _dangerButton(
            text: "Reset All Settings",
            onTap: () {},
            context: context,
          ),

          const SizedBox(height: 10),
          _dangerButton(text: "Clear All Data", onTap: () {}, context: context),
        ],
      ),
    );
  }

  Widget _dangerButton({
    required String text,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: customText(
            text: text,
            size: getScreenWidth(context) * 0.0075,

            color: Colors.pink,
            bold: true,
            isEnglish: true,
          ),
        ),
      ),
    );
  }
}
