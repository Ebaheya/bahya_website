import 'package:bahya_app/data/models/service_models.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_dropDown.dart';
import 'package:bahya_app/helper/custom_form_textfield.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/custom_searchbar.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/helper/service_formatters.dart';
import 'package:bahya_app/helper/heart_pull_refresh.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/service_admin_cubit.dart';
import 'package:bahya_app/logic/state/service_admin_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen>
    with TickerProviderStateMixin {
  String? selectedCategoryId;
  String query = '';

  int visibleServicesCount = 5;
  int visibleCategoriesCount = 8;

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<ServiceAdminCubit, ServiceAdminState>(
        builder: (context, state) {
          final isPageReady =
              !state.isLoading &&
              state.categories.isNotEmpty &&
              state.services.isNotEmpty;

          final filteredServices = isPageReady
              ? _filteredServices(state.services)
              : <PatientServiceModel>[];
          final visibleServices = filteredServices
              .take(visibleServicesCount)
              .toList();

          return HeartPullRefreshScrollView(
            onRefresh: () async {
              await context.read<ServiceAdminCubit>().loadDashboard();
            },
            slivers: [
              SliverToBoxAdapter(
                child: Directionality(
                  textDirection: context.appTextDirection,
                  child: Column(
                    children: [
                      customAppBar(
                        context: context,
                        preferredSize: Size.fromHeight(h * 0.12),
                        title: context.tr('كل الخدمات'),
                        subTitle: context.tr('عرض جميع الخدمات المتاحة'),
                        isHome: false,
                      ),
                      if (!isPageReady)
                        SizedBox(
                          width: w,
                          height: h * 0.65,
                          child: Center(child: customLoading()),
                        )
                      else
                        SizedBox(
                          height: h - (h * 0.12),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsiveSize(
                                context,
                                0.02,
                                min: 8,
                                max: 18,
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.02,
                                    min: 12,
                                    max: 18,
                                  ),
                                ),
                                CustomSearchBarWithFilter(
                                  hintText: context.tr(
                                    'ابحث عن خدمة، موقع، نوع الخدمة...',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      query = value.trim();
                                      visibleServicesCount = 5;
                                    });
                                  },
                                  onSearchTap: () {
                                    FocusScope.of(context).unfocus();
                                  },
                                  onFilterTap: () {
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.018,
                                    min: 12,
                                    max: 16,
                                  ),
                                ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                  child: _CategoryFilters(
                                    w: w,
                                    categories: state.categories,
                                    selectedCategoryId: selectedCategoryId,
                                    visibleCategoriesCount:
                                        visibleCategoriesCount,
                                    onSelected: (id) {
                                      setState(() {
                                        selectedCategoryId = id;
                                        visibleServicesCount = 5;
                                      });
                                    },
                                    onShowMoreCategories: () {
                                      setState(() {
                                        if (visibleCategoriesCount >=
                                            state.categories.length) {
                                          visibleCategoriesCount = 8;
                                        } else {
                                          visibleCategoriesCount += 8;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: filteredServices.isEmpty
                                      ? Center(
                                          child: customText(
                                            text: context.tr(
                                              'لا توجد خدمات متاحة حالياً',
                                            ),
                                            size: w * 0.04,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            Expanded(
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                switchInCurve:
                                                    Curves.easeOutCubic,
                                                switchOutCurve:
                                                    Curves.easeInCubic,
                                                child: LayoutBuilder(
                                                  key: ValueKey(
                                                    '${selectedCategoryId ?? 'all'}-$query-$visibleServicesCount-${visibleServices.length}',
                                                  ),
                                                  builder: (
                                                    context,
                                                    constraints,
                                                  ) {
                                                    final crossAxisCount =
                                                        constraints.maxWidth >
                                                            700
                                                        ? 3
                                                        : 2;

                                                    return GridView.builder(
                                                      padding: EdgeInsets.only(
                                                        top: responsiveHeight(
                                                          context,
                                                          0.025,
                                                          min: 14,
                                                          max: 24,
                                                        ),
                                                        bottom:
                                                            responsiveHeight(
                                                          context,
                                                          0.02,
                                                          min: 14,
                                                          max: 28,
                                                        ),
                                                      ),
                                                      itemCount:
                                                          visibleServices.length,
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount:
                                                            crossAxisCount,
                                                        crossAxisSpacing:
                                                            responsiveSize(
                                                          context,
                                                          0.035,
                                                          min: 12,
                                                          max: 18,
                                                        ),
                                                        mainAxisSpacing:
                                                            responsiveHeight(
                                                          context,
                                                          0.018,
                                                          min: 12,
                                                          max: 18,
                                                        ),
                                                        childAspectRatio:
                                                            constraints
                                                                        .maxWidth >
                                                                    700
                                                                ? 1.18
                                                                : 0.92,
                                                      ),
                                                      itemBuilder:
                                                          (context, index) {
                                                        final service =
                                                            visibleServices[
                                                                index];
                                                        final category =
                                                            _categoryForService(
                                                          service,
                                                          state.categories,
                                                        );

                                                        return TweenAnimationBuilder<
                                                            double>(
                                                          key: ValueKey(
                                                            service.id,
                                                          ),
                                                          tween: Tween(
                                                            begin: 0,
                                                            end: 1,
                                                          ),
                                                          duration: Duration(
                                                            milliseconds:
                                                                220 +
                                                                    (index *
                                                                        35),
                                                          ),
                                                          curve: Curves
                                                              .easeOutCubic,
                                                          builder: (
                                                            context,
                                                            value,
                                                            child,
                                                          ) {
                                                            return Opacity(
                                                              opacity: value,
                                                              child: Transform
                                                                  .translate(
                                                                offset: Offset(
                                                                  0,
                                                                  18 *
                                                                      (1 -
                                                                          value),
                                                                ),
                                                                child: child,
                                                              ),
                                                            );
                                                          },
                                                          child:
                                                              _ServiceGridCard(
                                                            w: w,
                                                            h: h,
                                                            service: service,
                                                            category: category,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            if (visibleServicesCount <
                                                filteredServices.length)
                                              _ShowMoreServicesButton(
                                                w: w,
                                                onTap: () {
                                                  setState(() {
                                                    visibleServicesCount += 5;
                                                  });
                                                },
                                              ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
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

  List<PatientServiceModel> _filteredServices(
    List<PatientServiceModel> services,
  ) {
    return services.where((service) {
      final matchesCategory =
          selectedCategoryId == null ||
          service.categoryId == selectedCategoryId;

      final searchText =
          '${service.title} ${service.location} ${service.category?.name ?? ''}'
              .toLowerCase();

      final matchesSearch =
          query.isEmpty || searchText.contains(query.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  ServiceCategoryModel? _categoryForService(
    PatientServiceModel service,
    List<ServiceCategoryModel> categories,
  ) {
    for (final category in categories) {
      if (category.id == service.categoryId) {
        return category;
      }
    }
    return service.category;
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.w,
    required this.categories,
    required this.selectedCategoryId,
    required this.visibleCategoriesCount,
    required this.onSelected,
    required this.onShowMoreCategories,
  });

  final double w;
  final List<ServiceCategoryModel> categories;
  final String? selectedCategoryId;
  final int visibleCategoriesCount;
  final ValueChanged<String?> onSelected;
  final VoidCallback onShowMoreCategories;

  @override
  Widget build(BuildContext context) {
    final visibleCategories = categories.take(visibleCategoriesCount).toList();
    final hasMore = categories.length > 8;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChipButton(
            w: w,
            title: context.tr('الكل'),
            icon: Icons.apps_rounded,
            color: Colors.pink,
            isSelected: selectedCategoryId == null,
            onTap: () => onSelected(null),
          ),
          for (final category in visibleCategories)
            _FilterChipButton(
              w: w,
              title: category.name,
              icon: iconFromKey(category.iconKey),
              color: colorFromHex(category.color),
              isSelected: selectedCategoryId == category.id,
              onTap: () => onSelected(category.id),
            ),
          if (hasMore)
            _MoreCategoryButton(
              w: w,
              expanded: visibleCategoriesCount >= categories.length,
              onTap: onShowMoreCategories,
            ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.w,
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final double w;
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.01, min: 4, max: 7),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(
            minWidth: responsiveSize(context, 0.18, min: 82, max: 145),
          ),
          height: responsiveHeight(context, 0.047, min: 38, max: 46),
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.025, min: 10, max: 16),
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(isSelected ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.25),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 17),
              SizedBox(width: responsiveSize(context, 0.014, min: 5, max: 8)),
              Flexible(
                child: customText(
                  text: title,
                  size: w * 0.03,
                  color: color,
                  bold: isSelected,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreCategoryButton extends StatelessWidget {
  const _MoreCategoryButton({
    required this.w,
    required this.expanded,
    required this.onTap,
  });

  final double w;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.01, min: 4, max: 7),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: responsiveHeight(context, 0.048, min: 40, max: 48),
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.035, min: 14, max: 20),
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE7549B), Color(0xFF9333EA)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE7549B).withOpacity(0.20),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: responsiveSize(context, 0.012, min: 5, max: 8)),
              customText(
                text: expanded
                    ? context.tr('عرض أقل')
                    : context.tr('عرض المزيد'),
                size: w * 0.03,
                color: Colors.white,
                bold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShowMoreServicesButton extends StatelessWidget {
  const _ShowMoreServicesButton({required this.w, required this.onTap});

  final double w;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.018, min: 12, max: 20),
        top: responsiveHeight(context, 0.01, min: 6, max: 12),
      ),
      child: Center(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.055, min: 20, max: 30),
              vertical: responsiveHeight(context, 0.014, min: 10, max: 14),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE7549B), Color(0xFF9333EA)],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE7549B).withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                customText(
                  text: context.tr('عرض المزيد'),
                  size: w * 0.032,
                  color: Colors.white,
                  bold: true,
                ),
                SizedBox(
                  width: responsiveSize(context, 0.018, min: 6, max: 10),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceGridCard extends StatelessWidget {
  const _ServiceGridCard({
    required this.w,
    required this.h,
    required this.service,
    required this.category,
  });

  final double w;
  final double h;
  final PatientServiceModel service;
  final ServiceCategoryModel? category;

  @override
  Widget build(BuildContext context) {
    final mainColor = colorFromHex(category?.color ?? '#E7549B');
    final mainIcon = iconFromKey(category?.iconKey ?? 'category');

    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.025, min: 10, max: 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: mainColor.withOpacity(0.12),
                child: Icon(mainIcon, color: mainColor),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) {
                      return BlocProvider.value(
                        value: context.read<ServiceAdminCubit>(),
                        child: EditServiceBottomSheet(
                          w: w,
                          h: h,
                          service: service,
                          category: category,
                          mainColor: mainColor,
                          mainIcon: mainIcon,
                        ),
                      );
                    },
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(
                    responsiveSize(context, 0.015, min: 6, max: 9),
                  ),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: mainColor,
                    size: w * 0.055,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.008, min: 5, max: 9)),
          customText(
            text: service.title,
            size: w * 0.035,
            color: Colors.black,
            bold: true,
            maxLines: 2,
            isCenter: false,
          ),
          SizedBox(height: responsiveHeight(context, 0.006, min: 4, max: 7)),
          _SmallInfo(
            w: w,
            icon: Icons.location_on_outlined,
            text: service.location,
            color: mainColor,
          ),
          _SmallInfo(
            w: w,
            icon: Icons.groups_rounded,
            text: formatSeatsAvailable(context, service.remainingSeats),
            color: mainColor,
          ),
          _SmallInfo(
            w: w,
            icon: Icons.calendar_month_rounded,
            text: formatServiceDate(context, service.date),
            color: mainColor,
          ),
          _SmallInfo(
            w: w,
            icon: Icons.access_time_rounded,
            text: formatServiceTime(context, service.time),
            color: mainColor,
          ),
        ],
      ),
    );
  }
}

class EditServiceBottomSheet extends StatefulWidget {
  const EditServiceBottomSheet({
    super.key,
    required this.w,
    required this.h,
    required this.service,
    required this.category,
    required this.mainColor,
    required this.mainIcon,
  });

  final double w;
  final double h;
  final PatientServiceModel service;
  final ServiceCategoryModel? category;
  final Color mainColor;
  final IconData mainIcon;

  @override
  State<EditServiceBottomSheet> createState() => _EditServiceBottomSheetState();
}

class _EditServiceBottomSheetState extends State<EditServiceBottomSheet> {
  late final TextEditingController nameController;
  late final TextEditingController locationController;
  late final TextEditingController capacityController;

  late String status;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.service.title);
    locationController = TextEditingController(text: widget.service.location);
    capacityController = TextEditingController(
      text: widget.service.capacity.toString(),
    );

    status = widget.service.status.trim().isNotEmpty
        ? widget.service.status.trim().toUpperCase()
        : 'ACTIVE';
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    final location = locationController.text.trim();
    final capacity = int.tryParse(capacityController.text.trim());

    if (name.isEmpty || location.isEmpty || capacity == null || capacity <= 0) {
      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr('يرجى إدخال بيانات صحيحة.'),
        isError: true,
      );
      return;
    }

    await context.read<ServiceAdminCubit>().updateService(
      serviceId: widget.service.id,
      data: {
        'name': name,
        'locationBranch': location,
        'capacity': capacity,
        'status': status,
      },
    );

    if (!mounted) return;

    final state = context.read<ServiceAdminCubit>().state;

    if (state.error != null) {
      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr(state.error!),
        isError: true,
      );
      return;
    }

    Navigator.pop(context);

    customDialog(
      context: context,
      title: context.tr('تم الحفظ'),
      message: context.tr('تم تعديل بيانات الخدمة بنجاح.'),
      isSuccess: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: EdgeInsets.all(
          responsiveSize(context, 0.045, min: 16, max: 24),
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: BlocBuilder<ServiceAdminCubit, ServiceAdminState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Directionality(
                textDirection: context.appTextDirection,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: responsiveSize(context, 0.13, min: 42, max: 56),
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    SizedBox(height: responsiveHeight(context, 0.02)),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: responsiveSize(
                            context,
                            0.06,
                            min: 24,
                            max: 34,
                          ),
                          backgroundColor: widget.mainColor.withOpacity(0.12),
                          child: Icon(widget.mainIcon, color: widget.mainColor),
                        ),
                        SizedBox(width: responsiveSize(context, 0.03)),
                        Expanded(
                          child: customText(
                            text: context.tr('تعديل بيانات الخدمة'),
                            size: responsiveSize(
                              context,
                              0.045,
                              min: 18,
                              max: 24,
                            ),
                            color: Colors.black,
                            bold: true,
                            isCenter: false,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: responsiveHeight(context, 0.025)),

                    CustomFormTextField(
                      controller: nameController,
                      labelText: context.tr('اسم الخدمة'),
                      hintText: context.tr('اكتب اسم الخدمة'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: CustomTextFieldType.text,
                      borderRadius: 16,
                      prefixIcon: Icon(
                        Icons.edit_rounded,
                        color: widget.mainColor,
                      ),
                    ),

                    SizedBox(height: responsiveHeight(context, 0.018)),

                    CustomFormTextField(
                      controller: locationController,
                      labelText: context.tr('الموقع أو الفرع'),
                      hintText: context.tr('اكتب الموقع أو الفرع'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: CustomTextFieldType.text,
                      borderRadius: 16,
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: widget.mainColor,
                      ),
                    ),

                    SizedBox(height: responsiveHeight(context, 0.018)),

                    CustomFormTextField(
                      controller: capacityController,
                      labelText: context.tr('عدد المقاعد'),
                      hintText: context.tr('اكتب عدد المقاعد'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: CustomTextFieldType.number,
                      borderRadius: 16,
                      prefixIcon: Icon(
                        Icons.groups_rounded,
                        color: widget.mainColor,
                      ),
                    ),

                    SizedBox(height: responsiveHeight(context, 0.018)),

                    customDropdown(
                      context: context,
                      value: status,
                      hint: context.tr('حالة الخدمة'),
                      items: const ['ACTIVE', 'CLOSED'],
                      icon: Icons.flag_outlined,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => status = value);
                      },
                    ),

                    SizedBox(height: responsiveHeight(context, 0.03)),

                    InkWell(
                      onTap: state.isSaving ? null : _save,
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        width: double.infinity,
                        height: responsiveHeight(
                          context,
                          0.06,
                          min: 48,
                          max: 58,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [widget.mainColor, const Color(0xFF9333EA)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: widget.mainColor.withOpacity(0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: responsiveHeight(
                            context,
                            0.06,
                            min: 48,
                            max: 58,
                          ),
                          child: ElevatedButton(
                            onPressed: state.isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              elevation: 8,
                              backgroundColor: widget.mainColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: customText(
                              text: context.tr(
                                state.isSaving
                                    ? 'جارٍ الحفظ...'
                                    : 'حفظ التعديلات',
                              ),
                              size: responsiveSize(
                                context,
                                0.035,
                                min: 15,
                                max: 18,
                              ),
                              color: Colors.white,
                              bold: true,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: responsiveHeight(context, 0.015)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({
    required this.w,
    required this.icon,
    required this.text,
    required this.color,
  });

  final double w;
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: responsiveHeight(context, 0.006, min: 4, max: 7),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: w * 0.032),
          SizedBox(width: responsiveSize(context, 0.01, min: 4, max: 7)),
          Expanded(
            child: customText(
              text: text,
              size: w * 0.025,
              color: Colors.grey[700],
              maxLines: 1,
              isCenter: false,
            ),
          ),
        ],
      ),
    );
  }
}
