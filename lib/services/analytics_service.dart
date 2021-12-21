import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../logger.dart';
import '../models/user.dart';

final log = getLogger('AnalyticsService');

class AnalyticsService {
  final FirebaseAnalytics firebaseAnalyticsService = FirebaseAnalytics();

  
  Future<void> onLogin({
    User user,
  }) async {
    log.i('onLogin | uid: ${user.uid},');
    await firebaseAnalyticsService.logLogin();
    await firebaseAnalyticsService.setUserProperty(
        name: 'identification', value: '${user.uid}');
    //     name: 'returning', value: '$returningUser');
    log.d('done setting user properties');
  }

  Future<void> onSignUp({User user}) async {
    log.i('onSignUp');
    await firebaseAnalyticsService.logSignUp(signUpMethod: 'phone_auth');
    await firebaseAnalyticsService.setUserProperty(
        name: 'identification', value: '${user.uid}');
  }

  Future<void> logCustomEvent(
      {@required String name, Map<String, dynamic> parameters}) async {
    log.i('logCustomEvent | name: $name, parameters: $parameters');
    await firebaseAnalyticsService.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  Future<void> dialogResponse(
      {@required String dialogType, @required String response}) async {
    log.i('dialogResponse | dialogType: $dialogType, response: $response');
    await firebaseAnalyticsService.logEvent(
      name: 'dialog_response',
      parameters: {
        'dialog_type': dialogType,
        'response': response,
      },
    );
  }

  Future<void> logShareItem(
      {String contentType, String itemId, String method}) async {
    log.i(
        'logShareItem | contentType: $contentType,  itemId: $itemId, method: $method');
    await firebaseAnalyticsService.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  Future<void> setCurrentScreen({@required String screenName}) async {
    log.i('setCurrentScreen | screeName: $screenName');
    await firebaseAnalyticsService.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: null,
    );
  }

  Future<void> logViewItem({
    @required String itemName,
    @required String itemId,
    @required String itemCategory,
  }) async {
    log.i(
        'logViewItem | itemName: $itemName, itemId: $itemId, itemCategory: $itemCategory');
    await firebaseAnalyticsService.logViewItem(
      itemId: itemId,
      itemName: itemName,
      itemCategory: itemCategory,
    );
  }

  Future<void> logSelectContent(
      {@required String contentType, @required String itemId}) async {
    log.i('logSelectContent | contentType: $contentType, itemId: $itemId');
    await firebaseAnalyticsService.logSelectContent(
      contentType: contentType,
      itemId: itemId,
    );
  }
}
