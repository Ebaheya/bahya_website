import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/helper/widgets/scheduled_list_widget.dart';

class PublishScheduleState {
  final bool isLoading;
  final bool isPublishing;
  final bool isSearchingPatients;
  final bool isSearchingVolunteers;
  final bool isLoadingAssignments;

  final String? error;

  final List<FormModel> activeForms;
  final List<FormModel> draftForms;
  final List<FormModel> publishedForms;

  final List<OptionUserModel> patientOptions;
  final List<OptionUserModel> volunteerOptions;

  final List<ScheduledItemModel> publishedAssignments;

  final Map<String, DateTime> lastPublishedAtByFormId;

  const PublishScheduleState({
    this.isLoading = false,
    this.isPublishing = false,
    this.isSearchingPatients = false,
    this.isSearchingVolunteers = false,
    this.isLoadingAssignments = false,
    this.error,
    this.activeForms = const [],
    this.draftForms = const [],
    this.publishedForms = const [],
    this.patientOptions = const [],
    this.volunteerOptions = const [],
    this.publishedAssignments = const [],
    this.lastPublishedAtByFormId = const {},
  });

  PublishScheduleState copyWith({
    bool? isLoading,
    bool? isPublishing,
    bool? isSearchingPatients,
    bool? isSearchingVolunteers,
    bool? isLoadingAssignments,
    String? error,
    List<FormModel>? activeForms,
    List<FormModel>? draftForms,
    List<FormModel>? publishedForms,
    List<OptionUserModel>? patientOptions,
    List<OptionUserModel>? volunteerOptions,
    List<ScheduledItemModel>? publishedAssignments,
    Map<String, DateTime>? lastPublishedAtByFormId,
  }) {
    return PublishScheduleState(
      isLoading: isLoading ?? this.isLoading,
      isPublishing: isPublishing ?? this.isPublishing,
      isSearchingPatients: isSearchingPatients ?? this.isSearchingPatients,
      isSearchingVolunteers:
          isSearchingVolunteers ?? this.isSearchingVolunteers,
      isLoadingAssignments: isLoadingAssignments ?? this.isLoadingAssignments,
      error: error,
      activeForms: activeForms ?? this.activeForms,
      draftForms: draftForms ?? this.draftForms,
      publishedForms: publishedForms ?? this.publishedForms,
      patientOptions: patientOptions ?? this.patientOptions,
      volunteerOptions: volunteerOptions ?? this.volunteerOptions,
      publishedAssignments: publishedAssignments ?? this.publishedAssignments,
      lastPublishedAtByFormId:
          lastPublishedAtByFormId ?? this.lastPublishedAtByFormId,
    );
  }
}
