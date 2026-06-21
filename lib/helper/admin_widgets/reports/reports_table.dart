import 'package:bahya_website/bloc/cubit/reports_cubit.dart';
import 'package:bahya_website/bloc/states/reports_state.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/filter_dropdown.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'reports_widgets.dart';

class ReportsTable extends StatefulWidget {
  const ReportsTable({super.key});

  @override
  State<ReportsTable> createState() => _ReportsTableState();
}

class _ReportsTableState extends State<ReportsTable> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _uiStatus(String status) {
    switch (status.toUpperCase()) {
      case "PENDING":
        return "Pending";
      case "INVESTIGATING":
        return "Investigating";
      case "RESOLVED":
        return "Resolved";
      default:
        return status;
    }
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? "");
    if (date == null) return value?.toString() ?? "";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Map<String, dynamic> _mapReport(Map<String, dynamic> report) {
    final reporter = report["reporter"] is Map
        ? Map<String, dynamic>.from(report["reporter"])
        : <String, dynamic>{};

    return {
      "id": report["id"],
      "role": reporter["role"] ?? "",
      "reporter": reporter["fullName"] ?? "",
      "email": reporter["email"] ?? "",
      "title": report["title"] ?? "",
      "body": report["body"] ?? "",
      "date": _formatDate(report["createdAt"]),
      "status": _uiStatus(report["status"]?.toString() ?? ""),
    };
  }

  void _reload({
    required BuildContext context,
    required String status,
    required String search,
    int page = 1,
  }) {
    context.read<ReportsCubit>().loadReports(
      status: status,
      search: search,
      page: page,
    );
  }

  Future<void> openReportDetails(Map<String, dynamic> report) async {
    try {
      final reportId = report["id"].toString();

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.25),
        builder: (_) => Center(child: customLoading()),
      );

      final detail = await AppRepository().getReportDetail(reportId);

      if (!mounted) return;

      Navigator.pop(context);

      final mappedReport = _mapReport(detail);

      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.25),
        builder: (_) {
          return BlocProvider.value(
            value: context.read<ReportsCubit>(),
            child: ReportDetailsDialog(
              report: mappedReport,
              onStatusChanged: (newStatus) {
                context.read<ReportsCubit>().changeStatus(
                  reportId: mappedReport["id"].toString(),
                  status: newStatus,
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      customDialog(
        context: context,
        title: "Error",
        message: e.toString().replaceFirst("Exception: ", ""),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        final reports = state.reports.map(_mapReport).toList();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            responsiveSize(context, 0.012, min: 14, max: 18),
          ),
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

                  final searchBox = modernInputBox(
                    icon: Icons.search,
                    child: CustomFormTextField(
                      hintText: localizedText(
                        context,
                        'Search by name, email or title',
                      ),
                      isSearch: true,
                      isRequired: false,
                      bordered: false,
                      textDirection: TextDirection.ltr,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: CustomTextFieldType.text,
                      controller: searchController,
                      onChange: (v) {
                        _reload(
                          context: context,
                          status: state.selectedStatus,
                          search: v,
                        );
                      },
                    ),
                  );

                  final dropdown = SizedBox(
                    height: responsiveHeight(context, 0.072, min: 48, max: 62),
                    width: isSmall
                        ? double.infinity
                        : (w * 0.15).clamp(170.0, 230.0),
                    child: FilterDropdown(
                      hint: state.selectedStatus,
                      items: const [
                        "All Status",
                        "Pending",
                        "Investigating",
                        "Resolved",
                      ],
                      onChanged: (v) {
                        _reload(
                          context: context,
                          status: v,
                          search: searchController.text,
                        );
                      },
                    ),
                  );

                  if (isSmall) {
                    return Column(
                      children: [
                        searchBox,
                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.014,
                            min: 10,
                            max: 14,
                          ),
                        ),
                        dropdown,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: searchBox),
                      SizedBox(
                        width: responsiveSize(context, 0.008, min: 10, max: 14),
                      ),
                      dropdown,
                    ],
                  );
                },
              ),
              SizedBox(
                height: responsiveHeight(context, 0.025, min: 16, max: 24),
              ),
              if (state.isLoading)
                SizedBox(height: 220, child: customLoading())
              else if (state.errorMessage != null)
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                )
              else if (reports.isEmpty)
                const EmptyReportsAnimation()
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 850) {
                      return Column(
                        children: reports.map((r) {
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
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          columnSpacing: responsiveSize(
                            context,
                            0.02,
                            min: 22,
                            max: 34,
                          ),
                          columns: [
                            _header(context, "Role"),
                            _header(context, "Reporter"),
                            _header(context, "Title"),
                            _header(context, "Date"),
                            _header(context, "Status"),
                            _header(context, "Actions"),
                          ],
                          rows: reports.map((r) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  _tableText(context, r["role"].toString()),
                                ),
                                DataCell(
                                  _tableText(context, r["reporter"].toString()),
                                ),
                                DataCell(
                                  _tableText(context, r["title"].toString()),
                                ),
                                DataCell(
                                  _tableText(context, r["date"].toString()),
                                ),
                                DataCell(
                                  ReportStatusBadge(
                                    status: r["status"].toString(),
                                  ),
                                ),
                                DataCell(
                                  ReportActionButton(
                                    title: "Open",
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
      },
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

class EmptyReportsAnimation extends StatefulWidget {
  const EmptyReportsAnimation({super.key});

  @override
  State<EmptyReportsAnimation> createState() => _EmptyReportsAnimationState();
}

class _EmptyReportsAnimationState extends State<EmptyReportsAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A004C).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  size: 64,
                  color: Color(0xFF7A004C),
                ),
              ),
            ),
            const SizedBox(height: 20),
            customText(
              text: "No reports found",
              size: responsiveSize(context, 0.01, min: 14, max: 18),
              bold: true,
              isEnglish: true,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
