part of '../../../screens/doctor/patients_info.dart';

class _PatientsStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _PatientsStateMessage({
    required this.icon,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.018, min: 18, max: 28),
        vertical: responsiveHeight(context, 0.08, min: 70, max: 120),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE83E8C),
            size: responsiveSize(context, 0.03, min: 34, max: 48),
          ),
          const SizedBox(height: 14),
          customText(
            text: title,
            size: responsiveSize(context, 0.01, min: 14, max: 18),
            color: const Color(0xFF271648),
            bold: true,
            maxLines: 3,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 16),
            _ActionButton(
              title: actionText!,
              icon: Icons.refresh,
              onTap: onAction!,
              isPrimary: false,
            ),
          ],
        ],
      ),
    );
  }
}

class _MobilePatientsListForInfo extends StatelessWidget {
  final List<PatientModel> patientsList;
  final String? loadingPatientId;
  final ValueChanged<PatientModel> onPatientTap;
  final ValueChanged<PatientModel> onPatientEdit;

  const _MobilePatientsListForInfo({
    super.key,
    required this.patientsList,
    required this.loadingPatientId,
    required this.onPatientTap,
    required this.onPatientEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: patientsList.map((patient) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: responsiveHeight(context, 0.018, min: 14, max: 18),
          ),
          child: _MobilePatientClinicalCard(
            patient: patient,
            isLoading: loadingPatientId == patient.id,
            onTap: () => onPatientTap(patient),
            onEdit: () => onPatientEdit(patient),
          ),
        );
      }).toList(),
    );
  }
}

class _MobilePatientClinicalCard extends StatelessWidget {
  final PatientModel patient;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _MobilePatientClinicalCard({
    required this.patient,
    required this.isLoading,
    required this.onTap,
    required this.onEdit,
  });

  String _safeValue(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    final diseaseStatus = readablePatientValue(patient.diseaseStatus);
    final tumorBiology = readablePatientValue(patient.tumorBiology);
    final surgery = readablePatientValue(patient.surgery);
    final chemo = readablePatientValue(patient.chemotherapy);

    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: isLoading ? 0.985 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              responsiveSize(context, 0.018, min: 16, max: 20),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD3E8)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE83E8C).withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedOpacity(
                  opacity: isLoading ? 0.30 : 1,
                  duration: const Duration(milliseconds: 220),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE83E8C), Color(0xFFFF7BB0)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE83E8C,
                                  ).withValues(alpha: 0.18),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: customText(
                                text: patient.fullName.trim().isEmpty
                                    ? 'P'
                                    : patient.fullName.trim()[0].toUpperCase(),
                                size: 22,
                                color: Colors.white,
                                bold: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                customText(
                                  text: _safeValue(patient.fullName),
                                  size: responsiveSize(
                                    context,
                                    0.012,
                                    min: 17,
                                    max: 20,
                                  ),
                                  color: const Color(0xFF271648),
                                  bold: true,
                                  isCenter: false,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _MobilePatientChip(
                                      icon: Icons.badge_outlined,
                                      text: _safeValue(patient.displayCrn),
                                    ),
                                    _MobilePatientChip(
                                      icon: Icons.event_available_outlined,
                                      text: _safeValue(
                                        patient.displayRegistrationDate,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: const Color(
                              0xFFE83E8C,
                            ).withValues(alpha: 0.75),
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: const Color(0xFFFFD6EA)),
                      const SizedBox(height: 14),
                      _MobilePatientInfoLine(
                        icon: Icons.assignment_outlined,
                        label: 'الحالة',
                        value: diseaseStatus,
                      ),
                      const SizedBox(height: 10),
                      _MobilePatientInfoLine(
                        icon: Icons.biotech_outlined,
                        label: 'البيولوجيا الورمية',
                        value: tumorBiology,
                      ),
                      const SizedBox(height: 10),
                      _MobilePatientInfoLine(
                        icon: Icons.medical_services_outlined,
                        label: 'الجراحة',
                        value: surgery,
                      ),
                      const SizedBox(height: 10),
                      _MobilePatientInfoLine(
                        icon: Icons.science_outlined,
                        label: 'العلاج الكيميائي',
                        value: chemo,
                      ),
                      const SizedBox(height: 16),
                      _MobileEditClinicalButton(
                        isLoading: isLoading,
                        onTap: onEdit,
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Transform.scale(
                          scale: 0.65,
                          child: customLoading(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobilePatientChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MobilePatientChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD6EA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFE83E8C), size: 15),
          const SizedBox(width: 6),
          customText(
            text: text,
            size: 11,
            color: const Color(0xFF7A104F),
            bold: true,
            isCenter: false,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _MobilePatientInfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MobilePatientInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  String get cleanValue {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0EF)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE83E8C), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: customText(
              text: label,
              size: 12,
              color: const Color(0xFF7A7890),
              bold: true,
              isCenter: false,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: customText(
              text: cleanValue,
              size: 12,
              color: const Color(0xFF271648),
              bold: true,
              isCenter: false,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileEditClinicalButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _MobileEditClinicalButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_MobileEditClinicalButton> createState() =>
      _MobileEditClinicalButtonState();
}

class _MobileEditClinicalButtonState extends State<_MobileEditClinicalButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isLoading
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            gradient: hover
                ? const LinearGradient(
                    colors: [Color(0xFFE83E8C), Color(0xFFFF7BB0)],
                  )
                : null,
            color: hover ? null : const Color(0xFFFFEAF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hover ? const Color(0xFFE83E8C) : const Color(0xFFFFC6DD),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: hover ? Colors.white : const Color(0xFFE83E8C),
                size: 20,
              ),
              const SizedBox(width: 8),
              customText(
                text: 'تعديل البيانات الطبية',
                size: 13,
                color: hover ? Colors.white : const Color(0xFFE83E8C),
                bold: true,
                isCenter: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
