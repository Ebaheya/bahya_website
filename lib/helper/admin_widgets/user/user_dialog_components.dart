part of 'user_table.dart';

class _ActionDialogCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onStatus;
  final VoidCallback onReset;

  const _ActionDialogCard({
    required this.user,
    required this.onEdit,
    required this.onStatus,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseDialogCard(
      width: 450,
      icon: Icons.manage_accounts_rounded,
      title: localizedText(context, "User Actions"),
      subtitle: user.email,
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.edit_rounded,
            title: localizedText(context, "Edit User"),
            subtitle: localizedText(context, "Edit full name only"),
            color: const Color(0xFFE40070),
            onTap: onEdit,
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: user.isActive
                ? Icons.person_off_rounded
                : Icons.person_add_alt_1_rounded,
            title: user.isActive
                ? localizedText(context, "Deactivate User")
                : localizedText(context, "Activate User"),
            subtitle: user.isActive
                ? localizedText(context, "Disable account access")
                : localizedText(context, "Enable account access"),
            color: user.isActive ? Colors.red : Colors.green,
            onTap: onStatus,
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.lock_reset_rounded,
            title: localizedText(context, "Send Reset Link"),
            subtitle: localizedText(context, "Send password reset email"),
            color: Colors.deepPurple,
            onTap: onReset,
          ),
          const SizedBox(height: 18),
          _DialogSecondaryButton(
            text: localizedText(context, "Close"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _ConfirmDialogCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionText;
  final Color actionColor;
  final Future<void> Function() onConfirm;

  const _ConfirmDialogCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionText,
    required this.actionColor,
    required this.onConfirm,
  });

  @override
  State<_ConfirmDialogCard> createState() => _ConfirmDialogCardState();
}

class _ConfirmDialogCardState extends State<_ConfirmDialogCard> {
  bool isLoading = false;

  Future<void> _confirm() async {
    setState(() => isLoading = true);

    try {
      await widget.onConfirm();

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

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
      width: 430,
      icon: widget.icon,
      iconColor: widget.actionColor,
      title: widget.title,
      subtitle: widget.message,
      child: Row(
        children: [
          Expanded(
            child: _DialogSecondaryButton(
              text: "Cancel",
              onTap: isLoading ? null : () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DialogPrimaryButton(
              text: widget.actionText,
              color: widget.actionColor,
              isLoading: isLoading,
              onTap: isLoading ? null : _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

class _BaseDialogCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;

  const _BaseDialogCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.iconColor = const Color(0xFFE40070),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.02, min: 16, max: 28),
      ),
      child: Container(
        width: width,
        padding: EdgeInsets.all(
          responsiveSize(context, 0.018, min: 18, max: 28),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFD6EA)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A004C).withValues(alpha: 0.14),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogTopIcon(icon: icon, color: iconColor),
              const SizedBox(height: 14),
              customText(
                text: title,
                size: 23,
                bold: true,
                color: const Color(0xFF7A004C),
                isEnglish: true,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                customText(
                  text: subtitle!,
                  size: 13,
                  color: Colors.grey.shade600,
                  isEnglish: true,
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogTopIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _DialogTopIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.9), const Color(0xFFFF5FA2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: Colors.white, size: 34),
    );
  }
}

class _DialogPrimaryButton extends StatelessWidget {
  final String text;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _DialogPrimaryButton({
    required this.text,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: onTap == null ? color.withValues(alpha: 0.45) : color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(width: 22, height: 22, child: customLoading())
                : customText(
                    text: text,
                    size: 14,
                    bold: true,
                    color: Colors.white,
                    isEnglish: true,
                  ),
          ),
        ),
      ),
    );
  }
}

class _DialogSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _DialogSecondaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: onTap == null
                  ? Colors.grey.withValues(alpha: 0.18)
                  : const Color(0xFFFF9BD0),
            ),
          ),
          child: Center(
            child: customText(
              text: text,
              size: 14,
              bold: true,
              color: onTap == null ? Colors.grey : const Color(0xFFE40070),
              isEnglish: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBFD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFD6EA)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: title,
                    size: 15,
                    bold: true,
                    color: const Color(0xFF272044),
                    isEnglish: true,
                    isCenter: false,
                  ),
                  const SizedBox(height: 4),
                  customText(
                    text: subtitle,
                    size: 12,
                    color: Colors.grey.shade600,
                    isEnglish: true,
                    isCenter: false,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
