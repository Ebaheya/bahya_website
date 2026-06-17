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
part 'user_mobile_actions.dart';
part 'edit_user_dialog.dart';
part 'user_dialog_components.dart';

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
