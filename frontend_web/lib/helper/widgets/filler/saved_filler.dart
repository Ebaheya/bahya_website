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

class _SavedFormsWidgetState extends State<SavedFormsWidget> {
  int currentPage = 0;

  int get itemsPerPage => widget.isMobileLayout ? 6 : 12;

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
  void didUpdateWidget(covariant SavedFormsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isMobileLayout != widget.isMobileLayout ||
        oldWidget.forms.length != widget.forms.length) {
      currentPage = 0;
      return;
    }

    if (currentPage >= totalPages) {
      currentPage = totalPages - 1;
    }
  }

  void _goToPage(int page) {
    if (page < 0 || page >= totalPages) return;

    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = responsiveHeight(context, 0.022, min: 15, max: 22);
    final textSize = responsiveHeight(context, 0.017, min: 12, max: 16);
    final paginationTextSize = responsiveHeight(
      context,
      0.014,
      min: 11,
      max: 13,
    );

    final padding = responsiveSize(context, 0.02, min: 12, max: 20);
    final radius = responsiveSize(context, 0.022, min: 16, max: 24);
    final gap = responsiveSize(context, 0.01, min: 8, max: 12);

    final listHeight = widget.isMobileLayout
        ? responsiveHeight(context, 0.37, min: 260, max: 420)
        : responsiveHeight(context, 1, min: 420, max: 580);

    return SizedBox(
      width: widget.isMobileLayout ? double.infinity : 340,
      child: Container(
        
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: customText(
                    text: "النماذج المحفوظة",
                    size: titleSize,
                    bold: true,
                    color: const Color(0xFF7A004C),
                    isCenter: false,
                  ),
                ),
                SizedBox(width: gap),
                const Icon(Icons.folder_open, color: Color(0xFF7A004C)),
              ],
            ),
            SizedBox(
              height: responsiveHeight(context, 0.015, min: 10, max: 16),
            ),
            SizedBox(
              height: listHeight,
              child: widget.forms.isEmpty
                  ? Center(
                      child: customText(
                        text: "لا توجد نماذج",
                        size: textSize,
                        color: Colors.grey,
                        bold: true,
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visibleForms.length,
                      separatorBuilder: (_, __) => SizedBox(
                        height: widget.isMobileLayout
                            ? responsiveHeight(context, 0.01, min: 8, max: 10)
                            : responsiveHeight(context, 0.006, min: 5, max: 7),
                      ),
                      itemBuilder: (context, index) {
                        return _formItem(
                          context: context,
                          form: visibleForms[index],
                          width: double.infinity,
                          textSize: textSize,
                          gap: gap,
                        );
                      },
                    ),
            ),
            if (widget.forms.length > itemsPerPage) ...[
              SizedBox(
                height: responsiveHeight(context, 0.012, min: 8, max: 12),
              ),
              _pagination(
                context: context,
                textSize: paginationTextSize,
                gap: gap,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pagination({
    required BuildContext context,
    required double textSize,
    required double gap,
  }) {
    final buttonSize = responsiveSize(context, 0.028, min: 26, max: 34);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _paginationArrow(
          context: context,
          icon: Icons.keyboard_arrow_left_rounded,
          size: buttonSize,
          enabled: currentPage > 0,
          onTap: () => _goToPage(currentPage - 1),
        ),
        SizedBox(width: gap),
        ...List.generate(totalPages, (index) {
          final active = index == currentPage;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.004, min: 3, max: 5),
            ),
            child: GestureDetector(
              onTap: () => _goToPage(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: buttonSize,
                height: buttonSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFFFF80C5), Color(0xFFC38CFF)],
                        )
                      : null,
                  color: active ? null : const Color(0xFFF8ECF7),
                  border: Border.all(
                    color: active
                        ? Colors.transparent
                        : const Color(0xFFFFC7DF),
                  ),
                ),
                child: customText(
                  text: "${index + 1}",
                  size: textSize,
                  bold: true,
                  color: active ? Colors.white : const Color(0xFF7A004C),
                ),
              ),
            ),
          );
        }),
        SizedBox(width: gap),
        _paginationArrow(
          context: context,
          icon: Icons.keyboard_arrow_right_rounded,
          size: buttonSize,
          enabled: currentPage < totalPages - 1,
          onTap: () => _goToPage(currentPage + 1),
        ),
      ],
    );
  }

  Widget _paginationArrow({
    required BuildContext context,
    required IconData icon,
    required double size,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F8),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFC7DF)),
          ),
          child: Icon(icon, size: size * 0.75, color: const Color(0xFFE40070)),
        ),
      ),
    );
  }

  Widget _formItem({
    required BuildContext context,
    required FormModel form,
    required double width,
    required double textSize,
    required double gap,
  }) {
    final active = widget.selectedFormId == form.id;

    return GestureDetector(
      onTap: () => widget.onSelect(form.id),
      child: AnimatedContainer(
        width: width,
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.014, min: 10, max: 14),
          vertical: responsiveHeight(context, 0.012, min: 9, max: 12),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.014, min: 12, max: 14),
          ),
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFFFF80C5), Color(0xFFC38CFF)],
                )
              : null,
          color: active ? null : const Color(0xFFF8ECF7),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFE40070).withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              Icons.description_rounded,
              size: responsiveSize(context, 0.024, min: 18, max: 22),
              color: active ? Colors.white : const Color(0xFF7A004C),
            ),
            SizedBox(width: gap),
            Expanded(
              child: customText(
                text: form.name,
                size: textSize,
                bold: true,
                color: active ? Colors.white : const Color(0xFF7A004C),
                isCenter: true,
                maxLines: widget.isMobileLayout ? 2 : 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
