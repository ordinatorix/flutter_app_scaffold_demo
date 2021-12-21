import 'package:flutter/material.dart';

import 'package:flutter_scaffold/UI/screens/account_settings/scr_account_settings.dart';
import 'package:flutter_scaffold/UI/screens/account_settings/scr_change_number_instruction.dart';
import 'package:flutter_scaffold/UI/screens/notification_settings/scr_notification_settings.dart';
import 'package:provider/provider.dart';

import '../../base_model.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import '../../../enums/view_state.dart';
import '../../../enums/theme_mode.dart';

import '../../../helpers/share_prefs_helper.dart';

import '../../../services/database_service.dart';
import '../../../services/authentication_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/url_launcher_service.dart';
import '../../../services/dialog_service.dart';
import '../../../services/navigation_service.dart';

import '../../../models/user.dart';
import '../../../models/settings.dart';

import '../../../generated/i18n.dart';

final log = getLogger('GeneralSettingsViewModel');

class GeneralSettingsViewModel extends BaseModel {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final AuthService auth = locator<AuthService>();
  final DatabaseService database = locator<DatabaseService>();
  final SharedPrefsHelper settings = locator<SharedPrefsHelper>();
  final UrlLauncherService _urlLauncherServices = locator<UrlLauncherService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  User user = User();
  AppSettings loadedSettings;
  List<bool> isSelected = [false, true, false];
  bool isMetric = true;
  String unit;

  /// Launch link in browser.
  ///
  /// Parameter Link to is a short description of what the link is about.
  void launchInBrowser({String url, String linkTo}) {
    log.i('launchInBrowser | url: $url');
    _urlLauncherServices.launchInBrowser(url: url, linkTo: linkTo);
  }

  void onWillPop() {
    _navigationService.removeUntil('/tab-screen');
  }

  void onAppbarBackButtonPressed() {
    _navigationService.replaceWith('/tab-screen');
  }

  void onNotificationListTileTap() {
    _navigationService.navigateTo(NotificationSettingsScreen.routeName);
  }

  void onChangeUsernameListTileTap() {
    _analyticsService.logCustomEvent(name: 'navigate_to_change_username');
    _navigationService.navigateTo(AccountSettingScreen.routeName);
  }

  void onChangeNumberListTileTap() {
    _analyticsService.logCustomEvent(name: 'navigate_to_change_phone');
    _navigationService.navigateTo(ChangeNumberInstructionScreen.routeName);
  }

  void initializeModel(BuildContext context) {
    log.i('initializeModel | context: $context');

    unit = I18n.of(context).generalSettingsScreenMetric;

    user = Provider.of<User>(context);

    loadedSettings = AppSettings(
      language: settings.setLocale,
      unitIsMetric: settings.isMetric,
      notification: settings.notificationSettings,
      scaffoldThemeMode: ScaffoldThemeMode.values[settings.whatThemeMode],
    );
    isMetric = settings.isMetric ?? true;
    isMetric
        ? unit = I18n.of(context).generalSettingsScreenMetric
        : unit = I18n.of(context).generalSettingsScreenImperial;

    for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
      if (buttonIndex == settings.whatThemeMode) {
        isSelected[buttonIndex] = true;
      } else {
        isSelected[buttonIndex] = false;
      }
    }
  }

  void onCloseAccountButtonPressed(BuildContext context) async {
    log.i('onCloseAccountButtonPressed | context: $context');
    setState(ViewState.Busy);
    var _dialogResponse = await _dialogService.showWarningDialog(
      title: I18n.of(context).generalSettingsScreenConfirmationTitle,
      description: I18n.of(context).generalSettingsScreenConfirmationContent,
      cancelTitle: I18n.of(context).buttonsCancelButton,
      confirmationTitle: I18n.of(context).buttonsProceedButton,
      dialogType: 'close_account',
    );

    if (_dialogResponse.confirmed) {
      await auth.closeAcount(ctx: context);
    }
    setState(ViewState.Idle);
  }

  void onUnitButtonPressed(BuildContext context, bool value) async {
    log.i('onUnitButtonPressed | context: $context, value: $value');
    await settings.updateIsMetric(value);

    isMetric = value;
    isMetric
        ? unit = I18n.of(context).generalSettingsScreenMetric
        : unit = I18n.of(context).generalSettingsScreenImperial;
    setState(ViewState.Idle);

    await database
        .updateUserSettings(
      user: user,
      settings: AppSettings(
        language: loadedSettings.language,
        unitIsMetric: value,
        notification: loadedSettings.notification,
        scaffoldThemeMode: loadedSettings.scaffoldThemeMode,
      ),
    )
        .catchError((onError) {
      log.e('error updating user settings: $onError');
      throw onError;
    });

    await _analyticsService
        .logCustomEvent(name: 'change_unit', parameters: {'metric': value});
  }

  void onDarkButtonPressed(int value) async {
    log.i('onDarkButtonPressed | value: $value');
    for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
      if (buttonIndex == value) {
        isSelected[buttonIndex] = true;
      } else {
        isSelected[buttonIndex] = false;
      }
    }
    setState(ViewState.Idle);
    await settings.updateThemeMode(value);

    await database
        .updateUserSettings(
      user: user,
      settings: AppSettings(
        language: loadedSettings.language,
        unitIsMetric: loadedSettings.unitIsMetric,
        notification: loadedSettings.notification,
        scaffoldThemeMode: ScaffoldThemeMode.values[value],
      ),
    )
        .catchError((onError) {
      log.e('error updating user settings: $onError');
      throw onError;
    });

    await _analyticsService
        .logCustomEvent(name: 'change_theme_mode', parameters: {'mode': value});
  }
}
