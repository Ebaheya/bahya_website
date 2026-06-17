import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/service_formatters.dart';
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

    return BlocProvider(
      create: (_) => PatientServicesCubit(AppRepository())..loadMyRequests(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: customAppBar(
          context: context,
          title: 'طلباتي',
          subTitle: 'هنا يمكنك متابعة طلباتك الحالية',
          isHome: false,
        ),
        body: BlocBuilder<PatientServicesCubit, PatientServicesState>(
          builder: (context, state) {
            if (state.isLoading) {
              return customLoading();
            }

            return SingleChildScrollView(
              child: Directionality(
                textDirection: context.appTextDirection,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(height: h * 0.15),
                      requestedState(
                        w: w,
                        h: h,
                        total: state.requests.length,
                        pending: state.requests
                            .where((r) => r.status.toUpperCase() == 'PENDING')
                            .length,
                        approved: state.requests
                            .where((r) => r.status.toUpperCase() == 'APPROVED')
                            .length,
                        rejected: state.requests
                            .where((r) => r.status.toUpperCase() == 'REJECTED')
                            .length,
                      ),
                      if (state.requests.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: h * 0.08),
                          child: customText(
                            text: 'لا توجد طلبات حالياً',
                            size: w * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                      for (final request in state.requests)
                        if (request.service != null)
                          serviceInfo(
                            isAccepted: request.status == 'APPROVED',
                            isUnderReview: request.status == 'PENDING',
                            isRequested: true,
                            w: w,
                            h: h,
                            title: request.service!.title,
                            date: formatServiceDate(
                              context,
                              request.service!.date,
                            ),
                            time: formatServiceTime(
                              context,
                              request.service!.time,
                            ),
                            location: request.service!.location,
                            meetingPlace: request.service!.meetingPlace,
                            categoryColor: request.service!.category == null
                                ? null
                                : colorFromHex(
                                    request.service!.category!.color,
                                  ),
                            categoryIcon: request.service!.category == null
                                ? null
                                : iconFromKey(
                                    request.service!.category!.iconKey,
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
}
