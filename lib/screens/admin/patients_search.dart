import 'package:bahya_app/data/models/service_models.dart';
import 'package:bahya_app/helper/animated_icon.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/custom_searchbar.dart';
import 'package:bahya_app/helper/heart_pull_refresh.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/service_admin_cubit.dart';
import 'package:bahya_app/logic/state/service_admin_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientsSearch extends StatefulWidget {
  const PatientsSearch({super.key});

  @override
  State<PatientsSearch> createState() => _PatientsSearchState();
}

class _PatientsSearchState extends State<PatientsSearch> {
  String searchText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ServiceAdminCubit>().loadPatientRequestsDetails();
    });
  }

  Future<void> _refreshPatients(BuildContext context) async {
    await context.read<ServiceAdminCubit>().loadPatientRequestsDetails();
  }

  Widget _buildHeader(BuildContext context, double h, bool isArabic) {
    return customAppBar(
      context: context,
      preferredSize: Size.fromHeight(h * 0.2),
      title: isArabic ? 'بحث عن مريض' : 'Search Patients',
      subTitle: isArabic
          ? 'ابحث عن المحاربات في رحلتهن'
          : 'Find warriors in their journey',
      isHome: false,
      onIconPressed: () => Navigator.pop(context),
      widgets: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomSearchBarWithFilter(
            hintText: isArabic
                ? 'ابحثي باسم المريضة أو رقم الملف...'
                : 'Search by patient name or file number...',
            onChanged: (value) {
              setState(() {
                searchText = value.trim().toLowerCase();
              });
            },
            onFilterTap: () {},
            onSearchTap: () {},
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);
    final isArabic = context.l10n.isArabic;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<ServiceAdminCubit, ServiceAdminState>(
        builder: (context, state) {
          final patients = _uniquePatientsFromRequests(state.requests);
          final filteredPatients = _filterPatients(patients);

          return HeartPullRefreshScrollView(
            onRefresh: () => _refreshPatients(context),
            slivers: [
              SliverToBoxAdapter(
                child: Directionality(
                  textDirection: context.appTextDirection,
                  child: Column(
                    children: [
                      _buildHeader(context, h, isArabic),
                      if (state.isLoading)
                        SizedBox(
                          width: w,
                          height: h * 0.55,
                          child: Center(child: customLoading()),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: w * 0.025),
                          child: Column(
                            children: [
                              if (state.error != null &&
                                  state.error!.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: responsiveHeight(
                                      context,
                                      0.08,
                                      min: 50,
                                      max: 80,
                                    ),
                                  ),
                                  child: customText(
                                    text: state.error!,
                                    size: w * 0.04,
                                    color: Colors.red,
                                    bold: true,
                                  ),
                                )
                              else if (filteredPatients.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: responsiveHeight(
                                      context,
                                      0.08,
                                      min: 50,
                                      max: 80,
                                    ),
                                  ),
                                  child: customText(
                                    text: isArabic
                                        ? 'لا توجد مريضات لديهن طلبات'
                                        : 'No patients with requests found',
                                    size: w * 0.04,
                                    color: Colors.grey,
                                    bold: true,
                                  ),
                                )
                              else ...[
                                Align(
                                  alignment: isArabic
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: customText(
                                    text: isArabic
                                        ? 'عدد المريضات: ${filteredPatients.length}'
                                        : 'Patients: ${filteredPatients.length}',
                                    size: w * 0.035,
                                    color: const Color(0xff14213D),
                                    bold: true,
                                  ),
                                ),
                                SizedBox(height: h * 0.015),
                                ...filteredPatients.map((patient) {
                                  final patientKey = _patientKey(patient);
                                  final patientRequests = state.requests.where((
                                    request,
                                  ) {
                                    return _patientKey(request) == patientKey;
                                  }).toList();

                                  return Padding(
                                    padding: EdgeInsets.only(bottom: h * 0.014),
                                    child: patientCard(
                                      context: context,
                                      w: w,
                                      h: h,
                                      patientName: patient.patientName,
                                      medicalNumber: patient.medicalNumber,
                                      requestCount: patientRequests.length,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/patientRequestsDetails',
                                          arguments: {
                                            'patientName': patient.patientName,
                                            'medicalNumber':
                                                patient.medicalNumber,
                                            'requestIds': patientRequests
                                                .map((e) => e.id)
                                                .toList(),
                                          },
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ],
                              SizedBox(
                                height: responsiveHeight(
                                  context,
                                  0.025,
                                  min: 18,
                                  max: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  List<ServiceRequestModel> _filterPatients(
    List<ServiceRequestModel> patients,
  ) {
    if (searchText.isEmpty) return patients;

    return patients.where((patient) {
      final name = patient.patientName.toLowerCase();
      final medicalNumber = patient.medicalNumber.toLowerCase();

      return name.contains(searchText) || medicalNumber.contains(searchText);
    }).toList();
  }

  List<ServiceRequestModel> _uniquePatientsFromRequests(
    List<ServiceRequestModel> requests,
  ) {
    final Map<String, ServiceRequestModel> patients = {};

    for (final request in requests) {
      final key = _patientKey(request);

      if (key.isNotEmpty && !patients.containsKey(key)) {
        patients[key] = request;
      }
    }

    return patients.values.toList();
  }

  String _patientKey(ServiceRequestModel request) {
    if (request.medicalNumber.trim().isNotEmpty) {
      return request.medicalNumber.trim();
    }

    return request.patientName.trim();
  }

  Widget patientCard({
    required BuildContext context,
    required double w,
    required double h,
    required String patientName,
    required String medicalNumber,
    required int requestCount,
    required VoidCallback onTap,
  }) {
    final isArabic = context.l10n.isArabic;

    final cardPadding = responsiveSize(context, 0.035, min: 12, max: 18);
    final cardRadius = responsiveSize(context, 0.055, min: 18, max: 26);
    final avatarRadius = responsiveHeight(context, 0.037, min: 27, max: 34);
    final gap = responsiveSize(context, 0.025, min: 8, max: 12);
    final titleSize = responsiveSize(context, 0.038, min: 14, max: 18);
    final numberSize = responsiveSize(context, 0.03, min: 11, max: 14);
    final badgeTextSize = responsiveSize(context, 0.028, min: 10, max: 13);
    final arrowSize = responsiveSize(context, 0.035, min: 13, max: 17);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(cardRadius),
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.08),
              blurRadius: responsiveSize(context, 0.05, min: 16, max: 24),
              offset: Offset(
                0,
                responsiveHeight(context, 0.01, min: 5, max: 10),
              ),
            ),
          ],
        ),
        child: Row(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            HoverWaveAvatar(
              radius: avatarRadius,
              iconColor: Colors.white,
              icon: Icons.person_rounded,
              onPressed: onTap,
            ),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: patientName.isEmpty ? '-' : patientName,
                    size: titleSize,
                    bold: true,
                    color: const Color(0xff14213D),
                    isCenter: false,
                    maxLines: 1,
                  ),
                  SizedBox(
                    height: responsiveHeight(context, 0.006, min: 4, max: 7),
                  ),
                  Row(
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      customText(
                        text: medicalNumber.isEmpty ? '-' : medicalNumber,
                        size: numberSize,
                        color: Colors.grey[600],
                        isEnglish: true,
                        isCenter: false,
                        bold: true,
                        maxLines: 1,
                      ),
                      SizedBox(
                        width: responsiveSize(context, 0.01, min: 4, max: 7),
                      ),
                      Icon(
                        Icons.badge_outlined,
                        size: responsiveSize(context, 0.035, min: 13, max: 16),
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.03, min: 10, max: 14),
                vertical: responsiveHeight(context, 0.008, min: 5, max: 8),
              ),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.10),
                borderRadius: BorderRadius.circular(30),
              ),
              child: customText(
                text: isArabic ? '$requestCount طلب' : '$requestCount requests',
                size: badgeTextSize,
                color: Colors.pink,
                bold: true,
                maxLines: 1,
              ),
            ),
            SizedBox(width: responsiveSize(context, 0.02, min: 7, max: 11)),
            Icon(
              isArabic
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_new_rounded,
              color: Colors.pink[300],
              size: arrowSize,
            ),
          ],
        ),
      ),
    );
  }
}
