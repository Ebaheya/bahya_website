import 'package:bahya_website/bloc/cubit/user_cubit.dart';
import 'package:bahya_website/bloc/states/user_state.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/admin_widgets/filter_dropdown.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
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

  void applyFilters() {
    setState(() {
      selectedPage = 1;
    });

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
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.018),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: modernInputBox(
                  icon: Icons.search,
                  child: CustomFormTextField(
                    hintText: "Search by name or email",
                    isSearch: true,
                    isRequired: false,
                    textDirection: TextDirection.ltr,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: CustomTextFieldType.text,
                    controller: searchController,
                    onChange: (_) => applyFilters(),
                  ),
                ),
              ),
              SizedBox(width: w * 0.015),
              Expanded(
                child: FilterDropdown(
                  hint: "All Roles",
                  items: const [
                    "All",
                    "ADMIN",
                    "DOCTOR",
                    "VOLUNTEER",
                    "PATIENT",
                    "CALL_CENTER",
                  ],
                  onChanged: (v) {
                    setState(() {
                      selectedRole = v == "All" ? null : v;
                    });
                    applyFilters();
                  },
                ),
              ),
              SizedBox(width: w * 0.015),
              Expanded(
                child: FilterDropdown(
                  hint: "All Status",
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
                ),
              ),
            ],
          ),

          SizedBox(height: h * 0.035),

          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              if (state is UserLoading) {
                return SizedBox(
                  height: h * 0.45,
                  child: Center(child: customLoading()),
                );
              }

              if (state is UserError) {
                return SizedBox(
                  height: h * 0.35,
                  child: Center(
                    child: customText(
                      text: state.message,
                      size: w * 0.012,
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

                if (selectedPage > totalPages) {
                  selectedPage = totalPages;
                }

                final startIndex = totalUsers == 0
                    ? 0
                    : (selectedPage - 1) * usersPerPage;

                final endIndex = totalUsers == 0
                    ? 0
                    : (startIndex + usersPerPage > totalUsers
                          ? totalUsers
                          : startIndex + usersPerPage);

                final pageUsers = totalUsers == 0
                    ? []
                    : users.sublist(startIndex, endIndex);

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFCFF),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          tableHeader(w),
                          Divider(
                            height: 1,
                            color: Colors.grey.withOpacity(0.12),
                          ),
                          ...pageUsers.map((user) {
                            return userRow(
                              context: context,
                              name: user.name,
                              email: user.email,
                              role: user.role,
                              isActive: user.isActive,
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    Row(
                      children: [
                        customText(
                          text: totalUsers == 0
                              ? "Showing 0 users"
                              : "Showing ${startIndex + 1} to $endIndex of $totalUsers users",
                          size: w * 0.009,
                          color: Colors.indigo.withOpacity(0.65),
                          isEnglish: true,
                        ),

                        const Spacer(),

                        pageButton(
                          w: w,
                          icon: Icons.arrow_back_ios_new_rounded,
                          selected: false,
                          onTap: selectedPage > 1
                              ? () => setState(() => selectedPage--)
                              : () {},
                        ),

                        ...List.generate(totalPages, (index) {
                          final pageNumber = index + 1;

                          return pageButton(
                            w: w,
                            text: pageNumber.toString(),
                            selected: selectedPage == pageNumber,
                            onTap: () {
                              setState(() {
                                selectedPage = pageNumber;
                              });
                            },
                          );
                        }),

                        pageButton(
                          w: w,
                          icon: Icons.arrow_forward_ios_rounded,
                          selected: false,
                          onTap: selectedPage < totalPages
                              ? () => setState(() => selectedPage++)
                              : () {},
                        ),
                      ],
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget tableHeader(double w) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: 18),
      child: Row(
        children: [
          tableTitle(w, "Name", flex: 3),
          tableTitle(w, "Email", flex: 4),
          tableTitle(w, "Role", flex: 2),
          tableTitle(w, "Status", flex: 2),
          tableTitle(w, "Actions", flex: 1),
        ],
      ),
    );
  }

  Widget tableTitle(double w, String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          customText(
            text: text,
            size: w * 0.009,
            bold: true,
            isEnglish: true,
            color: const Color(0xFF4B4D8F),
          ),
          SizedBox(width: w * 0.005),
          Icon(
            Icons.unfold_more_rounded,
            color: Colors.indigo.withOpacity(0.35),
            size: w * 0.011,
          ),
        ],
      ),
    );
  }

  Widget userRow({
    required BuildContext context,
    required String name,
    required String email,
    required String role,
    required bool isActive,
  }) {
    final w = getScreenWidth(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: 14),
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
                userAvatar(name),
                SizedBox(width: w * 0.015),
                Expanded(
                  child: customText(
                    text: name,
                    size: w * 0.009,
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
              text: email,
              size: w * 0.009,
              color: const Color(0xFF272044),
              isEnglish: true,
              maxLines: 1,
            ),
          ),
          Expanded(flex: 2, child: roleBadge(role, w)),
          Expanded(flex: 2, child: statusBadge(isActive, w)),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child:  IconButton(
                  icon: Icon(Icons.more_vert_rounded, color: Color(0xFF4B4D8F)),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userAvatar(String name) {
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
      radius: 20,
      backgroundColor: color,
      child: customText(
        text: initial,
        size: 13,
        color: const Color(0xFF272044),
        bold: true,
        isEnglish: true,
      ),
    );
  }

  Widget roleBadge(String role, double w) {
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: w * 0.01),
            SizedBox(width: w * 0.006),
            customText(
              text: role,
              size: w * 0.008,
              color: color,
              bold: true,
              isEnglish: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget statusBadge(bool isActive, double w) {
    final color = isActive ? Colors.green : Colors.red;
    final text = isActive ? "Active" : "Inactive";

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: w * 0.006),
            customText(
              text: text,
              size: w * 0.008,
              color: color,
              bold: true,
              isEnglish: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget pageButton({
    required double w,
    String? text,
    IconData? icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 38,
          height: 38,
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
                    size: w * 0.009,
                    color: Colors.indigo.withOpacity(0.7),
                  )
                : customText(
                    text: text!,
                    size: w * 0.009,
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
