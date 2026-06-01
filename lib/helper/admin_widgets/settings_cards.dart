import 'package:bahya_website/helper/admin_widgets/settings_widgets.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

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

class AccountSettingsCard extends StatelessWidget {
  const AccountSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsCard(
      icon: Icons.person_outline_rounded,
      title: "Account Settings",
      subtitle: "Manage your account information and preferences",
      rows: [
        SettingsRowData(
          Icons.person_outline_rounded,
          "Profile Name",
          "Bahya Admin",
          true,
          false,
          false,
        ),
        SettingsRowData(
          Icons.email_outlined,
          "Email",
          "admin@platform.com",
          true,
          false,
          false,
        ),
        SettingsRowData(
          Icons.shield_outlined,
          "Role",
          "System Administrator",
          true,
          false,
          false,
        ),
      ],
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

class SettingsCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<SettingsRowData> rows;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rows,
  });

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final isSmall = getScreenWidth(context) < 900;

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover ? 1.015 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.all(
            responsiveSize(context, 0.014, min: 16, max: 22),
          ),
          decoration: BoxDecoration(
            color: hover ? const Color(0xFFFFF8FC) : Colors.white,
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.016, min: 18, max: 22),
            ),
            border: Border.all(
              color: hover ? const Color(0xFFFFBBDC) : const Color(0xFFFFD6EA),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(hover ? .075 : .045),
                blurRadius: hover ? 24 : 18,
                offset: Offset(0, hover ? 12 : 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: isSmall ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Row(
                children: [
                  GradientSettingsIcon(icon: widget.icon, hover: hover),
                  SizedBox(
                    width: responsiveSize(context, 0.012, min: 12, max: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                          text: widget.title,
                          size: responsiveSize(
                            context,
                            0.011,
                            min: 16,
                            max: 19,
                          ),
                          bold: true,
                          color: SettingsColors.darkText,
                          isEnglish: true,
                          isCenter: false,
                          maxLines: 1,
                        ),
                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.006,
                            min: 4,
                            max: 6,
                          ),
                        ),
                        customText(
                          text: widget.subtitle,
                          size: responsiveSize(
                            context,
                            0.008,
                            min: 12,
                            max: 14,
                          ),
                          color: Colors.grey.shade600,
                          isEnglish: true,
                          isCenter: false,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: responsiveHeight(context, 0.018, min: 14, max: 18),
              ),
              Divider(color: Colors.grey.shade200),
              if (isSmall)
                Column(
                  children: widget.rows
                      .map((row) => SettingsRowItem(data: row))
                      .toList(),
                )
              else
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: widget.rows
                        .map((row) => SettingsRowItem(data: row))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsRowItem extends StatefulWidget {
  final SettingsRowData data;

  const SettingsRowItem({super.key, required this.data});

  @override
  State<SettingsRowItem> createState() => _SettingsRowItemState();
}

class _SettingsRowItemState extends State<SettingsRowItem> {
  late bool switchValue;

  @override
  void initState() {
    super.initState();
    switchValue = widget.data.switchInitialValue;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: responsiveHeight(context, 0.008, min: 7, max: 10),
      ),
      child: Row(
        children: [
          SoftSettingsIcon(icon: widget.data.icon),
          SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: widget.data.title,
                  size: responsiveSize(context, 0.0085, min: 12, max: 15),
                  bold: true,
                  color: SettingsColors.darkText,
                  isEnglish: true,
                  isCenter: false,
                  maxLines: 1,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.006, min: 4, max: 6),
                ),
                customText(
                  text: widget.data.value,
                  size: responsiveSize(context, 0.008, min: 12, max: 14),
                  color: Colors.grey.shade600,
                  isEnglish: true,
                  isCenter: false,
                  maxLines: isMobile ? 2 : 1,
                ),
              ],
            ),
          ),
          if (widget.data.isSwitch)
            Switch(
              value: switchValue,
              onChanged: (value) => setState(() => switchValue = value),
              activeColor: Colors.white,
              activeTrackColor: SettingsColors.purple,
            )
          else if (widget.data.hasEdit)
            EditSettingsButton(onTap: () {}),
        ],
      ),
    );
  }
}

