part of 'user_table.dart';

class _UserMobileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRefresh;

  const _UserMobileCard({required this.user, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorStateOfType<_UsersTableState>()!;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.014, min: 12, max: 16),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 14, max: 18)),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFF),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 18, max: 22),
        ),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              parent.userAvatar(context, user.name),
              SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
              Expanded(
                child: customText(
                  text: user.name,
                  size: responsiveSize(context, 0.011, min: 15, max: 18),
                  color: const Color(0xFF272044),
                  bold: true,
                  isEnglish: true,
                  isCenter: false,
                  maxLines: 1,
                ),
              ),
              _MoreButton(user: user, onRefresh: onRefresh),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
          customText(
            text: user.email,
            size: responsiveSize(context, 0.009, min: 12, max: 14),
            color: Colors.grey[700],
            isEnglish: true,
            isCenter: false,
            maxLines: 1,
          ),
          SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
          Wrap(
            spacing: responsiveSize(context, 0.01, min: 8, max: 12),
            runSpacing: responsiveHeight(context, 0.01, min: 8, max: 10),
            children: [
              parent.roleBadge(context, user.role),
              parent.statusBadge(context, user.isActive),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRefresh;

  const _MoreButton({required this.user, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final size = responsiveSize(context, 0.028, min: 36, max: 40);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showActionsDialog(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: const Color(0xFF4B4D8F),
          size: responsiveSize(context, 0.016, min: 19, max: 24),
        ),
      ),
    );
  }

  Future<void> _showActionsDialog(BuildContext context) async {
    final userCubit = context.read<UserCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return _ActionDialogCard(
          user: user,
          onEdit: () async {
            Navigator.pop(dialogContext);
            await Future.delayed(const Duration(milliseconds: 100));

            if (!dialogContext.mounted || !context.mounted) return;

            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _EditUserDialog(
                user: user,
                userCubit: userCubit,
                onRefresh: onRefresh,
              ),
            );
          },
          onStatus: () async {
            Navigator.pop(dialogContext);
            await Future.delayed(const Duration(milliseconds: 100));

            if (!context.mounted) return;

            await _confirmStatusChange(context, userCubit);
          },
          onReset: () async {
            Navigator.pop(dialogContext);
            await Future.delayed(const Duration(milliseconds: 100));

            if (!context.mounted) return;

            await _confirmResetPassword(context, userCubit);
          },
        );
      },
    );
  }

  Future<void> _confirmStatusChange(
    BuildContext context,
    UserCubit userCubit,
  ) async {
    final newStatus = !user.isActive;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _ConfirmDialogCard(
          icon: newStatus
              ? Icons.person_add_alt_1_rounded
              : Icons.person_off_rounded,
          title: newStatus
              ? localizedText(context, "تفعيل المستخدم")
              : localizedText(context, "تعطيل المستخدم"),
          message: newStatus
              ? "${localizedText(context, "هل تريد تفعيل")} ${user.name}?"
              : "${localizedText(context, "هل تريد تعطيل")} ${user.name}?",
          actionText: newStatus
              ? localizedText(context, "تفعيل")
              : localizedText(context, "تعطيل"),
          actionColor: newStatus ? Colors.green : Colors.red,
          onConfirm: () async {
            await userCubit.changeStatus(userId: user.id, isActive: newStatus);

            if (!context.mounted) return;

            onRefresh();

            customDialog(
              context: dialogContext,
              title: localizedText(context, "تم"),
              message: newStatus
                  ? localizedText(context, "تم تفعيل المستخدم بنجاح.")
                  : localizedText(context, "تم تعطيل المستخدم بنجاح."),
              isSuccess: true,
              onClose: () {
                Navigator.pop(dialogContext);
                Navigator.pop(dialogContext);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _confirmResetPassword(
    BuildContext context,
    UserCubit userCubit,
  ) async {
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return _BaseDialogCard(
              width: 430,
              icon: Icons.lock_reset_rounded,
              iconColor: Colors.deepPurple,
              title: localizedText(context, "إرسال رابط إعادة التعيين"),
              subtitle:
                  "${localizedText(context, "إرسال رابط إعادة التعيين إلى ")} ${user.email}?",
              child: Row(
                children: [
                  Expanded(
                    child: _DialogSecondaryButton(
                      text: localizedText(context, "الغاء"),
                      onTap: isLoading
                          ? null
                          : () => Navigator.pop(dialogContext),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogPrimaryButton(
                      text: localizedText(context, "ارسال"),
                      color: Colors.deepPurple,
                      isLoading: isLoading,
                      onTap: isLoading
                          ? null
                          : () async {
                              setDialogState(() => isLoading = true);

                              try {
                                await userCubit.sendResetLink(userId: user.id);

                                if (!dialogContext.mounted) return;
                                Navigator.pop(dialogContext);

                                if (!context.mounted) return;
                                customDialog(
                                  context: context,
                                  title: localizedText(context, "تم"),
                                  message: localizedText(
                                    context,
                                    "تم إرسال رابط إعادة تعيين كلمة المرور إلى البريد الإلكتروني للمستخدم.",
                                  ),
                                  isSuccess: true,
                                );
                              } catch (e) {
                                if (dialogContext.mounted) {
                                  setDialogState(() => isLoading = false);
                                }

                                if (!context.mounted) return;
                                customDialog(
                                  context: context,
                                  title: localizedText(context, "خطأ"),
                                  message: e.toString(),
                                  isError: true,
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
