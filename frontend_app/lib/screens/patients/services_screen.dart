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

  IconData _iconFromKey(String key) {
    switch (key) {
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final arguments = args is Map ? args : const {};
    final iconKey = (arguments['iconKey'] ?? '').toString().trim();
    final categoryId = arguments['categoryId']?.toString() ?? '';
    final title = arguments['title']?.toString() ?? 'الخدمات';
    final subTitle =
        arguments['subTitle']?.toString() ?? 'اختاري ما يناسبك وانضمي الآن';
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
          icon: _iconFromKey(iconKey),
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
