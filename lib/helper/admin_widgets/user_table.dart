import 'package:bahya_website/helper/admin_widgets/filter_dropdown.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class UsersTable extends StatelessWidget {
  const UsersTable({super.key});

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
          /// Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    hintStyle: TextStyle(
                      fontSize: w * 0.01,

                      fontFamily: 'ArabicCustomFont',
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              FilterDropdown(
                hint: "All Roles",
                items: const ["All", "Patient", "Therapist", "Admin"],
                onChanged: (v) {},
              ),

              const SizedBox(width: 10),

              FilterDropdown(
                hint: "All Status",
                items: const ["All", "Active", "Inactive"],
                onChanged: (v) {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Table
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 30,
                    headingRowHeight: 50,
                    dataRowHeight: 70,

                    columns: [
                      DataColumn(label: headerCell(context, "Name")),
                      DataColumn(label: headerCell(context, "Email")),
                      DataColumn(label: headerCell(context, "Role")),
                      DataColumn(label: headerCell(context, "Status")),
                      DataColumn(label: headerCell(context, "Last Active")),
                      DataColumn(label: headerCell(context, "Actions")),
                    ],

                    rows: _users.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: customText(
                                    text: user["name"][0],
                                    size: w * 0.01,
                                    isEnglish: true,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                customText(
                                  text: user["name"],
                                  size: w * 0.008,
                                  isEnglish: true,
                                ),
                              ],
                            ),
                          ),

                          DataCell(
                            customText(
                              text: user["email"],
                              size: w * 0.008,
                              isEnglish: true,
                            ),
                          ),

                          DataCell(_badge(user["role"], Colors.grey, context)),

                          DataCell(
                            _badge(
                              user["status"],
                              user["status"] == "Active"
                                  ? Colors.green
                                  : Colors.grey,
                              context,
                            ),
                          ),

                          DataCell(
                            customText(
                              text: user["last"],
                              size: w * 0.008,
                              isEnglish: true,
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
          ),
        ],
      ),
    );
  }

  Widget headerCell(BuildContext context, String text) {
    return customText(
      text: text,
      size: getScreenWidth(context) * 0.009,
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
        size: getScreenWidth(context) * 0.008,
        isEnglish: true,
      ),
    );
  }
}

final List<Map<String, dynamic>> _users = [
  {
    "name": "Sarah Johnson",
    "email": "sarah.j@email.com",
    "role": "Patient",
    "status": "Active",
    "last": "2 mins ago",
  },
  {
    "name": "Dr. Michael Chen",
    "email": "dr.chen@email.com",
    "role": "Therapist",
    "status": "Active",
    "last": "5 mins ago",
  },
  {
    "name": "Emma Williams",
    "email": "emma.w@email.com",
    "role": "Patient",
    "status": "Inactive",
    "last": "2 days ago",
  },
  {
    "name": "Dr. Lisa Anderson",
    "email": "dr.anderson@email.com",
    "role": "Therapist",
    "status": "Active",
    "last": "1 hour ago",
  },
];
