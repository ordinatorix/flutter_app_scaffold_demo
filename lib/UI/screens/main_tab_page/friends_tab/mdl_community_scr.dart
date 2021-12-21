import 'package:flutter/material.dart';
import 'package:flutter_scaffold/models/contacts.dart';
import 'package:provider/provider.dart';

import '../../../base_model.dart';

import '../../../../enums/view_state.dart';

// import '../../../../models/user.dart';

// import '../../../../services/authentication_service.dart';
import '../../../../services/database_service.dart';

import '../../../../services/analytics_service.dart';

import '../../../../locator.dart';
import '../../../../logger.dart';

final log = getLogger('CommunityScreenViewModel');

class CommunityScreenViewModel extends BaseModel {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final DatabaseService databaseService = locator<DatabaseService>();
  // final AuthService _authService = locator<AuthService>();

  // User authUser;
  List<UserContact> contactsList;
  final List<Tab> tabsList = [
    Tab(
      text: 'Family',
    ),
    Tab(text: 'All'),
  ];

  void initializeModel() async {
    log.i('initializeModel');

    // authUser = _authService.currentAuthenticatedUser();
    _analyticsService.setCurrentScreen(screenName: '/community-screen');
    setState(ViewState.Idle);
  }

  void updateModel(BuildContext context) {
    log.i('updateModel');
    contactsList = Provider.of<List<UserContact>>(context);
  }
}
