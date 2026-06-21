import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/patient_services_cubit.dart';
import 'package:bahya_app/logic/state/patient_services_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestedService extends StatelessWidget {
  const RequestedService({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    final isArabic = context.l10n.isArabic;

    return BlocProvider(
      create: (_) => PatientServicesCubit(AppRepository())..loadMyRequests(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: backgroundColor,
        appBar: customAppBar(
          context: context,
          title: isArabic ? 'طلباتي' : 'My Requests',
          subTitle: isArabic
              ? 'هنا يمكنك متابعة طلباتك الحالية'
              : 'Track your current requests here',
          isHome: false,
        ),
        body: BlocBuilder<PatientServicesCubit, PatientServicesState>(
          builder: (context, state) {
            if (state.isLoading) return customLoading();

            final total = state.requests.length;
            final pending = state.requests
                .where((r) => r.status.toUpperCase() == 'PENDING')
                .length;
            final approved = state.requests
                .where((r) => r.status.toUpperCase() == 'APPROVED')
                .length;
            final rejected = state.requests
                .where((r) => r.status.toUpperCase() == 'REJECTED')
                .length;

            return SingleChildScrollView(
              child: Directionality(
                textDirection: context.appTextDirection,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(context, 0.025, min: 8, max: 14),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.15,
                          min: 115,
                          max: 145,
                        ),
                      ),

                      requestedState(
                        w: w,
                        h: h,
                        total: total,
                        pending: pending,
                        approved: approved,
                        rejected: rejected,
                      ),

                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.012,
                          min: 8,
                          max: 12,
                        ),
                      ),

                      if (state.requests.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            top: responsiveHeight(
                              context,
                              0.08,
                              min: 45,
                              max: 75,
                            ),
                          ),
                          child: customText(
                            text: isArabic
                                ? 'لا توجد طلبات حالياً'
                                : 'No requests yet',
                            size: responsiveSize(
                              context,
                              0.04,
                              min: 14,
                              max: 18,
                            ),
                            color: Colors.grey,
                          ),
                        ),

                      for (final request in state.requests)
                        if (request.service != null)
                          Builder(
                            builder: (context) {
                              final service = request.service!;
                              final category = service.category;

                              final kind = category?.kind.toUpperCase() ?? '';
                              final categoryName =
                                  category?.name.toLowerCase() ?? '';
                              final iconKey = category?.iconKey ?? '';

                              final isTrip =
                                  kind == 'TRIP' ||
                                  kind == 'TOUR' ||
                                  kind == 'TRAVEL' ||
                                  iconKey.toLowerCase() == 'trip' ||
                                  iconKey.toLowerCase() == 'bus' ||
                                  categoryName.contains('رحلة') ||
                                  categoryName.contains('tour') ||
                                  categoryName.contains('trip');

                              final categoryColor = _colorFromHex(
                                category?.color ?? '#E7549B',
                              );

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
                                  isRequested: true,
                                  isTravel: isTrip,
                                  isSupport: kind == 'SUPPORT',
                                  isAccepted:
                                      request.status.toUpperCase() ==
                                      'APPROVED',
                                  isUnderReview:
                                      request.status.toUpperCase() == 'PENDING',
                                  isRejected:
                                      request.status.toUpperCase() ==
                                      'REJECTED',
                                  w: w,
                                  h: h,
                                  title: service.title,
                                  date: _formatDate(context, service.date),
                                  time: _formatTime(context, service.time),
                                  location: service.location,
                                  meetingPlace: service.meetingPlace,
                                  departureTime: service.departureTime == null
                                      ? null
                                      : _formatTime(
                                          context,
                                          service.departureTime!,
                                        ),
                                  endDate: service.endDate == null
                                      ? null
                                      : _formatDate(context, service.endDate!),
                                  availableSeats: service.remainingSeats
                                      .toDouble(),
                                  categoryColor: categoryColor,
                                  categoryIcon: _iconFromKey(iconKey),
                                ),
                              );
                            },
                          ),

                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.02,
                          min: 12,
                          max: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, String value) {
    final isArabic = context.l10n.isArabic;

    if (value.trim().isEmpty) return isArabic ? 'غير محدد' : 'Not set';

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

  String _formatTime(BuildContext context, String value) {
    final isArabic = context.l10n.isArabic;

    if (value.trim().isEmpty) return isArabic ? 'غير محدد' : 'Not set';

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
}
