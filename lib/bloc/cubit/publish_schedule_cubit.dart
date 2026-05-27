import 'package:bahya_website/bloc/states/publish_schedule_state.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/widgets/scheduled_list_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PublishScheduleCubit extends Cubit<PublishScheduleState> {
  final AppRepository repo;

  PublishScheduleCubit(this.repo) : super(const PublishScheduleState());

  Future<void> loadForms() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final response = await repo.getForms();

      final draftForms = response.data
          .where((e) => e.currentVersion?.status == "DRAFT")
          .toList();

      final publishedForms = response.data
          .where((e) => e.currentVersion?.status == "PUBLISHED")
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          draftForms: draftForms,
          publishedForms: publishedForms,
          error: null,
        ),
      );

      await loadPublishedAssignments();
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: "حدث خطأ أثناء تحميل النماذج."),
      );
    }
  }

  Future<void> searchPatients(String search) async {
    if (search.trim().isEmpty) {
      emit(state.copyWith(patientOptions: []));
      return;
    }

    emit(state.copyWith(isSearchingPatients: true, error: null));

    try {
      final response = await repo.getPatientOptions(search: search);

      emit(
        state.copyWith(
          isSearchingPatients: false,
          patientOptions: response.data,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSearchingPatients: false,
          error: "حدث خطأ أثناء البحث عن المرضى.",
        ),
      );
    }
  }

  Future<void> searchVolunteers(String search) async {
    if (search.trim().isEmpty) {
      emit(state.copyWith(volunteerOptions: []));
      return;
    }

    emit(state.copyWith(isSearchingVolunteers: true, error: null));

    try {
      final response = await repo.getVolunteerOptions(search: search);

      emit(
        state.copyWith(
          isSearchingVolunteers: false,
          volunteerOptions: response.data,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSearchingVolunteers: false,
          error: "حدث خطأ أثناء البحث عن المتطوعين.",
        ),
      );
    }
  }

  Future<bool> publishForm({
    required FormModel form,
    required Map<String, dynamic> body,
  }) async {
    if (state.isPublishing) return false;

    emit(state.copyWith(isPublishing: true, error: null));

    try {
      final status = form.currentVersion?.status.trim().toUpperCase();

      if (status == "DRAFT") {
        try {
          await repo.publishFormVersion(formId: form.id);
        } catch (e) {
          if (!e.toString().contains("FORM_VERSION_NOT_DRAFT")) {
            rethrow;
          }
        }
      }

      await repo.publishForm(formId: form.id, body: body);

      emit(state.copyWith(isPublishing: false, error: null));

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isPublishing: false,
          error: "حدث خطأ أثناء نشر النموذج.",
        ),
      );
      return false;
    }
  }

  Future<void> loadPublishedAssignments() async {
    try {
      emit(state.copyWith(isLoadingAssignments: true, error: null));

      final List<ScheduledItemModel> items = [];

      for (final form in state.publishedForms) {
        final formId = form.id;

        if (formId.isEmpty) continue;

        final response = await repo.getFormAssignments(formId: formId);

        for (final assignment in response.data) {
          items.add(
            ScheduledItemModel(
              form: form.name,
              date: assignment.publishAt == null
                  ? "فوري"
                  : _formatIsoDate(assignment.publishAt),
              repeat: assignment.status,
              hour: _extractHour(assignment.publishAt),
              publishType: _mapTargetToArabic(assignment.target),
              patientNames: await _buildPatientNames(assignment),
              volunteerNames: _buildVolunteerNames(assignment),
            ),
          );
        }
      }

      emit(
        state.copyWith(
          publishedAssignments: items,
          isLoadingAssignments: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingAssignments: false,
          error: "حدث خطأ أثناء تحميل بيانات النشر.",
        ),
      );
    }
  }

  String _mapTargetToArabic(String target) {
    switch (target) {
      case "SINGLE_PATIENT":
        return "مريض واحد";
      case "ALL_PATIENTS":
        return "كل المرضى";
      case "VOLUNTEER_FOR_PATIENT":
        return "متطوع لمريض";
      default:
        return "غير محدد";
    }
  }

Future<List<String>> _buildPatientNames(dynamic assignment) async {
    if (assignment.target == "ALL_PATIENTS") return ["كل المرضى"];

    final name = assignment.patient?.fullName;

    if (name != null && name.toString().trim().isNotEmpty) {
      return [name.toString()];
    }

    final patientId = assignment.patient?.id;

    if (patientId == null || patientId.toString().trim().isEmpty) {
      return ["غير محدد"];
    }

    try {
      final patient = await repo.getPatientById(patientId.toString());
      return patient.fullName.trim().isEmpty
          ? ["غير محدد"]
          : [patient.fullName];
    } catch (_) {
      return ["غير محدد"];
    }
  }

  List<String> _buildVolunteerNames(dynamic assignment) {
    final name = assignment.volunteer?.fullName;

    if (name != null && name.toString().trim().isNotEmpty) {
      return [name.toString()];
    }

    return [];
  }

  String _formatIsoDate(String? value) {
    if (value == null || value.isEmpty) return "فوري";

    try {
      final date = DateTime.parse(value).toLocal();
      final y = date.year.toString();
      final m = date.month.toString().padLeft(2, "0");
      final d = date.day.toString().padLeft(2, "0");

      return "$y-$m-$d";
    } catch (_) {
      return value;
    }
  }

  String _extractHour(String? value) {
    if (value == null || value.isEmpty) return "-";

    try {
      final date = DateTime.parse(value).toLocal();
      final h = date.hour.toString().padLeft(2, "0");
      final m = date.minute.toString().padLeft(2, "0");

      return "$h:$m";
    } catch (_) {
      return "-";
    }
  }
}
