import 'package:bahya_app/data/models/service_models.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/helper/service_formatters.dart';
import 'package:bahya_app/helper/widgets/animated_service_card.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/patient_services_cubit.dart';
import 'package:bahya_app/logic/state/patient_services_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceListBody extends StatefulWidget {
  const ServiceListBody({
    super.key,
    required this.categoryId,
    this.showCategoryChips = false,
  });

  final String categoryId;
  final bool showCategoryChips;

  @override
  State<ServiceListBody> createState() => _ServiceListBodyState();
}

class _ServiceListBodyState extends State<ServiceListBody> {
  Future<void> _requestService(String serviceId) async {
    final cubit = context.read<PatientServicesCubit>();

    await cubit.requestService(serviceId, categoryId: widget.categoryId);

    if (!mounted) return;

    final state = cubit.state;

    if (state.error != null) {
      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr(state.error!),
        isError: true,
      );
      return;
    }

    customDialog(
      context: context,
      title: context.tr('تم إرسال الطلب'),
      message: context.tr('تم إرسال طلبك بنجاح وسيتم مراجعته قريباً.'),
      isSuccess: true,
    );
  }

  Future<void> _cancelRequest(String requestId) async {
    final cubit = context.read<PatientServicesCubit>();

    await cubit.cancelRequest(requestId, categoryId: widget.categoryId);

    if (!mounted) return;

    final state = cubit.state;

    if (state.error != null) {
      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr(state.error!),
        isError: true,
      );
      return;
    }

    customDialog(
      context: context,
      title: context.tr('تم إلغاء الطلب'),
      message: context.tr('تم إلغاء طلبك بنجاح.'),
      isSuccess: true,
    );
  }

  ServiceRequestModel? _requestForService(
    PatientServiceModel service,
    List<ServiceRequestModel> requests,
  ) {
    for (final request in requests) {
      if (request.service?.id == service.id) return request;
    }
    return null;
  }

  bool _matchesCategory(PatientServiceModel service) {
    final selectedId = widget.categoryId.trim();
    final categoryId = service.categoryId.trim();
    final nestedId = service.category?.id.trim() ?? '';
    final status = service.status.trim().toUpperCase();

    return status == 'ACTIVE' &&
        selectedId.isNotEmpty &&
        (categoryId == selectedId || nestedId == selectedId);
  }

  bool _isTripCategory(ServiceCategoryModel? category) {
    final kind = category?.kind.trim().toUpperCase() ?? '';
    return kind == 'TRIP' || kind == 'TOUR';
  }

  ServiceCategoryModel? _categoryForService(
    PatientServiceModel service,
    List<ServiceCategoryModel> categories,
  ) {
    final categoryId = service.categoryId.trim();
    final nestedId = service.category?.id.trim() ?? '';

    for (final category in categories) {
      if (category.id.trim() == categoryId || category.id.trim() == nestedId) {
        return category;
      }
    }

    return service.category;
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return BlocBuilder<PatientServicesCubit, PatientServicesState>(
      builder: (context, state) {
        if (state.isLoading || !state.hasLoaded) {
          return Center(child: customLoading());
        }

        final services = state.services.where(_matchesCategory).toList();

        return SingleChildScrollView(
          child: Directionality(
            textDirection: context.appTextDirection,
            child: Column(
              children: [
                if (widget.showCategoryChips)
                  _CategoryChips(
                    categories: state.categories.where((c) {
                      return c.id.trim().isNotEmpty && c.isActive == true;
                    }).toList(),
                    selectedCategoryId: widget.categoryId,
                  ),
                if (services.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: h * 0.2),
                    child: customText(
                      text: context.tr('لا توجد خدمات متاحة حالياً'),
                      size: w * 0.04,
                      color: Colors.grey,
                    ),
                  )
                else
                  ...services.map((service) {
                    final category = _categoryForService(
                      service,
                      state.categories,
                    );

                    final isTrip = _isTripCategory(category);

                    final request = _requestForService(service, state.requests);

                    final requestStatus =
                        request?.status.trim().toUpperCase() ?? '';

                    final isPending = requestStatus == 'PENDING';
                    final isApproved = requestStatus == 'APPROVED';
                    final isRejected = requestStatus == 'REJECTED';
                    final isCancelled = requestStatus == 'CANCELLED';

                    final hasActiveRequest =
                        request != null && !isRejected && !isCancelled;

                    return serviceInfo(
                      w: w,
                      h: h,
                      title: service.title,
                      date: formatServiceDate(context, service.date),
                      time: formatServiceTime(context, service.time),
                      location: service.location,
                      endDate:
                          isTrip &&
                              service.endDate != null &&
                              service.endDate!.trim().isNotEmpty
                          ? formatServiceDate(context, service.endDate!)
                          : null,
                      departureTime:
                          isTrip &&
                              service.departureTime != null &&
                              service.departureTime!.trim().isNotEmpty
                          ? formatServiceTime(context, service.departureTime!)
                          : null,
                      meetingPlace: isTrip ? service.meetingPlace : null,
                      isTravel: isTrip,
                      availableSeats: service.remainingSeats.toDouble(),
                      isRequested: hasActiveRequest,
                      isUnderReview: isPending,
                      isAccepted: isApproved,
                      isRejected: isRejected,
                      categoryColor: category == null
                          ? null
                          : colorFromHex(category.color),
                      categoryIcon: category == null
                          ? null
                          : iconFromKey(category.iconKey),
                      onJoinPressed: state.isSubmitting || hasActiveRequest
                          ? null
                          : () => _requestService(service.id),
                      onCancelPressed:
                          state.isSubmitting || !isPending || request == null
                          ? null
                          : () => _cancelRequest(request.id),
                    );
                  }),
                SizedBox(height: responsiveHeight(context, 0.04, min: 24)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedCategoryId,
  });

  final List<ServiceCategoryModel> categories;
  final String selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.025, min: 10, max: 16),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final category in categories)
            ActionChip(
              label: Text(
                category.name,
                style: const TextStyle(fontFamily: 'ArabicCustomFont'),
              ),
              onPressed: () {
                context.read<PatientServicesCubit>().loadServices(
                  categoryId: category.id,
                );
              },
              backgroundColor: category.id == selectedCategoryId
                  ? Colors.pink.shade50
                  : Colors.white,
              side: BorderSide(color: Colors.pink.shade100),
            ),
        ],
      ),
    );
  }
}
