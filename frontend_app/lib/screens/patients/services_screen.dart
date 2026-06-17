import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/widgets/patient/service_list_body.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/patient_services_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final arguments = args is Map ? args : const {};
    final categoryId = arguments['categoryId']?.toString() ?? '';
    final title = arguments['title']?.toString() ?? 'الخدمات';
    final subTitle =
        arguments['subTitle']?.toString() ?? 'اختاري ما يناسبك وانضمي الآن';
    debugPrint('[ServicesScreen] args => $arguments');
    debugPrint('[ServicesScreen] categoryId => $categoryId');
    return BlocProvider(
      create: (_) {
        final cubit = PatientServicesCubit(AppRepository());
        if (categoryId.isNotEmpty) {
          cubit.loadServices(categoryId: categoryId);
        }
        return cubit;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: backgroundColor,
        appBar: customAppBar(
          context: context,
          title: context.tr(title),
          subTitle: context.tr(subTitle),
          icon: Icons.category_outlined,
          isHome: false,
        ),
        body: categoryId.isEmpty
            ? Center(
                child: customText(
                  text: 'لا توجد خدمات متاحة حالياً',
                  size: responsiveSize(context, 0.04, min: 16, max: 20),
                  color: Colors.grey,
                ),
              )
            : ServiceListBody(categoryId: categoryId, showCategoryChips: false),
      ),
    );
  }
}
