import 'package:bahya_website/bloc/cubit/user_cubit.dart';
import 'package:bahya_website/bloc/states/user_state.dart';
import 'package:bahya_website/data/api/models/user_model.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_dropDown.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/filter_dropdown.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersTable extends StatefulWidget {
  const UsersTable({super.key});

  @override
  State<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  final TextEditingController searchController = TextEditingController();

  String? selectedRole;
  bool? selectedStatus;

  int selectedPage = 1;
  final int usersPerPage = 5;

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().getAllUserInfo();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void applyFilters() {
    setState(() => selectedPage = 1);

    final cubit = context.read<UserCubit>();

    final hasFilters =
        searchController.text.trim().isNotEmpty ||
        selectedRole != null ||
        selectedStatus != null;

    if (hasFilters) {
      cubit.getFilteredUserInfo(
        nameOrEmail: searchController.text.trim(),
        role: selectedRole != null
            ? UserRole.values.firstWhere((e) => e.name == selectedRole)
            : null,
        isActive: selectedStatus,
      );
    } else {
      cubit.getAllUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 750;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.018, min: 14, max: 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 18, max: 24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: responsiveSize(context, 0.02, min: 18, max: 26),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          isMobile ? _mobileFilters(context) : _desktopFilters(context),
          SizedBox(height: responsiveHeight(context, 0.035, min: 22, max: 34)),
          _usersBlocContent(context, isMobile),
        ],
      ),
    );
  }

  Widget _desktopFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: modernInputBox(
            icon: Icons.search,
            child: CustomFormTextField(
              hintText: localizedText(context, 'Search by name or email'),
              isSearch: true,
              isRequired: false,
              bordered: false,
              textDirection: TextDirection.ltr,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: CustomTextFieldType.text,
              controller: searchController,
              onChange: (_) => applyFilters(),
            ),
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.015, min: 14, max: 22)),
        Expanded(child: _roleDropdown(context)),
        SizedBox(width: responsiveSize(context, 0.015, min: 14, max: 22)),
        Expanded(child: _statusDropdown(context)),
      ],
    );
  }

  Widget _mobileFilters(BuildContext context) {
    return Column(
      children: [
        modernInputBox(
          icon: Icons.search,
          child: CustomFormTextField(
            hintText: localizedText(context, 'Search by name or email'),
            isSearch: true,
            isRequired: false,
            bordered: false,
            textDirection: TextDirection.ltr,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: CustomTextFieldType.text,
            controller: searchController,
            onChange: (_) => applyFilters(),
          ),
        ),
        SizedBox(height: responsiveHeight(context, 0.016, min: 12, max: 16)),
        SizedBox(
          height: responsiveHeight(context, 0.06, min: 46, max: 56),
          child: _roleDropdown(context),
        ),
        SizedBox(height: responsiveHeight(context, 0.016, min: 12, max: 16)),
        SizedBox(
          height: responsiveHeight(context, 0.06, min: 46, max: 56),
          child: _statusDropdown(context),
        ),
      ],
    );
  }

  Widget _roleDropdown(BuildContext context) {
    return FilterDropdown(
      hint: selectedRole ?? "All Roles",
      items: const [
        "All",
        "ADMIN",
        "DOCTOR",
        "VOLUNTEER",
        "PATIENT",
        "CALL_CENTER",
      ],
      onChanged: (v) {
        setState(() => selectedRole = v == "All" ? null : v);
        applyFilters();
      },
    );
  }

  Widget _statusDropdown(BuildContext context) {
    return FilterDropdown(
      hint: selectedStatus == null
          ? "All Status"
          : selectedStatus == true
          ? "Active"
          : "Inactive",
      items: const ["All", "Active", "Inactive"],
      onChanged: (v) {
        setState(() {
          if (v == "All") {
            selectedStatus = null;
          } else if (v == "Active") {
            selectedStatus = true;
          } else {
            selectedStatus = false;
          }
        });
        applyFilters();
      },
    );
  }

  Widget _usersBlocContent(BuildContext context, bool isMobile) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return SizedBox(
            height: responsiveHeight(context, 0.45, min: 280, max: 460),
            child: Center(child: customLoading()),
          );
        }

        if (state is UserError) {
          return SizedBox(
            height: responsiveHeight(context, 0.35, min: 220, max: 360),
            child: Center(
              child: customText(
                text: state.message,
                size: responsiveSize(context, 0.012, min: 14, max: 18),
                color: Colors.red,
                isEnglish: true,
              ),
            ),
          );
        }

        if (state is UserLoaded || state is UserFilteredLoaded) {
          final users = state is UserLoaded
              ? state.users
              : (state as UserFilteredLoaded).users;

          final totalUsers = users.length;
          final totalPages = totalUsers == 0
              ? 1
              : (totalUsers / usersPerPage).ceil();

          if (selectedPage > totalPages) selectedPage = totalPages;

          final startIndex = totalUsers == 0
              ? 0
              : (selectedPage - 1) * usersPerPage;

          final endIndex = totalUsers == 0
              ? 0
              : (startIndex + usersPerPage > totalUsers
                    ? totalUsers
                    : startIndex + usersPerPage);

          final pageUsers = totalUsers == 0
              ? <UserModel>[]
              : users.sublist(startIndex, endIndex);

          return Column(
            children: [
              isMobile
                  ? _mobileUsersList(context, pageUsers)
                  : _desktopUsersTable(context, pageUsers),
              SizedBox(
                height: responsiveHeight(context, 0.02, min: 14, max: 20),
              ),
              isMobile
                  ? _mobilePagination(
                      context,
                      totalUsers,
                      startIndex,
                      endIndex,
                      totalPages,
                    )
                  : _desktopPagination(
                      context,
                      totalUsers,
                      startIndex,
                      endIndex,
                      totalPages,
                    ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _desktopUsersTable(BuildContext context, List<UserModel> pageUsers) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFF),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 18, max: 22),
        ),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          tableHeader(context),
          Divider(height: 1, color: Colors.grey.withOpacity(0.12)),
          ...pageUsers.map((user) {
            return userRow(context: context, user: user);
          }),
        ],
      ),
    );
  }

  Widget _mobileUsersList(BuildContext context, List<UserModel> pageUsers) {
    if (pageUsers.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: responsiveHeight(context, 0.08, min: 50, max: 80),
        ),
        child: customText(
          text: "No users found",
          size: responsiveSize(context, 0.012, min: 15, max: 18),
          color: Colors.grey,
          isEnglish: true,
        ),
      );
    }

    return Column(
      children: pageUsers.map((user) {
        return _UserMobileCard(user: user, onRefresh: applyFilters);
      }).toList(),
    );
  }

  Widget tableHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.02, min: 18, max: 26),
        vertical: responsiveHeight(context, 0.018, min: 14, max: 18),
      ),
      child: Row(
        children: [
          tableTitle(context, "Name", flex: 3),
          tableTitle(context, "Email", flex: 4),
          tableTitle(context, "Role", flex: 2),
          tableTitle(context, "Status", flex: 2),
          tableTitle(context, "Actions", flex: 1),
        ],
      ),
    );
  }

  Widget tableTitle(BuildContext context, String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          customText(
            text: text,
            size: responsiveSize(context, 0.009, min: 13, max: 16),
            bold: true,
            isEnglish: true,
            color: const Color(0xFF4B4D8F),
          ),
          SizedBox(width: responsiveSize(context, 0.005, min: 5, max: 8)),
          Icon(
            Icons.unfold_more_rounded,
            color: Colors.indigo.withOpacity(0.35),
            size: responsiveSize(context, 0.011, min: 15, max: 20),
          ),
        ],
      ),
    );
  }

  Widget userRow({required BuildContext context, required UserModel user}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.02, min: 18, max: 26),
        vertical: responsiveHeight(context, 0.016, min: 12, max: 16),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.10)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                userAvatar(context, user.name),
                SizedBox(
                  width: responsiveSize(context, 0.015, min: 12, max: 18),
                ),
                Expanded(
                  child: customText(
                    text: user.name,
                    size: responsiveSize(context, 0.009, min: 13, max: 16),
                    color: const Color(0xFF272044),
                    bold: true,
                    isEnglish: true,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: customText(
              text: user.email,
              size: responsiveSize(context, 0.009, min: 13, max: 16),
              color: const Color(0xFF272044),
              isEnglish: true,
              maxLines: 1,
            ),
          ),
          Expanded(flex: 2, child: roleBadge(context, user.role)),
          Expanded(flex: 2, child: statusBadge(context, user.isActive)),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _MoreButton(user: user, onRefresh: applyFilters),
            ),
          ),
        ],
      ),
    );
  }

  Widget userAvatar(BuildContext context, String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

    final colors = [
      const Color(0xFFEED7FF),
      const Color(0xFFDDF0FF),
      const Color(0xFFFFD9F7),
      const Color(0xFFFFEACC),
      const Color(0xFFD8F7E3),
    ];

    final color = colors[name.length % colors.length];

    return CircleAvatar(
      radius: responsiveSize(context, 0.014, min: 18, max: 22),
      backgroundColor: color,
      child: customText(
        text: initial,
        size: responsiveSize(context, 0.008, min: 12, max: 14),
        color: const Color(0xFF272044),
        bold: true,
        isEnglish: true,
      ),
    );
  }

  Widget roleBadge(BuildContext context, String role) {
    Color color = Colors.grey;
    IconData icon = Icons.shield_outlined;

    if (role == "DOCTOR") {
      color = Colors.deepPurple;
      icon = Icons.medical_services_outlined;
    } else if (role == "CALL_CENTER") {
      color = Colors.orange;
      icon = Icons.headset_mic_outlined;
    } else if (role == "VOLUNTEER") {
      color = Colors.blue;
      icon = Icons.volunteer_activism_outlined;
    } else if (role == "PATIENT") {
      color = Colors.pink;
      icon = Icons.person_outline_rounded;
    } else if (role == "ADMIN") {
      color = Colors.blueGrey;
      icon = Icons.security_rounded;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.01, min: 10, max: 12),
          vertical: responsiveHeight(context, 0.008, min: 6, max: 7),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: responsiveSize(context, 0.01, min: 14, max: 18),
            ),
            SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 9)),
            Flexible(
              child: customText(
                text: role,
                size: responsiveSize(context, 0.008, min: 11, max: 14),
                color: color,
                bold: true,
                isEnglish: true,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statusBadge(BuildContext context, bool isActive) {
    final color = isActive ? Colors.green : Colors.red;
    final text = isActive ? "Active" : "Inactive";

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.01, min: 10, max: 12),
          vertical: responsiveHeight(context, 0.008, min: 6, max: 7),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: responsiveSize(context, 0.005, min: 6, max: 7),
              height: responsiveSize(context, 0.005, min: 6, max: 7),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 9)),
            customText(
              text: text,
              size: responsiveSize(context, 0.008, min: 11, max: 14),
              color: color,
              bold: true,
              isEnglish: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktopPagination(
    BuildContext context,
    int totalUsers,
    int startIndex,
    int endIndex,
    int totalPages,
  ) {
    return Row(
      children: [
        customText(
          text: 'showing_users',
          namedArgs: {
            'from': '${totalUsers == 0 ? 0 : startIndex + 1}',
            'to': '$endIndex',
            'total': '$totalUsers',
          },
          size: responsiveSize(context, 0.009, min: 12, max: 15),
          color: Colors.indigo.withOpacity(0.65),
          isEnglish: false,
        ),
        const Spacer(),
        _paginationButtons(context, totalPages),
      ],
    );
  }

  Widget _mobilePagination(
    BuildContext context,
    int totalUsers,
    int startIndex,
    int endIndex,
    int totalPages,
  ) {
    return Column(
      children: [
        customText(
          text: 'showing_users',
          namedArgs: {
            'from': '${totalUsers == 0 ? 0 : startIndex + 1}',
            'to': '$endIndex',
            'total': '$totalUsers',
          },
          size: responsiveSize(context, 0.009, min: 12, max: 15),
          color: Colors.indigo.withOpacity(0.65),
          isEnglish: false,
        ),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _paginationButtons(context, totalPages),
        ),
      ],
    );
  }

  Widget _paginationButtons(BuildContext context, int totalPages) {
    return Row(
      children: [
        pageButton(
          context: context,
          icon: Icons.arrow_back_ios_new_rounded,
          selected: false,
          onTap: selectedPage > 1
              ? () => setState(() => selectedPage--)
              : () {},
        ),
        ...List.generate(totalPages, (index) {
          final pageNumber = index + 1;

          return pageButton(
            context: context,
            text: pageNumber.toString(),
            selected: selectedPage == pageNumber,
            onTap: () => setState(() => selectedPage = pageNumber),
          );
        }),
        pageButton(
          context: context,
          icon: Icons.arrow_forward_ios_rounded,
          selected: false,
          onTap: selectedPage < totalPages
              ? () => setState(() => selectedPage++)
              : () {},
        ),
      ],
    );
  }

  Widget pageButton({
    required BuildContext context,
    String? text,
    IconData? icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final size = responsiveSize(context, 0.028, min: 34, max: 40);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.004, min: 3, max: 5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFEFF8) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? buttonColor.withOpacity(0.35)
                  : Colors.grey.withOpacity(0.16),
            ),
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: responsiveSize(context, 0.009, min: 12, max: 15),
                    color: Colors.indigo.withOpacity(0.7),
                  )
                : customText(
                    text: text!,
                    size: responsiveSize(context, 0.009, min: 12, max: 15),
                    color: selected ? buttonColor : const Color(0xFF272044),
                    bold: selected,
                    isEnglish: true,
                  ),
          ),
        ),
      ),
    );
  }
}

