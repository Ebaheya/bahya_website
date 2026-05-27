import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/data/api/models/options_model.dart';
import 'package:bahya_website/helper/widgets/scheduled_list_widget.dart';

class PublishScheduleState {
  final bool isLoading;
  final bool isPublishing;
  final bool isSearchingPatients;
  final bool isSearchingVolunteers;
  final String? error;
final List<ScheduledItemModel> publishedAssignments;
  final bool isLoadingAssignments;
  final List<FormModel> draftForms;
  final List<FormModel> publishedForms;

  final List<OptionUserModel> patientOptions;
  final List<OptionUserModel> volunteerOptions;

  const PublishScheduleState({
    this.isLoading = false,
    this.isPublishing = false,
    this.isSearchingPatients = false,
    this.isSearchingVolunteers = false,
    this.error,
    this.draftForms = const [],
    this.publishedForms = const [],
    this.patientOptions = const [],
    this.volunteerOptions = const [],
    this.publishedAssignments = const [],
    this.isLoadingAssignments = false,
  });

  PublishScheduleState copyWith({
    bool? isLoading,
    bool? isPublishing,
    bool? isSearchingPatients,
    bool? isSearchingVolunteers,
    String? error,
    List<FormModel>? draftForms,
    List<FormModel>? publishedForms,
    List<OptionUserModel>? patientOptions,
    List<ScheduledItemModel>? publishedAssignments,
    bool? isLoadingAssignments,
    List<OptionUserModel>? volunteerOptions,
  }) {
    return PublishScheduleState(
      isLoading: isLoading ?? this.isLoading,
      isPublishing: isPublishing ?? this.isPublishing,
      isSearchingPatients: isSearchingPatients ?? this.isSearchingPatients,
      isSearchingVolunteers:
          isSearchingVolunteers ?? this.isSearchingVolunteers,
      error: error,
      draftForms: draftForms ?? this.draftForms,
      publishedForms: publishedForms ?? this.publishedForms,
      patientOptions: patientOptions ?? this.patientOptions,
      volunteerOptions: volunteerOptions ?? this.volunteerOptions,
      publishedAssignments: publishedAssignments ?? this.publishedAssignments,
      isLoadingAssignments: isLoadingAssignments ?? this.isLoadingAssignments,
    );
  }
}
