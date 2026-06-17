part of 'schedule_form_widget.dart';

class SelectedUsersChips extends StatelessWidget {
  final List<OptionUserModel> users;
  final void Function(OptionUserModel user) onRemove;

  const SelectedUsersChips({
    super.key,
    required this.users,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: scheduleSwitcherTransition,
          child: users.isEmpty
              ? const SizedBox.shrink(key: ValueKey("empty_chips"))
              : Padding(
                  key: ValueKey(
                    "${locale.languageCode}_${users.map((e) => e.id).join(",")}",
                  ),
                  padding: EdgeInsets.only(
                    top: responsiveHeight(context, 0.016, min: 12, max: 16),
                  ),
                  child: Align(
                    alignment: isEnglish
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Wrap(
                      textDirection: isEnglish
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      alignment: isEnglish
                          ? WrapAlignment.start
                          : WrapAlignment.end,
                      spacing: responsiveSize(context, 0.008, min: 8, max: 10),
                      runSpacing: responsiveHeight(
                        context,
                        0.012,
                        min: 8,
                        max: 10,
                      ),
                      children: users.map((user) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.85, end: 1),
                          duration: const Duration(milliseconds: 250),
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsiveSize(
                                context,
                                0.012,
                                min: 12,
                                max: 14,
                              ),
                              vertical: responsiveHeight(
                                context,
                                0.01,
                                min: 8,
                                max: 10,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEEF4),
                              borderRadius: BorderRadius.circular(
                                responsiveSize(
                                  context,
                                  0.012,
                                  min: 12,
                                  max: 14,
                                ),
                              ),
                              border: Border.all(
                                color: const Color(0xFFFFBCD4),
                              ),
                            ),
                            child: Row(
                              textDirection: isEnglish
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                customText(
                                  text: user.fullName,
                                  size: responsiveSize(
                                    context,
                                    0.0085,
                                    min: 12,
                                    max: 16,
                                  ),
                                  bold: true,
                                  color: const Color(0xFF7B1FA2),
                                  isEnglish: isEnglish,
                                ),
                                SizedBox(
                                  width: responsiveSize(
                                    context,
                                    0.006,
                                    min: 6,
                                    max: 8,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => onRemove(user),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: responsiveSize(
                                      context,
                                      0.012,
                                      min: 16,
                                      max: 18,
                                    ),
                                    color: const Color(0xFFE5007D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

Widget scheduleSwitcherTransition(Widget child, Animation<double> animation) {
  return FadeTransition(
    opacity: animation,
    child: SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: child,
    ),
  );
}
