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

  @override
  void initState() {
    super.initState();

    context.read<UserCubit>().getAllUserInfo();
  }

  void applyFilters() {
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

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomFormTextField(
                  labelText: "Search users...",
                  isSearch: true,
                  isRequired: false,
                  textDirection: TextDirection.ltr,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: CustomTextFieldType.text,
                  controller: searchController,
                  onChange: (_) => applyFilters(),
                ),
              ),

              const SizedBox(width: 10),

              FilterDropdown(
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

              const SizedBox(width: 10),

              FilterDropdown(
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
            ],
          ),

          const SizedBox(height: 20),

          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              if (state is UserLoading) {
                return customLoading();
              }

              if (state is UserError) {
                return SizedBox(
                  height: 200,
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

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),

                        child: DataTable(
                          columnSpacing: 30,

                          headingRowHeight: 50,

                          dataRowHeight: 70,

                          columns: [
                            DataColumn(label: headerCell(context, "Name")),

                            DataColumn(label: headerCell(context, "Email")),

                            DataColumn(label: headerCell(context, "Role")),

                            DataColumn(label: headerCell(context, "Status")),

                            // DataColumn(
                            //   label:
                            //       headerCell(
                            //     context,
                            //     "Last Active",
                            //   ),
                            // ),
                            DataColumn(label: headerCell(context, "Actions")),
                          ],

                          rows: users.map((user) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey[200],

                                        child: customText(
                                          text: user.name.isNotEmpty
                                              ? user.name[0]
                                              : '?',

                                          size: w * 0.01,

                                          isEnglish: true,
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      customText(
                                        text: user.name,

                                        size: w * 0.01,

                                        isEnglish: true,
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  customText(
                                    text: user.email,

                                    size: w * 0.01,

                                    isEnglish: true,
                                  ),
                                ),

                                DataCell(
                                  _badge(user.role, Colors.grey, context),
                                ),

                                DataCell(
                                  _badge(
                                    user.isActive ? "Active" : "Inactive",

                                    user.isActive ? Colors.green : Colors.grey,

                                    context,
                                  ),
                                ),

                                const DataCell(Icon(Icons.more_vert)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget headerCell(BuildContext context, String text) {
    return customText(
      text: text,

      size: getScreenWidth(context) * 0.01,

      bold: true,

      isEnglish: true,

      color: const Color(0xFF7A004C),
    );
  }

  Widget _badge(String text, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),

        borderRadius: BorderRadius.circular(20),
      ),

      child: customText(
        text: text,

        size: getScreenWidth(context) * 0.01,

        isEnglish: true,
      ),
    );
  }
}
