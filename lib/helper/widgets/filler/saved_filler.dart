import 'dart:math' as math;

import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class SavedFormsWidget extends StatefulWidget {
  final List<FormModel> forms;
  final String selectedFormId;
  final bool isMobileLayout;
  final Function(String id) onSelect;

  const SavedFormsWidget({
    super.key,
    required this.forms,
    required this.selectedFormId,
    required this.onSelect,
    this.isMobileLayout = false,
  });

  @override
  State<SavedFormsWidget> createState() => _SavedFormsWidgetState();
}

class _SavedFormsWidgetState extends State<SavedFormsWidget>
    with SingleTickerProviderStateMixin {
  static const int itemsPerPage = 5;

  late final AnimationController _controller;
  int currentPage = 0;

  int get totalPages {
    if (widget.forms.isEmpty) return 1;
    return (widget.forms.length / itemsPerPage).ceil();
  }

  List<FormModel> get visibleForms {
    final start = currentPage * itemsPerPage;
    final end = math.min(start + itemsPerPage, widget.forms.length);

    if (start >= widget.forms.length) return [];
    return widget.forms.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant SavedFormsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.forms.length != widget.forms.length) {
      currentPage = 0;
      _restartAnimation();
      return;
    }

    if (currentPage >= totalPages) {
      currentPage = totalPages - 1;
      _restartAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _restartAnimation() {
    _controller.reset();
    _controller.forward();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= totalPages || page == currentPage) return;

    setState(() => currentPage = page);
    _restartAnimation();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 700;

    return Column(
      children: [
        _SavedFormsCounter(
          total: widget.forms.length,
          from: widget.forms.isEmpty ? 0 : currentPage * itemsPerPage + 1,
          to: currentPage * itemsPerPage + visibleForms.length,
        ),
        SizedBox(height: responsiveHeight(context, 0.018, min: 14, max: 20)),
        if (widget.forms.isEmpty)
          const _EmptySavedForms()
        else
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: ListView.separated(
              key: ValueKey(currentPage),
              itemCount: visibleForms.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => SizedBox(
                height: responsiveHeight(context, 0.012, min: 10, max: 14),
              ),
              itemBuilder: (context, index) {
                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    (index * 0.06).clamp(0.0, 0.70),
                    1,
                    curve: Curves.easeOutCubic,
                  ),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(animation),
                    child: _SavedFormCard(
                      index: currentPage * itemsPerPage + index + 1,
                      form: visibleForms[index],
                      active: widget.selectedFormId == visibleForms[index].id,
                      onTap: () => widget.onSelect(visibleForms[index].id),
                    ),
                  ),
                );
              },
            ),
          ),
        if (widget.forms.length > itemsPerPage) ...[
          SizedBox(height: responsiveHeight(context, 0.022, min: 18, max: 26)),
          _SavedFormsPagination(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: _goToPage,
          ),
        ],
      ],
    );
  }
}

class _SavedFormsCounter extends StatelessWidget {
  final int total;
  final int from;
  final int to;

