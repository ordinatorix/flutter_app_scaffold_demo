import 'package:flutter_scaffold/helpers/share_prefs_helper.dart';
import 'package:flutter_scaffold/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../base_model.dart';

import '../../../logger.dart';
import '../../../locator.dart';

import '../../../models/user.dart';

import '../../../generated/i18n.dart';

import '../../../enums/view_state.dart';

import '../../../services/authentication_service.dart';

final log = getLogger('ChangePhoneNumberModel');

class ChangePhoneNumberModel extends BaseModel {
  final AuthService _authenticationService = locator<AuthService>();
  final SharedPrefsHelper _sharedPrefsHelper = locator<SharedPrefsHelper>();
  final NavigationService _navigationService = locator<NavigationService>();

  final form = GlobalKey<FormState>();
  final newPhoneNumberFocusNode = FocusNode();
  final oldPhoneNumberFocusNode = FocusNode();
  final currentPhoneNumberController = TextEditingController();
  final newPhoneNumberController = TextEditingController();

  String oldDialCode;
  String newDialCode;
  String _countryCode;

  String _currentPhoneNumber;
  String _newPhoneNumber;

  List userList;
  DeviceLocation deviceLocation;

  User editedUser = User(
    uid: null,
    displayName: '',
    email: '',
    phone: '',
    photoUrl: '',
    homeLocation: '',
    fullName: '',
  );

  void disposer() {
    log.i('disposer');
    newPhoneNumberFocusNode.dispose();
    oldPhoneNumberFocusNode.dispose();
    SystemChrome.restoreSystemUIOverlays();
  }

  /// Initialize change phone number view model.
  void initializeModel(BuildContext context, String uid) {
    log.i('initializeModel | context: $context, uid: $uid');
    userList = Provider.of<List<User>>(context);

    if (userList.isNotEmpty) {
      editedUser =
          userList.firstWhere((usr) => usr.uid == uid, orElse: () => null);
    }
  }

  /// Update phone number
  ///
  /// Verify the current phone number and updates with the new phone number.
  void updatePhoneNumber({
    @required BuildContext ctx,
  }) async {
    log.i('updatePhoneNumber | context: $ctx, ');

    _currentPhoneNumber =
        '$oldDialCode${currentPhoneNumberController.text.trim()}';
    _newPhoneNumber = '$newDialCode${newPhoneNumberController.text.trim()}';

    final isValid = form.currentState.validate();
    log.d('validation complete');
    if (!isValid) {
      log.d('isValid: $isValid');
      log.d('not valid');
      return;
    }

    setState(ViewState.Busy);
    log.d('Updating phone number.');
    form.currentState.save();
    if (editedUser.uid != null) {
      bool success = await _authenticationService.changePhoneNumber(
        currentPhoneNumber: _currentPhoneNumber,
        newPhoneNumber: _newPhoneNumber,
        ctx: ctx,
        deviceLocation: deviceLocation ?? editedUser.lastKnownLocation,
      );
      log.d('is success?: $success');
      if (success) {
        await _sharedPrefsHelper.updateCountryCode(_countryCode);
        _navigationService.removeUntil(
            '/tab-screen'); // Navigate to home screen phone number change.
      }
    }
    log.d('done changing number, changing state to idle');
    setState(ViewState.Idle);
  }

  /// phone number input form validator.
  String formValidator(String value, BuildContext context) {
    if (value.isEmpty) {
      return I18n.of(context).changePhoneNumberScreenNoNumberWarning;
    } else if (RegExp(r'^\d{8,10}$').hasMatch(value)) {
      return null;
    } else {
      return I18n.of(context).changePhoneNumberScreenInvalidNumberWarning;
    }
  }

  void onOldNumberCountryChanged({
    @required String countryCode,
    @required String countryDialCode,
    bool isInit,
  }) {
    log.i(
        'onCountryChanged | countryCode: $countryCode, countryDialCode: $countryDialCode, isInit: $isInit');
    oldDialCode = countryDialCode;
  }

  void onNewNumberCountryChanged({
    @required String countryCode,
    @required String countryDialCode,
    bool isInit,
  }) {
    log.i(
        'onCountryChanged | countryCode: $countryCode, countryDialCode: $countryDialCode, isInit: $isInit');
    newDialCode = countryDialCode;
    _countryCode = countryCode;
  }
}
