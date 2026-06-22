import 'package:bahya_website/bloc/states/publish_schedule_state.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/widgets/schedule/scheduled_list_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PublishScheduleCubit extends Cubit<PublishScheduleState> {
  final AppRepository repo;

  PublishScheduleCubit(this.repo) : super(const PublishScheduleState());

  static const Duration republishDelay = Duration(hours: 6);

  Future<void> loadForms() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await repo.getForms();

      final activeForms = response.data
          .where((e) => e.isActive == true)
          .toList();

      final draftForms = activeForms
          .where(
            (e) => e.currentVersion?.status.trim().toUpperCase() == "DRAFT",
          )
          .toList();

      final publishedForms = activeForms
          .where(
            (e) => e.currentVersion?.status.trim().toUpperCase() == "PUBLISHED",
          )
          .toList();

      emit(
        state.copyWith(
          isLoading: false,
          activeForms: activeForms,
          draftForms: draftForms,
          publishedForms: publishedForms,
          clearError: true,
        ),
      );

      await loadPublishedAssignments();
    } catch (e) {
      debugPrint("Load forms failed: $e");
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

    emit(state.copyWith(isSearchingPatients: true, clearError: true));

    try {
      final response = await repo.getPatient(search: search);

      emit(
        state.copyWith(
          isSearchingPatients: false,
          patientOptions: response.data,
        ),
      );
    } catch (e) {
      debugPrint("Search patients failed: $e");
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

    emit(state.copyWith(isSearchingVolunteers: true, clearError: true));

    try {
      final response = await repo.getVolunteer(search: search);

      emit(
        state.copyWith(
          isSearchingVolunteers: false,
          volunteerOptions: response.data,
        ),
      );
    } catch (e) {
      debugPrint("Search volunteers failed: $e");
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

    if (form.isActive != true) {
      emit(
        state.copyWith(
          isPublishing: false,
          error: "هذا النموذج غير مفعّل. فعّله أولاً قبل النشر.",
          clearSuccessMessage: true,
        ),
      );
      return false;
    }

    final lastCreatedAt = state.lastPublishedAtByFormId[form.id];

    if (lastCreatedAt != null) {
      final now = DateTime.now().toUtc();
      final difference = now.difference(lastCreatedAt.toUtc());

      if (difference < republishDelay) {
        final remaining = republishDelay - difference;
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes.remainder(60);

        emit(
          state.copyWith(
            isPublishing: false,
            error:
                "لا يمكن إعادة نشر نفس النموذج الآن. انتظر $hours ساعة و $minutes دقيقة.",
            clearSuccessMessage: true,
          ),
        );

        return false;
      }
    }

    emit(
      state.copyWith(
        isPublishing: true,
        clearError: true,
        clearSuccessMessage: true,
      ),
    );

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

      final updatedLastPublished = Map<String, DateTime>.from(
        state.lastPublishedAtByFormId,
      );

      updatedLastPublished[form.id] = DateTime.now().toUtc();

      emit(
        state.copyWith(
          isPublishing: false,
          lastPublishedAtByFormId: updatedLastPublished,
          successMessage: "تم نشر النموذج بنجاح.",
          clearError: true,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 700));
      await loadForms();

      return true;
    } catch (e) {
      debugPrint("Publish form failed: $e");
      emit(
        state.copyWith(
          isPublishing: false,
          error: "حدث خطأ أثناء نشر النموذج.",
        ),
      );
      return false;
    }
  }

  Future<bool> cancelPublishedAssignment(String assignmentId) async {
    if (state.isCancellingAssignment) return false;

    emit(
      state.copyWith(
        isCancellingAssignment: true,
        clearError: true,
        clearSuccessMessage: true,
      ),
    );

    try {
      await repo.cancelFormAssignment(assignmentId: assignmentId);

      debugPrint("Assignment cancelled successfully: $assignmentId");

      final updatedItems = state.publishedAssignments
          .where((item) => item.id != assignmentId)
          .toList();

      emit(
        state.copyWith(
          isCancellingAssignment: false,
          publishedAssignments: updatedItems,
          successMessage: "تم إلغاء النشر بنجاح.",
          clearError: true,
        ),
      );

      await loadPublishedAssignments();

      return true;
    } catch (e) {
      debugPrint("Cancel assignment failed: $e");

      emit(
        state.copyWith(
          isCancellingAssignment: false,
          error: "حدث خطأ أثناء إلغاء النشر.",
        ),
      );

      return false;
    }
  }

  Future<void> loadPublishedAssignments() async {
    try {
      emit(state.copyWith(isLoadingAssignments: true, clearError: true));

      final List<ScheduledItemModel> items = [];
      final Map<String, DateTime> lastPublishedMap = {};

      for (final form in state.activeForms) {
        if (form.id.isEmpty) continue;

        final response = await repo.getFormAssignments(
          formId: form.id,
          pageSize: 100,
        );

        for (final assignment in response.data) {
          final createdAt = _extractCreatedAt(assignment);

          if (createdAt != null) {
            final oldDate = lastPublishedMap[form.id];

            if (oldDate == null || createdAt.isAfter(oldDate)) {
              lastPublishedMap[form.id] = createdAt;
            }
          }

          items.add(
            ScheduledItemModel(
              id: assignment.id.toString(),
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

      items.sort((a, b) {
        final aKey = "${a.date} ${a.hour}";
        final bKey = "${b.date} ${b.hour}";
        return bKey.compareTo(aKey);
      });

      emit(
        state.copyWith(
          publishedAssignments: items,
          lastPublishedAtByFormId: lastPublishedMap,
          isLoadingAssignments: false,
        ),
      );
    } catch (e) {
      debugPrint("Load published assignments failed: $e");
      emit(
        state.copyWith(
          isLoadingAssignments: false,
          error: "حدث خطأ أثناء تحميل بيانات النشر.",
        ),
      );
    }
  }

  DateTime? _extractCreatedAt(dynamic assignment) {
    try {
      final createdAt = assignment.createdAt;

      if (createdAt != null && createdAt.toString().trim().isNotEmpty) {
        return DateTime.parse(createdAt.toString()).toUtc();
      }
    } catch (_) {}

    return null;
  }

  String _mapTargetToArabic(String target) {
    switch (target) {
      case "SINGLE_PATIENT":
        return "مريض واحد";
      case "ALL_PATIENTS":
        return "كل المرضى";
      case "SELECTED_PATIENTS":
        return "مجموعة من المرضى";
      case "VOLUNTEER_FOR_PATIENT":
        return "متطوعين ومرضى";
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

  void emitPublishing(bool value) {
    emit(state.copyWith(isPublishing: value));
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
