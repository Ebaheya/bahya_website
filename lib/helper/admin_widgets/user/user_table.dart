import 'package:bahya_website/bloc/cubit/user_cubit.dart';
import 'package:bahya_website/bloc/states/user_state.dart';
import 'package:bahya_website/data/api/models/user_model.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
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

part 'user_table_content.dart';

class UsersTable extends StatefulWidget {
  const UsersTable({super.key});

  @override
  State<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  void _updateState(VoidCallback callback) => setState(callback);

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
            color: Colors.black.withValues(alpha: 0.04),
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
}
