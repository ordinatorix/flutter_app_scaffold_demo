import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/screens/contacts_display/scr_contacts_display.dart';
import 'package:flutter_scaffold/enums/view_state.dart';
import 'package:flutter_scaffold/models/contacts.dart';
import 'package:flutter_scaffold/services/analytics_service.dart';
import 'package:flutter_scaffold/services/navigation_service.dart';
import 'package:provider/provider.dart';

import '../../../../../locator.dart';
import '../../../../../logger.dart';
import '../../../../base_model.dart';

final log = getLogger('FamilyGroupViewModel');

class FamilyGroupViewModel extends BaseModel {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final NavigationService _navigationService = locator<NavigationService>();

  List<UserContact> loadedFamily = [];
  List<UserContact> loadedContactsList;

  void initializeModel() async {
    log.i('initializeModel');

    _analyticsService.setCurrentScreen(screenName: '/family-group-screen');
  }

  void updateWidget(BuildContext context) {
    log.i('updateWidget | context: $context');

    loadedContactsList = Provider.of<List<UserContact>>(context);
    log.d('contacts from db: $loadedContactsList');

    loadedFamily = loadedContactsList
        .where((element) => element.inGroup == true)
        .toList();

    log.d('loaded family list: $loadedFamily');
    setState(ViewState.Idle);
  }

  void showContactsList() async {
    log.i('showContactsList');
    log.w('Show permission request');

    _navigationService.navigateTo(ContactsDisplayScreen.routeName);
  }
}
