import 'package:bahya_website/bloc/cubit/user_cubit.dart';
import 'package:bahya_website/helper/admin_widgets/user/add_user.dart';
import 'package:bahya_website/helper/admin_widgets/page_header.dart';
import 'package:bahya_website/helper/admin_widgets/user/user_table.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isMobile = w < 650;

    return BlocProvider(
      create: (context) => UserCubit(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(
          responsiveSize(context, 0.014, min: 14, max: 22),
        ),
        child: Column(
          children: [
            pageHeader(
              context: context,
              title: "Users Management",
              subtitle: 'Manage and monitor all platform users',
              icon: Icons.people_rounded,
              widgets: [
                CustomGlowButton(
                  title: "Add User",
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const AddUserDialog(),
                    );
                  },
                  textSize: responsiveSize(context, 0.009, min: 12, max: 15),
                  textColor: textColor,
                  glowColor: Colors.white,
                  width: isMobile
                      ? responsiveSize(context, 0.35, min: 135, max: 180)
                      : responsiveSize(context, 0.1, min: 120, max: 170),
                  height: responsiveHeight(context, 0.052, min: 42, max: 50),
                  borderRadius: responsiveSize(
                    context,
                    0.012,
                    min: 12,
                    max: 18,
                  ),
                ),
              ],
            ),

            SizedBox(
              height: responsiveHeight(context, 0.025, min: 16, max: 24),
            ),

            const UsersTable(),
          ],
        ),
      ),
    );
  }
}
