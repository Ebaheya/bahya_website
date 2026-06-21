import 'package:bahya_app/data/models/service_models.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/chatbot_card.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/widgets/patient/articles.dart';
import 'package:bahya_app/helper/widgets/patient/patient_home_widgets.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/service_admin_cubit.dart';
import 'package:bahya_app/logic/state/service_admin_state.dart';
import 'package:bahya_app/screens/patients/chatbot_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientsHome extends StatefulWidget {
  const PatientsHome({super.key});

  @override
  State<PatientsHome> createState() => _PatientsHomeState();
}

class _PatientsHomeState extends State<PatientsHome> {
  int currentIndex = 0;
  int visibleCategoriesCount = 4;

  bool _serviceBelongsToCategory(
    PatientServiceModel service,
    ServiceCategoryModel category,
  ) {
    final serviceCategoryId = service.categoryId.trim();
    final nestedCategoryId = service.category?.id.trim() ?? '';
    final categoryId = category.id.trim();

    final isActive = service.status.trim().toUpperCase() == 'ACTIVE';

    return isActive &&
        categoryId.isNotEmpty &&
        (serviceCategoryId == categoryId || nestedCategoryId == categoryId);
  }

  void _showMoreCategories(int total) {
    setState(() {
      if (visibleCategoriesCount >= total) {
        visibleCategoriesCount = 4;
      } else {
        visibleCategoriesCount = (visibleCategoriesCount + 4).clamp(4, total);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: customAppBar(
        title: context.tr('أهلًا بعودتك، البطلة'),
        subTitle: context.tr('اليوم هو بداية جديدة مليئة بالأمل'),
        context: context,
      ),
      backgroundColor: backgroundColor,
      body: BlocBuilder<ServiceAdminCubit, ServiceAdminState>(
        builder: (context, state) {
          if (state.isLoading) {
            return SizedBox(
              height: h,
              width: w,
              child: Center(child: customLoading()),
            );
          }

          return Directionality(
            textDirection: context.appTextDirection,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.15,
                        min: 112,
                        max: 138,
                      ),
                    ),
                    ChatBotCard(
                      w: w,
                      h: h,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatBotScreen(),
                          ),
                        );
                      },
                    ),
                    sectionTitle(
                      context: context,
                      w: w,
                      title: context.tr('الخدمات المجتمعية'),
                    ),
                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.024,
                        min: 18,
                        max: 22,
                      ),
                    ),
                    _DynamicCategoriesSection(
                      w: w,
                      h: h,
                      categories: state.categories,
                      services: state.services,
                      visibleCount: visibleCategoriesCount,
                      onToggleMore: _showMoreCategories,
                      serviceBelongsToCategory: _serviceBelongsToCategory,
                    ),
                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.034,
                        min: 24,
                        max: 30,
                      ),
                    ),
                    sectionTitle(
                      context: context,
                      w: w,
                      title: context.tr('مقالات مفيدة'),
                    ),
                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.016,
                        min: 12,
                        max: 16,
                      ),
                    ),
                    articles(w: w, context: context),
                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.2,
                        min: 150,
                        max: 180,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: responsiveHeight(context, 0.035, min: 28, max: 40),
          right: responsiveSize(context, 0.02, min: 6, max: 10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            languageFloatingButton(context: context),
            SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
            _MyRequestsButton(
              w: w,
              h: h,
              isSelected: currentIndex == 1,
              onTap: () {
                setState(() => currentIndex = 1);
                Navigator.pushNamed(context, '/requestedService');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicCategoriesSection extends StatelessWidget {
  const _DynamicCategoriesSection({
    required this.w,
    required this.h,
    required this.categories,
    required this.services,
    required this.visibleCount,
    required this.onToggleMore,
    required this.serviceBelongsToCategory,
  });

  final double w;
  final double h;
  final List<ServiceCategoryModel> categories;
  final List<PatientServiceModel> services;
  final int visibleCount;
  final ValueChanged<int> onToggleMore;
  final bool Function(PatientServiceModel, ServiceCategoryModel)
  serviceBelongsToCategory;

  @override
  Widget build(BuildContext context) {
    final activeCategories = categories.where((category) {
      return category.id.trim().isNotEmpty && category.isActive == true;
    }).toList();

    final categoriesWithServices = activeCategories.where((category) {
      return services.any(
        (service) => serviceBelongsToCategory(service, category),
      );
    }).toList();

    if (categoriesWithServices.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: h * 0.025),
        child: customText(
          text: context.tr('لا توجد خدمات متاحة حالياً'),
          size: w * 0.035,
          color: Colors.grey,
        ),
      );
    }

    final visibleLimit = visibleCount > categoriesWithServices.length
        ? categoriesWithServices.length
        : visibleCount;

    final visibleCategories = categoriesWithServices
        .take(visibleLimit)
        .toList();
    final showActionCard = categoriesWithServices.length > 4;
    final isExpanded = visibleLimit >= categoriesWithServices.length;

    final cardWidth = responsiveSize(context, 0.43, min: 158, max: 210);
    final listHeight = responsiveHeight(context, 0.245, min: 178, max: 225);

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visibleCategories.length + (showActionCard ? 1 : 0),
        separatorBuilder: (_, __) =>
            SizedBox(width: responsiveSize(context, 0.028, min: 10, max: 12)),
        itemBuilder: (context, index) {
          if (index >= visibleCategories.length) {
            return SizedBox(
              width: cardWidth,
              child: _MoreCategoryCard(
                w: w,
                h: h,
                isExpanded: isExpanded,
                onTap: () => onToggleMore(categoriesWithServices.length),
              ),
            );
          }

          final category = visibleCategories[index];
          final categoryColor = colorFromHex(category.color);

          return SizedBox(
            width: cardWidth,
            child: serviceCard(
              title: category.name,
              description: context.tr(
                'اكتشفي الخدمات المتاحة وانضمي لما يناسبك',
              ),
              onTap: () {
                debugPrint('[Home] clicked category id=${category.id}');
                debugPrint('[Home] clicked category name=${category.name}');
                Navigator.pushNamed(
                  context,
                  '/servicesScreen',
                  arguments: {
                    'categoryId': category.id.trim(),
                    'title': category.name,
                    'subTitle': 'اختاري ما يناسبك وانضمي الآن',
                    'iconKey': category.iconKey.trim(),
                  },
                );
              },
              w: w,
              h: h,
              icon: iconFromKey(category.iconKey),
              primaryColor: categoryColor.withOpacity(0.20),
              secondaryColor: categoryColor,
              salesBackgroundColor: categoryColor.withOpacity(0.45),
            ),
          );
        },
      ),
    );
  }
}

