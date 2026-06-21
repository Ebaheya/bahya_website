import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_generated_ar.dart';
import 'app_localizations_generated_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'lib/app_localizations_generated.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @aGroupOfPatients.
  ///
  /// In en, this message translates to:
  /// **'A group of patients'**
  String get aGroupOfPatients;

  /// No description provided for @aSinglePatient.
  ///
  /// In en, this message translates to:
  /// **'A single patient'**
  String get aSinglePatient;

  /// No description provided for @accessSavedForms.
  ///
  /// In en, this message translates to:
  /// **'Access saved forms'**
  String get accessSavedForms;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @changeYourAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Change your account password'**
  String get changeYourAccountPassword;

  /// No description provided for @activated.
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get activated;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activeTreatment.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE_TREATMENT'**
  String get activeTreatment;

  /// No description provided for @activeTreatment2.
  ///
  /// In en, this message translates to:
  /// **'Active treatment'**
  String get activeTreatment2;

  /// No description provided for @activeUsers.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get activeUsers;

  /// No description provided for @addNewDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Add new diagnosis'**
  String get addNewDiagnosis;

  /// No description provided for @addNewPatient.
  ///
  /// In en, this message translates to:
  /// **'Add new patient'**
  String get addNewPatient;

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewUser;

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get addOption;

  /// No description provided for @addQuestions.
  ///
  /// In en, this message translates to:
  /// **'Add questions'**
  String get addQuestions;

  /// No description provided for @addQuestionsAndAnswers.
  ///
  /// In en, this message translates to:
  /// **'Add questions and answers'**
  String get addQuestionsAndAnswers;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @adjuvant.
  ///
  /// In en, this message translates to:
  /// **'Adjuvant'**
  String get adjuvant;

  /// No description provided for @adjuvant2.
  ///
  /// In en, this message translates to:
  /// **'ADJUVANT'**
  String get adjuvant2;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @admin2.
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get admin2;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminPanel;

  /// No description provided for @adminPanel2.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel2;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allActivities.
  ///
  /// In en, this message translates to:
  /// **'All Activities'**
  String get allActivities;

  /// No description provided for @allClinicalDataRequiredForThePsychosocialProject.
  ///
  /// In en, this message translates to:
  /// **'All clinical data required for the psychosocial project'**
  String get allClinicalDataRequiredForThePsychosocialProject;

  /// No description provided for @allPatients.
  ///
  /// In en, this message translates to:
  /// **'All patients'**
  String get allPatients;

  /// No description provided for @allRole.
  ///
  /// In en, this message translates to:
  /// **'All Role'**
  String get allRole;

  /// No description provided for @allRoles.
  ///
  /// In en, this message translates to:
  /// **'All Roles'**
  String get allRoles;

  /// No description provided for @allRoles2.
  ///
  /// In en, this message translates to:
  /// **'All roles'**
  String get allRoles2;

  /// No description provided for @allStatus.
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get allStatus;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get allStatuses;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get allTypes;

  /// No description provided for @always.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get always;

  /// No description provided for @anErrorOccurredWhileActivatingTheForm.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while activating the form.'**
  String get anErrorOccurredWhileActivatingTheForm;

  /// No description provided for @anErrorOccurredWhileDeletingTheQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the questionnaire.'**
  String get anErrorOccurredWhileDeletingTheQuestionnaire;

  /// No description provided for @anErrorOccurredWhileDisablingTheForm.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while disabling the form.'**
  String get anErrorOccurredWhileDisablingTheForm;

  /// No description provided for @anErrorOccurredWhileLoadingForms.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading forms.'**
  String get anErrorOccurredWhileLoadingForms;

  /// No description provided for @anErrorOccurredWhileLoadingTheQuestionnaireForEditing.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading the questionnaire for editing.'**
  String get anErrorOccurredWhileLoadingTheQuestionnaireForEditing;

  /// No description provided for @anErrorOccurredWhilePublishingSomeForms.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while publishing some forms.'**
  String get anErrorOccurredWhilePublishingSomeForms;

  /// No description provided for @anErrorOccurredWhileSavingTheQuestionnaireTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving the questionnaire. Try again.'**
  String get anErrorOccurredWhileSavingTheQuestionnaireTryAgain;

  /// No description provided for @anErrorOccurredWhileSigningOutTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while signing out. Try again.'**
  String get anErrorOccurredWhileSigningOutTryAgain;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @answerAgain.
  ///
  /// In en, this message translates to:
  /// **'Answer again'**
  String get answerAgain;

  /// No description provided for @answerDate.
  ///
  /// In en, this message translates to:
  /// **'Answer date'**
  String get answerDate;

  /// No description provided for @answerDetails.
  ///
  /// In en, this message translates to:
  /// **'Answer details'**
  String get answerDetails;

  /// No description provided for @answerMoreThanHalfTheDays.
  ///
  /// In en, this message translates to:
  /// **'Answer: More than half the days'**
  String get answerMoreThanHalfTheDays;

  /// No description provided for @anxiety.
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get anxiety;

  /// No description provided for @anxietyQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Anxiety questionnaire'**
  String get anxietyQuestionnaire;

  /// No description provided for @anxietyReductionRate.
  ///
  /// In en, this message translates to:
  /// **'Anxiety reduction rate'**
  String get anxietyReductionRate;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @areYouSureYouWantToDeleteThisQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this questionnaire?'**
  String get areYouSureYouWantToDeleteThisQuestionnaire;

  /// No description provided for @assessmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Assessment details'**
  String get assessmentDetails;

  /// No description provided for @assessmentSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Assessment saved successfully'**
  String get assessmentSavedSuccessfully;

  /// No description provided for @assessments.
  ///
  /// In en, this message translates to:
  /// **'Assessments'**
  String get assessments;

  /// No description provided for @atLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Characters;

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBackup;

  /// No description provided for @availableForms.
  ///
  /// In en, this message translates to:
  /// **'Available forms'**
  String get availableForms;

  /// No description provided for @averageAge.
  ///
  /// In en, this message translates to:
  /// **'Average age'**
  String get averageAge;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get basicInformation;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @breastCancer.
  ///
  /// In en, this message translates to:
  /// **'Breast cancer'**
  String get breastCancer;

  /// No description provided for @breastConservative.
  ///
  /// In en, this message translates to:
  /// **'BREAST_CONSERVATIVE'**
  String get breastConservative;

  /// No description provided for @breastConservativeSurgery.
  ///
  /// In en, this message translates to:
  /// **'BREAST_CONSERVATIVE_SURGERY'**
  String get breastConservativeSurgery;

  /// No description provided for @breastConservativeSurgery2.
  ///
  /// In en, this message translates to:
  /// **'Breast Conservative Surgery'**
  String get breastConservativeSurgery2;

  /// No description provided for @breastConservativeSurgery3.
  ///
  /// In en, this message translates to:
  /// **'Breast Conservative surgery'**
  String get breastConservativeSurgery3;

  /// No description provided for @callCenter.
  ///
  /// In en, this message translates to:
  /// **'CALL_CENTER'**
  String get callCenter;

  /// No description provided for @callCenter2.
  ///
  /// In en, this message translates to:
  /// **'Call center'**
  String get callCenter2;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel edit'**
  String get cancelEdit;

  /// No description provided for @cancelPublishing.
  ///
  /// In en, this message translates to:
  /// **'Cancel publishing'**
  String get cancelPublishing;

  /// No description provided for @cancelSchedule.
  ///
  /// In en, this message translates to:
  /// **'Cancel schedule'**
  String get cancelSchedule;

  /// No description provided for @cannotAddMoreThan.
  ///
  /// In en, this message translates to:
  /// **'Cannot add more than'**
  String get cannotAddMoreThan;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @changeName.
  ///
  /// In en, this message translates to:
  /// **'Change name'**
  String get changeName;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change Status'**
  String get changeStatus;

  /// No description provided for @changingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Changing language'**
  String get changingLanguage;

  /// No description provided for @chemotherapy.
  ///
  /// In en, this message translates to:
  /// **'Chemotherapy'**
  String get chemotherapy;

  /// No description provided for @chooseAFormFromTheList.
  ///
  /// In en, this message translates to:
  /// **'Choose a form from the list'**
  String get chooseAFormFromTheList;

  /// No description provided for @chooseAFormToPublish.
  ///
  /// In en, this message translates to:
  /// **'Choose a form to publish'**
  String get chooseAFormToPublish;

  /// No description provided for @chooseAFormToStartFillingTheQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Choose a form to start filling the questionnaire'**
  String get chooseAFormToStartFillingTheQuestionnaire;

  /// No description provided for @chooseBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Choose birth date'**
  String get chooseBirthDate;

  /// No description provided for @chooseDepartment.
  ///
  /// In en, this message translates to:
  /// **'Choose Department'**
  String get chooseDepartment;

  /// No description provided for @chooseDiagnosisDate.
  ///
  /// In en, this message translates to:
  /// **'Choose diagnosis date'**
  String get chooseDiagnosisDate;

  /// No description provided for @chooseMenopausalStatus.
  ///
  /// In en, this message translates to:
  /// **'Choose menopausal status'**
  String get chooseMenopausalStatus;

  /// No description provided for @choosePublishingType.
  ///
  /// In en, this message translates to:
  /// **'Choose publishing type'**
  String get choosePublishingType;

  /// No description provided for @chooseRole.
  ///
  /// In en, this message translates to:
  /// **'Choose Role'**
  String get chooseRole;

  /// No description provided for @chooseThePatientThenStartAnsweringManually.
  ///
  /// In en, this message translates to:
  /// **'Choose the patient then start answering manually'**
  String get chooseThePatientThenStartAnsweringManually;

  /// No description provided for @chooseTheRightServiceFromTheListBelow.
  ///
  /// In en, this message translates to:
  /// **'Choose the right service from the list below'**
  String get chooseTheRightServiceFromTheListBelow;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// No description provided for @clickForDetails.
  ///
  /// In en, this message translates to:
  /// **'Click for details'**
  String get clickForDetails;

  /// No description provided for @clinicalData.
  ///
  /// In en, this message translates to:
  /// **'Clinical data'**
  String get clinicalData;

  /// No description provided for @comorbidities.
  ///
  /// In en, this message translates to:
  /// **'Comorbidities'**
  String get comorbidities;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @configureNotificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Configure notification preferences'**
  String get configureNotificationPreferences;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get contactName;

  /// No description provided for @contactYouByPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact you by phone'**
  String get contactYouByPhone;

  /// No description provided for @contentReport.
  ///
  /// In en, this message translates to:
  /// **'Content Report'**
  String get contentReport;

  /// No description provided for @controlDataStorageAndBackupSettings.
  ///
  /// In en, this message translates to:
  /// **'Control data storage and backup settings'**
  String get controlDataStorageAndBackupSettings;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @createAndEditQuestionForms.
  ///
  /// In en, this message translates to:
  /// **'Create and edit question forms'**
  String get createAndEditQuestionForms;

  /// No description provided for @createNewDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Create new diagnosis'**
  String get createNewDiagnosis;

  /// No description provided for @createNewQuestion.
  ///
  /// In en, this message translates to:
  /// **'Create new question'**
  String get createNewQuestion;

  /// No description provided for @createNewQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Create new questionnaire'**
  String get createNewQuestionnaire;

  /// No description provided for @createPatient.
  ///
  /// In en, this message translates to:
  /// **'Create Patient'**
  String get createPatient;

  /// No description provided for @createStaff.
  ///
  /// In en, this message translates to:
  /// **'Create Staff'**
  String get createStaff;

  /// No description provided for @currentDiseaseStatus.
  ///
  /// In en, this message translates to:
  /// **'Current disease status'**
  String get currentDiseaseStatus;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @dailyAt200Am.
  ///
  /// In en, this message translates to:
  /// **'Daily at 2:00 AM'**
  String get dailyAt200Am;

  /// No description provided for @dailyDose.
  ///
  /// In en, this message translates to:
  /// **'Daily dose'**
  String get dailyDose;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get dashboardOverview;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @dataRetention.
  ///
  /// In en, this message translates to:
  /// **'Data Retention'**
  String get dataRetention;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Delete questionnaire'**
  String get deleteQuestionnaire;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @depression.
  ///
  /// In en, this message translates to:
  /// **'Depression'**
  String get depression;

  /// No description provided for @depressionReductionRate.
  ///
  /// In en, this message translates to:
  /// **'Depression reduction rate'**
  String get depressionReductionRate;

  /// No description provided for @detailedAnswers.
  ///
  /// In en, this message translates to:
  /// **'Detailed answers'**
  String get detailedAnswers;

  /// No description provided for @diabetes.
  ///
  /// In en, this message translates to:
  /// **'diabetes'**
  String get diabetes;

  /// No description provided for @diagnoses.
  ///
  /// In en, this message translates to:
  /// **'diagnoses.'**
  String get diagnoses;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get diagnosis;

  /// No description provided for @diagnosisComparisonChart.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis comparison chart'**
  String get diagnosisComparisonChart;

  /// No description provided for @diagnosisDate.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis date'**
  String get diagnosisDate;

  /// No description provided for @diagnosisModerateAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis: moderate anxiety'**
  String get diagnosisModerateAnxiety;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @diseaseStatus.
  ///
  /// In en, this message translates to:
  /// **'Disease status'**
  String get diseaseStatus;

  /// No description provided for @doYouFeelTenseOrNervous.
  ///
  /// In en, this message translates to:
  /// **'Do you feel tense or nervous?'**
  String get doYouFeelTenseOrNervous;

  /// No description provided for @doYouHaveDifficultyControllingWorry.
  ///
  /// In en, this message translates to:
  /// **'Do you have difficulty controlling worry?'**
  String get doYouHaveDifficultyControllingWorry;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @doctor2.
  ///
  /// In en, this message translates to:
  /// **'DOCTOR'**
  String get doctor2;

  /// No description provided for @doctorNotes.
  ///
  /// In en, this message translates to:
  /// **'Doctor notes'**
  String get doctorNotes;

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @doneSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Done successfully'**
  String get doneSuccessfully;

  /// No description provided for @eG.
  ///
  /// In en, this message translates to:
  /// **'e.g.'**
  String get eG;

  /// No description provided for @eGDiabetesHypertension.
  ///
  /// In en, this message translates to:
  /// **'e.g. diabetes, hypertension'**
  String get eGDiabetesHypertension;

  /// No description provided for @eGLoginIssue.
  ///
  /// In en, this message translates to:
  /// **'e.g. login issue'**
  String get eGLoginIssue;

  /// No description provided for @eGStageTwo.
  ///
  /// In en, this message translates to:
  /// **'e.g. stage two'**
  String get eGStageTwo;

  /// No description provided for @eGYesBreastCancer.
  ///
  /// In en, this message translates to:
  /// **'e.g. yes - breast cancer'**
  String get eGYesBreastCancer;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editMode.
  ///
  /// In en, this message translates to:
  /// **'Edit mode'**
  String get editMode;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'EDITED'**
  String get edited;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get emergencyContact;

  /// No description provided for @emergencyContactName.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Name'**
  String get emergencyContactName;

  /// No description provided for @emergencyContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Phone'**
  String get emergencyContactPhone;

  /// No description provided for @emergencyInformation.
  ///
  /// In en, this message translates to:
  /// **'Emergency information'**
  String get emergencyInformation;

  /// No description provided for @emergencyNumber.
  ///
  /// In en, this message translates to:
  /// **'Emergency number'**
  String get emergencyNumber;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @enterAValidDateMmDdYyyy.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date (mm/dd/yyyy)'**
  String get enterAValidDateMmDdYyyy;

  /// No description provided for @enterAValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterAValidEmailAddress;

  /// No description provided for @enterAValidName.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid name'**
  String get enterAValidName;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter age'**
  String get enterAge;

  /// No description provided for @enterAn11DigitPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter an 11-digit phone number'**
  String get enterAn11DigitPhoneNumber;

  /// No description provided for @enterFullPatientName.
  ///
  /// In en, this message translates to:
  /// **'Enter full patient name'**
  String get enterFullPatientName;

  /// No description provided for @enterNumbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Enter numbers only'**
  String get enterNumbersOnly;

  /// No description provided for @enterOption.
  ///
  /// In en, this message translates to:
  /// **'Enter option'**
  String get enterOption;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @enterPatientAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter patient address'**
  String get enterPatientAddress;

  /// No description provided for @enterPatientName.
  ///
  /// In en, this message translates to:
  /// **'Enter patient name'**
  String get enterPatientName;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterQuestionnaireName.
  ///
  /// In en, this message translates to:
  /// **'Enter Questionnaire Name'**
  String get enterQuestionnaireName;

  /// No description provided for @enterTheIssueTitleAndDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter the issue title and details'**
  String get enterTheIssueTitleAndDetails;

  /// No description provided for @enterTheNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password'**
  String get enterTheNewPassword;

  /// No description provided for @enterThePatientBasicAndClinicalData.
  ///
  /// In en, this message translates to:
  /// **'Enter the patient basic and clinical data'**
  String get enterThePatientBasicAndClinicalData;

  /// No description provided for @enterYourEmailAndChooseAPreferredContactMethod.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and choose a preferred contact method'**
  String get enterYourEmailAndChooseAPreferredContactMethod;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @error2.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get error2;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// No description provided for @failedToCreatePatient.
  ///
  /// In en, this message translates to:
  /// **'Failed to create patient:'**
  String get failedToCreatePatient;

  /// No description provided for @failedToCreateStaff.
  ///
  /// In en, this message translates to:
  /// **'Failed to create staff:'**
  String get failedToCreateStaff;

  /// No description provided for @familyHistory.
  ///
  /// In en, this message translates to:
  /// **'Family history'**
  String get familyHistory;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'FEMALE'**
  String get female;

  /// No description provided for @female2.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female2;

  /// No description provided for @fileNumber.
  ///
  /// In en, this message translates to:
  /// **'File number'**
  String get fileNumber;

  /// No description provided for @fillOutQuestionnaires.
  ///
  /// In en, this message translates to:
  /// **'Fill out questionnaires'**
  String get fillOutQuestionnaires;

  /// No description provided for @fillOutTheFormForThePatient.
  ///
  /// In en, this message translates to:
  /// **'Fill out the form for the patient'**
  String get fillOutTheFormForThePatient;

  /// No description provided for @fillPatientQuestionnaires.
  ///
  /// In en, this message translates to:
  /// **'Fill patient questionnaires'**
  String get fillPatientQuestionnaires;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'FOLLOW_UP'**
  String get followUp;

  /// No description provided for @followUp2.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp2;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// No description provided for @formName.
  ///
  /// In en, this message translates to:
  /// **'Form name'**
  String get formName;

  /// No description provided for @formScheduleWasCancelled.
  ///
  /// In en, this message translates to:
  /// **'Form schedule was cancelled'**
  String get formScheduleWasCancelled;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullPatientName.
  ///
  /// In en, this message translates to:
  /// **'Full patient name'**
  String get fullPatientName;

  /// No description provided for @gad7Questionnaire.
  ///
  /// In en, this message translates to:
  /// **'GAD-7 questionnaire'**
  String get gad7Questionnaire;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @generalAnxietyAssessment.
  ///
  /// In en, this message translates to:
  /// **'General anxiety assessment'**
  String get generalAnxietyAssessment;

  /// No description provided for @generalMentalDisorder.
  ///
  /// In en, this message translates to:
  /// **'General mental disorder'**
  String get generalMentalDisorder;

  /// No description provided for @generalStatisticsDashboard.
  ///
  /// In en, this message translates to:
  /// **'General statistics dashboard'**
  String get generalStatisticsDashboard;

  /// No description provided for @hasnaaAhmed.
  ///
  /// In en, this message translates to:
  /// **'Hasnaa Ahmed'**
  String get hasnaaAhmed;

  /// No description provided for @her2Enriched.
  ///
  /// In en, this message translates to:
  /// **'HER2-enriched'**
  String get her2Enriched;

  /// No description provided for @her2Enriched2.
  ///
  /// In en, this message translates to:
  /// **'HER2_ENRICHED'**
  String get her2Enriched2;

  /// No description provided for @hereYouCanWriteDoctorNotes.
  ///
  /// In en, this message translates to:
  /// **'Here you can write doctor notes...'**
  String get hereYouCanWriteDoctorNotes;

  /// No description provided for @hormonalTherapy.
  ///
  /// In en, this message translates to:
  /// **'Hormonal therapy'**
  String get hormonalTherapy;

  /// No description provided for @hypertension.
  ///
  /// In en, this message translates to:
  /// **'hypertension'**
  String get hypertension;

  /// No description provided for @immunotherapy.
  ///
  /// In en, this message translates to:
  /// **'Immunotherapy'**
  String get immunotherapy;

  /// No description provided for @immunotherapyIfAny.
  ///
  /// In en, this message translates to:
  /// **'Immunotherapy if any'**
  String get immunotherapyIfAny;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @incorrectEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get incorrectEmailOrPassword;

  /// No description provided for @initialAssessment.
  ///
  /// In en, this message translates to:
  /// **'Initial assessment'**
  String get initialAssessment;

  /// No description provided for @invalidResetToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid reset token'**
  String get invalidResetToken;

  /// No description provided for @investigating.
  ///
  /// In en, this message translates to:
  /// **'Investigating'**
  String get investigating;

  /// No description provided for @ipWhitelist.
  ///
  /// In en, this message translates to:
  /// **'IP Whitelist'**
  String get ipWhitelist;

  /// No description provided for @irreversibleActions.
  ///
  /// In en, this message translates to:
  /// **'Irreversible actions'**
  String get irreversibleActions;

  /// No description provided for @issueDetails.
  ///
  /// In en, this message translates to:
  /// **'Issue details'**
  String get issueDetails;

  /// No description provided for @issueTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue title'**
  String get issueTitle;

  /// No description provided for @itemsPerPage.
  ///
  /// In en, this message translates to:
  /// **'Items per page'**
  String get itemsPerPage;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumber;

  /// No description provided for @listOfAssessmentsCompletedByThePatient.
  ///
  /// In en, this message translates to:
  /// **'List of assessments completed by the patient'**
  String get listOfAssessmentsCompletedByThePatient;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @loggedInSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get loggedInSuccessfully;

  /// No description provided for @loggedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully.'**
  String get loggedOutSuccessfully;

  /// No description provided for @loginAndIdentityInformation.
  ///
  /// In en, this message translates to:
  /// **'Login and identity information'**
  String get loginAndIdentityInformation;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @luminalA.
  ///
  /// In en, this message translates to:
  /// **'Luminal A'**
  String get luminalA;

  /// No description provided for @luminalA2.
  ///
  /// In en, this message translates to:
  /// **'LUMINAL_A'**
  String get luminalA2;

  /// No description provided for @luminalB.
  ///
  /// In en, this message translates to:
  /// **'Luminal B'**
  String get luminalB;

  /// No description provided for @luminalB2.
  ///
  /// In en, this message translates to:
  /// **'LUMINAL_B'**
  String get luminalB2;

  /// No description provided for @mainDashboard.
  ///
  /// In en, this message translates to:
  /// **'Main dashboard'**
  String get mainDashboard;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'MALE'**
  String get male;

  /// No description provided for @male2.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male2;

  /// No description provided for @manageAccountData.
  ///
  /// In en, this message translates to:
  /// **'Manage account data'**
  String get manageAccountData;

  /// No description provided for @manageAndMonitorAllPlatformUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage and monitor all platform users'**
  String get manageAndMonitorAllPlatformUsers;

  /// No description provided for @manageSecurityAndPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Manage security and privacy settings'**
  String get manageSecurityAndPrivacySettings;

  /// No description provided for @manageYourAccountInformationAndPreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your account information and preferences'**
  String get manageYourAccountInformationAndPreferences;

  /// No description provided for @manageYourAccountPreferencesAndSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage your account, preferences and system settings'**
  String get manageYourAccountPreferencesAndSystemSettings;

  /// No description provided for @mastectomy.
  ///
  /// In en, this message translates to:
  /// **'MASTECTOMY'**
  String get mastectomy;

  /// No description provided for @mastectomy2.
  ///
  /// In en, this message translates to:
  /// **'Mastectomy'**
  String get mastectomy2;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @menopausalStatus.
  ///
  /// In en, this message translates to:
  /// **'Menopausal status'**
  String get menopausalStatus;

  /// No description provided for @mentalDisorder.
  ///
  /// In en, this message translates to:
  /// **'Mental disorder'**
  String get mentalDisorder;

  /// No description provided for @message30Minutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get message30Minutes;

  /// No description provided for @message90Days.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get message90Days;

  /// No description provided for @metastatic.
  ///
  /// In en, this message translates to:
  /// **'Metastatic'**
  String get metastatic;

  /// No description provided for @metastatic2.
  ///
  /// In en, this message translates to:
  /// **'METASTATIC'**
  String get metastatic2;

  /// No description provided for @metastaticChemotherapy.
  ///
  /// In en, this message translates to:
  /// **'METASTATIC_CHEMOTHERAPY'**
  String get metastaticChemotherapy;

  /// No description provided for @mildAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Mild anxiety'**
  String get mildAnxiety;

  /// No description provided for @mildDepression.
  ///
  /// In en, this message translates to:
  /// **'Mild depression'**
  String get mildDepression;

  /// No description provided for @moderateAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Moderate anxiety'**
  String get moderateAnxiety;

  /// No description provided for @moderateDepression.
  ///
  /// In en, this message translates to:
  /// **'Moderate depression'**
  String get moderateDepression;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @moreInformation.
  ///
  /// In en, this message translates to:
  /// **'More information'**
  String get moreInformation;

  /// No description provided for @moreThanHalfTheDays.
  ///
  /// In en, this message translates to:
  /// **'More than half the days'**
  String get moreThanHalfTheDays;

  /// No description provided for @multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get multipleChoice;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameAToZ.
  ///
  /// In en, this message translates to:
  /// **'Name A to Z'**
  String get nameAToZ;

  /// No description provided for @nameZToA.
  ///
  /// In en, this message translates to:
  /// **'Name Z to A'**
  String get nameZToA;

  /// No description provided for @needsSpecialistEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Needs specialist evaluation'**
  String get needsSpecialistEvaluation;

  /// No description provided for @neoadjuvant.
  ///
  /// In en, this message translates to:
  /// **'Neoadjuvant'**
  String get neoadjuvant;

  /// No description provided for @neoadjuvant2.
  ///
  /// In en, this message translates to:
  /// **'NEOADJUVANT'**
  String get neoadjuvant2;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @newlyDiagnosed.
  ///
  /// In en, this message translates to:
  /// **'Newly diagnosed'**
  String get newlyDiagnosed;

  /// No description provided for @newlyDiagnosed2.
  ///
  /// In en, this message translates to:
  /// **'NEWLY_DIAGNOSED'**
  String get newlyDiagnosed2;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get no;

  /// No description provided for @no2.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no2;

  /// No description provided for @noAnswers.
  ///
  /// In en, this message translates to:
  /// **'No answers'**
  String get noAnswers;

  /// No description provided for @noAssessmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No assessments yet'**
  String get noAssessmentsYet;

  /// No description provided for @noDone.
  ///
  /// In en, this message translates to:
  /// **'No Done'**
  String get noDone;

  /// No description provided for @noForms.
  ///
  /// In en, this message translates to:
  /// **'No forms'**
  String get noForms;

  /// No description provided for @noFormsAreCurrentlyPublished.
  ///
  /// In en, this message translates to:
  /// **'No forms are currently published'**
  String get noFormsAreCurrentlyPublished;

  /// No description provided for @noSavedFormsYet.
  ///
  /// In en, this message translates to:
  /// **'No saved forms yet.'**
  String get noSavedFormsYet;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @nodone.
  ///
  /// In en, this message translates to:
  /// **'NoDone'**
  String get nodone;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get none;

  /// No description provided for @none2.
  ///
  /// In en, this message translates to:
  /// **'NONE'**
  String get none2;

  /// No description provided for @none3.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none3;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @normalCases.
  ///
  /// In en, this message translates to:
  /// **'Normal cases'**
  String get normalCases;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @nurses.
  ///
  /// In en, this message translates to:
  /// **'Nurses'**
  String get nurses;

  /// No description provided for @ofTotalPatients.
  ///
  /// In en, this message translates to:
  /// **'of total patients'**
  String get ofTotalPatients;

  /// No description provided for @often.
  ///
  /// In en, this message translates to:
  /// **'Often'**
  String get often;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @oldestAge.
  ///
  /// In en, this message translates to:
  /// **'Oldest age'**
  String get oldestAge;

  /// No description provided for @oldestRegistrationDate.
  ///
  /// In en, this message translates to:
  /// **'Oldest registration date'**
  String get oldestRegistrationDate;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @options2.
  ///
  /// In en, this message translates to:
  /// **'options'**
  String get options2;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'OTHER'**
  String get other;

  /// No description provided for @other2.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other2;

  /// No description provided for @overallImprovementRate.
  ///
  /// In en, this message translates to:
  /// **'Overall improvement rate'**
  String get overallImprovementRate;

  /// No description provided for @palliative.
  ///
  /// In en, this message translates to:
  /// **'Palliative'**
  String get palliative;

  /// No description provided for @palliative2.
  ///
  /// In en, this message translates to:
  /// **'PALLIATIVE'**
  String get palliative2;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordCanContainOnlyEnglishLettersNumbersAndSpecialCharacters.
  ///
  /// In en, this message translates to:
  /// **'Password can contain only English letters, numbers, and special characters'**
  String get passwordCanContainOnlyEnglishLettersNumbersAndSpecialCharacters;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordHasBeenResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password has been reset successfully'**
  String get passwordHasBeenResetSuccessfully;

  /// No description provided for @passwordMustBeAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMustBeAtLeast8Characters;

  /// No description provided for @passwordResetInstructionsHaveBeenSentToYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Password reset instructions have been sent to your email'**
  String get passwordResetInstructionsHaveBeenSentToYourEmail;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @patient2.
  ///
  /// In en, this message translates to:
  /// **'PATIENT'**
  String get patient2;

  /// No description provided for @patientAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Patient added successfully'**
  String get patientAddedSuccessfully;

  /// No description provided for @patientAddress.
  ///
  /// In en, this message translates to:
  /// **'Patient address'**
  String get patientAddress;

  /// No description provided for @patientClinicalData.
  ///
  /// In en, this message translates to:
  /// **'Patient clinical data'**
  String get patientClinicalData;

  /// No description provided for @patientCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Patient created successfully'**
  String get patientCreatedSuccessfully;

  /// No description provided for @patientData.
  ///
  /// In en, this message translates to:
  /// **'Patient data'**
  String get patientData;

  /// No description provided for @patientDataAndClinicalStatusInOnePlace.
  ///
  /// In en, this message translates to:
  /// **'Patient data and clinical status in one place'**
  String get patientDataAndClinicalStatusInOnePlace;

  /// No description provided for @patientInformation.
  ///
  /// In en, this message translates to:
  /// **'Patient information'**
  String get patientInformation;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient name'**
  String get patientName;

  /// No description provided for @patientPersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Patient personal information'**
  String get patientPersonalInformation;

  /// No description provided for @patientProgressChart.
  ///
  /// In en, this message translates to:
  /// **'Patient progress chart'**
  String get patientProgressChart;

  /// No description provided for @patientStatus.
  ///
  /// In en, this message translates to:
  /// **'Patient status'**
  String get patientStatus;

  /// No description provided for @patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients;

  /// No description provided for @patientsList.
  ///
  /// In en, this message translates to:
  /// **'Patients list'**
  String get patientsList;

  /// No description provided for @patientsWithNormalCases.
  ///
  /// In en, this message translates to:
  /// **'Patients with normal cases'**
  String get patientsWithNormalCases;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get percent;

  /// No description provided for @periMenopausal.
  ///
  /// In en, this message translates to:
  /// **'PERI_MENOPAUSAL'**
  String get periMenopausal;

  /// No description provided for @periMenopausal2.
  ///
  /// In en, this message translates to:
  /// **'Peri-menopausal'**
  String get periMenopausal2;

  /// No description provided for @permanentlyDeleteAllDataFromTheSystem.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all data from the system'**
  String get permanentlyDeleteAllDataFromTheSystem;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneNumber2.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber2;

  /// No description provided for @phq9Questionnaire.
  ///
  /// In en, this message translates to:
  /// **'PHQ-9 questionnaire'**
  String get phq9Questionnaire;

  /// No description provided for @pleaseCompleteAllRequiredSelections.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required selections'**
  String get pleaseCompleteAllRequiredSelections;

  /// No description provided for @pleaseCompleteAllSelections.
  ///
  /// In en, this message translates to:
  /// **'Please complete all selections'**
  String get pleaseCompleteAllSelections;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseFixTheFieldErrors.
  ///
  /// In en, this message translates to:
  /// **'Please fix the field errors.'**
  String get pleaseFixTheFieldErrors;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @postMenopausal.
  ///
  /// In en, this message translates to:
  /// **'POST_MENOPAUSAL'**
  String get postMenopausal;

  /// No description provided for @postMenopausal2.
  ///
  /// In en, this message translates to:
  /// **'Post-menopausal'**
  String get postMenopausal2;

  /// No description provided for @postmenopausal.
  ///
  /// In en, this message translates to:
  /// **'Postmenopausal'**
  String get postmenopausal;

  /// No description provided for @preMenopausal.
  ///
  /// In en, this message translates to:
  /// **'PRE_MENOPAUSAL'**
  String get preMenopausal;

  /// No description provided for @preMenopausal2.
  ///
  /// In en, this message translates to:
  /// **'Pre-menopausal'**
  String get preMenopausal2;

  /// No description provided for @prePostMenopause.
  ///
  /// In en, this message translates to:
  /// **'Pre / post menopause'**
  String get prePostMenopause;

  /// No description provided for @preferredContactMethod.
  ///
  /// In en, this message translates to:
  /// **'Preferred contact method'**
  String get preferredContactMethod;

  /// No description provided for @premenopausal.
  ///
  /// In en, this message translates to:
  /// **'Premenopausal'**
  String get premenopausal;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @problemBody.
  ///
  /// In en, this message translates to:
  /// **'Problem Body'**
  String get problemBody;

  /// No description provided for @problemSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Problem sent successfully'**
  String get problemSentSuccessfully;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Profile Name'**
  String get profileName;

  /// No description provided for @profileName2.
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get profileName2;

  /// No description provided for @psychologicalSupportTeam.
  ///
  /// In en, this message translates to:
  /// **'Psychological Support Team'**
  String get psychologicalSupportTeam;

  /// No description provided for @publishForm.
  ///
  /// In en, this message translates to:
  /// **'Publish form'**
  String get publishForm;

  /// No description provided for @publishQuestions.
  ///
  /// In en, this message translates to:
  /// **'Publish questions'**
  String get publishQuestions;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @publishedForms.
  ///
  /// In en, this message translates to:
  /// **'Published forms'**
  String get publishedForms;

  /// No description provided for @publishingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Publishing cancelled'**
  String get publishingCancelled;

  /// No description provided for @publishingDate.
  ///
  /// In en, this message translates to:
  /// **'Publishing date'**
  String get publishingDate;

  /// No description provided for @publishingTime.
  ///
  /// In en, this message translates to:
  /// **'Publishing time'**
  String get publishingTime;

  /// No description provided for @publishingType.
  ///
  /// In en, this message translates to:
  /// **'Publishing type'**
  String get publishingType;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @question1HaveYouFeltLittleInterestOrPleasureInDoingThings.
  ///
  /// In en, this message translates to:
  /// **'Question 1: Have you felt little interest or pleasure in doing things?'**
  String get question1HaveYouFeltLittleInterestOrPleasureInDoingThings;

  /// No description provided for @questionText.
  ///
  /// In en, this message translates to:
  /// **'Question text'**
  String get questionText;

  /// No description provided for @questionnaireRecordedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire recorded successfully'**
  String get questionnaireRecordedSuccessfully;

  /// No description provided for @questionnaireTitle.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire Title'**
  String get questionnaireTitle;

  /// No description provided for @questionsInOneQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'questions in one questionnaire.'**
  String get questionsInOneQuestionnaire;

  /// No description provided for @radiotherapy.
  ///
  /// In en, this message translates to:
  /// **'Radiotherapy'**
  String get radiotherapy;

  /// No description provided for @receiveInstructionsByEmail.
  ///
  /// In en, this message translates to:
  /// **'Receive instructions by email'**
  String get receiveInstructionsByEmail;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @recentRegistrationDate.
  ///
  /// In en, this message translates to:
  /// **'Recent Registration date'**
  String get recentRegistrationDate;

  /// No description provided for @recoverPassword.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get recoverPassword;

  /// No description provided for @recurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get recurrence;

  /// No description provided for @recurrence2.
  ///
  /// In en, this message translates to:
  /// **'RECURRENCE'**
  String get recurrence2;

  /// No description provided for @registrationDate.
  ///
  /// In en, this message translates to:
  /// **'Registration date'**
  String get registrationDate;

  /// No description provided for @reportAProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportAProblem;

  /// No description provided for @reportDetails.
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get reportDetails;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report issue'**
  String get reportIssue;

  /// No description provided for @reporter.
  ///
  /// In en, this message translates to:
  /// **'Reporter'**
  String get reporter;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @reportsManagement.
  ///
  /// In en, this message translates to:
  /// **'Reports Management'**
  String get reportsManagement;

  /// No description provided for @republish.
  ///
  /// In en, this message translates to:
  /// **'Republish'**
  String get republish;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetAllSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset All Settings'**
  String get resetAllSettings;

  /// No description provided for @resolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @restoreAllSettingsToTheirDefaultValues.
  ///
  /// In en, this message translates to:
  /// **'Restore all settings to their default values'**
  String get restoreAllSettingsToTheirDefaultValues;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'Results count:'**
  String get resultsCount;

  /// No description provided for @reviewAndResolveUserReports.
  ///
  /// In en, this message translates to:
  /// **'Review and resolve user reports'**
  String get reviewAndResolveUserReports;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAnswers.
  ///
  /// In en, this message translates to:
  /// **'Save answers'**
  String get saveAnswers;

  /// No description provided for @saveAssessment.
  ///
  /// In en, this message translates to:
  /// **'Save assessment'**
  String get saveAssessment;

  /// No description provided for @saveEmail.
  ///
  /// In en, this message translates to:
  /// **'Save email'**
  String get saveEmail;

  /// No description provided for @saveName.
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get saveName;

  /// No description provided for @savePatient.
  ///
  /// In en, this message translates to:
  /// **'Save patient'**
  String get savePatient;

  /// No description provided for @saveQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Save questionnaire'**
  String get saveQuestionnaire;

  /// No description provided for @saveStatus.
  ///
  /// In en, this message translates to:
  /// **'Save Status'**
  String get saveStatus;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @savedForms.
  ///
  /// In en, this message translates to:
  /// **'Saved forms'**
  String get savedForms;

  /// No description provided for @savedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Saved questions'**
  String get savedQuestions;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @scheduleAndPublishForms.
  ///
  /// In en, this message translates to:
  /// **'Schedule and publish forms'**
  String get scheduleAndPublishForms;

  /// No description provided for @scheduleForms.
  ///
  /// In en, this message translates to:
  /// **'Schedule forms'**
  String get scheduleForms;

  /// No description provided for @scheduledForms.
  ///
  /// In en, this message translates to:
  /// **'Scheduled forms'**
  String get scheduledForms;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @score2.
  ///
  /// In en, this message translates to:
  /// **'Score: 2'**
  String get score2;

  /// No description provided for @searchByNameEmailOrTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email or title'**
  String get searchByNameEmailOrTitle;

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get searchByNameOrEmail;

  /// No description provided for @searchByNameOrFileNumber.
  ///
  /// In en, this message translates to:
  /// **'Search by name or file number...'**
  String get searchByNameOrFileNumber;

  /// No description provided for @searchForAPatient.
  ///
  /// In en, this message translates to:
  /// **'Search for a patient...'**
  String get searchForAPatient;

  /// No description provided for @searchForPatientByName.
  ///
  /// In en, this message translates to:
  /// **'Search for patient by name'**
  String get searchForPatientByName;

  /// No description provided for @searchForVolunteerByName.
  ///
  /// In en, this message translates to:
  /// **'Search for volunteer by name'**
  String get searchForVolunteerByName;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectPatient.
  ///
  /// In en, this message translates to:
  /// **'Select patient'**
  String get selectPatient;

  /// No description provided for @selectPatients.
  ///
  /// In en, this message translates to:
  /// **'Select patients'**
  String get selectPatients;

  /// No description provided for @selectPatientsOrVolunteers.
  ///
  /// In en, this message translates to:
  /// **'Select patients or volunteers'**
  String get selectPatientsOrVolunteers;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select status'**
  String get selectStatus;

  /// No description provided for @selectSurgery.
  ///
  /// In en, this message translates to:
  /// **'Select surgery'**
  String get selectSurgery;

  /// No description provided for @selectTreatment.
  ///
  /// In en, this message translates to:
  /// **'Select treatment'**
  String get selectTreatment;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select type'**
  String get selectType;

  /// No description provided for @selectVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Select volunteer'**
  String get selectVolunteer;

  /// No description provided for @selectedPatients.
  ///
  /// In en, this message translates to:
  /// **'Selected patients'**
  String get selectedPatients;

  /// No description provided for @selectedVolunteers.
  ///
  /// In en, this message translates to:
  /// **'Selected volunteers'**
  String get selectedVolunteers;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @separateMedicationsWithCommas.
  ///
  /// In en, this message translates to:
  /// **'Separate medications with commas'**
  String get separateMedicationsWithCommas;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @sessionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Session Timeout'**
  String get sessionTimeout;

  /// No description provided for @setTotalFormDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Set total form diagnosis'**
  String get setTotalFormDiagnosis;

  /// No description provided for @setTotalScoreRangesWithTheMatchingDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Set total score ranges with the matching diagnosis'**
  String get setTotalScoreRangesWithTheMatchingDiagnosis;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @severalDays.
  ///
  /// In en, this message translates to:
  /// **'Several days'**
  String get severalDays;

  /// No description provided for @severeAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Severe anxiety'**
  String get severeAnxiety;

  /// No description provided for @severeDepression.
  ///
  /// In en, this message translates to:
  /// **'Severe depression'**
  String get severeDepression;

  /// No description provided for @showing0Users.
  ///
  /// In en, this message translates to:
  /// **'Showing 0 users'**
  String get showing0Users;

  /// No description provided for @showing1To12Of248Patients.
  ///
  /// In en, this message translates to:
  /// **'Showing 1 to 12 of 248 patients'**
  String get showing1To12Of248Patients;

  /// No description provided for @showing5Of24Activities.
  ///
  /// In en, this message translates to:
  /// **'Showing 5 of 24 activities'**
  String get showing5Of24Activities;

  /// No description provided for @showingFromToToOfTotalUsers.
  ///
  /// In en, this message translates to:
  /// **'Showing {from} to {to} of {total} users'**
  String showingFromToToOfTotalUsers(Object from, Object to, Object total);

  /// No description provided for @showingUsers.
  ///
  /// In en, this message translates to:
  /// **'showing_users'**
  String showingUsers(Object from, Object to, Object total);

  /// No description provided for @showingZeroUsers.
  ///
  /// In en, this message translates to:
  /// **'showing_zero_users'**
  String get showingZeroUsers;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @singleChoice.
  ///
  /// In en, this message translates to:
  /// **'Single choice'**
  String get singleChoice;

  /// No description provided for @sleepQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Sleep questionnaire'**
  String get sleepQuestionnaire;

  /// No description provided for @smsNotifications.
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get smsNotifications;

  /// No description provided for @sometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get sometimes;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get sortBy;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @staffCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Staff created successfully'**
  String get staffCreatedSuccessfully;

  /// No description provided for @stage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get stage;

  /// No description provided for @stage0.
  ///
  /// In en, this message translates to:
  /// **'Stage 0'**
  String get stage0;

  /// No description provided for @stage02.
  ///
  /// In en, this message translates to:
  /// **'STAGE_0'**
  String get stage02;

  /// No description provided for @stageAtDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Stage at diagnosis'**
  String get stageAtDiagnosis;

  /// No description provided for @stageI.
  ///
  /// In en, this message translates to:
  /// **'Stage I'**
  String get stageI;

  /// No description provided for @stageI2.
  ///
  /// In en, this message translates to:
  /// **'STAGE_I'**
  String get stageI2;

  /// No description provided for @stageIi.
  ///
  /// In en, this message translates to:
  /// **'Stage II'**
  String get stageIi;

  /// No description provided for @stageIi2.
  ///
  /// In en, this message translates to:
  /// **'STAGE_II'**
  String get stageIi2;

  /// No description provided for @stageIiExample.
  ///
  /// In en, this message translates to:
  /// **'Stage II example'**
  String get stageIiExample;

  /// No description provided for @stageIii.
  ///
  /// In en, this message translates to:
  /// **'Stage III'**
  String get stageIii;

  /// No description provided for @stageIii2.
  ///
  /// In en, this message translates to:
  /// **'STAGE_III'**
  String get stageIii2;

  /// No description provided for @stageIv.
  ///
  /// In en, this message translates to:
  /// **'Stage IV'**
  String get stageIv;

  /// No description provided for @stageIv2.
  ///
  /// In en, this message translates to:
  /// **'STAGE_IV'**
  String get stageIv2;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get status;

  /// No description provided for @status2.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status2;

  /// No description provided for @submissionDate.
  ///
  /// In en, this message translates to:
  /// **'Submission date'**
  String get submissionDate;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @successfullyPublished.
  ///
  /// In en, this message translates to:
  /// **'successfully Published'**
  String get successfullyPublished;

  /// No description provided for @surgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get surgery;

  /// No description provided for @switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'Switch to Arabic'**
  String get switchToArabic;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @systemAdministration.
  ///
  /// In en, this message translates to:
  /// **'System Administration'**
  String get systemAdministration;

  /// No description provided for @targetGroup.
  ///
  /// In en, this message translates to:
  /// **'Target group'**
  String get targetGroup;

  /// No description provided for @targetedTherapy.
  ///
  /// In en, this message translates to:
  /// **'Targeted therapy'**
  String get targetedTherapy;

  /// No description provided for @targetedTherapyIfAny.
  ///
  /// In en, this message translates to:
  /// **'Targeted therapy if any'**
  String get targetedTherapyIfAny;

  /// No description provided for @theDiagnosisCannotExceed50Characters.
  ///
  /// In en, this message translates to:
  /// **'The diagnosis cannot exceed 50 characters'**
  String get theDiagnosisCannotExceed50Characters;

  /// No description provided for @theFormHasBeenActivatedAndCanBeRepublishedNow.
  ///
  /// In en, this message translates to:
  /// **'The form has been activated and can be republished now.'**
  String get theFormHasBeenActivatedAndCanBeRepublishedNow;

  /// No description provided for @theFormHasBeenDisabledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The form has been disabled successfully.'**
  String get theFormHasBeenDisabledSuccessfully;

  /// No description provided for @theFormHasBeenSelectedChooseTheTargetGroupAndThenPublishIt.
  ///
  /// In en, this message translates to:
  /// **'The form has been selected. Choose the target group and then publish it.'**
  String get theFormHasBeenSelectedChooseTheTargetGroupAndThenPublishIt;

  /// No description provided for @theFormWasPublishedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The form was published successfully.'**
  String get theFormWasPublishedSuccessfully;

  /// No description provided for @theQuestionnaireHasBeenDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The questionnaire has been deleted successfully.'**
  String get theQuestionnaireHasBeenDeletedSuccessfully;

  /// No description provided for @theQuestionnaireHasBeenLoadedForEditingTheQuestionnaireTitleCannotBeEdit.
  ///
  /// In en, this message translates to:
  /// **'The questionnaire has been loaded for editing. The questionnaire title cannot be edited.'**
  String
  get theQuestionnaireHasBeenLoadedForEditingTheQuestionnaireTitleCannotBeEdit;

  /// No description provided for @theQuestionnaireMustContainAtLeastOneQuestion.
  ///
  /// In en, this message translates to:
  /// **'The questionnaire must contain at least one question.'**
  String get theQuestionnaireMustContainAtLeastOneQuestion;

  /// No description provided for @theScoreMustBeBetween0And100.
  ///
  /// In en, this message translates to:
  /// **'The score must be between 0 and 100'**
  String get theScoreMustBeBetween0And100;

  /// No description provided for @theTitleCannotExceed25Characters.
  ///
  /// In en, this message translates to:
  /// **'The title cannot exceed 25 characters'**
  String get theTitleCannotExceed25Characters;

  /// No description provided for @theUserCanChooseMoreThanOneAnswer.
  ///
  /// In en, this message translates to:
  /// **'The user can choose more than one answer'**
  String get theUserCanChooseMoreThanOneAnswer;

  /// No description provided for @theUserCanChooseOnlyOneAnswer.
  ///
  /// In en, this message translates to:
  /// **'The user can choose only one answer'**
  String get theUserCanChooseOnlyOneAnswer;

  /// No description provided for @thereMustBeAtLeastOneDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'There must be at least one diagnosis.'**
  String get thereMustBeAtLeastOneDiagnosis;

  /// No description provided for @thisChartShowsImprovementInDepressionAndAnxietyLevelsDuringTreatment.
  ///
  /// In en, this message translates to:
  /// **'This chart shows improvement in depression and anxiety levels during treatment'**
  String
  get thisChartShowsImprovementInDepressionAndAnxietyLevelsDuringTreatment;

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// No description provided for @thisPatientHasNotFilledOutAnyQuestionnaireYet.
  ///
  /// In en, this message translates to:
  /// **'This patient has not filled out any questionnaire yet.'**
  String get thisPatientHasNotFilledOutAnyQuestionnaireYet;

  /// No description provided for @thisPatientHasNotSubmittedAnyAssessmentsYetAssessmentsWillAppearHereOnce.
  ///
  /// In en, this message translates to:
  /// **'This patient has not submitted any assessments yet. Assessments will appear here once they are recorded.'**
  String
  get thisPatientHasNotSubmittedAnyAssessmentsYetAssessmentsWillAppearHereOnce;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @tnbc.
  ///
  /// In en, this message translates to:
  /// **'TNBC'**
  String get tnbc;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @totalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total patients'**
  String get totalPatients;

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total score'**
  String get totalScore;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @treatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get treatment;

  /// No description provided for @treatmentPlan.
  ///
  /// In en, this message translates to:
  /// **'Treatment plan'**
  String get treatmentPlan;

  /// No description provided for @tripleNegative.
  ///
  /// In en, this message translates to:
  /// **'Triple negative'**
  String get tripleNegative;

  /// No description provided for @tripleNegative2.
  ///
  /// In en, this message translates to:
  /// **'TRIPLE_NEGATIVE'**
  String get tripleNegative2;

  /// No description provided for @tumorBiology.
  ///
  /// In en, this message translates to:
  /// **'Tumor biology'**
  String get tumorBiology;

  /// No description provided for @twoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthentication;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @userRolesDistribution.
  ///
  /// In en, this message translates to:
  /// **'User Roles Distribution'**
  String get userRolesDistribution;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @usersManagement.
  ///
  /// In en, this message translates to:
  /// **'Users Management'**
  String get usersManagement;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @viewAndManageData.
  ///
  /// In en, this message translates to:
  /// **'View and manage data'**
  String get viewAndManageData;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @viewProgress.
  ///
  /// In en, this message translates to:
  /// **'View progress'**
  String get viewProgress;

  /// No description provided for @volanteers.
  ///
  /// In en, this message translates to:
  /// **'Volanteers'**
  String get volanteers;

  /// No description provided for @volanteersAndPatients.
  ///
  /// In en, this message translates to:
  /// **'Volanteers and Patients'**
  String get volanteersAndPatients;

  /// No description provided for @volunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get volunteer;

  /// No description provided for @volunteer2.
  ///
  /// In en, this message translates to:
  /// **'VOLUNTEER'**
  String get volunteer2;

  /// No description provided for @volunteerForm.
  ///
  /// In en, this message translates to:
  /// **'Volunteer form'**
  String get volunteerForm;

  /// No description provided for @volunteers.
  ///
  /// In en, this message translates to:
  /// **'Volunteers'**
  String get volunteers;

  /// No description provided for @volunteersAndPatients.
  ///
  /// In en, this message translates to:
  /// **'Volunteers and Patients'**
  String get volunteersAndPatients;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcome;

  /// No description provided for @welcomeBackHereSWhatSHappeningToday.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, here\'s what\'s happening today'**
  String get welcomeBackHereSWhatSHappeningToday;

  /// No description provided for @welcomeToTheSupportAndCarePlatform.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the support and care platform'**
  String get welcomeToTheSupportAndCarePlatform;

  /// No description provided for @willNoLongerBeAvailableForPublishingDoYouWantToContinue.
  ///
  /// In en, this message translates to:
  /// **'will no longer be available for publishing. Do you want to continue?'**
  String get willNoLongerBeAvailableForPublishingDoYouWantToContinue;

  /// No description provided for @writeDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Write diagnosis'**
  String get writeDiagnosis;

  /// No description provided for @writeTheIssueDetailsHere.
  ///
  /// In en, this message translates to:
  /// **'Write the issue details here...'**
  String get writeTheIssueDetailsHere;

  /// No description provided for @writeTheQuestion.
  ///
  /// In en, this message translates to:
  /// **'Write the question'**
  String get writeTheQuestion;

  /// No description provided for @writeTheQuestionHere.
  ///
  /// In en, this message translates to:
  /// **'Write the question here'**
  String get writeTheQuestionHere;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @yearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsOfExperience;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @yesNo.
  ///
  /// In en, this message translates to:
  /// **'Yes / No'**
  String get yesNo;

  /// No description provided for @youCanSetADiagnosisForEachTotalScoreRange.
  ///
  /// In en, this message translates to:
  /// **'You can set a diagnosis for each total-score range'**
  String get youCanSetADiagnosisForEachTotalScoreRange;

  /// No description provided for @youngestAge.
  ///
  /// In en, this message translates to:
  /// **'Youngest age'**
  String get youngestAge;

  /// No description provided for @scaleRating.
  ///
  /// In en, this message translates to:
  /// **'Scale / Rating'**
  String get scaleRating;

  /// No description provided for @minimumValue.
  ///
  /// In en, this message translates to:
  /// **'Minimum value'**
  String get minimumValue;

  /// No description provided for @maximumValue.
  ///
  /// In en, this message translates to:
  /// **'Maximum value'**
  String get maximumValue;

  /// No description provided for @minimumLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum label'**
  String get minimumLabel;

  /// No description provided for @maximumLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum label'**
  String get maximumLabel;

  /// No description provided for @verySevere.
  ///
  /// In en, this message translates to:
  /// **'Very severe'**
  String get verySevere;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @drugs.
  ///
  /// In en, this message translates to:
  /// **'Drugs'**
  String get drugs;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @writeMedicinesSeparatedByCommas.
  ///
  /// In en, this message translates to:
  /// **'Write medicines separated by commas'**
  String get writeMedicinesSeparatedByCommas;

  /// No description provided for @searchForPatientOrQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Search for a patient or questionnaire...'**
  String get searchForPatientOrQuestionnaire;

  /// No description provided for @auditLogs.
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get auditLogs;

  /// No description provided for @crn.
  ///
  /// In en, this message translates to:
  /// **'CRN'**
  String get crn;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirmPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @editFullNameOnly.
  ///
  /// In en, this message translates to:
  /// **'Edit full name only'**
  String get editFullNameOnly;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @entity.
  ///
  /// In en, this message translates to:
  /// **'Entity'**
  String get entity;

  /// No description provided for @failedToLoadAccountInformation.
  ///
  /// In en, this message translates to:
  /// **'Failed to load account information'**
  String get failedToLoadAccountInformation;

  /// No description provided for @latestSystemActivityLogs.
  ///
  /// In en, this message translates to:
  /// **'Latest system activity logs'**
  String get latestSystemActivityLogs;

  /// No description provided for @loadingAccountInformation.
  ///
  /// In en, this message translates to:
  /// **'Loading account information...'**
  String get loadingAccountInformation;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @noPatientsFound.
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatientsFound;

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noReportsFound;

  /// No description provided for @onlyFullNameCanBeEdited.
  ///
  /// In en, this message translates to:
  /// **'Only full name can be edited.'**
  String get onlyFullNameCanBeEdited;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @openNotifications.
  ///
  /// In en, this message translates to:
  /// **'Open Notifications'**
  String get openNotifications;

  /// No description provided for @openReports.
  ///
  /// In en, this message translates to:
  /// **'Open Reports'**
  String get openReports;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @sendPasswordResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send password reset email'**
  String get sendPasswordResetEmail;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @updateAccountPasswordSecurely.
  ///
  /// In en, this message translates to:
  /// **'Update your account password securely'**
  String get updateAccountPasswordSecurely;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @userActions.
  ///
  /// In en, this message translates to:
  /// **'User Actions'**
  String get userActions;

  /// No description provided for @pendingSubmissionsExplanation.
  ///
  /// In en, this message translates to:
  /// **'Any questionnaire submitted by a patient or volunteer will appear here before it is approved as an official assessment.'**
  String get pendingSubmissionsExplanation;

  /// No description provided for @questionnaireAnswers.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire answers'**
  String get questionnaireAnswers;

  /// No description provided for @createNewQuestionnaireTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new questionnaire'**
  String get createNewQuestionnaireTitle;

  /// No description provided for @choosePatientToViewQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Choose a patient from the list to view the questionnaire.'**
  String get choosePatientToViewQuestionnaire;

  /// No description provided for @volunteerSurveyInstruction.
  ///
  /// In en, this message translates to:
  /// **'Choose a patient and complete the assigned surveys'**
  String get volunteerSurveyInstruction;

  /// No description provided for @chooseDiagnosisSeverity.
  ///
  /// In en, this message translates to:
  /// **'Choose diagnosis / severity'**
  String get chooseDiagnosisSeverity;

  /// No description provided for @chooseStage.
  ///
  /// In en, this message translates to:
  /// **'Choose stage'**
  String get chooseStage;

  /// No description provided for @chooseFormFromList.
  ///
  /// In en, this message translates to:
  /// **'Choose a form from the list'**
  String get chooseFormFromList;

  /// No description provided for @selectVolunteers.
  ///
  /// In en, this message translates to:
  /// **'Select volunteers'**
  String get selectVolunteers;

  /// No description provided for @numericRangeChoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a score from a numeric range such as 0 to 10'**
  String get numericRangeChoiceDescription;

  /// No description provided for @patientNameFemale.
  ///
  /// In en, this message translates to:
  /// **'Patient name'**
  String get patientNameFemale;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get personalData;

  /// No description provided for @pendingAssessmentsForReview.
  ///
  /// In en, this message translates to:
  /// **'Pending assessments for review'**
  String get pendingAssessmentsForReview;

  /// No description provided for @surgeryLabel.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get surgeryLabel;

  /// No description provided for @accountInactive.
  ///
  /// In en, this message translates to:
  /// **'Account is inactive'**
  String get accountInactive;

  /// No description provided for @volunteersLabel.
  ///
  /// In en, this message translates to:
  /// **'Volunteers'**
  String get volunteersLabel;

  /// No description provided for @assignedPatients.
  ///
  /// In en, this message translates to:
  /// **'Assigned patients'**
  String get assignedPatients;

  /// No description provided for @fillQuestionnaireForPatient.
  ///
  /// In en, this message translates to:
  /// **'Complete the questionnaire on behalf of the patient'**
  String get fillQuestionnaireForPatient;

  /// No description provided for @editMedicalData.
  ///
  /// In en, this message translates to:
  /// **'Edit medical data'**
  String get editMedicalData;

  /// No description provided for @answerDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Answer details'**
  String get answerDetailsTitle;

  /// No description provided for @sentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sent successfully'**
  String get sentSuccessfully;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @allPatientsTitle.
  ///
  /// In en, this message translates to:
  /// **'All patients'**
  String get allPatientsTitle;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @reviewThenApproveAssessment.
  ///
  /// In en, this message translates to:
  /// **'Review the questions and answers, then approve them as an official assessment'**
  String get reviewThenApproveAssessment;

  /// No description provided for @patientNumber.
  ///
  /// In en, this message translates to:
  /// **'Patient number'**
  String get patientNumber;

  /// No description provided for @rangeOptionsGeneratedExplanation.
  ///
  /// In en, this message translates to:
  /// **'Options are generated automatically for each value in the range, and the score equals the selected value.'**
  String get rangeOptionsGeneratedExplanation;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// No description provided for @noQuestionsInQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'There are no questions in this questionnaire.'**
  String get noQuestionsInQuestionnaire;

  /// No description provided for @noVisibleSubmissionAnswers.
  ///
  /// In en, this message translates to:
  /// **'There are no visible answers in this submission.'**
  String get noVisibleSubmissionAnswers;

  /// No description provided for @noAssignedQuestionnaires.
  ///
  /// In en, this message translates to:
  /// **'There are currently no questionnaires assigned to you.'**
  String get noAssignedQuestionnaires;

  /// No description provided for @noPendingAssessments.
  ///
  /// In en, this message translates to:
  /// **'There are no assessments pending review'**
  String get noPendingAssessments;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @itemsPerPageShort.
  ///
  /// In en, this message translates to:
  /// **'Per page'**
  String get itemsPerPageShort;

  /// No description provided for @volunteerWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Workspace'**
  String get volunteerWorkspace;

  /// No description provided for @example27.
  ///
  /// In en, this message translates to:
  /// **'Example: 27'**
  String get example27;

  /// No description provided for @exampleComorbidities.
  ///
  /// In en, this message translates to:
  /// **'Example: diabetes, hypertension'**
  String get exampleComorbidities;

  /// No description provided for @exampleNone.
  ///
  /// In en, this message translates to:
  /// **'Example: none'**
  String get exampleNone;

  /// No description provided for @doctorReview.
  ///
  /// In en, this message translates to:
  /// **'Doctor review'**
  String get doctorReview;

  /// No description provided for @doctorNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor notes'**
  String get doctorNotesTitle;

  /// No description provided for @questionType.
  ///
  /// In en, this message translates to:
  /// **'Question type'**
  String get questionType;

  /// No description provided for @deactivateUser.
  ///
  /// In en, this message translates to:
  /// **'Deactivate User'**
  String get deactivateUser;

  /// No description provided for @activateUser.
  ///
  /// In en, this message translates to:
  /// **'Activate User'**
  String get activateUser;

  /// No description provided for @disableAccountAccess.
  ///
  /// In en, this message translates to:
  /// **'Disable account access'**
  String get disableAccountAccess;

  /// No description provided for @enableAccountAccess.
  ///
  /// In en, this message translates to:
  /// **'Enable account access'**
  String get enableAccountAccess;

  /// No description provided for @doYouWantToDeactivateUser.
  ///
  /// In en, this message translates to:
  /// **'Do you want to deactivate {name}?'**
  String doYouWantToDeactivateUser(Object name);

  /// No description provided for @doYouWantToActivateUser.
  ///
  /// In en, this message translates to:
  /// **'Do you want to activate {name}?'**
  String doYouWantToActivateUser(Object name);

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @sendPasswordResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send password reset link to {email}?'**
  String sendPasswordResetLink(Object email);

  /// No description provided for @passwordResetLinkSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent successfully.'**
  String get passwordResetLinkSentSuccessfully;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Password Reset Link'**
  String get resetPasswordLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
