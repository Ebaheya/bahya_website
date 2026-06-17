import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/admin_widgets/settings/settings_widgets.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
part 'settings_card_components.dart';

class SettingsDesktopGrid extends StatelessWidget {
  const SettingsDesktopGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return GridView.count(
      crossAxisCount: w < 1050 ? 1 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: responsiveSize(context, 0.018, min: 16, max: 24),
      mainAxisSpacing: responsiveHeight(context, 0.024, min: 16, max: 24),
      childAspectRatio: w < 650
          ? 1.05
          : w < 1050
          ? 2.15
          : 1.72,
      children: const [
        AccountSettingsCard(),
        NotificationSettingsCard(),
        SecuritySettingsCard(),
        DataManagementSettingsCard(),
      ],
    );
  }
}

class SettingsMobileCards extends StatelessWidget {
  const SettingsMobileCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AccountSettingsCard(),
        SizedBox(height: responsiveHeight(context, 0.018, min: 14, max: 18)),
        const NotificationSettingsCard(),
        SizedBox(height: responsiveHeight(context, 0.018, min: 14, max: 18)),
        const SecuritySettingsCard(),
        SizedBox(height: responsiveHeight(context, 0.018, min: 14, max: 18)),
        const DataManagementSettingsCard(),
      ],
    );
  }
}

class AccountSettingsCard extends StatefulWidget {
  const AccountSettingsCard({super.key});

  @override
  State<AccountSettingsCard> createState() => _AccountSettingsCardState();
}

class _AccountSettingsCardState extends State<AccountSettingsCard> {
  final WebService web = WebService();

  Future<Map<String, dynamic>> _loadCurrentUser() async {
    final res = await web.getUserInfo();

    if (res["user"] is Map) {
      return Map<String, dynamic>.from(res["user"]);
    }

    return Map<String, dynamic>.from(res);
  }

  String _roleName(String? role) {
    switch (role) {
      case "ADMIN":
        return "System Administrator";
      case "DOCTOR":
        return "Doctor";
      case "VOLUNTEER":
        return "Volunteer";
      case "CALL_CENTER":
        return "Call Center";
      case "PATIENT":
        return "Patient";
      default:
        return role ?? "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SettingsCard(
            icon: Icons.person_outline_rounded,
            title: "Account Settings",
            subtitle: "Loading account information...",
            rows: const [],
            customBody: SizedBox(
              height: responsiveHeight(context, 0.16, min: 120, max: 160),
              child: Center(child: customLoading()),
            ),
          );
        }

        if (snapshot.hasError) {
          return const SettingsCard(
            icon: Icons.person_outline_rounded,
            title: "Account Settings",
            subtitle: "Failed to load account information",
            rows: [
              SettingsRowData(
                Icons.error_outline_rounded,
                "Error",
                "Could not load user data",
                false,
                false,
                false,
              ),
            ],
          );
        }

        final user = snapshot.data ?? {};

        final fullName = user["fullName"]?.toString() ?? "-";
        final email = user["email"]?.toString() ?? "-";
        final role = user["role"]?.toString();

        return SettingsCard(
          icon: Icons.person_outline_rounded,
          title: "Account Settings",
          subtitle: "Manage your account information and preferences",
          rows: [
            SettingsRowData(
              Icons.person_outline_rounded,
              "Profile Name",
              fullName,
              true,
              false,
              false,
            ),
            SettingsRowData(
              Icons.email_outlined,
              "Email",
              email,
              true,
              false,
              false,
            ),
            SettingsRowData(
              Icons.shield_outlined,
              "Role",
              _roleName(role),
              true,
              false,
              false,
            ),
          ],
        );
      },
    );
  }
}

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsCard(
      icon: Icons.notifications_none_rounded,
      title: "Notifications",
      subtitle: "Configure notification preferences",
      rows: [
        SettingsRowData(
          Icons.notifications_none_rounded,
          "Push Notifications",
          "Enabled",
          false,
          true,
          true,
        ),
        SettingsRowData(
          Icons.email_outlined,
          "Email Notifications",
          "Enabled",
          false,
          true,
          true,
        ),
        SettingsRowData(
          Icons.sms_outlined,
          "SMS Notifications",
          "Disabled",
          false,
          true,
          false,
        ),
      ],
    );
  }
}

class SecuritySettingsCard extends StatelessWidget {
  const SecuritySettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsCard(
      icon: Icons.security_rounded,
      title: "Security",
      subtitle: "Manage security and privacy settings",
      rows: [
        SettingsRowData(
          Icons.lock_outline_rounded,
          "Two-Factor Authentication",
          "Enabled",
          false,
          true,
          true,
        ),
        SettingsRowData(
          Icons.access_time_rounded,
          "Session Timeout",
          "30 minutes",
          true,
          false,
          false,
        ),
        SettingsRowData(
          Icons.language_rounded,
          "IP Whitelist",
          "Configured",
          true,
          false,
          false,
        ),
      ],
    );
  }
}

class DataManagementSettingsCard extends StatelessWidget {
  const DataManagementSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsCard(
      icon: Icons.storage_rounded,
      title: "Data Management",
      subtitle: "Control data storage and backup settings",
      rows: [
        SettingsRowData(
          Icons.cloud_upload_outlined,
          "Auto Backup",
          "Daily at 2:00 AM",
          true,
          false,
          false,
        ),
        SettingsRowData(
          Icons.inventory_2_outlined,
          "Data Retention",
          "90 days",
          true,
          false,
          false,
        ),
        SettingsRowData(
          Icons.download_outlined,
          "Export Format",
          "CSV, JSON",
          true,
          false,
          false,
        ),
      ],
    );
  }
}

class SettingsRowData {
  final IconData icon;
  final String title;
  final String value;
  final bool hasEdit;
  final bool isSwitch;
  final bool switchInitialValue;

  const SettingsRowData(
    this.icon,
    this.title,
    this.value,
    this.hasEdit,
    this.isSwitch,
    this.switchInitialValue,
  );
}
