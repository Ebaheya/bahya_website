part of 'scheduled_list_widget.dart';

class ScheduledItemCard extends StatelessWidget {
  final String formName;
  final String date;
  final String repeat;
  final String hour;
  final String publishType;
  final List<String> patientNames;
  final List<String> volunteerNames;
  final VoidCallback onDelete;
  final bool showDelete;

  const ScheduledItemCard({
    super.key,
    required this.formName,
    required this.date,
    required this.repeat,
    required this.hour,
    required this.publishType,
    required this.patientNames,
    required this.volunteerNames,
    required this.onDelete,
    this.showDelete = true,
  });

  bool get isAllPatients {
    return publishType == "كل المرضى" ||
        publishType == "ALL_PATIENTS" ||
        publishType.contains("كل");
  }

  bool get isVolunteerTarget {
    return publishType == "متطوع لمريض" ||
        publishType == "المتطوعين" ||
        publishType == "VOLUNTEER_FOR_PATIENT";
  }

  bool get isSelectedPatients {
    return publishType == "مجموعه من المرضى" ||
        publishType == "مجموعة من المرضى" ||
        publishType == "SELECTED_PATIENTS";
  }

  String get readablePublishType {
    if (isAllPatients) return "كل المرضى";
    if (isVolunteerTarget) return "متطوعين ومرضى";
    if (isSelectedPatients) return "مجموعة من المرضى";
    return publishType;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 750;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.022, min: 14, max: 34),
        vertical: responsiveHeight(context, 0.022, min: 14, max: 24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 16, max: 20),
        ),
        border: Border.all(color: const Color(0xFFF3DCEB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: responsiveSize(context, 0.016, min: 12, max: 18),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isMobile ? _mobileLayout(context) : _desktopLayout(context),
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SideLine(),
        SizedBox(width: responsiveSize(context, 0.018, min: 14, max: 26)),
        _StatusBadge(showDelete: showDelete, status: repeat),
        SizedBox(width: responsiveSize(context, 0.026, min: 18, max: 36)),
        Expanded(flex: 4, child: _mainInfo()),
        SizedBox(width: responsiveSize(context, 0.02, min: 14, max: 26)),
        Expanded(flex: 4, child: _dateInfoBox()),
        if (showDelete) ...[
          SizedBox(width: responsiveSize(context, 0.02, min: 14, max: 24)),
          _CancelButton(onDelete: onDelete),
        ],
      ],
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SideLine(
              height: responsiveHeight(context, 0.055, min: 42, max: 56),
            ),
            SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
            _StatusBadge(showDelete: showDelete, status: repeat),
            const Spacer(),
            if (showDelete) _CancelButton(onDelete: onDelete),
          ],
        ),
        SizedBox(height: responsiveHeight(context, 0.018, min: 12, max: 18)),
        _mainInfo(),
        SizedBox(height: responsiveHeight(context, 0.018, min: 12, max: 18)),
        _dateInfoBox(),
      ],
    );
  }

  Widget _mainInfo() {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(
              text: formName,
              size: responsiveSize(context, 0.014, min: 17, max: 26),
              bold: true,
              color: const Color(0xFF8A0057),
              maxLines: 2,
              isCenter: false,
            ),
            SizedBox(height: responsiveHeight(context, 0.01, min: 8, max: 12)),
            _TargetBadge(text: readablePublishType),
            SizedBox(
              height: responsiveHeight(context, 0.014, min: 10, max: 14),
            ),
            if (isAllPatients)
              const _NamesBlock(
                title: "المرضى",
                names: ["كل المرضى"],
                icon: Icons.groups_rounded,
              )
            else if (isVolunteerTarget) ...[
              _NamesBlock(
                title: "المرضى المختارين",
                names: patientNames,
                icon: Icons.personal_injury_rounded,
              ),
              SizedBox(
                height: responsiveHeight(context, 0.012, min: 8, max: 12),
              ),
              _NamesBlock(
                title: "المتطوعين المختارين",
                names: volunteerNames,
                icon: Icons.volunteer_activism_rounded,
              ),
            ] else
              _NamesBlock(
                title: "المرضى المختارين",
                names: patientNames,
                icon: Icons.personal_injury_rounded,
              ),
          ],
        );
      },
    );
  }

  Widget _dateInfoBox() {
    return Builder(
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.02, min: 14, max: 28),
            vertical: responsiveHeight(context, 0.014, min: 12, max: 16),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4FA),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.014, min: 14, max: 16),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ScheduleInfoBlock(
                  title: showDelete ? "الموعد القادم" : "تاريخ النشر",
                  value: date,
                  subValue: repeat.trim().isEmpty ? null : "($repeat)",
                ),
              ),
              Container(
                width: 1,
                height: responsiveHeight(context, 0.065, min: 46, max: 65),
                color: const Color(0xFFEED5E3),
              ),
              Expanded(
                child: ScheduleInfoBlock(
                  title: "وقت النشر",
                  value: hour.isEmpty ? "-" : hour,
                  isTime: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
