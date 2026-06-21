import 'package:bahya_website/bloc/cubit/settings_cubit.dart';
import 'package:bahya_website/bloc/states/settings_state.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/admin_widgets/settings/change_password.dart';
import 'package:bahya_website/helper/admin_widgets/settings/settings_widgets.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            SettingsRowData(
              Icons.lock_outline_rounded,
              "Password",
              "Change your account password",
              true,
              false,
              false,
              onEdit: () => showChangePasswordDialog(context),
            ),
          ],
        );
      },
    );
  }
}


class AuditLogsCard extends StatelessWidget {
  const AuditLogsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsCubit>().state;
    final totalPages = state.total == 0
        ? 1
        : (state.total / state.pageSize).ceil();

    return SettingsCard(
      icon: Icons.history_rounded,
      title: "Audit Logs",
      subtitle: "Latest system activity logs",
      rows: const [],
      customBody: Column(
        children: [
          if (state.logs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("No audit logs found"),
            )
          else
            ...state.logs.map(
              (log) =>
                  AuditLogItem(log: log, userNamesById: state.userNamesById),
            ),
          SizedBox(height: responsiveHeight(context, 0.016, min: 12, max: 18)),
          _AuditPagination(
            currentPage: state.page,
            totalPages: totalPages,
            onPrevious: state.page <= 1
                ? null
                : () => context.read<SettingsCubit>().loadData(
                    page: state.page - 1,
                  ),
            onNext: state.page >= totalPages
                ? null
                : () => context.read<SettingsCubit>().loadData(
                    page: state.page + 1,
                  ),
          ),
        ],
      ),
    );
  }
}

class _AuditPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _AuditPagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.012, min: 12, max: 18),
        vertical: responsiveHeight(context, 0.01, min: 8, max: 12),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7FC),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFD6EA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PageButton(
            icon: Icons.arrow_back_ios_new_rounded,
            enabled: onPrevious != null,
            onTap: onPrevious,
          ),
          SizedBox(width: responsiveSize(context, 0.01, min: 10, max: 14)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
              vertical: responsiveHeight(context, 0.007, min: 6, max: 8),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(24),
            ),
            child: customText(
              text: "$currentPage",
              size: responsiveSize(context, 0.0085, min: 12, max: 15),
              color: Colors.white,
              bold: true,
              isEnglish: true,
            ),
          ),
          SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 12)),
          customText(
            text: "of $totalPages",
            size: responsiveSize(context, 0.008, min: 12, max: 14),
            color: Colors.grey,
            bold: true,
            isEnglish: true,
          ),
          SizedBox(width: responsiveSize(context, 0.01, min: 10, max: 14)),
          _PageButton(
            icon: Icons.arrow_forward_ios_rounded,
            enabled: onNext != null,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: responsiveSize(context, 0.028, min: 34, max: 42),
        height: responsiveSize(context, 0.028, min: 34, max: 42),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? const Color(0xFFFF9BD0) : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: responsiveSize(context, 0.008, min: 12, max: 15),
          color: enabled ? SettingsColors.pink : Colors.grey.shade400,
        ),
      ),
    );
  }
}

class AuditLogItem extends StatelessWidget {
  final Map<String, dynamic> log;
 final Map<String, String> userNamesById;

  const AuditLogItem({
    super.key,
    required this.log,
    required this.userNamesById,
  });

  String _formatAction(dynamic value) {
    return value?.toString().replaceAll('_', ' ') ?? "-";
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? "")?.toLocal();
    if (date == null) return "-";

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _formatTime(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? "")?.toLocal();
    if (date == null) return "-";

    final hour12 = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? "PM" : "AM";

    return "$hour12:$minute $period";
  }

 String _actorName() {
    final actorId = log["actorId"]?.toString();

    if (actorId == null || actorId.trim().isEmpty) {
      return "System";
    }

    return userNamesById[actorId] ?? actorId;
  }

  @override
  Widget build(BuildContext context) {
    final action = _formatAction(log["action"]);
    final entity = log["entityType"]?.toString().replaceAll('_', ' ') ?? "-";
    final actor = _actorName();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(responsiveSize(context, 0.01, min: 12, max: 16)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD6EA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SoftSettingsIcon(icon: Icons.receipt_long_rounded),
          SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: action,
                  size: responsiveSize(context, 0.0088, min: 13, max: 16),
                  bold: true,
                  color: SettingsColors.darkText,
                  isEnglish: true,
                  isCenter: false,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.008, min: 6, max: 8),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.person_outline_rounded,
                      title: "User",
                      text: actor,
                    ),
                    _InfoChip(
                      icon: Icons.category_outlined,
                      title: "Entity",
                      text: entity,
                    ),
                    _InfoChip(
                      icon: Icons.calendar_month_outlined,
                      title: "Date",
                      text: _formatDate(log["createdAt"]),
                    ),
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      title: "Time",
                      text: _formatTime(log["createdAt"]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.008, min: 9, max: 12),
        vertical: responsiveHeight(context, 0.006, min: 5, max: 7),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD6EA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: responsiveSize(context, 0.008, min: 13, max: 15),
            color: SettingsColors.pink,
          ),
          const SizedBox(width: 5),
          customText(
            text: "$title:",
            size: responsiveSize(context, 0.0078, min: 11, max: 13),
            color: SettingsColors.darkText,
            bold: true,
            isEnglish: true,
            isCenter: false,
          ),
          customText(
            text: text,
            size: responsiveSize(context, 0.0078, min: 11, max: 13),
            color: Colors.grey,
            isEnglish: true,
            isCenter: false,
          ),
        ],
      ),
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
  final VoidCallback? onEdit;

  const SettingsRowData(
    this.icon,
    this.title,
    this.value,
    this.hasEdit,
    this.isSwitch,
    this.switchInitialValue, {
    this.onEdit,
  });
}
