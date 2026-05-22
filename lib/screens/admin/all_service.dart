import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/custom_searchbar.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  int selectedFilter = 0;
  int selectedPage = 1;

  final List<String> filters = ["الكل", "رحلات", "دعم نفسي", "تعليمية"];

  final List<Map<String, dynamic>> services = [
    {
      "title": "محو أمية مستوى ثالث",
      "type": "تعليمية",
      "location": "الرياض - حي العليا",
      "seats": "20 مقعد",
      "date": "20-10-2024",
      "time": "AM 10:00",
      "isTravel": false,
      "isSupport": false,
    },
    {
      "title": "جلسة دعم نفسي",
      "type": "دعم نفسي",
      "location": "الرياض - حي النخيل",
      "seats": "10 مقاعد",
      "date": "22-06-2024",
      "time": "AM 11:00",
      "isTravel": false,
      "isSupport": true,
    },
    {
      "title": "رحلة ترفيهية للحديقة",
      "type": "رحلات",
      "location": "الرياض - حي النخيل",
      "seats": "15 مقعد",
      "date": "25-10-2024",
      "time": "PM 03:00",
      "isTravel": true,
      "isSupport": false,
    },
    {
      "title": "استشارات نفسية فردية",
      "type": "دعم نفسي",
      "location": "جدة - حي السلامة",
      "seats": "8 مقاعد",
      "date": "22-10-2024",
      "time": "PM 04:00",
      "isTravel": false,
      "isSupport": true,
    },
    {
      "title": "دورة أساسيات الحاسب",
      "type": "تعليمية",
      "location": "الرياض - حي الملز",
      "seats": "25 مقعد",
      "date": "28-10-2024",
      "time": "AM 09:00",
      "isTravel": false,
      "isSupport": false,
    },
    {
      "title": "ورشة إدارة الضغوط",
      "type": "دعم نفسي",
      "location": "جدة - حي الشاطئ",
      "seats": "12 مقعد",
      "date": "30-10-2024",
      "time": "PM 09:04",
      "isTravel": false,
      "isSupport": true,
    },
    {
      "title": "رحلة ثقافية للمتحف",
      "type": "رحلات",
      "location": "الدمام - حي الفيصلية",
      "seats": "18 مقعد",
      "date": "02-11-2024",
      "time": "AM 08:30",
      "isTravel": true,
      "isSupport": false,
    },
    {
      "title": "دورة اللغة الإنجليزية",
      "type": "تعليمية",
      "location": "الرياض - حي الياسمين",
      "seats": "20 مقعد",
      "date": "05-11-2024",
      "time": "AM 10:00",
      "isTravel": false,
      "isSupport": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return Scaffold(
      appBar: customAppBar(
        context: context,
        preferredSize: Size.fromHeight(h * 0.12),
        title: "كل الخدمات",
        subTitle: "عرض جميع الخدمات المتاحة",
        isHome: false,
      ),
      backgroundColor: backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              CustomSearchBarWithFilter(
                hintText: "ابحث عن خدمة، موقع، نوع الخدمة...",
                onChanged: (value) {},
                onFilterTap: () {},
              ),

              SizedBox(height: 15),

              Row(
                children: List.generate(filters.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: filterButton(
                        w: w,
                        title: filters[index],
                        isSelected: selectedFilter == index,
                        onTap: () {
                          setState(() {
                            selectedFilter = index;
                          });
                        },
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: h * 0.02),

              Expanded(
                child: GridView.builder(
                  itemCount: services.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = services[index];

                    return serviceGridCard(
                      w: w,
                      h: h,
                      title: item["title"],
                      type: item["type"],
                      location: item["location"],
                      seats: item["seats"],
                      date: item["date"],
                      time: item["time"],
                      isTravel: item["isTravel"],
                      isSupport: item["isSupport"],
                      onMoreTap: () {},
                    );
                  },
                ),
              ),

              SizedBox(height: h * 0.01),

              // customText(
              //   text: "عرض 1 - 8 من 24 خدمة",
              //   size: w * 0.03,
              //   color: Colors.grey,
              // ),

              // SizedBox(height: h * 0.012),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     pageButton(
              //       w: w,
              //       child: Icons.arrow_back_ios_new_rounded,
              //       isIcon: true,
              //       isSelected: false,
              //       onTap: () {},
              //     ),
              //     pageButton(
              //       w: w,
              //       text: "1",
              //       isSelected: selectedPage == 1,
              //       onTap: () => setState(() => selectedPage = 1),
              //     ),
              //     pageButton(
              //       w: w,
              //       text: "2",
              //       isSelected: selectedPage == 2,
              //       onTap: () => setState(() => selectedPage = 2),
              //     ),
              //     pageButton(
              //       w: w,
              //       text: "3",
              //       isSelected: selectedPage == 3,
              //       onTap: () => setState(() => selectedPage = 3),
              //     ),
              //     pageButton(
              //       w: w,
              //       child: Icons.arrow_forward_ios_rounded,
              //       isIcon: true,
              //       isSelected: false,
              //       onTap: () {},
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget filterButton({
    required double w,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData icon = Icons.grid_view_rounded;
    Color mainColor = Colors.pink;
    Color lightColor = Colors.pink[50]!;
    if (title.contains("تعليم")) {
      icon = Icons.menu_book_rounded;
      mainColor = Colors.green[600]!;
      lightColor = Colors.green[100]!;
    } else if (title.contains("رحلات")) {
      icon = Icons.directions_bus_rounded;
      mainColor = Colors.blue[600]!;
      lightColor = Colors.blue[100]!;
    } else if (title.contains("دعم")) {
      icon = Icons.groups_rounded;
      mainColor = Colors.purple[600]!;
      lightColor = Colors.purple[100]!;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: lightColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? mainColor : lightColor.withOpacity(0.8),
            width: isSelected ? 1.2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: mainColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: mainColor, size: w * 0.04),
            SizedBox(width: w * 0.01),
            customText(
              text: title,
              size: w * 0.03,
              color: mainColor,
              bold: isSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget serviceGridCard({
    required double w,
    required double h,
    required String title,
    required String type,
    required String location,
    required String seats,
    required String date,
    required String time,
    required bool isTravel,
    required bool isSupport,
    required VoidCallback onMoreTap,
  }) {
    final Color mainColor = isTravel
        ? Colors.blue
        : (isSupport ? Colors.purple : Colors.green);

    final Color lightColor = mainColor.withOpacity(0.12);

    final IconData mainIcon = isTravel
        ? Icons.directions_bus_rounded
        : (isSupport ? Icons.groups_rounded : Icons.menu_book_rounded);

    return Container(
      padding: EdgeInsets.all(w * 0.025),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.08),
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
              Container(
                height: h * 0.055,
                width: h * 0.055,
                decoration: BoxDecoration(
                  color: lightColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(mainIcon, color: mainColor, size: w * 0.055),
              ),
              const Spacer(),
              IconButton(
                onPressed: onMoreTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.more_vert, color: mainColor, size: w * 0.055),
              ),
            ],
          ),

          SizedBox(height: h * 0.006),

          customText(
            text: title,
            size: w * 0.035,
            color: Colors.black,
            bold: true,
            maxLines: 2,
            isCenter: false,
          ),

          SizedBox(height: 5),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: mainColor,
                size: w * 0.035,
              ),
              SizedBox(width: 2),
              Expanded(
                child: customText(
                  text: location,
                  size: w * 0.026,
                  color: Colors.grey[600],
                  maxLines: 1,
                  isCenter: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          serviceSmallInfo(
            w: w,
            icon: Icons.groups_rounded,
            text: seats,
            color: mainColor,
          ),
          SizedBox(height: 5),
          serviceSmallInfo(
            w: w,
            icon: Icons.calendar_month_rounded,
            text: date,
            color: mainColor,
          ),
          SizedBox(height: 5),
          serviceSmallInfo(
            w: w,
            icon: Icons.access_time_rounded,
            text: time,
            color: mainColor,
          ),
        ],
      ),
    );
  }

  Widget serviceSmallInfo({
    required double w,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: w * 0.032),
        SizedBox(width: w * 0.01),
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
    );
  }

  // Widget pageButton({
  //   required double w,
  //   String? text,
  //   IconData? child,
  //   bool isIcon = false,
  //   required bool isSelected,
  //   required VoidCallback onTap,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 4),
  //     child: InkWell(
  //       onTap: onTap,
  //       borderRadius: BorderRadius.circular(10),
  //       child: Container(
  //         height: 34,
  //         width: 34,
  //         decoration: BoxDecoration(
  //           color: isSelected ? Colors.pink[300] : Colors.white,
  //           borderRadius: BorderRadius.circular(10),
  //           border: Border.all(color: Colors.grey.withOpacity(0.15)),
  //         ),
  //         child: Center(
  //           child: isIcon
  //               ? Icon(child, size: w * 0.035, color: Colors.grey)
  //               : customText(
  //                   text: text!,
  //                   size: w * 0.03,
  //                   color: isSelected ? Colors.white : Colors.grey,
  //                   bold: isSelected,
  //                 ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
