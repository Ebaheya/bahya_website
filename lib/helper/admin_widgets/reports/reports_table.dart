import 'package:bahya_website/helper/filter_dropdown.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

import 'reports_widgets.dart';

class ReportsTable extends StatefulWidget {
  const ReportsTable({super.key});

  @override
  State<ReportsTable> createState() => _ReportsTableState();
}

class _ReportsTableState extends State<ReportsTable> {
  String selectedStatus = "All Status";
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredReports {
    return reports.where((r) {
      final query = searchController.text.trim().toLowerCase();
      final status = r["status"].toString();

      final matchSearch =
          query.isEmpty ||
          r["reporter"].toString().toLowerCase().contains(query) ||
          r["email"].toString().toLowerCase().contains(query) ||
          r["title"].toString().toLowerCase().contains(query);

      final matchStatus =
          selectedStatus == "All Status" || selectedStatus == status;

      return matchSearch && matchStatus;
    }).toList();
  }

  void openReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (_) {
        return ReportDetailsDialog(
          report: report,
          onStatusChanged: (newStatus) {
            setState(() {
              report["status"] = newStatus;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.012, min: 14, max: 18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 14, max: 18),
        ),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 750;

              if (isSmall) {
                return Column(
                  children: [
                    modernInputBox(
                      icon: Icons.search,
                      child: CustomFormTextField(
                        hintText: "Search by name, email or title",
                        isSearch: true,
                        isRequired: false,
                        bordered: false,
                        textDirection: TextDirection.ltr,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: CustomTextFieldType.text,
                        controller: searchController,
                        onChange: (v) => setState(() {}),
                      ),
                    ),
                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.014,
                        min: 10,
                        max: 14,
                      ),
                    ),
                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.065,
                        min: 48,
                        max: 58,
                      ),
                      child: FilterDropdown(
                        hint: selectedStatus,
                        items: const [
                          "All Status",
                          "Pending",
                          "Investigating",
                          "Completed",
                        ],
                        onChanged: (v) {
                          setState(() => selectedStatus = v);
                        },
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: modernInputBox(
                      icon: Icons.search,
                      child: CustomFormTextField(
                        hintText: "Search by name, email or title",
                        isSearch: true,
                        isRequired: false,
                        bordered: false,
                        textDirection: TextDirection.ltr,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: CustomTextFieldType.text,
                        controller: searchController,
                        onChange: (v) => setState(() {}),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: responsiveSize(context, 0.008, min: 10, max: 14),
                  ),
                  SizedBox(
                    height: responsiveHeight(context, 0.072, min: 48, max: 62),
                    width: (w * 0.15).clamp(170.0, 230.0),
                    child: FilterDropdown(
                      hint: selectedStatus,
                      items: const [
                        "All Status",
                        "Pending",
                        "Investigating",
                        "Completed",
                      ],
                      onChanged: (v) {
                        setState(() => selectedStatus = v);
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: responsiveHeight(context, 0.025, min: 16, max: 24)),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 850) {
                return Column(
                  children: filteredReports.map((r) {
                    return ReportMobileCard(
                      report: r,
                      onTap: () => openReportDetails(r),
                    );
                  }).toList(),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: responsiveSize(
                      context,
                      0.02,
                      min: 22,
                      max: 34,
                    ),
                    headingRowHeight: responsiveHeight(
                      context,
                      0.055,
                      min: 46,
                      max: 54,
                    ),
                    dataRowMinHeight: responsiveHeight(
                      context,
                      0.06,
                      min: 58,
                      max: 68,
                    ),
                    dataRowMaxHeight: responsiveHeight(
                      context,
                      0.075,
                      min: 64,
                      max: 76,
                    ),
                    columns: [
                      _header(context, "Role"),
                      _header(context, "Reporter"),
                      _header(context, "Title"),
                      _header(context, "Date"),
                      _header(context, "Status"),
                      _header(context, "Actions"),
                    ],
                    rows: filteredReports.map((r) {
                      return DataRow(
                        cells: [
                          DataCell(_tableText(context, r["role"].toString())),
                          DataCell(
                            _tableText(context, r["reporter"].toString()),
                          ),
                          DataCell(
                            SizedBox(
                              width: responsiveSize(
                                context,
                                0.13,
                                min: 170,
                                max: 260,
                              ),
                              child: customText(
                                text: r["title"].toString(),
                                size: responsiveSize(
                                  context,
                                  0.008,
                                  min: 12,
                                  max: 15,
                                ),
                                isEnglish: true,
                                maxLines: 1,
                                isCenter: false,
                              ),
                            ),
                          ),
                          DataCell(_tableText(context, r["date"].toString())),
                          DataCell(
                            ReportStatusBadge(status: r["status"].toString()),
                          ),
                          DataCell(
                            ReportActionButton(
                              title: "Resolve",
                              onTap: () => openReportDetails(r),
                            ),
                          ),
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

  DataColumn _header(BuildContext context, String text) {
    return DataColumn(
      label: customText(
        text: text,
        size: responsiveSize(context, 0.009, min: 13, max: 16),
        bold: true,
        isEnglish: true,
        color: const Color(0xFF7A004C),
      ),
    );
  }

  Widget _tableText(BuildContext context, String text) {
    return customText(
      text: text,
      size: responsiveSize(context, 0.008, min: 12, max: 15),
      isEnglish: true,
    );
  }
}
