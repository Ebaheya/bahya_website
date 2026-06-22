part of 'saved_filler_widget.dart';

extension _SavedFillerFields on _DynamicFormFillerWidgetState {
  Widget _patientSearch() {
    final state = context.watch<DoctorFormsCubit>().state;

    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: CustomFormTextField(
            controller: patientSearchController,
            labelText: localizedText(context, 'اختيار المريض'),
            hintText: localizedText(context, 'ابحث باسم المريض'),
            keyboardType: CustomTextFieldType.text,
            prefixIcon: const Icon(Icons.search_rounded),
            onChange: (value) {
              context.read<DoctorFormsCubit>().searchPatients(value);
              setState(() {});
            },
          ),
        ),
        if (state.patientAlreadyFilledMessage != null) ...[
          const SizedBox(height: 12),
          customText(
            text: state.patientAlreadyFilledMessage!,
            size: responsiveSize(context, 0.010, min: 12, max: 15),
            bold: true,
            color: Colors.red,
          ),
        ],
        if (widget.selectedPatient != null) ...[
          const SizedBox(height: 14),
          _selectedPatientCard(),
        ],
        if (widget.isSearchingPatients) ...[
          const SizedBox(height: 14),
          customLoading(),
        ],
        if (widget.patients.isNotEmpty) ...[
          const SizedBox(height: 14),
          _patientsList(),
        ],
      ],
    );
  }

  Widget _selectedPatientCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.016, min: 14, max: 18)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.020, min: 20, max: 26),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE7549B).withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.read<DoctorFormsCubit>().clearSelectedPatient();
              patientSearchController.clear();
              setState(() {});
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
          Expanded(
            child: customText(
              text: widget.selectedPatient!.fullName,
              size: responsiveSize(context, 0.012, min: 14, max: 18),
              bold: true,
              color: Colors.white,
              isCenter: false,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.person_rounded, color: Colors.white),
        ],
      ),
    );
  }

  Widget _patientsList() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: responsiveHeight(context, 0.30, min: 190, max: 280),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFBFD),
        border: Border.all(
          color: const Color(0xFFE7549B).withValues(alpha: 0.12),
        ),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.020, min: 20, max: 26),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: widget.patients.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: const Color(0xFFE7549B).withValues(alpha: 0.10),
        ),
        itemBuilder: (context, index) {
          final patient = widget.patients[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            title: Text(
              patient.fullName,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: const Color(0xFF831843),
                fontWeight: FontWeight.bold,
                fontSize: responsiveSize(context, 0.010, min: 13, max: 16),
              ),
            ),
            trailing: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFFE7549B)),
            ),
            onTap: () async {
              await context.read<DoctorFormsCubit>().selectPatient(patient);

              if (!mounted) return;

              patientSearchController.clear();
              setState(() {});
            },
          );
        },
      ),
    );
  }

  Widget _questionCard({required int index, required dynamic question}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.020, min: 16, max: 24)),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFBFD),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.024, min: 24, max: 32),
        ),
        border: Border.all(
          color: const Color(0xFFE7549B).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(
            text: question.text ?? '',
            size: responsiveSize(context, 0.014, min: 16, max: 22),
            bold: true,
            color: const Color(0xFF241B4B),
            isCenter: false,
            maxLines: 4,
          ),
          SizedBox(height: responsiveHeight(context, 0.024, min: 18, max: 26)),
          if (question.type == 'SCALE')
            _scaleQuestion(question)
          else
            ..._choiceQuestion(question),
        ],
      ),
    );
  }

  Widget _scaleQuestion(dynamic question) {
    final cubit = context.read<DoctorFormsCubit>();
    final min = question.scaleMin ?? 0;
    final max = question.scaleMax ?? 10;
    final current = cubit.getScaleAnswer(question.id);

    return Column(
      children: [
        Slider(
          value: (current ?? min).toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: const Color(0xFFE7549B),
          inactiveColor: const Color(0xFFFFD6E9),
          label: (current ?? min).toString(),
          onChanged: (value) {
            final score = value.round();

            cubit.setScaleAnswer(
              questionId: question.id,
              value: score,
              score: score,
            );

            _updateState(() {});
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: customText(
            text: current == null ? 'اختر درجة' : '$current',
            size: responsiveSize(context, 0.012, min: 14, max: 18),
            bold: true,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  List<Widget> _choiceQuestion(dynamic question) {
    final cubit = context.read<DoctorFormsCubit>();

    return (question.choices ?? []).map<Widget>((choice) {
      final selected = cubit.isChoiceSelected(
        questionId: question.id,
        choiceId: choice.id,
      );

      final score = choice.score ?? choice.value ?? 0;

      return InkWell(
        onTap: () {
          if (question.type == 'MULTI_SELECT') {
            cubit.toggleMultiChoiceAnswer(
              questionId: question.id,
              choiceId: choice.id,
              score: score,
            );
          } else {
            cubit.setSingleChoiceAnswer(
              questionId: question.id,
              choiceId: choice.id,
              score: score,
            );
          }

          _updateState(() {});
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: EdgeInsets.only(
            bottom: responsiveHeight(context, 0.012, min: 10, max: 14),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.016, min: 14, max: 20),
            vertical: responsiveHeight(context, 0.014, min: 12, max: 16),
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : const Color(0xFFE7549B).withValues(alpha: 0.12),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFFE7549B).withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              _scoreBadge(score, selected),
              const SizedBox(width: 12),
              Expanded(
                child: customText(
                  text: choice.label ?? '',
                  size: responsiveSize(context, 0.011, min: 13, max: 17),
                  bold: true,
                  color: selected ? Colors.white : const Color(0xFF241B4B),
                  isCenter: false,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                question.type == 'MULTI_SELECT'
                    ? selected
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded
                    : selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? Colors.white : const Color(0xFFE7549B),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _scoreBadge(dynamic score, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.16)
            : const Color(0xFFFFF4FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: customText(
        text: '$score',
        size: responsiveSize(context, 0.0095, min: 12, max: 14),
        bold: true,
        color: selected ? Colors.white : const Color(0xFFE7549B),
      ),
    );
  }

  Widget _resultStep({
    required int score,
    required String diagnosis,
    required String patientStatus,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            responsiveSize(context, 0.020, min: 16, max: 24),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4FA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE7549B).withValues(alpha: 0.12),
            ),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _resultTile(
                icon: Icons.score_rounded,
                title: localizedText(context, 'Score'),
                value: '$score',
              ),
              _resultTile(
                icon: Icons.psychology_rounded,
                title: localizedText(context, 'Diagnosis'),
                value: diagnosis,
              ),
              _resultTile(
                icon: Icons.health_and_safety_rounded,
                title: localizedText(context, 'Patient status'),
                value: patientStatus,
              ),
            ],
          ),
        ),
        SizedBox(height: responsiveHeight(context, 0.024, min: 18, max: 26)),
        _statusDropdown(),
        SizedBox(height: responsiveHeight(context, 0.024, min: 18, max: 26)),
        _notesField(),
      ],
    );
  }

  Widget _resultTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: _isMobile ? double.infinity : 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE7549B).withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: title,
                  size: responsiveSize(context, 0.009, min: 11, max: 13),
                  color: Colors.grey.shade600,
                  isCenter: false,
                ),
                const SizedBox(height: 4),
                customText(
                  text: value,
                  size: responsiveSize(context, 0.011, min: 13, max: 16),
                  color: const Color(0xFF831843),
                  bold: true,
                  isCenter: false,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDropdown() {
    final state = context.watch<DoctorFormsCubit>().state;

    final statuses = [
      {'value': 'NORMAL', 'label': 'طبيعي', 'icon': Icons.check_circle_outline},
      {'value': 'MILD', 'label': 'بسيط', 'icon': Icons.info_outline},
      {
        'value': 'MODERATE',
        'label': 'متوسط',
        'icon': Icons.warning_amber_rounded,
      },
      {'value': 'SEVERE', 'label': 'شديد', 'icon': Icons.priority_high_rounded},
      {'value': 'CRITICAL', 'label': 'حرج', 'icon': Icons.dangerous_outlined},
    ];

    final statusValues = statuses.map((item) => item['value']).toSet();
    final safeSelectedStatus = statusValues.contains(state.selectedStatus)
        ? state.selectedStatus
        : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFBFD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE7549B).withValues(alpha: 0.16),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: safeSelectedStatus,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFE7549B),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(18),
            hint: customText(
              text: 'اختر حالة المريض',
              size: 14,
              color: Colors.grey.shade600,
            ),
            items: statuses.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'] as String,
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: const Color(0xFFE7549B),
                    ),
                    const SizedBox(width: 10),
                    customText(
                      text: item['label'] as String,
                      size: 14,
                      bold: true,
                      color: const Color(0xFF831843),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              context.read<DoctorFormsCubit>().changeStatus(value);
            },
          ),
        ),
      ),
    );
  }

  Widget _notesField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.020, min: 16, max: 22)),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFBFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE7549B).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(
            text: localizedText(context, 'ملاحظات الطبيب'),
            size: responsiveSize(context, 0.013, min: 15, max: 19),
            bold: true,
            color: const Color(0xFF831843),
            isCenter: false,
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomFormTextField(
              controller: noteController,
              hintText: localizedText(context, 'اكتب ملاحظات الطبيب هنا...'),
              keyboardType: CustomTextFieldType.text,
              maxLines: 4,
              bordered: false,
              centerHint: false,
              isRequired: false,
            ),
          ),
        ],
      ),
    );
  }
}
