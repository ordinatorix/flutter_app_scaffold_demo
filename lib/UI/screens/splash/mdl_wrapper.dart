import 'package:flutter/material.dart';

import '../../base_model.dart';

import '../../../services/navigation_service.dart';
import '../../../services/authentication_service.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import '../../../models/user.dart';

import '../login/scr_login.dart';
import '../main_tab_page/tab_screen.dart';

final log = getLogger('WrapperViewModel');

class WrapperViewModel extends BaseModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final AuthService _authService = locator<AuthService>();
  User _authUser;
  bool isStorageReady = false;
  void initModel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log.i('initModel');
      log.w('is storage ready: $isStorageReady');
      if (isStorageReady) {
        _authUser = _authService.currentAuthenticatedUser();

        log.d('authenticated user is: $_authUser');
        if (_authUser == null) {
          log.d('user: $_authUser showing login screen');
          _navigationService.replaceWith(LoginScreen.routeName);
        } else {
          if (_authUser.uid.isNotEmpty) {
            log.d('user.uid: ${_authUser.uid}');

            _navigationService.replaceWith(TabsScreen.routeName);
          } else {
            log.d('user.uid: ${_authUser.uid} showing splash screen');
          }
        }
      }
    });
  }
}
