import 'package:bahya_app/helper/base.dart';

import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final TextEditingController timeController = TextEditingController();

  final TextEditingController dateController = TextEditingController();

  bool isTravel = false;

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
        title: 'اضافة خدمه جديده',
        subTitle: 'مساعدة المحاربات في رحلتهن',
        isHome: false,
        icon: Icons.playlist_add_outlined,
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: getScreenHeight(context) * 0.15),
                serviceAddForm(
                  context: context,
                  timeController: timeController,
                  isTravel: isTravel,
                  onChanged: (value) {
                    setState(() {
                      isTravel = value == "رحلات و نزهات";
                    });
                  },
                ),
                SizedBox(height: getScreenHeight(context) * 0.02),
                Container(
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
                            text: "الخدمات المسجله",
                            size: w * 0.035,
                            color: Colors.black,
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/all_services');
                            },
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
                                    text: "عرض الكل",
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
                      registeredServiceTile(
                        w: w,
                        h: h,
                        title: "محو أمية مستوى ثالث",
                        location: "الرياض - حي العليا",
                        seats: "20 مقعد",
                        date: "20-10-2024",
                        time: "10:00 AM",
                        isTravel: false,
                        isSupport: false,
                        onMoreTap: () {},
                      ),
                      registeredServiceTile(
                        w: w,
                        h: h,
                        title: "محو أمية مستوى ثالث",
                        location: "الرياض - حي العليا",
                        seats: "20 مقعد",
                        date: "20-10-2024",
                        time: "10:00 AM",
                        isTravel: false,
                        isSupport: true,
                        onMoreTap: () {},
                      ),
                      registeredServiceTile(
                        w: w,
                        h: h,
                        title: "محو أمية مستوى ثالث",
                        location: "الرياض - حي العليا",
                        seats: "20 مقعد",
                        date: "20-10-2024",
                        time: "10:00 AM",
                        isTravel: true,
                        isSupport: false,
                        onMoreTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
