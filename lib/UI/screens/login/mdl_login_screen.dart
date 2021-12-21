import 'package:flutter/material.dart';
import 'package:flutter_scaffold/services/navigation_service.dart';

import '../../base_model.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import '../../../enums/view_state.dart';

import '../../../models/user.dart' show DeviceLocation;

import '../../../services/authentication_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/url_launcher_service.dart';

import '../../../helpers/share_prefs_helper.dart';

import '../../../generated/i18n.dart';

final log = getLogger('LoginScreenModel');

class LoginScreenModel extends BaseModel {
  final AuthService _authenticationService = locator<AuthService>();
  final SharedPrefsHelper _prefsHelper = locator<SharedPrefsHelper>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final UrlLauncherService _urlLauncherServices = locator<UrlLauncherService>();
  final NavigationService _navigationService = locator<NavigationService>();
  String dialCode;
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DeviceLocation deviceLocation;

  /// Dispose controller.
  void disposer() {
    log.i('disposer');
    phoneController.dispose();
  }

  /// Signup or login user.
  Future phoneLogin({String phoneNumber, BuildContext ctx}) async {
    log.i('phoneLogin | context: $ctx phoneNumber: $phoneNumber');
    _analyticsService.logCustomEvent(name: 'login_button_pressed');
    setState(ViewState.Busy);
    await _authenticationService.phoneLogin(
      phoneNumber: phoneNumber,
      ctx: ctx,
      deviceLocation: deviceLocation,
    );
    // TODO: check if screen is still mounted / not disposed
    setState(ViewState.Idle);
  }

  Future anonLogin() async {
    log.i('anonLogin');
    setState(ViewState.Busy);
    await _authenticationService.anonLogin();
    _navigationService.replaceWith('/tab-screen');
log.w('save user to db is needed');

    setState(ViewState.Idle);
  }

  /// Open web link in browser.
  launchInBrowser({String url, String linkTo}) async {
    log.i('launchInBrowser | url: $url');
    await _urlLauncherServices.launchInBrowser(url: url, linkTo: linkTo);
  }

  /// Validate phone number format.
  String validateForm(String value, BuildContext context) {
    if (value.isEmpty) {
      return I18n.of(context).loginScreenNoNumberWarning;
    } else if (RegExp(r'^\d{8,10}$').hasMatch(value)) {
      return null;
    } else {
      return I18n.of(context).loginScreenInvalidNumberWarning;
    }
  }

  /// On Country Changed
  ///
  /// Svaes the country code to sharedprefs and assign dialCode to local variable.
  void onCountryChanged({
    @required String countryCode,
    @required String countryDialCode,
    bool isInit,
  }) {
    log.i(
        'onCountryChanged | countryCode: $countryCode, countryDialCode: $countryDialCode, isInit: $isInit');
    dialCode = countryDialCode;
    _prefsHelper.updateCountryCode(countryCode);
  }
}
