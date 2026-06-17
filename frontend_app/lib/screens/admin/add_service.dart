import 'package:bahya_app/data/models/service_models.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_date_picker.dart';
import 'package:bahya_app/helper/custom_form_textfield.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/custom_time_picker.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/helper/service_formatters.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/service_admin_cubit.dart';
import 'package:bahya_app/logic/state/service_admin_state.dart';
import 'package:bahya_app/screens/admin/all_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bahya_app/helper/custom_loading.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final startDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final capacityController = TextEditingController();
  final endDateController = TextEditingController();
  final departureTimeController = TextEditingController();
  final meetingPlaceController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    capacityController.dispose();
    endDateController.dispose();
    departureTimeController.dispose();
    meetingPlaceController.dispose();
    super.dispose();
  }

  bool _isTripCategory(ServiceCategoryModel? category) {
    return category?.kind.toUpperCase() == 'TRIP';
  }

  Future<void> _submit(ServiceCategoryModel? selectedCategory) async {
    final category = selectedCategory;
    final capacity = int.tryParse(capacityController.text.trim());
    final isTrip = _isTripCategory(category);

    if (category == null ||
        nameController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        startDateController.text.trim().isEmpty ||
        startTimeController.text.trim().isEmpty ||
        capacity == null) {
      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr('يرجى إدخال بيانات الخدمة المطلوبة.'),
        isError: true,
      );
      return;
    }

    if (capacity <= 0) {
      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr('عدد المقاعد يجب أن يكون أكبر من صفر.'),
        isError: true,
      );
      return;
    }

    if (isTrip &&
        (endDateController.text.trim().isEmpty ||
            departureTimeController.text.trim().isEmpty ||
            meetingPlaceController.text.trim().isEmpty)) {
      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr(
          'يرجى إدخال تاريخ النهاية ومكان التجمع ووقت الانطلاق للرحلة.',
        ),
        isError: true,
      );
      return;
    }

    await context.read<ServiceAdminCubit>().createService({
      'categoryId': category.id,
      'name': nameController.text.trim(),
      'locationBranch': locationController.text.trim(),
      'startDate': _apiDate(startDateController.text),
      'startTime': _apiTime(startTimeController.text),
      'capacity': capacity,
      'endDate': isTrip ? _apiDate(endDateController.text) : null,
      'departureTime': isTrip ? _apiTime(departureTimeController.text) : null,
      'meetingPlace': isTrip ? meetingPlaceController.text.trim() : null,
    });

    if (!mounted) return;

    final state = context.read<ServiceAdminCubit>().state;

    customDialog(
      context: context,
      title: state.error == null ? context.tr('تم الحفظ') : context.tr('خطأ'),
      message: state.error ?? context.tr('تم حفظ الخدمة بنجاح.'),
      isSuccess: state.error == null,
      isError: state.error != null,
    );
  }

  String _apiDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return value;
    final month = parts[0].padLeft(2, '0');
    final day = parts[1].padLeft(2, '0');
    return '${parts[2]}-$month-$day';
  }

  String _apiTime(String value) {
    final trimmed = value.trim();
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$').firstMatch(trimmed);
    if (match == null) return trimmed;

    var hour = int.parse(match.group(1)!);
    final minute = match.group(2)!;
    final period = match.group(3)!;

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: customAppBar(
        context: context,
        title: context.tr('اضافة خدمه جديده'),
        subTitle: context.tr('مساعدة المحاربات في رحلتهن'),
        isHome: false,
        icon: Icons.playlist_add_outlined,
      ),
      body: BlocBuilder<ServiceAdminCubit, ServiceAdminState>(
        builder: (context, state) {
          final bool isPageReady =
              !state.isLoading && state.categories.isNotEmpty;

          if (!isPageReady) {
            return SizedBox(
              height: h,
              width: w,
              child: Center(child: customLoading()),
            );
          }

          final selectedCategory =
              state.selectedCategory ??
              (state.categories.isNotEmpty ? state.categories.first : null);

          return SingleChildScrollView(
            child: Directionality(
              textDirection: context.appTextDirection,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: h * 0.15),
                    _ServiceFormCard(
                      w: w,
                      h: h,
                      categories: state.categories,
                      selectedCategory: selectedCategory,
                      onCategoryChanged: (category) {
                        context.read<ServiceAdminCubit>().selectCategory(
                          category,
                        );

                        if (category?.kind.toUpperCase() != 'TRIP') {
                          endDateController.clear();
                          departureTimeController.clear();
                          meetingPlaceController.clear();
                        }
                      },
                      nameController: nameController,
                      locationController: locationController,
                      startDateController: startDateController,
                      startTimeController: startTimeController,
                      capacityController: capacityController,
                      endDateController: endDateController,
                      departureTimeController: departureTimeController,
                      meetingPlaceController: meetingPlaceController,
                      isSaving: state.isSaving,
                      onSubmit: () => _submit(selectedCategory),
                    ),
                    SizedBox(height: h * 0.02),
                    _RegisteredServices(
                      w: w,
                      h: h,
                      services: state.services,
                      categories: state.categories,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ServiceFormCard extends StatelessWidget {
  const _ServiceFormCard({
    required this.w,
    required this.h,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.nameController,
    required this.locationController,
    required this.startDateController,
    required this.startTimeController,
    required this.capacityController,
    required this.endDateController,
    required this.departureTimeController,
    required this.meetingPlaceController,
    required this.isSaving,
    required this.onSubmit,
  });

  final double w;
  final double h;
  final List<ServiceCategoryModel> categories;
  final ServiceCategoryModel? selectedCategory;
  final ValueChanged<ServiceCategoryModel?> onCategoryChanged;
  final TextEditingController nameController;
  final TextEditingController locationController;
  final TextEditingController startDateController;
  final TextEditingController startTimeController;
  final TextEditingController capacityController;
  final TextEditingController endDateController;
  final TextEditingController departureTimeController;
  final TextEditingController meetingPlaceController;
  final bool isSaving;
  final VoidCallback onSubmit;

  bool get isTrip => selectedCategory?.kind.toUpperCase() == 'TRIP';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<ServiceCategoryModel>(
            value: selectedCategory,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.tr('اختر نوع الخدمه'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(
                          _iconFromKey(category.iconKey),
                          color: _colorFromHex(category.color),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'ArabicCustomFont',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: category.kind.toUpperCase() == 'TRIP'
                                ? Colors.blue.withOpacity(0.10)
                                : Colors.purple.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            category.kind.toUpperCase() == 'TRIP'
                                ? context.tr('رحلة')
                                : context.tr('أخرى'),
                            style: TextStyle(
                              fontFamily: 'ArabicCustomFont',
                              fontSize: 11,
                              color: category.kind.toUpperCase() == 'TRIP'
                                  ? Colors.blue
                                  : Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: onCategoryChanged,
          ),

          SizedBox(height: h * 0.018),

          CustomFormTextField(
            controller: nameController,
            hintText: context.tr('اسم الخدمه مثال: محو الاميه المستوى الاول'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: CustomTextFieldType.text,
            borderRadius: 14,
            prefixIcon: const Icon(
              Icons.local_offer_outlined,
              color: Color(0xFFEA4C89),
            ),
          ),

          SizedBox(height: h * 0.018),

          Row(
            children: [
              Expanded(
                child: CustomDatePickerField(
                  hintText: context.tr('تاريخ الخدمه'),
                  controller: startDateController,
                  borderRadius: 14,
                  firstAllowedDate: DateTime.now().add(Duration(days: 1)),
                ),
              ),
              SizedBox(width: w * 0.035),
              Expanded(
                child: CustomTimePickerField(
                  borderRadius: 14,
                  labelText: null,
                  hintText: context.tr('الوقت'),
                  controller: startTimeController,
                ),
              ),
            ],
          ),

          SizedBox(height: h * 0.018),

          CustomFormTextField(
            controller: locationController,
            hintText: context.tr('الموقع او الفرع : مثال: الرياض - حي النخيل'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: CustomTextFieldType.text,
            borderRadius: 14,
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFFEA4C89),
            ),
          ),

          SizedBox(height: h * 0.018),

          CustomFormTextField(
            controller: capacityController,
            hintText: context.tr('عدد المقاعد المتوفره : مثال: 10 مقاعد'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: CustomTextFieldType.number,
            borderRadius: 14,
            prefixIcon: const Icon(
              Icons.groups_rounded,
              color: Color(0xFFEA4C89),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: isTrip
                ? Column(
                    children: [
                      SizedBox(height: h * 0.022),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_bus_rounded,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: customText(
                                text: context.tr(
                                  'بيانات إضافية مطلوبة للرحلات',
                                ),
                                size: w * 0.035,
                                color: Colors.blue,
                                bold: true,
                                isCenter: false,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.018),

                      CustomDatePickerField(
                        hintText: context.tr('تاريخ النهايه'),
                        controller: endDateController,
                        borderRadius: 14,
                      ),

                      SizedBox(height: h * 0.018),

                      CustomFormTextField(
                        controller: meetingPlaceController,
                        hintText: context.tr(
                          'مكان التجمع : مثال: الرياض - حي النخيل',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: CustomTextFieldType.text,
                        borderRadius: 14,
                        isRequired: false,
                        prefixIcon: const Icon(
                          Icons.directions_bus_rounded,
                          color: Color(0xFFEA4C89),
                        ),
                      ),

                      SizedBox(height: h * 0.018),

                      CustomTimePickerField(
                        borderRadius: 14,
                        labelText: null,
                        hintText: context.tr('وقت الانطلاق'),
                        controller: departureTimeController,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: h * 0.025),

          CustomGlowButton(
            width: double.infinity,
            height: h * 0.06,
            borderRadius: 18,
            title: isSaving
                ? context.tr('جاري الحفظ...')
                : context.tr('اضافة الخدمه'),
            onPressed: isSaving ? () {} : onSubmit,
            isGradient: true,
          ),
        ],
      ),
    );
  }
}

class _RegisteredServices extends StatelessWidget {
  const _RegisteredServices({
    required this.w,
    required this.h,
    required this.services,
    required this.categories,
  });

  final double w;
  final double h;
  final List<PatientServiceModel> services;
  final List<ServiceCategoryModel> categories;

  ServiceCategoryModel? _categoryForService(PatientServiceModel service) {
    for (final category in categories) {
      if (category.id == service.categoryId) {
        return category;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              customText(
                text: context.tr('الخدمات المسجله'),
                size: w * 0.035,
                color: Colors.black,
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/all_services'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.purple,
                        size: 16,
                      ),
                      customText(
                        text: context.tr('عرض الكل'),
                        size: w * 0.03,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (services.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: h * 0.03),
              child: customText(
                text: context.tr('لا توجد خدمات متاحة حالياً'),
                size: w * 0.035,
                color: Colors.grey,
              ),
            ),
          for (final service in services.take(3))
            Builder(
              builder: (context) {
                final category = _categoryForService(service);

                final mainColor = category == null
                    ? const Color(0xFFE7549B)
                    : _colorFromHex(category.color);

                final mainIcon = _iconFromKey(category?.iconKey ?? 'category');

                return registeredServiceTile(
                  w: w,
                  h: h,
                  title: service.title,
                  location: service.location,
                  seats: formatSeatsAvailable(context, service.remainingSeats),
                  date: formatServiceDate(context, service.date),
                  time: formatServiceTime(context, service.time),
                  categoryColor: mainColor,
                  iconKey: category?.iconKey,
                  onMoreTap: () {
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
                );
              },
            ),
        ],
      ),
    );
  }
}

Color _colorFromHex(String hex) {
  final value = hex.replaceAll('#', '');
  final parsed = int.tryParse('FF$value', radix: 16);
  return Color(parsed ?? 0xFFE7549B);
}

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
