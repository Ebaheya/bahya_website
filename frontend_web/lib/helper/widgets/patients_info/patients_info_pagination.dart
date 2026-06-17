part of '../../../screens/patients_info.dart';

class _PaginationBar extends StatelessWidget {
  final int page;
  final int pageSize;
  final int total;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int?> onPageSizeChanged;

  const _PaginationBar({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSizeChanged,
  });

  int get totalPages {
    if (total <= 0) return 1;
    return (total / pageSize).ceil();
  }

  bool get canGoPrevious => page > 1;
  bool get canGoNext => page < totalPages;

  String get rangeText {
    if (total == 0) return '0 / 0';
    final start = ((page - 1) * pageSize) + 1;
    final end = (page * pageSize).clamp(0, total);
    return '$start - $end / $total';
  }

  List<Widget> _pageNumbers(BuildContext context) {
    return List.generate(totalPages, (index) {
      final pageNumber = index + 1;
      return _PageNumber(
        title: pageNumber.toString(),
        active: pageNumber == page,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    if (w < 800) {
      return Column(
        children: [
          customText(
            text: rangeText,
            size: responsiveSize(context, 0.0075, min: 12, max: 13),
            color: const Color(0xFF7A7890),
            bold: true,
            isCenter: true,
            isEnglish: true,
          ),
          const SizedBox(height: 14),
          Wrap(
            textDirection: _activeTextDirection,
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _PageButton(
                title: 'السابق',
                enabled: canGoPrevious,
                onTap: onPrevious,
              ),
              ..._pageNumbers(context),
              _PageButton(title: 'التالي', enabled: canGoNext, onTap: onNext),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            textDirection: _activeTextDirection,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PageSizeDropdown(value: pageSize, onChanged: onPageSizeChanged),
              const SizedBox(width: 10),
              customText(
                text: 'لكل صفحة',
                size: responsiveSize(context, 0.0075, min: 12, max: 13),
                color: const Color(0xFF7A7890),
                bold: true,
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      textDirection: _activeTextDirection,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PageSizeDropdown(value: pageSize, onChanged: onPageSizeChanged),
            const SizedBox(width: 10),
            customText(
              text: 'لكل صفحة',
              size: responsiveSize(context, 0.0075, min: 12, max: 13),
              color: const Color(0xFF7A7890),
              bold: true,
              isCenter: false,
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PageButton(
              title: 'السابق',
              enabled: canGoPrevious,
              onTap: onPrevious,
            ),
            const SizedBox(width: 8),
            ..._pageNumbers(context),
            const SizedBox(width: 8),
            _PageButton(title: 'التالي', enabled: canGoNext, onTap: onNext),
          ],
        ),
        const Spacer(),
        customText(
          text: rangeText,
          size: responsiveSize(context, 0.0075, min: 12, max: 13),
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
          isEnglish: true,
        ),
      ],
    );
  }
}

class _PageNumber extends StatelessWidget {
  final String title;
  final bool active;

  const _PageNumber({required this.title, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: responsiveSize(context, 0.022, min: 32, max: 34),
      height: responsiveSize(context, 0.022, min: 32, max: 34),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE83E8C) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? const Color(0xFFE83E8C) : Colors.grey.shade200,
        ),
      ),
      child: customText(
        text: title,
        size: responsiveSize(context, 0.0075, min: 12, max: 13),
        color: active ? Colors.white : const Color(0xFF6B667A),
        bold: true,
        isCenter: true,
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final String title;
  final bool enabled;
  final VoidCallback? onTap;

  const _PageButton({required this.title, this.enabled = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.42,
        child: Container(
          height: responsiveSize(context, 0.022, min: 32, max: 34),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: customText(
            text: title,
            size: responsiveSize(context, 0.0075, min: 12, max: 13),
            color: const Color(0xFF6B667A),
            bold: true,
            isCenter: true,
          ),
        ),
      ),
    );
  }
}

class _PageSizeDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int?> onChanged;

  const _PageSizeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [10, 20, 30, 50];

    return Container(
      height: responsiveSize(context, 0.022, min: 34, max: 36),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: options.contains(value) ? value : 20,
          iconSize: 18,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          items: options.map((option) {
            return DropdownMenuItem<int>(
              value: option,
              child: customText(
                text: option.toString(),
                size: responsiveSize(context, 0.0075, min: 12, max: 13),
                color: const Color(0xFF2D244C),
                bold: true,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
