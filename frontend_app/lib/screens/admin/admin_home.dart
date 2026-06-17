import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/service_formatters.dart';
import 'package:bahya_app/helper/widgets/patient/patient_home_widgets.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/service_admin_cubit.dart';
import 'package:bahya_app/logic/state/service_admin_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminHome extends StatelessWidget {
  AdminHome({super.key});

  final WebService webService = WebService();

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return BlocBuilder<ServiceAdminCubit, ServiceAdminState>(
      builder: (context, state) {
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: backgroundColor,
          appBar: customAppBar(
            preferredSize: Size.fromHeight(h * 0.3),
            context: context,
            title: 'لوحة إدارة الخدمات',
            subTitle: 'مساعدة المحاربات في رحلتهن',
            isHome: false,
            isAdmin: true,
            icon: Icons.logout_outlined,
            onIconPressed: () => webService.logout(),
            widgets: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: _AdminSummaryCards(
                  key: ValueKey(state.summary.toString()),
                  w: w,
                  h: h,
                  summary: state.summary,
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: EdgeInsetsDirectional.only(
              end: responsiveSize(context, 0.02, min: 8, max: 16),
              bottom: responsiveHeight(context, 0.02, min: 12, max: 20),
            ),
            child: languageFloatingButton(context: context),
          ),
          body: SingleChildScrollView(
            child: Directionality(
              textDirection: context.appTextDirection,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: h * 0.32),
                    _AdminButton(
                      title: 'انشاء خدمه جديده ',
                      onPressed: () =>
                          Navigator.pushNamed(context, '/addService'),
                    ),
                    SizedBox(height: h * 0.02),
                    _AdminButton(
                      title: 'انشاء كاتجورى جديده ',
                      onPressed: () =>
                          Navigator.pushNamed(context, '/create_category'),
                    ),
                    SizedBox(height: h * 0.02),
                    _AdminButton(
                      title: 'تاريخ الطلبات',
                      onPressed: () =>
                          Navigator.pushNamed(context, '/patientsSearch'),
                    ),
                    SizedBox(height: h * 0.02),
                    Row(
                      children: [
                        customText(text: 'الطلبات الوارده', size: w * 0.035),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            key: ValueKey(state.requests.length),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                customText(
                                  text: '${state.requests.length} طلبات جديده',
                                  size: w * 0.03,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.02),
                    if (state.isLoading)
                      Padding(
                        padding: EdgeInsets.only(top: h * 0.08),
                        child: customText(
                          text: 'جاري التحميل...',
                          size: w * 0.04,
                          color: Colors.grey,
                        ),
                      )
                    else if (state.requests.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: h * 0.08),
                        child: customText(
                          text: 'لا توجد طلبات حالياً',
                          size: w * 0.04,
                          color: Colors.grey,
                        ),
                      )
                    else
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: Column(
                          key: ValueKey(
                            state.requests.map((e) => e.id).join('-'),
                          ),
                          children: [
                            for (
                              int index = 0;
                              index < state.requests.length;
                              index++
                            )
                              _AnimatedRequestCard(
                                index: index,
                                child: requestedServiceCard(
                                  w: w,
                                  h: h,
                                  nameOfPatient:
                                      state.requests[index].patientName.isEmpty
                                      ? 'غير محدد'
                                      : state.requests[index].patientName,
                                  medicalNumber:
                                      state
                                          .requests[index]
                                          .medicalNumber
                                          .isEmpty
                                      ? 'غير محدد'
                                      : state.requests[index].medicalNumber,
                                  service:
                                      state.requests[index].service?.title ??
                                      'غير محدد',
                                  requestDate: formatServiceDate(
                                    context,
                                    state.requests[index].requestDate,
                                  ),
                                  onAccept: state.isSaving
                                      ? null
                                      : () => context
                                            .read<ServiceAdminCubit>()
                                            .approveRequest(
                                              state.requests[index].id,
                                            ),
                                  onDeny: state.isSaving
                                      ? null
                                      : () => context
                                            .read<ServiceAdminCubit>()
                                            .rejectRequest(
                                              state.requests[index].id,
                                            ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: h * 0.02),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedRequestCard extends StatelessWidget {
  const _AnimatedRequestCard({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (index * 45)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: Transform.scale(scale: 0.96 + (value * 0.04), child: child),
          ),
        );
      },
    );
  }
}

class _AdminButton extends StatelessWidget {
  const _AdminButton({required this.title, required this.onPressed});

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomGlowButton(
      width: double.infinity,
      borderRadius: 12,
      title: title,
      onPressed: onPressed,
      isGradient: true,
    );
  }
}

class _AdminSummaryCards extends StatelessWidget {
  const _AdminSummaryCards({
    super.key,
    required this.w,
    required this.h,
    required this.summary,
  });

  final double w;
  final double h;
  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    final pending = _summaryValue(['pending', 'PENDING', 'pendingCount']);
    final approved = _summaryValue(['approved', 'APPROVED', 'approvedCount']);
    final total = _summaryValue(['total', 'totalCount', 'requests']);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _SummaryCard(
          w: w,
          h: h,
          icon: Icons.av_timer_rounded,
          count: pending,
          title: 'طلبات قيد المراجعة',
        ),
        _SummaryCard(
          w: w,
          h: h,
          icon: Icons.person_add_alt_rounded,
          count: total,
          title: 'إجمالي الطلبات',
        ),
        _SummaryCard(
          w: w,
          h: h,
          icon: Icons.check_circle,
          count: approved,
          title: 'طلبات تمت الموافقة عليها',
        ),
      ],
    );
  }

  String _summaryValue(List<String> keys) {
    for (final key in keys) {
      final value = summary[key];
      if (value != null) return value.toString();
    }
    return '0';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.w,
    required this.h,
    required this.icon,
    required this.count,
    required this.title,
  });

  final double w;
  final double h;
  final IconData icon;
  final String count;
  final String title;

  int get countNumber => int.tryParse(count) ?? 0;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$title-$count'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.92 + (value * 0.08),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        width: w * 0.25,
        height: h * 0.18,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: w * 0.08),
            const SizedBox(height: 4),
            TweenAnimationBuilder<int>(
              key: ValueKey('$title-$countNumber'),
              tween: IntTween(begin: 0, end: countNumber),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return FittedBox(
                  child: customText(
                    text: value.toString(),
                    size: w * 0.07,
                    color: Colors.white,
                    bold: true,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Expanded(
              child: customText(
                text: title,
                size: w * 0.032,
                maxLines: 3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
