import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ml.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('hi'),
    Locale('ml')
  ];

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAccount;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @fillDetails.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the details to sign up'**
  String get fillDetails;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @confirmEmergencyCall.
  ///
  /// In en, this message translates to:
  /// **'Confirm Emergency Call'**
  String get confirmEmergencyCall;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @shops.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get shops;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @bookingSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Booking Successful!'**
  String get bookingSuccessful;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking Failed'**
  String get bookingFailed;

  /// No description provided for @appointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Appointment Date'**
  String get appointmentDate;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get profileUpdated;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dob;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @validation_pleaseEnterPlace.
  ///
  /// In en, this message translates to:
  /// **'Please enter a place to search'**
  String get validation_pleaseEnterPlace;

  /// No description provided for @validation_pleaseSelectSpecialization.
  ///
  /// In en, this message translates to:
  /// **'Please select a specialization'**
  String get validation_pleaseSelectSpecialization;

  /// No description provided for @findYourCare.
  ///
  /// In en, this message translates to:
  /// **'Find Your Care'**
  String get findYourCare;

  /// No description provided for @searchHospitals.
  ///
  /// In en, this message translates to:
  /// **'Search Hospitals & Clinics'**
  String get searchHospitals;

  /// No description provided for @searchByPlace.
  ///
  /// In en, this message translates to:
  /// **'Search by place'**
  String get searchByPlace;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital;

  /// No description provided for @clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinic;

  /// No description provided for @selectSpecialization.
  ///
  /// In en, this message translates to:
  /// **'Select Specialization'**
  String get selectSpecialization;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @findYourShop.
  ///
  /// In en, this message translates to:
  /// **'Find Your Shop'**
  String get findYourShop;

  /// No description provided for @searchPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Search Pharmacies & Equipment'**
  String get searchPharmacies;

  /// No description provided for @pharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get pharmacies;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @yourBookings.
  ///
  /// In en, this message translates to:
  /// **'Your Bookings'**
  String get yourBookings;

  /// No description provided for @noAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments on this day.'**
  String get noAppointments;

  /// No description provided for @patientDetails.
  ///
  /// In en, this message translates to:
  /// **'Patient Details'**
  String get patientDetails;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get notSet;

  /// No description provided for @noNameSet.
  ///
  /// In en, this message translates to:
  /// **'No name set'**
  String get noNameSet;

  /// No description provided for @noPhoneSet.
  ///
  /// In en, this message translates to:
  /// **'No phone set'**
  String get noPhoneSet;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointment;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient\'s Name'**
  String get patientName;

  /// No description provided for @patientAge.
  ///
  /// In en, this message translates to:
  /// **'Patient\'s Age'**
  String get patientAge;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @aboutMediGo.
  ///
  /// In en, this message translates to:
  /// **'About MediGo'**
  String get aboutMediGo;

  /// No description provided for @aboutMediGoContent.
  ///
  /// In en, this message translates to:
  /// **'MediGo is a platform to connect patients with doctors and medical facilities seamlessly. Find care, book appointments, and manage your health.'**
  String get aboutMediGoContent;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please sign in.'**
  String get accountAlreadyExists;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your email is not confirmed. Please check your email to verify.'**
  String get emailNotConfirmed;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetYourPassword;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a New Password'**
  String get setNewPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your new password below.'**
  String get pleaseEnterNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully! Please sign in.'**
  String get passwordUpdatedSuccess;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deleteAccountWarningTitle;

  /// No description provided for @deleteAccountWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data, including appointments and profile information, will be permanently deleted.'**
  String get deleteAccountWarningMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @cancelWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get cancelWarningTitle;

  /// No description provided for @cancelWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this appointment?'**
  String get cancelWarningMessage;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @bookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @myMedicalRecords.
  ///
  /// In en, this message translates to:
  /// **'My Medical Records'**
  String get myMedicalRecords;

  /// No description provided for @uploadNewRecord.
  ///
  /// In en, this message translates to:
  /// **'Upload New Record'**
  String get uploadNewRecord;

  /// No description provided for @fileDescription.
  ///
  /// In en, this message translates to:
  /// **'File Description (e.g., \'Blood Test Results\')'**
  String get fileDescription;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @noRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'You have not uploaded any medical records yet.'**
  String get noRecordsFound;

  /// No description provided for @recordUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record uploaded successfully!'**
  String get recordUploadedSuccess;

  /// No description provided for @deleteRecordWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Record?'**
  String get deleteRecordWarningTitle;

  /// No description provided for @deleteRecordWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this record?'**
  String get deleteRecordWarningMessage;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @consultingTime.
  ///
  /// In en, this message translates to:
  /// **'Consulting Time'**
  String get consultingTime;

  /// No description provided for @validation_timeOutsideHours.
  ///
  /// In en, this message translates to:
  /// **'The selected time is outside the doctor\'s consulting hours.'**
  String get validation_timeOutsideHours;

  /// No description provided for @yourTokenIs.
  ///
  /// In en, this message translates to:
  /// **'Your token number is:'**
  String get yourTokenIs;

  /// No description provided for @tokenNumber.
  ///
  /// In en, this message translates to:
  /// **'Token Number'**
  String get tokenNumber;

  /// No description provided for @validation_slotUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This time slot is no longer available. Please select a different time.'**
  String get validation_slotUnavailable;

  /// No description provided for @filterUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get filterUpcoming;

  /// No description provided for @filterPast.
  ///
  /// In en, this message translates to:
  /// **'Past / Cancelled'**
  String get filterPast;

  /// No description provided for @noPastAppointments.
  ///
  /// In en, this message translates to:
  /// **'You have no past appointments.'**
  String get noPastAppointments;

  /// No description provided for @validation_invalidPlace.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid place from the list.'**
  String get validation_invalidPlace;

  /// No description provided for @timings.
  ///
  /// In en, this message translates to:
  /// **'Timings'**
  String get timings;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @vision.
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get vision;

  /// No description provided for @visionContent.
  ///
  /// In en, this message translates to:
  /// **'To create a healthier future by making quality healthcare accessible, affordable, and convenient for everyone, everywhere.'**
  String get visionContent;

  /// No description provided for @mission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get mission;

  /// No description provided for @missionContent.
  ///
  /// In en, this message translates to:
  /// **'To empower patients and doctors by providing a seamless, intelligent, and secure digital platform that simplifies medical bookings, management, and communication.'**
  String get missionContent;

  /// No description provided for @validation_nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters.'**
  String get validation_nameMinLength;

  /// No description provided for @validation_phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit phone number.'**
  String get validation_phoneInvalid;

  /// No description provided for @validation_ageInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age (0-120).'**
  String get validation_ageInvalid;

  /// No description provided for @validation_passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get validation_passwordLength;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @todaysAppointments.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appointments'**
  String get todaysAppointments;

  /// No description provided for @noAppointmentsToday.
  ///
  /// In en, this message translates to:
  /// **'You have no appointments today.'**
  String get noAppointmentsToday;

  /// No description provided for @allAppointments.
  ///
  /// In en, this message translates to:
  /// **'All Appointments'**
  String get allAppointments;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get myNotes;

  /// No description provided for @typeYourNoteHere.
  ///
  /// In en, this message translates to:
  /// **'Type your private note here...'**
  String get typeYourNoteHere;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNote;

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved!'**
  String get noteSaved;

  /// No description provided for @patientPhone.
  ///
  /// In en, this message translates to:
  /// **'Patient Phone'**
  String get patientPhone;

  /// No description provided for @callPatient.
  ///
  /// In en, this message translates to:
  /// **'Call Patient'**
  String get callPatient;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get editSchedule;

  /// No description provided for @todayAppointments.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appointments'**
  String get todayAppointments;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcome;

  /// No description provided for @doctorLogin.
  ///
  /// In en, this message translates to:
  /// **'Doctor Portal Login'**
  String get doctorLogin;

  /// No description provided for @manageAvailability.
  ///
  /// In en, this message translates to:
  /// **'Manage Availability'**
  String get manageAvailability;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @appointmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Appointment Status'**
  String get appointmentStatus;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @medicalReports.
  ///
  /// In en, this message translates to:
  /// **'Medical Reports'**
  String get medicalReports;

  /// No description provided for @uploadNewReport.
  ///
  /// In en, this message translates to:
  /// **'Upload New Report'**
  String get uploadNewReport;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @setYourHours.
  ///
  /// In en, this message translates to:
  /// **'Set your default consulting hours.'**
  String get setYourHours;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @availabilityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Availability updated!'**
  String get availabilityUpdated;

  /// No description provided for @errorUpdatingAvailability.
  ///
  /// In en, this message translates to:
  /// **'Error updating availability.'**
  String get errorUpdatingAvailability;

  /// No description provided for @manageLeave.
  ///
  /// In en, this message translates to:
  /// **'Manage Leave'**
  String get manageLeave;

  /// No description provided for @selectLeaveDates.
  ///
  /// In en, this message translates to:
  /// **'Select date range to mark as unavailable.'**
  String get selectLeaveDates;

  /// No description provided for @leaveDates.
  ///
  /// In en, this message translates to:
  /// **'Leave Dates'**
  String get leaveDates;

  /// No description provided for @saveLeave.
  ///
  /// In en, this message translates to:
  /// **'Save Leave Dates'**
  String get saveLeave;

  /// No description provided for @leaveUpdated.
  ///
  /// In en, this message translates to:
  /// **'Leave dates updated.'**
  String get leaveUpdated;

  /// No description provided for @errorLeave.
  ///
  /// In en, this message translates to:
  /// **'Error updating leave'**
  String get errorLeave;

  /// No description provided for @tapToRemove.
  ///
  /// In en, this message translates to:
  /// **'Tap a date to remove it'**
  String get tapToRemove;

  /// No description provided for @noLeaveDates.
  ///
  /// In en, this message translates to:
  /// **'You have no leave dates scheduled.'**
  String get noLeaveDates;

  /// No description provided for @manageLeaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Select single days or a date range to mark as on leave.'**
  String get manageLeaveDesc;

  /// No description provided for @scheduledLeave.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Leave Days'**
  String get scheduledLeave;

  /// No description provided for @availabilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Set your weekly consulting start and end times.'**
  String get availabilityDesc;

  /// No description provided for @saveAvailability.
  ///
  /// In en, this message translates to:
  /// **'Save Availability'**
  String get saveAvailability;

  /// No description provided for @errorAvailability.
  ///
  /// In en, this message translates to:
  /// **'Error saving availability'**
  String get errorAvailability;
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
      <String>['en', 'hi', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ml':
      return AppLocalizationsMl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
