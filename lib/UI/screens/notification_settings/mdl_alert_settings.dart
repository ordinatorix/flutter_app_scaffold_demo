
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_scaffold/enums/theme_mode.dart';

import '../../base_model.dart';

import '../../../logger.dart';
import '../../../locator.dart';

import '../../../enums/view_state.dart';

import '../../../services/database_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/navigation_service.dart';

import '../../../helpers/share_prefs_helper.dart';

import '../../../models/settings.dart';
import '../../../models/user.dart';

import '../../../generated/i18n.dart';

final log = getLogger('AlertSettingsScreenModel');

class AlertSettingsScreenModel extends BaseModel {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final SharedPrefsHelper settings = locator<SharedPrefsHelper>();
  // TODO: make use of fcm service for this
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NavigationService _navigationService = locator<NavigationService>();

  AppSettings loadedSettings = AppSettings();
  Map loadedAlerts;
  List statusTranslated;
  List status = ['rumored', 'confirmed', 'cleared'];

  void setAnalyticsCustomEvent(
      {String name, Map<String, dynamic> parameters}) async {
    log.i('setAnalyticsCustomEvent | name: $name, parameters: $parameters');
    await _analyticsService.logCustomEvent(name: name, parameters: parameters);
  }

  void loadSettings() {
    log.i('loadSettings');
    loadedSettings = AppSettings(
      language: settings.setLocale,
      unitIsMetric: settings.isMetric,
      notification: settings.notificationSettings,
      scaffoldThemeMode: ScaffoldThemeMode.values[settings.whatThemeMode],
    );

    loadedAlerts = loadedSettings.notification;
  }

  void getTranslatedStatus(BuildContext context) {
    log.i('getTranslatedStatus | context: $context');
    statusTranslated = [
      I18n.of(context).alertSettingsScreenRumored,
      I18n.of(context).alertSettingsScreenConfirmed,
      I18n.of(context).alertSettingsScreenCleared,
    ];
  }

  void onAppbarCloseButtonPressed() {
    setAnalyticsCustomEvent(
        name: 'closed_page',
        parameters: {'screen_name': 'alert-setting-screen'});
    _navigationService.removeUntil('/tab-screen');
  }

  void onBoxChecked(int index, bool value, Map argument, User user) {
    log.i(
        'onBoxChecked | index: $index, value: $value, argument: $argument, uid: ${user.uid}');
    setState(ViewState.Idle);
    //  save value locally using shared prefs
    loadedAlerts[argument['${status[index]}Subscription']] = value;
    // try to update the notification settings in shared prefs
    settings.updateNotificationSettings(loadedAlerts);
    if (value) {
      // subscribe to FCM topics
      _firebaseMessaging
          .subscribeToTopic(argument['${status[index]}Subscription'])
          .whenComplete(() {
        log.d(
            'completed subscription to ${argument['${status[index]}Subscription']} topic');
        // update settings in cloud db
        _databaseService
            .updateUserSettings(
          user: user,
          settings: AppSettings(
            language: loadedSettings.language,
            unitIsMetric: loadedSettings.unitIsMetric,
            notification: loadedAlerts,
            scaffoldThemeMode: loadedSettings.scaffoldThemeMode,
          ),
        )
            .whenComplete(() {
          setAnalyticsCustomEvent(
              name: 'subscribed_to_notification',
              parameters: {
                'notification': argument['${status[index]}Subscription']
              });

          log.d('updated settings in db');
        });
      }).catchError((e) {
        // unsubscribe from topic
        _firebaseMessaging
            .unsubscribeFromTopic(argument['${status[index]}Subscription']);

        loadedAlerts[argument['${status[index]}Subscription']] = !value;
        settings.updateNotificationSettings(loadedAlerts);

        value = !value;
        setState(ViewState.Idle);
        log.e('error sunscribing to topics: $e');
      });
    } else {
      // unsubscribe from FCM topics
      _firebaseMessaging
          .unsubscribeFromTopic(argument['${status[index]}Subscription'])
          .whenComplete(() {
        setAnalyticsCustomEvent(
            name: 'unsubscribed_to_notification',
            parameters: {
              'notification': argument['${status[index]}Subscription']
            });

        log.d('completed cancel subscription from ?');
        // update cloud db
        _databaseService
            .updateUserSettings(
          user: user,
          settings: AppSettings(
            language: loadedSettings.language,
            unitIsMetric: loadedSettings.unitIsMetric,
            notification: loadedAlerts,
            scaffoldThemeMode: loadedSettings.scaffoldThemeMode,
          ),
        )
            .whenComplete(() {
          log.d('updated settings in db');
        });
      }).catchError((e) {
        loadedAlerts[argument['${status[index]}Subscription']] = !value;
        settings.updateNotificationSettings(loadedAlerts);

        value = !value;
        setState(ViewState.Idle);
        log.e('error unsubscribing from topics: $e');
      });
    }
  }
}
