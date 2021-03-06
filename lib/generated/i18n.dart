import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes
// ignore_for_file: unnecessary_brace_in_string_interps

//WARNING: This file is automatically generated. DO NOT EDIT, all your changes would be lost.

typedef LocaleChangeCallback = void Function(Locale locale);

class I18n implements WidgetsLocalizations {
  const I18n();
  static Locale _locale;
  static bool _shouldReload = false;

  static set locale(Locale newLocale) {
    _shouldReload = true;
    I18n._locale = newLocale;
  }

  static const GeneratedLocalizationsDelegate delegate = GeneratedLocalizationsDelegate();

  /// function to be invoked when changing the language
  static LocaleChangeCallback onLocaleChanged;

  static I18n of(BuildContext context) =>
    Localizations.of<I18n>(context, WidgetsLocalizations);

  @override
  TextDirection get textDirection => TextDirection.ltr;

  /// "Hello ${name}"
  String greetTo(String name) => "Hello ${name}";
  /// "Show All"
  String get showAll => "Show All";
  /// "Show Rumored"
  String get showRumored => "Show Rumored";
  /// "Show Confirmed"
  String get showConfirmed => "Show Confirmed";
  /// "Show Cleared"
  String get showCleared => "Show Cleared";
  /// "Show Fake"
  String get showFake => "Show Fake";
  /// "return"
  String get navigateBackToolTip => "return";
  /// "close"
  String get closePageToolTip => "close";
  /// "add post"
  String get tabScreenFabToolTip => "add post";
  /// "Map"
  String get homeScreenTitle => "Map";
  /// "Map functionality will not work without access to Location services."
  String get homeScreenNoGPS => "Map functionality will not work without access to Location services.";
  /// "Show current location"
  String get homeScreenLocationToolTip => "Show current location";
  /// "Change map type"
  String get homeScreenMapTypeToolTip => "Change map type";
  /// "Feed"
  String get feedScreenTitle => "Feed";
  /// "No posts have been submittted today"
  String get feedScreenNoActivity => "No posts have been submittted today";
  /// "meters"
  String get feedScreenMetricUnit => "meters";
  /// "miles"
  String get feedScreenImperialUnit => "miles";
  /// "yesterday"
  String get feedScreenYesterday => "yesterday";
  /// "${number} days ago"
  String feedScreenDayAgo(String number) => "${number} days ago";
  /// "${number} hours ago"
  String feedScreenHoursAgo(String number) => "${number} hours ago";
  /// "${number} minutes ago"
  String feedScreenMinutesAgo(String number) => "${number} minutes ago";
  /// "${number} seconds ago"
  String feedScreenSecondsAgo(String number) => "${number} seconds ago";
  /// "Now"
  String get feedScreenNow => "Now";
  /// "Rumored Ongoing"
  String get feedScreenRumoredOngoing => "Rumored Ongoing";
  /// "Confirmed Ongoing"
  String get feedScreenConfirmedOngoing => "Confirmed Ongoing";
  /// "Area Cleared"
  String get feedScreenAreaCleared => "Area Cleared";
  /// "Fake"
  String get feedScreenFake => "Fake";
  /// "Unclear"
  String get feedScreenUnclear => "Unclear";
  /// "Event Details"
  String get feedItemDetailScreenTitle => "Event Details";
  /// "Clear"
  String get feedItemDetailScreenClearButton => "Clear";
  /// "Verify"
  String get feedItemDetailScreenVerifyButton => "Verify";
  /// "Updates: "
  String get feedItemDetailScreenEventCardComments => "Updates: ";
  /// "Tags: "
  String get feedItemDetailScreenEventCardTags => "Tags: ";
  /// "No post found."
  String get feedItemDetailScreenNoPostFound => "No post found.";
  /// "Community"
  String get communityScreenTitle => "Community";
  /// "COMMING SOON!"
  String get communityScreenSoon => "COMMING SOON!";
  /// "Follow Me"
  String get communityScreenFollow => "Follow Me";
  /// ""
  String get postEditScreenTitle => "";
  /// "Post Tags"
  String get postEditScreenBottomSheetTagTitle => "Post Tags";
  /// "Emergency Tags"
  String get postEditScreenBottomSheetEmergencyTitle => "Emergency Tags";
  /// "Cannot update post without selecting a status."
  String get postEditScreenSelectStatusWarning => "Cannot update post without selecting a status.";
  /// "Add Tags"
  String get postEditScreenAddTagsButton => "Add Tags";
  /// "Emergency Services"
  String get postEditScreenAddEmergencyServices => "Emergency Services";
  /// "open camera"
  String get postEditScreenOpenCameraToolTip => "open camera";
  /// "Comment"
  String get postEditScreenCommentButton => "Comment";
  /// "Already submitted post."
  String get postEditScreenAlreadySubmittedSnackBar => "Already submitted post.";
  /// "Please select a tag that best describes the event you are posting."
  String get postEditScreenSelectTagSnackBar => "Please select a tag that best describes the event you are posting.";
  /// "Submit Post"
  String get postEditScreenSubmitButton => "Submit Post";
  /// "Police onsite"
  String get postEditScreenPoliceOnsite => "Police onsite";
  /// "Ambulance onsite"
  String get postEditScreenAmbulanceOnsite => "Ambulance onsite";
  /// "Firefighters onsite"
  String get postEditScreenFirefightersOnsite => "Firefighters onsite";
  /// "No Location chosen."
  String get postEditScreenNoLocationChosen => "No Location chosen.";
  /// "Tap to modify post location"
  String get postEditScreenTapToModifyLocation => "Tap to modify post location";
  /// "Confirmed"
  String get postEditScreenConfirmedStatus => "Confirmed";
  /// "Cleared"
  String get postEditScreenClearedStatus => "Cleared";
  /// "Fake"
  String get postEditScreenFakeStatus => "Fake";
  /// "Status"
  String get postEditScreenStatus => "Status";
  /// "Can only select a total of"
  String get postEditScreenTagLimit => "Can only select a total of";
  /// "Uploading ${media}, ${index} of ${length}"
  String postEditScreenUploadText(String media, String index, String length) => "Uploading ${media}, ${index} of ${length}";
  /// "Event Details"
  String get postCommentScreenTitle => "Event Details";
  /// "Comment"
  String get postCommentScreenLabelText => "Comment";
  /// "Please enter a comment before saving"
  String get postCommentScreenNoCommentWarning => "Please enter a comment before saving";
  /// "Please enter a valid Comment"
  String get postCommentScreenInvalidCommentWarning => "Please enter a valid Comment";
  /// "Send a Post"
  String get gridMenuScreenTitle => "Send a Post";
  /// "Change Number"
  String get accountSettingsScreenChangeNumber => "Change Number";
  /// "Change Username"
  String get accountSettingsScreenChangeUsername => "Change Username";
  /// "Hold for video, tap for photo."
  String get cameraScreenActionButtonInfo => "Hold for video, tap for photo.";
  /// "Video recording paused"
  String get cameraScreenRecordingPaused => "Video recording paused";
  /// "Video recording resumed"
  String get cameraScreenRecordingResumed => "Video recording resumed";
  /// "There was an error with the device camera. Try again!"
  String get cameraScreenCameraError => "There was an error with the device camera. Try again!";
  /// "done"
  String get cameraScreenCameraFABTooltip => "done";
  /// "Change Number"
  String get changeNumberInstructionScreenTitle => "Change Number";
  /// "Changing your phone number will migrate your account info and settings."
  String get changeNumberInstructionScreenInfo => "Changing your phone number will migrate your account info and settings.";
  /// "Before proceeding, please confirm that you are able to receive SMS or calls at your new number."
  String get changeNumberInstructionScreenInfo2 => "Before proceeding, please confirm that you are able to receive SMS or calls at your new number.";
  /// "If you have both a new phone and a new phone number, first change your number on your old phone."
  String get changeNumberInstructionScreenInfo3 => "If you have both a new phone and a new phone number, first change your number on your old phone.";
  /// "Enter old phone number."
  String get changePhoneNumberScreenOldNumberTextfieldCaption => "Enter old phone number.";
  /// "Enter new phone number."
  String get changePhoneNumberScreenNewNumberTextfieldCaption => "Enter new phone number.";
  /// "Phone Number"
  String get changePhoneNumberScreenTextFieldLabel => "Phone Number";
  /// "Enter a valid phone number."
  String get changePhoneNumberScreenInvalidNumberWarning => "Enter a valid phone number.";
  /// "Please enter a phone number."
  String get changePhoneNumberScreenNoNumberWarning => "Please enter a phone number.";
  /// "User Profile was successfully updated"
  String get changeUsernameScreenUpdateSuccessful => "User Profile was successfully updated";
  /// "Username"
  String get changeUsernameScreenTextFieldLabel => "Username";
  /// "Enter a valid Username."
  String get changeUsernameScreenInvalidUsernameWarning => "Enter a valid Username.";
  /// "Username can only contain letters, numbers, '-', '_'"
  String get changeUsernameScreenNoUsernameWarning => "Username can only contain letters, numbers, '-', '_'";
  /// "Settings"
  String get generalSettingsScreenTitle => "Settings";
  /// "General Settings"
  String get generalSettingsScreenGeneralSettings => "General Settings";
  /// "Language"
  String get generalSettingsScreenLanguage => "Language";
  /// "Default"
  String get generalSettingsScreenLanguageOptionDefault => "Default";
  /// "English"
  String get generalSettingsScreenLanguageOptionEnglish => "English";
  /// "French"
  String get generalSettingsScreenLanguageOptionFrench => "French";
  /// "Spanish"
  String get generalSettingsScreenLanguageOptionSpanish => "Spanish";
  /// "Italian"
  String get generalSettingsScreenLanguageOptionItalian => "Italian";
  /// "Haitian Creole"
  String get generalSettingsScreenLanguageOptionHaitianKreyol => "Haitian Creole";
  /// "English"
  String get generalSettingsScreenEnglish => "English";
  /// "Theme"
  String get generalSettingsScreenTheme => "Theme";
  /// "Light"
  String get generalSettingsScreenModeLight => "Light";
  /// "Auto"
  String get generalSettingsScreenModeAuto => "Auto";
  /// "Dark"
  String get generalSettingsScreenModeDark => "Dark";
  /// "Units"
  String get generalSettingsScreenUnits => "Units";
  /// "Metric"
  String get generalSettingsScreenMetric => "Metric";
  /// "Imperial"
  String get generalSettingsScreenImperial => "Imperial";
  /// "Manage notifications"
  String get generalSettingsScreenManageNotifications => "Manage notifications";
  /// "Account Settings"
  String get generalSettingsScreenAccountSettings => "Account Settings";
  /// "Change username"
  String get generalSettingsScreenChangeUsername => "Change username";
  /// "Change phone number"
  String get generalSettingsScreenChangeNumber => "Change phone number";
  /// "About"
  String get generalSettingsScreenAbout => "About";
  /// "Privacy policy"
  String get generalSettingsScreenPrivacyPolicy => "Privacy policy";
  /// "Terms of Services"
  String get generalSettingsScreenTermsOfServices => "Terms of Services";
  /// "Post a bug"
  String get generalSettingsScreenReportBug => "Post a bug";
  /// "Danger Zone"
  String get generalSettingsScreenDangerZone => "Danger Zone";
  /// "Closing your account will result in complete loss of account info and settings. Once this is done, all data will be lost forever.\nProceed with caution."
  String get generalSettingsScreenAccountCloseWarning => "Closing your account will result in complete loss of account info and settings. Once this is done, all data will be lost forever.\nProceed with caution.";
  /// "Are you sure?"
  String get generalSettingsScreenConfirmationTitle => "Are you sure?";
  /// "This will erase all your account data.\nDo you wish to continue?"
  String get generalSettingsScreenConfirmationContent => "This will erase all your account data.\nDo you wish to continue?";
  /// "Close Account"
  String get generalSettingsScreenCloseAccountButton => "Close Account";
  /// "More Images"
  String get imageListViewerScreenTitle => "More Images";
  /// "Login"
  String get loginScreenLogin => "Login";
  /// "Phone Number"
  String get loginScreenNumber => "Phone Number";
  /// "XX XX XX XX"
  String get loginScreenHintText => "XX XX XX XX";
  /// "Enter a valid phone number."
  String get loginScreenInvalidNumberWarning => "Enter a valid phone number.";
  /// "Please enter a phone number."
  String get loginScreenNoNumberWarning => "Please enter a phone number.";
  /// "Verify"
  String get loginScreenLoginButton => "Verify";
  /// "Message rates and data rates may apply."
  String get loginScreenRateWarning => "Message rates and data rates may apply.";
  /// "By continuing, you agree to our "
  String get loginScreenPolicyAgreementWarning => "By continuing, you agree to our ";
  /// "Terms of Use"
  String get loginScreenTermsOfUse => "Terms of Use";
  /// "Privacy Policy."
  String get loginScreenPrivacyPolicy => "Privacy Policy.";
  /// " and "
  String get loginScreenAnd => " and ";
  /// "Notifications"
  String get notificationSettingsScreenTitle => "Notifications";
  /// "Select to change settings"
  String get notificationSettingsScreenListTileSubtitle => "Select to change settings";
  /// "Profile"
  String get profileSettingScreenTitle => "Profile";
  /// "Upload an image"
  String get profileSettingScreenUploadImage => "Upload an image";
  /// "No image captured"
  String get profileSettingScreenNoCapture => "No image captured";
  /// "Take Picture"
  String get profileSettingScreenTakePicture => "Take Picture";
  /// "Posted: --"
  String get profileSettingScreenDefaultPosted => "Posted: --";
  /// "Verified: --"
  String get profileSettingScreenDefaultVerified => "Verified: --";
  /// "Posted:"
  String get profileSettingScreenPostedCount => "Posted:";
  /// "Verified:"
  String get profileSettingScreenVerifiedCount => "Verified:";
  /// "Profile Photo"
  String get profileSettingScreenProfilePhoto => "Profile Photo";
  /// "You have not yet submitted any posts"
  String get profileSettingScreenNoSubmittedPosts => "You have not yet submitted any posts";
  /// "Select Location"
  String get selectLocationScreenTitle => "Select Location";
  /// "rumored"
  String get alertSettingsScreenRumored => "rumored";
  /// "cleared"
  String get alertSettingsScreenCleared => "cleared";
  /// "confirmed"
  String get alertSettingsScreenConfirmed => "confirmed";
  /// "Could not find contacts. Please check permissions and try again."
  String get contactsDisplayScreenEmptyStateText => "Could not find contacts. Please check permissions and try again.";
  /// "Location Not Found"
  String get emptyStateLocationNotFound => "Location Not Found";
  /// "Please enable location to access this feature."
  String get emptyStateEnableLocationText => "Please enable location to access this feature.";
  /// "Stay Safe with APP_SCAFFOLD"
  String get drawerShareTitle => "Stay Safe with APP_SCAFFOLD";
  /// "Join the growing network of citizens concerned with their safety!\nWith APP_SCAFFOLD, you can do your part in distributing accurate information."
  String get drawerShareText => "Join the growing network of citizens concerned with their safety!\nWith APP_SCAFFOLD, you can do your part in distributing accurate information.";
  /// "Help your friends stay safe with APP_SCAFFOLD"
  String get drawerShareChooser => "Help your friends stay safe with APP_SCAFFOLD";
  /// "New User"
  String get drawerNewUser => "New User";
  /// "Sign up to access all features"
  String get drawerPlaceHolder => "Sign up to access all features";
  /// "My Profile"
  String get drawerMyProfile => "My Profile";
  /// "Share App"
  String get drawerShareApp => "Share App";
  /// "Feedback"
  String get drawerFeedback => "Feedback";
  /// "Latest Release"
  String get drawerRelease => "Latest Release";
  /// "Settings"
  String get drawerSettings => "Settings";
  /// "Logout"
  String get drawerLogout => "Logout";
  /// "Are you sure?"
  String get drawerConfirmationTitle => "Are you sure?";
  /// "You will be logged out of your account.\nDo you wish to continue?"
  String get drawerConfirmationContent => "You will be logged out of your account.\nDo you wish to continue?";
  /// "Florist"
  String get modelPostFloristTitle => "Florist";
  /// "Rose"
  String get modelPostFloristA => "Rose";
  /// "Orchid"
  String get modelPostFloristB => "Orchid";
  /// "Cactus"
  String get modelPostFloristC => "Cactus";
  /// "Traffic"
  String get modelPostTrafficTitle => "Traffic";
  /// "Moderate"
  String get modelPostModerate => "Moderate";
  /// "Heavy"
  String get modelPostHeavy => "Heavy";
  /// "Standstill"
  String get modelPostStandstill => "Standstill";
  /// "Crash"
  String get modelPostCrashTitle => "Crash";
  /// "Minor"
  String get modelPostMinor => "Minor";
  /// "Major"
  String get modelPostMajor => "Major";
  /// "Hotel"
  String get modelPostHotelTitle => "Hotel";
  /// "Single Bed"
  String get modelPostSingleBed => "Single Bed";
  /// "Multi Bed"
  String get modelPostMultiBed => "Multi Bed";
  /// "Hazard"
  String get modelPostHazardTitle => "Hazard";
  /// "Debris"
  String get modelPostDebris => "Debris";
  /// "Flood"
  String get modelPostFlood => "Flood";
  /// "Fire"
  String get modelPostFire => "Fire";
  /// "Library"
  String get modelPostLibraryTitle => "Library";
  /// "Book Rental"
  String get modelPostBookRental => "Book Rental";
  /// "Book Purchase"
  String get modelPostBookPurchase => "Book Purchase";
  /// "Error"
  String get dialogsErrorTitle => "Error";
  /// "Open link in browser."
  String get dialogsFcmOpenLinkButton => "Open link in browser.";
  /// "Show Me"
  String get dialogsFcmShowMeButton => "Show Me";
  /// "A ${title} has been recently posted."
  String dialogsPostNotificationTitle(String title) => "A ${title} has been recently posted.";
  /// "Enable GPS Location."
  String get dialogsLocationPromptTitle => "Enable GPS Location.";
  /// "To properly use all features of the app, turn on device location service."
  String get dialogsLocationPromptContent => "To properly use all features of the app, turn on device location service.";
  /// "GO TO SETTINGS"
  String get dialogsLocationPromptGoToSettings => "GO TO SETTINGS";
  /// "User has been disabled. Please contact APP_SCAFFOLD customer care."
  String get dialogsSmsUserDisabled => "User has been disabled. Please contact APP_SCAFFOLD customer care.";
  /// "Credentials entered are invalid."
  String get dialogsSmsInvalidCredentials => "Credentials entered are invalid.";
  /// "User was not found."
  String get dialogsSmsUserNotFound => "User was not found.";
  /// "User was not found."
  String get dialogsSmsUserMismatch => "User was not found.";
  /// "Invalid phone number."
  String get dialogsSmsInvalidPhoneNumber => "Invalid phone number.";
  /// "Invalid email."
  String get dialogsSmsInvalidEmail => "Invalid email.";
  /// "Wrong password."
  String get dialogsSmsWrongPassword => "Wrong password.";
  /// "Email is already in use. Please sign in."
  String get dialogsSmsEmailInUse => "Email is already in use. Please sign in.";
  /// "Recent login is required."
  String get dialogsSmsRecentLoginRequired => "Recent login is required.";
  /// "Weak password, enter a stronger one."
  String get dialogsSmsWeakPassword => "Weak password, enter a stronger one.";
  /// "The sms verification code used is invalid."
  String get dialogsSmsInvalidCode => "The sms verification code used is invalid.";
  /// "Check network connection."
  String get dialogsSmsNetworkError => "Check network connection.";
  /// "This number is already in use."
  String get dialogsSmsCredentialInUse => "This number is already in use.";
  /// "Error"
  String get dialogsSmsVerificationFailedPromptTitle => "Error";
  /// "Error during phone number verification."
  String get dialogsSmsVerificationError => "Error during phone number verification.";
  /// "Enter Verification Code"
  String get dialogsSmsVerificationPromptLogin => "Enter Verification Code";
  /// "Verify New Number"
  String get dialogsSmsVerificationPromptNewPhone => "Verify New Number";
  /// "Verify Old Number"
  String get dialogsSmsVerificationPromptOldPhone => "Verify Old Number";
  /// "Enter verification code."
  String get dialogsSmsVerificationPromptCloseAccountMessage => "Enter verification code.";
  /// "Confirm the closing of your account."
  String get dialogsSmsVerificationPromptCloseAccountTitle => "Confirm the closing of your account.";
  /// "Something went wrong while submitting the post. Check your network connection and make sure that location services are enabled!"
  String get dialogsPostFailed => "Something went wrong while submitting the post. Check your network connection and make sure that location services are enabled!";
  /// "Saving Failed!"
  String get dialogsPostFailedSubmitTitle => "Saving Failed!";
  /// "Update Failed!"
  String get dialogsPostFailedReviewTitle => "Update Failed!";
  /// "User Update Failed!"
  String get dialogsFailedUsernameSaveDialogTitle => "User Update Failed!";
  /// "Phonenumber Update Failed!"
  String get dialogsFailedPhoneNumberSaveDialogTitle => "Phonenumber Update Failed!";
  /// "Something went wrong while updating your profile!"
  String get dialogsFailedSaveDialogContent => "Something went wrong while updating your profile!";
  /// "selected login method is not allowed."
  String get dialogsOperationNotAllowed => "selected login method is not allowed.";
  /// "SUCCESS!"
  String get dialogsPostSuccessTitle => "SUCCESS!";
  /// "Post Submitted"
  String get dialogsPostSuccessSubmitTitle => "Post Submitted";
  /// "Your post has been submitted."
  String get dialogsPostSuccessSubmitMessage => "Your post has been submitted.";
  /// "Verification Submitted"
  String get dialogsPostSuccessReviewTitle => "Verification Submitted";
  /// "Your submission is currently being reviewed."
  String get dialogsPostSuccessReviewMessage => "Your submission is currently being reviewed.";
  /// "DATE"
  String get dialogsPostSuccessDate => "DATE";
  /// "TIME"
  String get dialogsPostSuccessTime => "TIME";
  /// "Warning!"
  String get dialogsWarningTitle => "Warning!";
  /// "You are about to publish your current location.\n\nDo you want to proceed?"
  String get dialogsWarningMessage => "You are about to publish your current location.\n\nDo you want to proceed?";
  /// "Are You Sure?"
  String get dialogsWillPopTitle => "Are You Sure?";
  /// "Do you want to continue exiting the App"
  String get dialogsWillPopMessage => "Do you want to continue exiting the App";
  /// "Okay"
  String get buttonsOkayButton => "Okay";
  /// "YES"
  String get buttonsYesButton => "YES";
  /// "Done"
  String get buttonsDoneButton => "Done";
  /// "Proceed"
  String get buttonsProceedButton => "Proceed";
  /// "NO"
  String get buttonsNoButton => "NO";
  /// "Abort"
  String get buttonsAbortButton => "Abort";
  /// "Dismiss"
  String get buttonsDismissButton => "Dismiss";
  /// "Cancel"
  String get buttonsCancelButton => "Cancel";
  /// "Close"
  String get buttonsCloseButton => "Close";
  /// "Save"
  String get buttonsSaveButton => "Save";
  /// "Update account info"
  String get buttonsUpdateAccountButton => "Update account info";
  /// "NEXT"
  String get buttonsNextButton => "NEXT";
}

class _I18n_en_US extends I18n {
  const _I18n_en_US();

  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class _I18n_fr_FR extends I18n {
  const _I18n_fr_FR();


  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const GeneratedLocalizationsDelegate();
  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale("en", "US"),
      Locale("fr", "FR")
    ];
  }

  LocaleResolutionCallback resolution({Locale fallback}) {
    return (Locale locale, Iterable<Locale> supported) {
      if (isSupported(locale)) {
        return locale;
      }
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    };
  }

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    I18n._locale ??= locale;
    I18n._shouldReload = false;
    final String lang = I18n._locale != null ? I18n._locale.toString() : "";
    final String languageCode = I18n._locale != null ? I18n._locale.languageCode : "";
    if ("en_US" == lang) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_en_US());
    }
    else if ("fr_FR" == lang) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_fr_FR());
    }
    else if ("en" == languageCode) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_en_US());
    }
    else if ("fr" == languageCode) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_fr_FR());
    }

    return SynchronousFuture<WidgetsLocalizations>(const I18n());
  }

  @override
  bool isSupported(Locale locale) {
    for (var i = 0; i < supportedLocales.length && locale != null; i++) {
      final l = supportedLocales[i];
      if (l.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => I18n._shouldReload;
}