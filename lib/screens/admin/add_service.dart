import 'package:bahya_app/helper/base.dart';

import 'package:bahya_app/helper/widgets/constant.dart';
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
    return Scaffold(
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
                SizedBox(height: getScreenHeight(context) * 0.02),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

