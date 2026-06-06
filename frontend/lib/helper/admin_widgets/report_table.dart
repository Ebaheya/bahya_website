import 'package:bahya_website/helper/admin_widgets/filter_dropdown.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class ReportsTable extends StatefulWidget {
  const ReportsTable({super.key});

  @override
  State<ReportsTable> createState() => _ReportsTableState();
}

class _ReportsTableState extends State<ReportsTable> {
  String selectedStatus = "All Status";

  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// Search + Filter
          Row(
            children: [
              Expanded(
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
                    onChange: (v) => setState(() {}),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              /// Single Filter Dropdown
              SizedBox(
                height: h * 0.072,
                width: w * 0.15,
                child: FilterDropdown(
                  hint: selectedStatus,
                  items: const [
                    "All Status",
                    "Pending",
                    "Investigating",
                    "Resolved",
                  ],
                  onChanged: (v) {
                    setState(() => selectedStatus = v);
                  },
                ),
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
                      _header(context, "Role"),
                      _header(context, "Reporter"),
                      _header(context, "Title"),
                      _header(context, "Reason"),
                      // _header(context, "Priority"),
                      _header(context, "Date"),
                      _header(context, "Status"),
                      _header(context, "Actions"),
                    ],

                    rows: reports.map((r) {
                      return DataRow(
                        cells: [
                          DataCell(
                            customText(
                              text: r["role"].toString(),
                              size: w * 0.008,
                              isEnglish: true,
                            ),
                          ),

                          DataCell(
                            customText(
                              text: r["reporter"].toString(),
                              size: w * 0.008,
                              isEnglish: true,
                            ),
                          ),

                          DataCell(
                            customText(
                              text: r["type"].toString(),
                              size: w * 0.008,
                              isEnglish: true,
                            ),
                          ),

                          DataCell(
                            customText(
                              text: r["reason"].toString(),
                              size: w * 0.008,
                              isEnglish: true,
                              color: textColor,
                            ),
                          ),

                          // DataCell(
                          //   _badgePriority(r["priority"].toString(), context),
                          // ),
                          DataCell(
                            customText(
                              text: r["date"].toString(),
                              size: w * 0.008,
                              isEnglish: true,
                            ),
                          ),

                          DataCell(
                            _badgeStatus(r["status"].toString(), context),
                          ),

                          DataCell(_actionButton(r["status"].toString())),
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

  /// Header
  DataColumn _header(BuildContext context, String text) {
    return DataColumn(
      label: customText(
        text: text,
        size: getScreenWidth(context) * 0.009,
        bold: true,
        isEnglish: true,
        color: const Color(0xFF7A004C),
      ),
    );
  }

  /// Priority Badge
  // Widget _badgePriority(String text, BuildContext context) {
  //   Color color;

  //   switch (text) {
  //     case "High":
  //       color = Colors.purple;
  //       break;
  //     case "Medium":
  //       color = Colors.blue;
  //       break;
  //     case "Low":
  //       color = Colors.grey;
  //       break;
  //     case "Critical":
  //       color = Colors.pink;
  //       break;
  //     default:
  //       color = Colors.grey;
  //   }

  //   return _badge(text, color, context);
  // }

  /// Status Badge
  Widget _badgeStatus(String text, BuildContext context) {
    Color color;

    switch (text) {
      case "Pending":
        color = Colors.purple;
        break;
      case "Investigating":
        color = Colors.blue;
        break;
      case "Resolved":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return _badge(text, color, context);
  }

  /// Common Badge
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
        color: color,
      ),
    );
  }

  /// Action Button (Resolve)
  Widget _actionButton(String status) {
    if (status == "Resolved") return const SizedBox();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
      ),
      child: customText(
        text: "Resolve",
        size: getScreenWidth(context) * 0.008,
        isEnglish: true,
        color: Colors.white,
      ),
    );
  }
}

final reports = [
  {
    "role": "#1",
    "reporter": "Sarah Johnson",
    "type": "Content Report",
    "reason": "Inappropriate language",
    "priority": "High",
    "date": "2024-04-26",
    "status": "Pending",
  },
  {
    "role": "#2",
    "reporter": "James Martinez",
    "type": "Technical Issue",
    "reason": "Chat not loading",
    "priority": "Medium",
    "date": "2024-04-26",
    "status": "Resolved",
  },
  {
    "role": "#3",
    "reporter": "Emma Williams",
    "type": "User Behavior",
    "reason": "Harassment concern",
    "priority": "High",
    "date": "2024-04-25",
    "status": "Pending",
  },
  {
    "role": "#4",
    "reporter": "John Davis",
    "type": "Bug Report",
    "reason": "Payment error",
    "priority": "High",
    "date": "2024-04-25",
    "status": "Investigating",
  },
];