class _UserMobileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRefresh;

  const _UserMobileCard({required this.user, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorStateOfType<_UsersTableState>()!;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.014, min: 12, max: 16),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 14, max: 18)),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFF),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 18, max: 22),
        ),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              parent.userAvatar(context, user.name),
              SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
              Expanded(
                child: customText(
                  text: user.name,
                  size: responsiveSize(context, 0.011, min: 15, max: 18),
                  color: const Color(0xFF272044),
                  bold: true,
                  isEnglish: true,
                  isCenter: false,
                  maxLines: 1,
                ),
              ),
              _MoreButton(user: user, onRefresh: onRefresh),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
          customText(
            text: user.email,
            size: responsiveSize(context, 0.009, min: 12, max: 14),
            color: Colors.grey[700],
            isEnglish: true,
            isCenter: false,
            maxLines: 1,
          ),
          SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
          Wrap(
            spacing: responsiveSize(context, 0.01, min: 8, max: 12),
            runSpacing: responsiveHeight(context, 0.01, min: 8, max: 10),
            children: [
              parent.roleBadge(context, user.role),
              parent.statusBadge(context, user.isActive),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRefresh;

  const _MoreButton({required this.user, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final size = responsiveSize(context, 0.028, min: 36, max: 40);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showActionsDialog(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: const Color(0xFF4B4D8F),
          size: responsiveSize(context, 0.016, min: 19, max: 24),
        ),
      ),
    );
  }

  Future<void> _showActionsDialog(BuildContext context) async {
    final userCubit = context.read<UserCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return _ActionDialogCard(
          user: user,
          onEdit: () async {
            Navigator.pop(dialogContext);
            await Future.delayed(const Duration(milliseconds: 100));

            if (!dialogContext.mounted || !context.mounted) return;

            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _EditUserDialog(
                user: user,
                userCubit: userCubit,
                onRefresh: onRefresh,
              ),
            );
          },
          onStatus: () async {
            Navigator.pop(dialogContext);
            await Future.delayed(const Duration(milliseconds: 100));

            if (!context.mounted) return;

            await _confirmStatusChange(context, userCubit);
          },
          onReset: () async {
            Navigator.pop(dialogContext);
            await Future.delayed(const Duration(milliseconds: 100));

            if (!context.mounted) return;

            await _confirmResetPassword(context, userCubit);
          },
        );
      },
    );
  }

  Future<void> _confirmStatusChange(
    BuildContext context,
    UserCubit userCubit,
  ) async {
    final newStatus = !user.isActive;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _ConfirmDialogCard(
          icon: newStatus
              ? Icons.person_add_alt_1_rounded
              : Icons.person_off_rounded,
          title: newStatus ? "Activate User" : "Deactivate User",
          message: newStatus
              ? "Do you want to activate ${user.name}?"
              : "Do you want to deactivate ${user.name}?",
          actionText: newStatus ? "Activate" : "Deactivate",
          actionColor: newStatus ? Colors.green : Colors.red,
          onConfirm: () async {
            await userCubit.changeStatus(userId: user.id, isActive: newStatus);

            if (!context.mounted) return;

            onRefresh();

            customDialog(
              context: dialogContext,
              title: "Success",
              message: newStatus
                  ? "User activated successfully."
                  : "User deactivated successfully.",
              isSuccess: true,
              onClose: () {
                Navigator.pop(dialogContext);
                Navigator.pop(dialogContext);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _confirmResetPassword(
    BuildContext context,
    UserCubit userCubit,
  ) async {
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return _BaseDialogCard(
              width: 430,
              icon: Icons.lock_reset_rounded,
              iconColor: Colors.deepPurple,
              title: "Send Reset Link",
              subtitle: "Send password reset link to ${user.email}?",
              child: Row(
                children: [
                  Expanded(
                    child: _DialogSecondaryButton(
                      text: "Cancel",
                      onTap: isLoading
                          ? null
                          : () => Navigator.pop(dialogContext),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogPrimaryButton(
                      text: "Send",
                      color: Colors.deepPurple,
                      isLoading: isLoading,
                      onTap: isLoading
                          ? null
                          : () async {
                              setDialogState(() => isLoading = true);

                              try {
                                await userCubit.sendResetLink(userId: user.id);

                                if (!dialogContext.mounted) return;
                                Navigator.pop(dialogContext);

                                if (!context.mounted) return;
                                customDialog(
                                  context: context,
                                  title: "Done",
                                  message:
                                      "Password reset link sent successfully.",
                                  isSuccess: true,
                                );
                              } catch (e) {
                                if (dialogContext.mounted) {
                                  setDialogState(() => isLoading = false);
                                }

                                if (!context.mounted) return;
                                customDialog(
                                  context: context,
                                  title: "Error",
                                  message: e.toString(),
                                  isError: true,
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EditUserDialog extends StatefulWidget {
  final UserModel user;
  final UserCubit userCubit;
  final VoidCallback onRefresh;

  const _EditUserDialog({
    required this.user,
    required this.userCubit,
    required this.onRefresh,
  });

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController roleController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    roleController = TextEditingController(text: widget.user.role);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    roleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => isSaving = true);

    try {
      await widget.userCubit.updateUserName(
        userId: widget.user.id,
        fullName: nameController.text.trim(),
      );

      if (!mounted) return;

      widget.onRefresh();

      customDialog(
        context: context,
        title: "Success",
        message: "User updated successfully.",
        isSuccess: true,
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      customDialog(
        context: context,
        title: "Error",
        message: e.toString(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BaseDialogCard(
      width: 540,
      icon: Icons.edit_rounded,
      title: "Edit User",
      subtitle: "Only full name can be edited.",
      child: Form(
        key: formKey,
        child: Column(
          children: [
            CustomFormTextField(
              controller: nameController,
              labelText: "Full Name",
              hintText: "Enter full name",
              keyboardType: CustomTextFieldType.name,
              textDirection: TextDirection.ltr,
              isRequired: true,
              bordered: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 14),
            CustomFormTextField(
              controller: emailController,
              labelText: "Email",
              hintText: "Email",
              keyboardType: CustomTextFieldType.email,
              textDirection: TextDirection.ltr,
              readOnly: true,
              isRequired: false,
              bordered: true,
              autovalidateMode: AutovalidateMode.disabled,
            ),
            const SizedBox(height: 14),
            CustomFormTextField(
              controller: roleController,
              labelText: "Role",
              hintText: "Role",
              keyboardType: CustomTextFieldType.text,
              textDirection: TextDirection.ltr,
              readOnly: true,
              isRequired: false,
              bordered: true,
              autovalidateMode: AutovalidateMode.disabled,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogSecondaryButton(
                    text: "Cancel",
                    onTap: isSaving ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogPrimaryButton(
                    text: "Save",
                    color: const Color(0xFFE40070),
                    isLoading: isSaving,
                    onTap: isSaving ? null : _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionDialogCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onStatus;
  final VoidCallback onReset;

  const _ActionDialogCard({
    required this.user,
    required this.onEdit,
    required this.onStatus,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseDialogCard(
      width: 450,
      icon: Icons.manage_accounts_rounded,
      title: "User Actions",
      subtitle: user.email,
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.edit_rounded,
            title: "Edit User",
            subtitle: "Edit full name only",
            color: const Color(0xFFE40070),
            onTap: onEdit,
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: user.isActive
                ? Icons.person_off_rounded
                : Icons.person_add_alt_1_rounded,
            title: user.isActive ? "Deactivate User" : "Activate User",
            subtitle: user.isActive
                ? "Disable account access"
                : "Enable account access",
            color: user.isActive ? Colors.red : Colors.green,
            onTap: onStatus,
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.lock_reset_rounded,
            title: "Send Reset Link",
            subtitle: "Send password reset email",
            color: Colors.deepPurple,
            onTap: onReset,
          ),
          const SizedBox(height: 18),
          _DialogSecondaryButton(
            text: "Close",
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _ConfirmDialogCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionText;
  final Color actionColor;
  final Future<void> Function() onConfirm;

  const _ConfirmDialogCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionText,
    required this.actionColor,
    required this.onConfirm,
  });

  @override
  State<_ConfirmDialogCard> createState() => _ConfirmDialogCardState();
}

class _ConfirmDialogCardState extends State<_ConfirmDialogCard> {
  bool isLoading = false;

  Future<void> _confirm() async {
    setState(() => isLoading = true);

    try {
      await widget.onConfirm();

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      customDialog(
        context: context,
        title: "Error",
        message: e.toString(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BaseDialogCard(
      width: 430,
      icon: widget.icon,
      iconColor: widget.actionColor,
      title: widget.title,
      subtitle: widget.message,
      child: Row(
        children: [
          Expanded(
            child: _DialogSecondaryButton(
              text: "Cancel",
              onTap: isLoading ? null : () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DialogPrimaryButton(
              text: widget.actionText,
              color: widget.actionColor,
              isLoading: isLoading,
              onTap: isLoading ? null : _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

class _BaseDialogCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;

  const _BaseDialogCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.iconColor = const Color(0xFFE40070),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.02, min: 16, max: 28),
      ),
      child: Container(
        width: width,
        padding: EdgeInsets.all(
          responsiveSize(context, 0.018, min: 18, max: 28),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFD6EA)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A004C).withOpacity(0.14),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogTopIcon(icon: icon, color: iconColor),
              const SizedBox(height: 14),
              customText(
                text: title,
                size: 23,
                bold: true,
                color: const Color(0xFF7A004C),
                isEnglish: true,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                customText(
                  text: subtitle!,
                  size: 13,
                  color: Colors.grey.shade600,
                  isEnglish: true,
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogTopIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _DialogTopIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), const Color(0xFFFF5FA2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: Colors.white, size: 34),
    );
  }
}

class _DialogPrimaryButton extends StatelessWidget {
  final String text;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _DialogPrimaryButton({
    required this.text,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: onTap == null ? color.withOpacity(0.45) : color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(width: 22, height: 22, child: customLoading())
                : customText(
                    text: text,
                    size: 14,
                    bold: true,
                    color: Colors.white,
                    isEnglish: true,
                  ),
          ),
        ),
      ),
    );
  }
}

class _DialogSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _DialogSecondaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: onTap == null
                  ? Colors.grey.withOpacity(0.18)
                  : const Color(0xFFFF9BD0),
            ),
          ),
          child: Center(
            child: customText(
              text: text,
              size: 14,
              bold: true,
              color: onTap == null ? Colors.grey : const Color(0xFFE40070),
              isEnglish: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBFD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFD6EA)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: title,
                    size: 15,
                    bold: true,
                    color: const Color(0xFF272044),
                    isEnglish: true,
                    isCenter: false,
                  ),
                  const SizedBox(height: 4),
                  customText(
                    text: subtitle,
                    size: 12,
                    color: Colors.grey.shade600,
                    isEnglish: true,
                    isCenter: false,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