  const _SavedFormsCounter({
    required this.total,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.018, min: 16, max: 22),
        vertical: responsiveHeight(context, 0.014, min: 12, max: 16),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4FA),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 20, max: 26),
        ),
        border: Border.all(
          color: const Color(0xFFE7549B).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: responsiveSize(context, 0.040, min: 42, max: 52),
            height: responsiveSize(context, 0.040, min: 42, max: 52),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.library_books_rounded,
              color: Colors.white,
              size: responsiveSize(context, 0.020, min: 22, max: 28),
            ),
          ),
          SizedBox(width: responsiveSize(context, 0.014, min: 12, max: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: 'النماذج المعروضة',
                  size: responsiveSize(context, 0.012, min: 14, max: 17),
                  color: const Color(0xFF831843),
                  bold: true,
                  isCenter: false,
                ),
                const SizedBox(height: 4),
                customText(
                  text: total == 0 ? 'لا توجد نماذج' : 'من $from إلى $to',
                  size: responsiveSize(context, 0.009, min: 11, max: 13),
                  color: Colors.grey.shade600,
                  isCenter: false,
                ),
              ],
            ),
          ),
          customText(
            text: '$to / $total',
            size: responsiveSize(context, 0.012, min: 14, max: 17),
            color: const Color(0xFFE7549B),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SavedFormCard extends StatefulWidget {
  final int index;
  final FormModel form;
  final bool active;
  final VoidCallback onTap;

  const _SavedFormCard({
    required this.index,
    required this.form,
    required this.active,
    required this.onTap,
  });

  @override
  State<_SavedFormCard> createState() => _SavedFormCardState();
}

class _SavedFormCardState extends State<_SavedFormCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 700;

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!isMobile) setState(() => _hover = false);
      },
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 20, max: 26),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0.0, _hover && !isMobile ? -4.0 : 0.0),
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.016, min: 14, max: 20),
            vertical: responsiveHeight(context, 0.014, min: 12, max: 16),
          ),
          decoration: BoxDecoration(
            gradient: widget.active
                ? const LinearGradient(
                    colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.active ? null : const Color(0xFFFEFBFD),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.018, min: 20, max: 26),
            ),
            border: Border.all(
              color: widget.active
                  ? Colors.transparent
                  : _hover
                  ? const Color(0xFFE7549B).withValues(alpha: 0.35)
                  : const Color(0xFFE7549B).withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.active
                    ? const Color(0xFFE7549B).withValues(alpha: 0.18)
                    : const Color(
                        0xFF831843,
                      ).withValues(alpha: _hover ? 0.13 : 0.06),
                blurRadius: _hover || widget.active ? 22 : 14,
                offset: Offset(0, _hover || widget.active ? 12 : 7),
              ),
            ],
          ),
          child: Row(
            children: [
              customText(
                text: widget.index.toString().padLeft(2, '0'),
                size: responsiveSize(context, 0.012, min: 14, max: 17),
                bold: true,
                color: widget.active ? Colors.white : const Color(0xFFE7549B),
              ),
              SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
              Container(
                width: responsiveSize(context, 0.040, min: 42, max: 52),
                height: responsiveSize(context, 0.040, min: 42, max: 52),
                decoration: BoxDecoration(
                  color: widget.active
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFFFFF4FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.active
                        ? Colors.white.withValues(alpha: 0.20)
                        : const Color(0xFFE7549B).withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  widget.active
                      ? Icons.check_circle_rounded
                      : Icons.description_rounded,
                  color: widget.active ? Colors.white : const Color(0xFFE7549B),
                  size: responsiveSize(context, 0.020, min: 22, max: 28),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
              Expanded(
                child: customText(
                  text: widget.form.name,
                  size: responsiveSize(context, 0.011, min: 13, max: 16),
                  bold: true,
                  color: widget.active ? Colors.white : const Color(0xFF831843),
                  isCenter: false,
                  maxLines: 1,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: widget.active ? Colors.white : const Color(0xFFE7549B),
                size: responsiveSize(context, 0.014, min: 14, max: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedFormsPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _SavedFormsPagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _SavedPageButton(
            icon: Icons.chevron_right_rounded,
            enabled: currentPage > 0,
            onTap: () => onPageChanged(currentPage - 1),
          ),
          ...List.generate(totalPages, (index) {
            final selected = index == currentPage;

            return InkWell(
              onTap: () => onPageChanged(index),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: selected ? 42 : 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selected ? null : const Color(0xFFF8EEF6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : const Color(0xFFE7549B).withValues(alpha: 0.12),
                  ),
                ),
                child: customText(
                  text: '${index + 1}',
                  size: 14,
                  color: selected ? Colors.white : const Color(0xFF831843),
                  bold: true,
                ),
              ),
            );
          }),
          _SavedPageButton(
            icon: Icons.chevron_left_rounded,
            enabled: currentPage < totalPages - 1,
            onTap: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }
}

class _SavedPageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _SavedPageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFE7549B).withValues(alpha: 0.10)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFFE7549B) : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}

class _EmptySavedForms extends StatelessWidget {
  const _EmptySavedForms();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.018, min: 16, max: 24)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4FA),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 20, max: 26),
        ),
        border: Border.all(
          color: const Color(0xFFE7549B).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            color: const Color(0xFFE7549B),
            size: responsiveSize(context, 0.040, min: 42, max: 58),
          ),
          SizedBox(height: responsiveHeight(context, 0.012, min: 10, max: 14)),
          customText(
            text: 'لا توجد نماذج محفوظة',
            size: responsiveSize(context, 0.012, min: 14, max: 18),
            color: Colors.grey.shade700,
            bold: true,
          ),
        ],
      ),
    );
  }
}
