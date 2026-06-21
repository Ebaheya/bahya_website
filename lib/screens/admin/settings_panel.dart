import 'package:bahya_website/bloc/cubit/settings_cubit.dart';
import 'package:bahya_website/bloc/states/settings_state.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/admin_widgets/settings/settings_cards.dart';
import 'package:bahya_website/helper/admin_widgets/settings/settings_widgets.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(AppRepository())..loadData(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          responsiveSize(context, 0.015, min: 14, max: 26),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            responsiveSize(context, 0.018, min: 16, max: 28),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFD6EA)),
          ),
          child: Column(
            children: [
              const SettingsHeader(),
              SizedBox(
                height: responsiveHeight(context, 0.03, min: 20, max: 28),
              ),
              const AccountSettingsCard(),
              SizedBox(
                height: responsiveHeight(context, 0.026, min: 18, max: 24),
              ),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return SizedBox(
                      height: responsiveHeight(
                        context,
                        0.3,
                        min: 220,
                        max: 360,
                      ),
                      child: Center(child: customLoading()),
                    );
                  }

                  if (state.errorMessage != null) {
                    return Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    );
                  }

                  return const AuditLogsCard();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
