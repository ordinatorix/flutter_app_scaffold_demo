import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:package_info/package_info.dart';

import '../../base_model.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import '../../../models/user.dart';

import '../../../enums/view_state.dart';

import '../../../services/dialog_service.dart';
import '../../../services/authentication_service.dart';
import '../../../services/database_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/url_launcher_service.dart';
import '../../../services/navigation_service.dart';

import '../../../generated/i18n.dart';

import '../../screens/user_profile/scr_profile_settings.dart';
import '../../screens/general_settings/scr_general_settings.dart';

final log = getLogger('MainDrawerViewModel');

class MainDrawerViewModel extends BaseModel {
  final AuthService _auth = locator<AuthService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final DatabaseService databaseService = locator<DatabaseService>();
  final UrlLauncherService _urlLauncherService = locator<UrlLauncherService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  User authUser;
  String appVersion;

  /// initialize main drawer model.
  void initializeModel() async {
    log.i('initializeModel');
    _analyticsService.logCustomEvent(name: 'show_main_drawer');
    PackageInfo.fromPlatform().then((value) {
      appVersion = '${value.version}+${value.buildNumber}';
      setState(ViewState.Idle);
      log.d(
          '${value.appName}, ${value.version}, ${value.buildNumber}, ${value.packageName}');
    });
  }

  /// Get current user.
  void initializeUser() {
    log.i('initializeUser');
    if (authUser == null) {
      authUser = _auth.currentAuthenticatedUser();
      log.d('currentuser info: $authUser;');
    }
  }

  /// Share button tap handler.
  ///
  /// Provides the user with options to share the app.
  void onShareButtonTap(BuildContext context) async {
    log.i('onShareButtonTap | context: $context');
    try {
      bool share = await FlutterShare.share(
          title: I18n.of(context).drawerShareTitle,
          text: I18n.of(context).drawerShareText,
          linkUrl:
              'https://drive.google.com/drive/folders/1zy1aa24yNTkoM15SRwMbMDatPsfFMMmy?usp=sharing',
          chooserTitle: I18n.of(context).drawerShareChooser);
      if (share) {
        await _analyticsService.logShareItem(
            contentType: 'app_install_link', itemId: '', method: 'app_chooser');
      }
    } catch (e) {
      throw e;
    }
  }

  /// Open URL.
  ///
  /// Opens url using device default browser.
  void _openUrl({String url, String linkTo}) async {
    log.i('_openUrl | url: $url');
    await _urlLauncherService.launchInBrowser(url: url, linkTo: linkTo);
  }

  /// Feedback button tap handler.
  ///
  /// User sends feedback about the app to team.
  /// This will open a web page in browser.
  void onFeedbackButtonTap() async {
    log.i('onFeedbackButtonTap');
    try {
      await _analyticsService.logCustomEvent(name: 'send_feedback');
      _openUrl(
          url: 'https://forms.gle/udJYiuG748ktoBth8', linkTo: 'send_feedback');
    } catch (e) {
      throw e;
    }
  }

  /// New release button tap handler.
  ///
  /// Provides user with easy option to update the app to the latest version.
  /// Will open link in browser.
  /// USED FOR TESTING easy access to version online
  void onNewReleaseButtonTap() async {
    log.i('onNewReleaseButtonTap');
    try {
      await _analyticsService.logCustomEvent(name: 'get_new_release');
      _openUrl(
          url:
              'https://drive.google.com/drive/folders/1zy1aa24yNTkoM15SRwMbMDatPsfFMMmy?usp=sharing',
          linkTo: 'get_new_release');
    } catch (e) {
      throw e;
    }
  }

  /// Profile button tap handler.
  ///
  /// Navigate to the profile page.
  void onMyProfileButtonTap() {
    log.i('onMyProfileButtonTap');
    _analyticsService.logCustomEvent(name: 'view_profile');
    _navigationService.replaceWith(ProfileSettingsScreen.routeName);
  }

  /// Setting button tap handler.
  ///
  /// Navigate to the settings page.
  void onSettingsButtonPressed() {
    log.i('onSettingsButtonPressed');
    _analyticsService.logCustomEvent(name: 'view_settings');
    _navigationService.replaceWith(GeneralSettingsScreen.routeName);
  }

  /// Log out button tap handler.
  ///
  /// Logs the user out of the app without deleting account.
  void onLogoutButtonTap(BuildContext context) async {
    log.i('onLogoutButtonTap | context: $context');
    setState(ViewState.Busy);
    var _dialogResponse = await _dialogService.showWarningDialog(
        title: I18n.of(context).drawerConfirmationTitle,
        description: I18n.of(context).drawerConfirmationContent,
        confirmationTitle: I18n.of(context).buttonsProceedButton,
        cancelTitle: I18n.of(context).buttonsCancelButton,
        dialogType: 'logout');

    if (_dialogResponse.confirmed) {
      await _auth.signOut().catchError((e) {
        //TODO: show dialog to user
        log.e('error during signout process: $e');
      });
      _navigationService.replaceWith('/');
    }
    setState(ViewState.Idle);
  }
}
