part of 'user_table.dart';

class _EditUserDialog extends StatefulWidget {
  final UserModel user;
  final UserCubit userCubit;
  final VoidCallback onRefresh;

  const _EditUserDialog({
    required this.user,
    required this.userCubit,
    required this.onRefresh,
  });

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController roleController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    roleController = TextEditingController(text: widget.user.role);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    roleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => isSaving = true);

    try {
      await widget.userCubit.updateUserName(
        userId: widget.user.id,
        fullName: nameController.text.trim(),
      );

      if (!mounted) return;

      widget.onRefresh();

      customDialog(
        context: context,
        title: "Success",
        message: "User updated successfully.",
        isSuccess: true,
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      customDialog(
        context: context,
        title: "Error",
        message: e.toString(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BaseDialogCard(
      width: 540,
      icon: Icons.edit_rounded,
      title: "Edit User",
      subtitle: "Only full name can be edited.",
      child: Form(
        key: formKey,
        child: Column(
          children: [
            CustomFormTextField(
              controller: nameController,
              labelText: "Full Name",
              hintText: "Enter full name",
              keyboardType: CustomTextFieldType.name,
              textDirection: TextDirection.ltr,
              isRequired: true,
              bordered: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 14),
            CustomFormTextField(
              controller: emailController,
              labelText: "Email",
              hintText: "Email",
              keyboardType: CustomTextFieldType.email,
              textDirection: TextDirection.ltr,
              readOnly: true,
              isRequired: false,
              bordered: true,
              autovalidateMode: AutovalidateMode.disabled,
            ),
            const SizedBox(height: 14),
            CustomFormTextField(
              controller: roleController,
              labelText: "Role",
              hintText: "Role",
              keyboardType: CustomTextFieldType.text,
              textDirection: TextDirection.ltr,
              readOnly: true,
              isRequired: false,
              bordered: true,
              autovalidateMode: AutovalidateMode.disabled,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogSecondaryButton(
                    text: "Cancel",
                    onTap: isSaving ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogPrimaryButton(
                    text: "Save",
                    color: const Color(0xFFE40070),
                    isLoading: isSaving,
                    onTap: isSaving ? null : _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
