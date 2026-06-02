import 'package:bahya_website/helper/admin_widgets/settings/settings_cards.dart';
import 'package:bahya_website/helper/admin_widgets/settings/settings_widgets.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);
    final isSmall = width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          responsiveSize(context, 0.015, min: 14, max: 26),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            responsiveSize(context, 0.018, min: 16, max: 28),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFD6EA)),
          ),
          child: Column(
            children: [
              const SettingsHeader(),
              SizedBox(
                height: responsiveHeight(context, 0.03, min: 20, max: 28),
              ),
              isSmall
                  ? const SettingsMobileCards()
                  : const SettingsDesktopGrid(),
              SizedBox(
                height: responsiveHeight(context, 0.026, min: 18, max: 24),
              ),
              const DangerZoneCard(),
            ],
          ),
        ),
      ),
    );
  }
}
