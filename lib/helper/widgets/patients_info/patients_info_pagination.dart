part of '../../../screens/doctor/patients_info.dart';

class _PaginationBar extends StatelessWidget {
  final int page;
  final int pageSize;
  final int total;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PaginationBar({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = total <= 0 ? 1 : (total / pageSize).ceil();
    final canPrevious = page > 1;
    final canNext = page < totalPages;

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.012, min: 12, max: 18),
          vertical: responsiveHeight(context, 0.012, min: 10, max: 14),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFBFD),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.020, min: 20, max: 26),
          ),
          border: Border.all(
            color: const Color(0xFFE7549B).withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF831843).withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PaginationButton(
              icon: Icons.chevron_left_rounded,
              enabled: canPrevious,
              onTap: onPrevious,
            ),
            SizedBox(width: responsiveSize(context, 0.010, min: 8, max: 14)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.018, min: 16, max: 24),
                vertical: responsiveHeight(context, 0.010, min: 8, max: 12),
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: customText(
                text: '$page / $totalPages',
                size: responsiveSize(context, 0.010, min: 13, max: 16),
                color: Colors.white,
                bold: true,
              ),
            ),
            SizedBox(width: responsiveSize(context, 0.010, min: 8, max: 14)),
            _PaginationButton(
              icon: Icons.chevron_right_rounded,
              enabled: canNext,
              onTap: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationButton({
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
        width: responsiveSize(context, 0.034, min: 36, max: 42),
        height: responsiveSize(context, 0.034, min: 36, max: 42),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFE7549B).withValues(alpha: 0.10)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFFE7549B) : Colors.grey,
          size: responsiveSize(context, 0.018, min: 22, max: 26),
        ),
      ),
    );
  }
}
