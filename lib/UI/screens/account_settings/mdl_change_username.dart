import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome;

import '../../base_model.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import '../../../enums/view_state.dart';

import '../../../models/user.dart';

import '../../../generated/i18n.dart';

import '../../../services/database_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/authentication_service.dart';
import '../../../services/dialog_service.dart';

final log = getLogger('ChangeUsernameModel');

class ChangeUsernameModel extends BaseModel {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final AuthService _authenticationService = locator<AuthService>();
  final DatabaseService _database = locator<DatabaseService>();
  final DialogService _dialogService = locator<DialogService>();
  final form = GlobalKey<FormState>();
  final usernameFocusNode = FocusNode();
  List userList = [];
  DeviceLocation deviceLocation;

  User editedUser;

  /// Update user list with result from db.
  void updateUserList(String uid) {
    if (userList.isNotEmpty) {
      editedUser =
          userList.firstWhere((usr) => usr.uid == uid, orElse: () => null);
    }
  }

  /// Initialize change username view model.
  void initializeModel(User authUser) {
    log.i('initializeModel | authUser: $authUser');
    log.wtf(
        'lastSignInTime: ${authUser.lastSignInTime.hour}:${authUser.lastSignInTime.minute}');
    editedUser = User(
      uid: null,
      displayName: '',
      email: '',
      phone: '',
      photoUrl: '',
      homeLocation: '',
      lastKnownLocation: null,
      lastSignInTime: authUser.lastSignInTime,
      fullName: '',
    );
  }

  /// Dispose change username view model.
  void disposer() {
    log.i('disposer');
    usernameFocusNode.dispose();
    SystemChrome.restoreSystemUIOverlays();
  }

  /// Username input form validator.
  String formValidator(String value, BuildContext context) {
    if (value.isEmpty) {
      return I18n.of(context).changeUsernameScreenNoUsernameWarning;
    } else if (RegExp(r'^(?=[a-zA-Z0-9_-]{2,15}$)(?!.*[_-]{2})[^].*[^]$')
        .hasMatch(value)) {
      return null;
    } else {
      return I18n.of(context).changeUsernameScreenInvalidUsernameWarning;
    }
  }

  /// Save username input form.
  ///
  /// Updates the username in the db and auth services.
  void saveForm({BuildContext ctx}) async {
    final isValid = form.currentState.validate();
    log.d('validation complete');
    if (!isValid) {
      log.d('isValid: $isValid');
      log.d('not valid');
      return;
    }

    setState(ViewState.Busy);
    log.d('saving user');
    form.currentState.save();
    if (editedUser.uid != null) {
      try {
        await _database.updateUser(
          user: editedUser,
        );
        await _authenticationService.updateUserAuthProfile(
            displayName: editedUser.displayName);
        await _analyticsService.logCustomEvent(name: 'changed_phone_username');
      } catch (error) {
        log.e('error saving form: $error');

        await _dialogService.showErrorDialog(
          title: I18n.of(ctx).dialogsFailedUsernameSaveDialogTitle,
          description: I18n.of(ctx).dialogsFailedSaveDialogContent,
          dialogType: 'user_update_failed',
        );
      }
    }
    log.d('done updating');

    setState(ViewState.Idle);
    ScaffoldMessenger.of(ctx).removeCurrentSnackBar();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(I18n.of(ctx).changeUsernameScreenUpdateSuccessful),
      ),
    );
  }
}
