import 'dart:math' as math;

import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/heart_pull_refresh.dart';
import 'package:bahya_app/helper/widgets/animated_service_card.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/service_admin_cubit.dart';
import 'package:bahya_app/logic/state/service_admin_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientRequestsDetails extends StatefulWidget {
  final String? patientName;
  final String? medicalNumber;

  const PatientRequestsDetails({
    super.key,
    this.patientName,
    this.medicalNumber,
  });

  @override
  State<PatientRequestsDetails> createState() => _PatientRequestsDetailsState();
}

class _PatientRequestsDetailsState extends State<PatientRequestsDetails> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceAdminCubit>().loadPatientRequestsDetails();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.l10n.isArabic;
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    debugPrint(
      'PatientRequestsDetails : ${widget.patientName} - ${widget.medicalNumber}',
    );

    final args = ModalRoute.of(context)?.settings.arguments;
    final arguments = args is Map ? args : const {};

    final selectedPatientName =
        arguments['patientName']?.toString().trim() ??
        widget.patientName?.trim() ??
        '';

    final selectedMedicalNumber =
        arguments['medicalNumber']?.toString().trim() ??
        widget.medicalNumber?.trim() ??
        '';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<ServiceAdminCubit, ServiceAdminState>(
        builder: (context, state) {
          final rawRequestIds = arguments['requestIds'];
          final selectedRequestIds = rawRequestIds is List
              ? rawRequestIds.map((e) => e.toString()).toSet()
              : <String>{};

          final requests = state.requests.where((request) {
            if (selectedRequestIds.isNotEmpty) {
              return selectedRequestIds.contains(request.id);
            }

            final sameMedicalNumber =
                selectedMedicalNumber.isNotEmpty &&
                request.medicalNumber.trim() == selectedMedicalNumber;

            final sameName =
                selectedPatientName.isNotEmpty &&
                request.patientName.trim() == selectedPatientName;

            return sameMedicalNumber || sameName;
          }).toList();

          Widget content;

          if (state.isLoading) {
            content = SizedBox(
              height: h * 0.55,
              width: w,
              child: Center(child: customLoading()),
            );
          } else if (requests.isEmpty) {
            content = SizedBox(
              height: h * 0.55,
              width: w,
              child: Center(
                child: customText(
                  text: isArabic
                      ? 'لا توجد طلبات لهذه البطلة'
                      : 'No requests found for this patient',
                  size: responsiveSize(context, 0.04, min: 14, max: 18),
                  color: Colors.grey,
                  bold: true,
                ),
              ),
            );
          } else {
            final patient = requests.first;
            final total = requests.length;
            final pending = requests
                .where((r) => r.status.toUpperCase() == 'PENDING')
                .length;
            final approved = requests
                .where((r) => r.status.toUpperCase() == 'APPROVED')
                .length;
            final rejected = requests
                .where((r) => r.status.toUpperCase() == 'REJECTED')
                .length;

            content = Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.025, min: 8, max: 14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: responsiveHeight(context, 0.02, min: 14, max: 20),
                  ),
                  patientDetailsCard(
                    context: context,
                    patientName: patient.patientName,
                    medicalNumber: patient.medicalNumber,
                    totalRequests: total,
                  ),
                  SizedBox(
                    height: responsiveHeight(context, 0.012, min: 8, max: 12),
                  ),
                  requestedState(
                    context: context,
                    total: total,
                    pending: pending,
                    approved: approved,
                    rejected: rejected,
                  ),
                  SizedBox(
                    height: responsiveHeight(context, 0.012, min: 8, max: 12),
                  ),
                  customText(
                    text: isArabic ? 'الخدمات المطلوبة' : 'Requested Services',
                    size: responsiveSize(context, 0.043, min: 15, max: 19),
                    bold: true,
                    color: const Color(0xff14213D),
                    isCenter: false,
                  ),
                  SizedBox(
                    height: responsiveHeight(context, 0.006, min: 4, max: 8),
                  ),
                  ...requests.map((request) {
                    final service = request.service;

                    if (service == null) {
                      return const SizedBox.shrink();
                    }

                    final category = service.category;
                    final kind = category?.kind.toUpperCase() ?? '';
                    final categoryName = category?.name.toLowerCase() ?? '';

                    final isTrip =
                        kind == 'TRIP' ||
                        kind == 'TOUR' ||
                        kind == 'TRAVEL' ||
                        categoryName.contains('رحلة') ||
                        categoryName.contains('tour') ||
                        categoryName.contains('trip');

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: responsiveHeight(
                          context,
                          0.006,
                          min: 4,
                          max: 8,
                        ),
                      ),
                      child: serviceInfo(
                        forAdmin: true,
                        isTravel: isTrip,
                        isSupport: kind == 'SUPPORT',
                        isUnderReview:
                            request.status.toUpperCase() == 'PENDING',
                        isAccepted:
                            request.status.toUpperCase() == 'APPROVED',
                        isRejected:
                            request.status.toUpperCase() == 'REJECTED',
                        w: w,
                        h: h,
                        title: service.title,
                        date: formatServiceDateValue(context, service.date),
                        time: formatServiceTimeValue(context, service.time),
                        location: service.location,
                        meetingPlace: service.meetingPlace,
                        departureTime: service.departureTime == null
                            ? null
                            : formatServiceTimeValue(
                                context,
                                service.departureTime!,
                              ),
                        endDate: service.endDate == null
                            ? null
                            : formatServiceDateValue(context, service.endDate!),
                        availableSeats: service.remainingSeats.toDouble(),
                        categoryColor: _colorFromHex(
                          category?.color ?? '#E7549B',
                        ),
                        categoryIcon: _iconFromKey(category?.iconKey ?? ''),
                      ),
                    );
                  }),
                  SizedBox(
                    height: responsiveHeight(context, 0.012, min: 10, max: 16),
                  ),
                ],
              ),
            );
          }

          return HeartPullRefreshScrollView(
            onRefresh: () async {
              await context
                  .read<ServiceAdminCubit>()
                  .loadPatientRequestsDetails();
            },
            slivers: [
              SliverToBoxAdapter(
                child: Directionality(
                  textDirection: context.appTextDirection,
                  child: Column(
                    children: [
                      customAppBar(
                        context: context,
                        title: isArabic
                            ? 'تفاصيل طلبات البطلة'
                            : 'Patient Requests Details',
                        subTitle: isArabic
                            ? 'متابعة طلبات الخدمات الخاصة بالبطلة'
                            : 'Track patient service requests',
                        isHome: false,
                      ),
                      content,
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String formatServiceDateValue(BuildContext context, String value) {
    final isArabic = context.l10n.isArabic;

    if (value.trim().isEmpty) {
      return isArabic ? 'غير محدد' : 'Not set';
    }

    try {
      final date = DateTime.parse(value).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day/$month/$year';
    } catch (_) {
      return value;
    }
  }

  String formatServiceTimeValue(BuildContext context, String value) {
    final isArabic = context.l10n.isArabic;

    if (value.trim().isEmpty) {
      return isArabic ? 'غير محدد' : 'Not set';
    }

    try {
      final cleanValue = value.trim();

      int hour;
      int minute;

      if (cleanValue.contains('T')) {
        final date = DateTime.parse(cleanValue).toLocal();
        hour = date.hour;
        minute = date.minute;
      } else {
        final parts = cleanValue.split(':');
        hour = int.parse(parts[0]);
        minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      }

      final period = hour >= 12
          ? (isArabic ? 'مساءً' : 'PM')
          : (isArabic ? 'صباحًا' : 'AM');

      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final formattedMinute = minute.toString().padLeft(2, '0');

      return '$hour12:$formattedMinute $period';
    } catch (_) {
      return value;
    }
  }

  Color _colorFromHex(String hex) {
    final value = hex.replaceAll('#', '').trim();
    final parsed = int.tryParse('FF$value', radix: 16);
    return Color(parsed ?? 0xFFE7549B);
  }

  IconData _iconFromKey(String key) {
    switch (key.toLowerCase().trim()) {
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'support':
        return Icons.groups_rounded;
      case 'home':
        return Icons.home_outlined;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'heart':
        return Icons.favorite_border_rounded;
      case 'school':
        return Icons.school_outlined;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'more':
        return Icons.more_horiz_rounded;
      case 'gaming':
        return Icons.sports_esports_rounded;
      case 'trip':
        return Icons.beach_access_rounded;
      case 'business':
        return Icons.business_center_outlined;
      case 'laundry':
        return Icons.local_laundry_service_outlined;
      case 'pets':
        return Icons.pets_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'medical':
        return Icons.medical_services_outlined;
      case 'tools':
        return Icons.build_rounded;
      case 'child':
        return Icons.child_care_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  Widget patientDetailsCard({
    required BuildContext context,
    required String patientName,
    required String medicalNumber,
    required int totalRequests,
  }) {
    final isArabic = context.l10n.isArabic;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.045, min: 14, max: 22)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.065, min: 24, max: 30),
        ),
        border: Border.all(color: Colors.pink.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.10),
            blurRadius: responsiveSize(context, 0.065, min: 22, max: 30),
            offset: Offset(
              0,
              responsiveHeight(context, 0.014, min: 8, max: 14),
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -responsiveSize(context, 0.055, min: 18, max: 28),
            top: -responsiveHeight(context, 0.02, min: 14, max: 22),
            child: Icon(
              Icons.favorite_rounded,
              size: responsiveSize(context, 0.24, min: 85, max: 110),
              color: Colors.pink.withOpacity(0.045),
            ),
          ),
          Column(
            children: [
              Row(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  _AnimatedProfileIcon(
                    size: responsiveHeight(context, 0.095, min: 72, max: 92),
                    iconSize: responsiveSize(context, 0.1, min: 34, max: 44),
                  ),
                  SizedBox(
                    width: responsiveSize(context, 0.035, min: 10, max: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        customText(
                          text: patientName.isEmpty ? '-' : patientName,
                          size: responsiveSize(context, 0.05, min: 18, max: 23),
                          bold: true,
                          color: const Color(0xff14213D),
                          maxLines: 1,
                          isCenter: false,
                        ),
                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.008,
                            min: 5,
                            max: 9,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: isArabic
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              color: Colors.grey[500],
                              size: responsiveSize(
                                context,
                                0.038,
                                min: 14,
                                max: 18,
                              ),
                            ),
                            SizedBox(
                              width: responsiveSize(
                                context,
                                0.012,
                                min: 4,
                                max: 7,
                              ),
                            ),
                            Flexible(
                              child: customText(
                                text: medicalNumber.isEmpty
                                    ? '-'
                                    : medicalNumber,
                                size: responsiveSize(
                                  context,
                                  0.032,
                                  min: 12,
                                  max: 15,
                                ),
                                color: Colors.grey[600],
                                bold: true,
                                isEnglish: true,
                                maxLines: 1,
                                isCenter: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: responsiveHeight(context, 0.018, min: 12, max: 18),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveSize(context, 0.035, min: 12, max: 16),
                  vertical: responsiveHeight(context, 0.014, min: 10, max: 14),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7FB),
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.045, min: 16, max: 20),
                  ),
                  border: Border.all(color: Colors.pink.withOpacity(0.08)),
                ),
                child: Row(
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  children: [
                    Container(
                      width: responsiveHeight(context, 0.045, min: 34, max: 44),
                      height: responsiveHeight(
                        context,
                        0.045,
                        min: 34,
                        max: 44,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(
                          responsiveSize(context, 0.035, min: 12, max: 16),
                        ),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: iconColor,
                        size: responsiveSize(context, 0.052, min: 19, max: 24),
                      ),
                    ),
                    SizedBox(
                      width: responsiveSize(context, 0.025, min: 8, max: 12),
                    ),
                    Expanded(
                      child: customText(
                        text: isArabic
                            ? 'إجمالي طلبات المريضة'
                            : 'Total patient requests',
                        size: responsiveSize(context, 0.033, min: 12, max: 15),
                        color: Colors.grey[700],
                        bold: true,
                        isCenter: false,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveSize(
                          context,
                          0.035,
                          min: 12,
                          max: 16,
                        ),
                        vertical: responsiveHeight(
                          context,
                          0.007,
                          min: 5,
                          max: 8,
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: customText(
                        text: totalRequests.toString(),
                        size: responsiveSize(context, 0.038, min: 14, max: 18),
                        color: Colors.white,
                        bold: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget requestedState({
    required BuildContext context,
    required int total,
    required int pending,
    required int approved,
    required int rejected,
  }) {
    final isArabic = context.l10n.isArabic;

    Widget stateBox({
      required String count,
      required String title,
      required IconData icon,
      required Color color,
    }) {
      return Expanded(
        child: Container(
          height: responsiveHeight(context, 0.115, min: 88, max: 110),
          margin: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.01, min: 3, max: 5),
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.045, min: 16, max: 20),
            ),
            border: Border.all(color: color.withOpacity(0.14)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: responsiveSize(context, 0.062, min: 22, max: 28),
              ),
              SizedBox(
                height: responsiveHeight(context, 0.006, min: 4, max: 7),
              ),
              customText(
                text: count,
                size: responsiveSize(context, 0.052, min: 18, max: 23),
                color: color,
                bold: true,
              ),
              SizedBox(
                height: responsiveHeight(context, 0.003, min: 2, max: 4),
              ),
              customText(
                text: title,
                size: responsiveSize(context, 0.028, min: 10, max: 13),
                color: color,
                bold: true,
                maxLines: 1,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.04, min: 14, max: 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.055, min: 20, max: 26),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: responsiveSize(context, 0.06, min: 20, max: 28),
            offset: Offset(0, responsiveHeight(context, 0.01, min: 6, max: 10)),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              customText(
                text: isArabic ? 'حالة الطلبات' : 'Requests Status',
                size: responsiveSize(context, 0.043, min: 15, max: 19),
                bold: true,
                color: const Color(0xff14213D),
              ),
              const Spacer(),
              customText(
                text: isArabic ? 'الإجمالي $total' : 'Total $total',
                size: responsiveSize(context, 0.032, min: 12, max: 15),
                color: iconColor,
                bold: true,
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.016, min: 10, max: 16)),
          Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              stateBox(
                count: rejected.toString(),
                title: isArabic ? 'مرفوض' : 'Rejected',
                icon: Icons.close_rounded,
                color: Colors.pink,
              ),
              stateBox(
                count: pending.toString(),
                title: isArabic ? 'مراجعة' : 'Pending',
                icon: Icons.access_time_rounded,
                color: Colors.orange,
              ),
              stateBox(
                count: approved.toString(),
                title: isArabic ? 'مقبول' : 'Approved',
                icon: Icons.check_circle_outline_rounded,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedProfileIcon extends StatefulWidget {
  final double size;
  final double iconSize;

  const _AnimatedProfileIcon({required this.size, required this.iconSize});

  @override
  State<_AnimatedProfileIcon> createState() => _AnimatedProfileIconState();
}

class _AnimatedProfileIconState extends State<_AnimatedProfileIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pink = Colors.pink;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final wave = math.sin(t * math.pi * 2);
        final scale = 1.0 + (wave.abs() * 0.04);
        final glow = 0.12 + (wave.abs() * 0.18);

        return Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [pink.shade300, pink.shade500, pink.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: pink.withOpacity(glow),
                    blurRadius: 14 + (wave.abs() * 8),
                    spreadRadius: 1 + (wave.abs() * 2),
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, -2 * wave),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: widget.iconSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
