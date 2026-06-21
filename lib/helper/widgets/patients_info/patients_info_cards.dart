part of '../../../screens/patients_info.dart';

class _PatientsGrid extends StatelessWidget {
  final List<PatientModel> patientsList;
  final int crossAxisCount;
  final double mainAxisExtent;
  final String? loadingPatientId;
  final ValueChanged<PatientModel> onPatientTap;
  final ValueChanged<PatientModel> onPatientEdit;

  const _PatientsGrid({
    super.key,
    required this.patientsList,
    required this.crossAxisCount,
    required this.mainAxisExtent,
    required this.loadingPatientId,
    required this.onPatientTap,
    required this.onPatientEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: patientsList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: mainAxisExtent,
        crossAxisSpacing: responsiveSize(context, 0.01, min: 12, max: 18),
        mainAxisSpacing: responsiveHeight(context, 0.02, min: 14, max: 20),
      ),
      itemBuilder: (context, index) {
        final patient = patientsList[index];

        return _PatientCard(
          index: index,
          patient: patient,
          isLoading: loadingPatientId == patient.id,
          onTap: () => onPatientTap(patient),
          onEdit: () => onPatientEdit(patient),
        );
      },
    );
  }
}

class _PatientCard extends StatelessWidget {
  final int index;
  final PatientModel patient;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _PatientCard({
    required this.index,
    required this.patient,
    required this.isLoading,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isSmall = w < 700;

    final profile = _PatientCardProfile(
      patientName: patient.fullName,
      fileNumber: patient.displayCrn,
      diseaseStatus: readablePatientValue(patient.diseaseStatus),
      registerDate: patient.displayRegistrationDate,
    );

    final details = Column(
      children: [
        _PatientInfoTile(
          icon: Icons.assignment_outlined,
          label: 'الحالة',
          value: readablePatientValue(patient.diseaseStatus),
        ),
        SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 10)),
        _PatientInfoTile(
          icon: Icons.biotech_outlined,
          label: 'البيولوجيا الورمية',
          value: readablePatientValue(patient.tumorBiology),
        ),
        SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 10)),
        _PatientInfoTile(
          icon: Icons.medical_services_outlined,
          label: 'الجراحة',
          value: readablePatientValue(patient.surgery),
        ),
        SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 10)),
        _PatientInfoTile(
          icon: Icons.science_outlined,
          label: 'العلاج الكيميائي',
          value: readablePatientValue(patient.chemotherapy),
        ),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
        _EditClinicalButton(isLoading: isLoading, onTap: onEdit),
      ],
    );

    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: isLoading ? 0.985 : 1,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: EdgeInsets.all(
            responsiveSize(context, 0.012, min: 14, max: 18),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFD3E8)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE83E8C).withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: isLoading ? 0.28 : 1,
                child: isSmall
                    ? Column(
                        children: [
                          profile,
                          const SizedBox(height: 16),
                          Container(height: 2, color: const Color(0xFFFFC6DD)),
                          const SizedBox(height: 16),
                          details,
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(flex: 5, child: profile),
                          Container(
                            width: 1,
                            margin: EdgeInsets.symmetric(
                              horizontal: responsiveSize(
                                context,
                                0.012,
                                min: 14,
                                max: 18,
                              ),
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: const Color(
                                    0xFFFFC6DD,
                                  ).withValues(alpha: 0.9),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(flex: 6, child: details),
                        ],
                      ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Center(
                    child: Transform.scale(scale: 0.62, child: customLoading()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditClinicalButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _EditClinicalButton({required this.isLoading, required this.onTap});

  @override
  State<_EditClinicalButton> createState() => _EditClinicalButtonState();
}

class _EditClinicalButtonState extends State<_EditClinicalButton> {
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
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.01, min: 12, max: 16),
            vertical: responsiveHeight(context, 0.014, min: 10, max: 13),
          ),
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
            boxShadow: hover
                ? [
                    BoxShadow(
                      color: const Color(0xFFE83E8C).withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: hover ? Colors.white : const Color(0xFFE83E8C),
                size: responsiveSize(context, 0.012, min: 17, max: 20),
              ),
              const SizedBox(width: 8),
              customText(
                text: 'تعديل البيانات الطبية',
                size: responsiveSize(context, 0.0078, min: 12, max: 14),
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