class DangerZoneCard extends StatefulWidget {
  const DangerZoneCard({super.key});

  @override
  State<DangerZoneCard> createState() => _DangerZoneCardState();
}

class _DangerZoneCardState extends State<DangerZoneCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: EdgeInsets.all(
          responsiveSize(context, 0.014, min: 16, max: 22),
        ),
        decoration: BoxDecoration(
          color: hover ? const Color(0xFFFFFAFC) : Colors.white,
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.016, min: 18, max: 22),
          ),
          border: Border.all(
            color: hover ? const Color(0xFFFFB8CC) : const Color(0xFFFFD6EA),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(hover ? 0.09 : 0.04),
              blurRadius: hover ? 22 : 14,
              offset: Offset(0, hover ? 10 : 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                SoftSettingsIcon(
                  icon: Icons.warning_amber_rounded,
                  danger: true,
                  size: responsiveSize(context, 0.04, min: 44, max: 52),
                ),
                SizedBox(
                  width: responsiveSize(context, 0.012, min: 12, max: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customText(
                        text: "Danger Zone",
                        size: responsiveSize(context, 0.011, min: 16, max: 20),
                        bold: true,
                        color: SettingsColors.danger,
                        isEnglish: true,
                        isCenter: false,
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.006,
                          min: 4,
                          max: 6,
                        ),
                      ),
                      customText(
                        text: "Irreversible actions",
                        size: responsiveSize(context, 0.008, min: 12, max: 14),
                        color: Colors.grey.shade500,
                        isEnglish: true,
                        isCenter: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 18)),
            DangerAction(
              icon: Icons.restore_rounded,
              title: "Reset All Settings",
              subtitle: "Restore all settings to their default values",
              buttonText: "Reset",
              onTap: () {},
            ),
            SizedBox(
              height: responsiveHeight(context, 0.014, min: 10, max: 12),
            ),
            DangerAction(
              icon: Icons.delete_outline_rounded,
              title: "Clear All Data",
              subtitle: "Permanently delete all data from the system",
              buttonText: "Clear Data",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class DangerAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;

  const DangerAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = getScreenWidth(context) < 650;

    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.01, min: 12, max: 14)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F6),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 14, max: 16),
        ),
        border: Border.all(color: const Color(0xFFFFCADB)),
      ),
      child: isSmall
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dangerInfo(context),
                SizedBox(
                  height: responsiveHeight(context, 0.014, min: 10, max: 14),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _dangerButton(context),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: _dangerInfo(context)),
                _dangerButton(context),
              ],
            ),
    );
  }

  Widget _dangerInfo(BuildContext context) {
    return Row(
      children: [
        SoftSettingsIcon(icon: icon, danger: true),
        SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                text: title,
                size: responsiveSize(context, 0.0085, min: 12, max: 15),
                bold: true,
                color: SettingsColors.darkText,
                isEnglish: true,
                isCenter: false,
                maxLines: 1,
              ),
              SizedBox(
                height: responsiveHeight(context, 0.006, min: 4, max: 6),
              ),
              customText(
                text: subtitle,
                size: responsiveSize(context, 0.0075, min: 12, max: 13),
                color: Colors.grey.shade600,
                isEnglish: true,
                isCenter: false,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dangerButton(BuildContext context) {
    return CustomGlowButton(
      onPressed: onTap,
      borderRadius: 12,
      title: buttonText,
      glowColor: Colors.white,
      textSize: responsiveSize(context, 0.008, min: 12, max: 14),
      backgroundColor: SettingsColors.danger,
      width: responsiveSize(context, 0.1, min: 100, max: 140),
      height: responsiveHeight(context, 0.04, min: 34, max: 40),
      textColor: Colors.white,
    );
  }
}