class _MoreCategoryCard extends StatelessWidget {
  const _MoreCategoryCard({
    required this.w,
    required this.h,
    required this.isExpanded,
    required this.onTap,
  });

  final double w;
  final double h;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFE7549B);
    const secondColor = Color(0xFF9333EA);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(
          responsiveSize(context, 0.035, min: 12, max: 16),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: mainColor.withOpacity(0.22), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(0.14),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: responsiveSize(context, 0.16, min: 56, max: 70),
              height: responsiveSize(context, 0.16, min: 56, max: 70),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [mainColor, secondColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.add_rounded,
                color: Colors.white,
                size: responsiveSize(context, 0.075, min: 28, max: 36),
              ),
            ),
            SizedBox(
              height: responsiveHeight(context, 0.018, min: 12, max: 16),
            ),
            customText(
              text: isExpanded
                  ? context.tr('عرض أقل')
                  : context.tr('عرض المزيد'),
              size: w * 0.037,
              color: const Color(0xFF8A174A),
              bold: true,
              maxLines: 1,
            ),
            SizedBox(height: responsiveHeight(context, 0.008, min: 6, max: 9)),
            customText(
              text: isExpanded
                  ? context.tr('العودة لأول 4 فئات')
                  : context.tr('عرض 4 فئات إضافية'),
              size: w * 0.027,
              color: Colors.grey[600],
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _MyRequestsButton extends StatelessWidget {
  const _MyRequestsButton({
    required this.w,
    required this.h,
    required this.isSelected,
    required this.onTap,
  });

  final double w;
  final double h;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(34),
      child: Container(
        height: responsiveHeight(context, 0.065, min: 52, max: 62),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.045, min: 16, max: 22),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: const Color(0xFFE7549B).withOpacity(0.55),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE7549B).withOpacity(0.16),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFFE7549B),
              size: responsiveSize(context, 0.04, min: 16, max: 20),
            ),
            SizedBox(width: responsiveSize(context, 0.035, min: 12, max: 16)),
            customText(
              text: context.tr('طلباتي'),
              size: w * 0.038,
              color: const Color(0xFF8A174A),
              bold: true,
            ),
            SizedBox(width: responsiveSize(context, 0.035, min: 12, max: 16)),
            Container(
              width: responsiveSize(context, 0.1, min: 38, max: 46),
              height: responsiveSize(context, 0.1, min: 38, max: 46),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFE7549B), Color(0xFF9333EA)],
                ),
              ),
              child: Icon(
                Icons.assignment_rounded,
                color: Colors.white,
                size: responsiveSize(context, 0.05, min: 20, max: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
