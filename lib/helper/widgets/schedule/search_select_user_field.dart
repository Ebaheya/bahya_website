part of 'schedule_form_widget.dart';

class SearchSelectUserField extends StatefulWidget {
  final String title;
  final String hint;
  final String noResultsText;
  final TextEditingController controller;
  final List<OptionUserModel> options;
  final bool isLoading;
  final void Function(String value) onSearch;
  final void Function(OptionUserModel user) onSelect;

  const SearchSelectUserField({
    super.key,
    required this.title,
    required this.hint,
    required this.noResultsText,
    required this.controller,
    required this.options,
    required this.isLoading,
    required this.onSearch,
    required this.onSelect,
  });

  @override
  State<SearchSelectUserField> createState() => _SearchSelectUserFieldState();
}

class _SearchSelectUserFieldState extends State<SearchSelectUserField> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final languageCode = locale.languageCode;
        final isEnglish = languageCode == 'en';

        final translatedHint = localizedTextByLocaleCode(
          languageCode,
          widget.hint,
        );

        final translatedNoResults = localizedTextByLocaleCode(
          languageCode,
          widget.noResultsText,
        );

        final hasSearchText = widget.controller.text.trim().isNotEmpty;
        final showNoResults =
            hasSearchText && !widget.isLoading && widget.options.isEmpty;

        return Directionality(
          textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
          child: Column(
            crossAxisAlignment: isEnglish
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              scheduleLabel(context: context, title: widget.title),
              SizedBox(
                height: responsiveHeight(context, 0.016, min: 12, max: 16),
              ),

              TextField(
                controller: widget.controller,
                textDirection: isEnglish
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                textAlign: isEnglish ? TextAlign.left : TextAlign.right,
                onChanged: (value) {
                  setState(() {});
                  widget.onSearch(value);
                },
                style: TextStyle(
                  fontFamily: "ArabicCustomFont",
                  fontSize: responsiveSize(context, 0.009, min: 13, max: 17),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B2B2B),
                ),
                decoration: InputDecoration(
                  hintText: translatedHint,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(
                      context,
                      0.012,
                      min: 12,
                      max: 16,
                    ),
                    vertical: responsiveHeight(
                      context,
                      0.015,
                      min: 12,
                      max: 16,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF7B1FA2),
                    size: responsiveSize(context, 0.016, min: 20, max: 24),
                  ),
                  suffixIcon: widget.isLoading
                      ? Padding(
                          padding: EdgeInsets.all(
                            responsiveSize(context, 0.008, min: 10, max: 12),
                          ),
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: const Color(0xFFE5007D),
                            size: responsiveSize(
                              context,
                              0.014,
                              min: 18,
                              max: 22,
                            ),
                          ),
                          onPressed: () {
                            setState(() => widget.controller.clear());
                            widget.onSearch("");
                          },
                        )
                      : null,
                  hintStyle: TextStyle(
                    fontFamily: "ArabicCustomFont",
                    fontSize: responsiveSize(context, 0.0085, min: 12, max: 16),
                    color: Colors.black38,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: _inputBorder(context, const Color(0xFFF2C9E0)),
                  enabledBorder: _inputBorder(context, const Color(0xFFF2C9E0)),
                  focusedBorder: _inputBorder(context, const Color(0xFFE5007D)),
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: scheduleSwitcherTransition,
                child: widget.options.isNotEmpty
                    ? _OptionsList(
                        key: ValueKey(
                          "options_${languageCode}_${widget.title}_${widget.options.length}",
                        ),
                        options: widget.options,
                        onSelect: widget.onSelect,
                      )
                    : showNoResults
                    ? _NoResultsBox(
                        key: ValueKey(
                          "no_results_${languageCode}_${widget.title}",
                        ),
                        text: translatedNoResults,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  OutlineInputBorder _inputBorder(BuildContext context, Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.014, min: 14, max: 16),
      ),
      borderSide: BorderSide(color: color),
    );
  }
}

class _OptionsList extends StatelessWidget {
  final List<OptionUserModel> options;
  final void Function(OptionUserModel user) onSelect;

  const _OptionsList({
    super.key,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        return Directionality(
          textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
          child: Container(
            margin: EdgeInsets.only(
              top: responsiveHeight(context, 0.012, min: 8, max: 10),
            ),
            constraints: BoxConstraints(
              maxHeight: responsiveHeight(context, 0.24, min: 150, max: 220),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.014, min: 14, max: 16),
              ),
              border: Border.all(color: const Color(0xFFF2C9E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = options[index];

                return ListTile(
                  minLeadingWidth: responsiveSize(
                    context,
                    0.02,
                    min: 28,
                    max: 36,
                  ),
                  leading: Icon(
                    Icons.person_rounded,
                    color: const Color(0xFFE5007D),
                    size: responsiveSize(context, 0.016, min: 20, max: 24),
                  ),
                  title: customText(
                    text: user.fullName,
                    size: responsiveSize(context, 0.009, min: 13, max: 17),
                    bold: true,
                    color: const Color(0xFF2B2B2B),
                    isCenter: false,
                    align: isEnglish ? TextAlign.start : TextAlign.end,
                    isEnglish: isEnglish,
                  ),
                  onTap: () => onSelect(user),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _NoResultsBox extends StatelessWidget {
  final String text;

  const _NoResultsBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        return Align(
          alignment: isEnglish ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(
              top: responsiveHeight(context, 0.012, min: 8, max: 10),
            ),
            width: double.infinity,
            padding: EdgeInsets.all(
              responsiveSize(context, 0.012, min: 12, max: 16),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F8),
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.014, min: 14, max: 16),
              ),
              border: Border.all(color: const Color(0xFFF2C9E0)),
            ),
            child: customText(
              text: text,
              size: responsiveSize(context, 0.0085, min: 12, max: 16),
              bold: true,
              color: const Color(0xFFE5007D),
              isCenter: false,
              align: isEnglish ? TextAlign.start : TextAlign.end,
              isEnglish: isEnglish,
            ),
          ),
        );
      },
    );
  }
}
