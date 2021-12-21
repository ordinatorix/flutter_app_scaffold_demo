import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logger.dart';

final log = getLogger('SharedPrefsHelper');

class SharedPrefsHelper {
  SharedPreferences _prefs;
  bool get isReady => _prefs != null;

  StreamController<SharedPrefsHelper> _controller =
      StreamController<SharedPrefsHelper>.broadcast();

  Stream<SharedPrefsHelper> get sharedPrefsStream => _controller.stream;

  StreamController<bool> _readyController = StreamController<bool>.broadcast();
  Stream<bool> get isReadyStream => _readyController.stream;
  SharedPrefsHelper() {
    log.i('SharedPrefsHelper constructor');

    SharedPreferences.getInstance().then((pref) {
      _prefs = pref;
      log.d('ready');
      _controller.add(this);
      _readyController.add(isReady);
    });
  }

  /// Dispose of app wide prefs.
  void dispose() {
    log.i('dispose');
    _controller?.close();
    _readyController.close();
    log.d('sharedPrefs controller closed');
  }

  /// Initialize this class.
  Future<bool> init() async {
    log.i('init');
    _controller.stream;
    _controller.add(this);
    _prefs = await SharedPreferences.getInstance();
    _controller.add(this);
    return isReady;
  }

  /// Is the app freshly installed?
  static const String _isFreshKey = 'is_fresh_app_install';
  bool get isFresh => _prefs?.getBool(_isFreshKey) ?? true;
  set isFresh(bool value) => updateIsFresh(value);

  /// Update fresh status.
  Future updateIsFresh(bool value) async {
    log.i('updateIsFresh | value: $value');

    await _prefs.setBool(_isFreshKey, value);

    // adding to controller to make available to the stream
    _controller.add(this);
  }

  /// Save user selected theme in [sharedPrefs].
  static const String _themeModeKey = 'theme_mode_key';
  int get whatThemeMode => _prefs?.getInt(_themeModeKey) ?? 1;
  set whatThemeMode(int value) => updateThemeMode(value);

  /// Update user selected theme in shared prefs.
  Future updateThemeMode(int value) async {
    log.i('updateThemeMode | value: $value');

    await _prefs.setInt(_themeModeKey, value);

    // adding to controller to make available to the stream
    _controller.add(this);
  }

  /// Save user selected units in [sharedPrefs].
  static const String _isMetricKey = 'isMetric';
  bool get isMetric => _prefs?.getBool(_isMetricKey) ?? true;
  set isMetric(bool value) => updateIsMetric(value);

  /// Update user selected units.
  Future updateIsMetric(bool value) async {
    log.i('updateIsMetric | value: $value');

    await _prefs.setBool(_isMetricKey, value);

    // adding to controller to make available to the stream
    _controller.add(this);
  }

  /// Save location service status in [sharedPrefs].
  static const String _isLocationEnabledKey = 'isLocationEnabled';
  bool get isLocationEnabled => _prefs?.getBool(_isLocationEnabledKey) ?? true;
  set isLocationEnabled(bool value) => updateIsLocationEnabled(value);

  /// Update location service status.
  Future updateIsLocationEnabled(bool value) async {
    log.i('updateIsLocationEnabled | value: $value');

    await _prefs.setBool(_isLocationEnabledKey, value);

    // adding to controller to make available to the stream
    _controller.add(this);
  }

  /// Save user locale in [sharedPrefs].
  static const String _localeKey = 'locale';
  String get setLocale => _prefs?.getString(_localeKey) ?? Platform.localeName;
  set setLocale(String value) => updateSetLocale(value);

  /// Update user locale.
  Future updateSetLocale(String value) async {
    log.i('updateSetLocale | value: $value');

    await _prefs.setString(_localeKey, value);
    // adding to controller to make available to the stream
    _controller.add(this);
  }

  /// Save user country code in [sharedPrefs].
  static const String _countryCodeKey = 'countryCode';
  String get countryCode => _prefs?.getString(_countryCodeKey) ?? 'NONE';
  set countryCode(String value) => updateCountryCode(value);

  /// Update user country code.
  Future updateCountryCode(String value) async {
    log.i('updateCountryCode | value: $value');

    await _prefs?.setString(_countryCodeKey, value);
    // adding to controller to make available to the stream
    _controller.add(this);
  }

  /// convert Map to String and save notifications in [sharedPrefs].
  static const String _notificationKey = 'notificationKey';
  Map get notificationSettings {
    return json.decode(_prefs?.getString(_notificationKey));
  }

  set notificationSettings(Map value) => updateNotificationSettings(value);

  /// Update user notification settings.
  Future updateNotificationSettings(Map value) async {
    log.i('updateNotificationSettings | value: $value');

    var stringedValue = json.encode(value);
    await _prefs.setString(_notificationKey, stringedValue);
    log.d('setting notification: $stringedValue');
    // adding to controller to make available to the stream
    _controller.add(this);
  }

  /// /// Save user selected tag list in [sharedPrefs].
  static const String _postTagListKey = 'PostTagListKey';
  List<String> get postTagList =>
      _prefs?.getStringList(_postTagListKey) ?? [];

  set postTagList(List<String> value) => updatePostTagList(value);

  /// Update tags.
  Future updatePostTagList(List<String> value) async {
    log.i('updatePostTagList | value: $value');

    await _prefs.setStringList(_postTagListKey, value);

    // adding to controller to make available to the stream
    _controller.add(this);
  }

  /// Save user selected emergency tag list in [sharedPrefs].
  static const String _emergencyTagListKey = 'emergencyTagListKey';
  List<String> get emergencyTagList =>
      _prefs?.getStringList(_emergencyTagListKey) ?? [];

  set emergencyTagList(List<String> value) => updateEmergencyTagList(value);

  /// Update emergency tags.
  Future updateEmergencyTagList(List<String> value) async {
    log.i('updateEmergencyTagList | value: $value');

    await _prefs.setStringList(_emergencyTagListKey, value);

    // adding to controller to make available to the stream
    _controller.add(this);
  }

  /// Set tag state in [sharedPrefs].
  Future<void> setTagState(String key, bool value) async {
    log.i('setTagState | key: $key, value: $value');
    _prefs.setBool(key, value);
  }

  /// get tag state from [sharedPrefs].
  Future<bool> getTagState(String key) async {
    log.i('getTagState | key: $key');
    bool state = _prefs.getBool(key);
    return state;
  }

  /// set int in [sharedPrefs].
  Future<void> setInt(String key, int value) async {
    log.i('setInt | key: $key, value: $value');
    _prefs.setInt(key, value);
  }

  /// get int from [sharedPrefs].
  Future<int> getInt(String key) async {
    log.i('getInt | key: $key');
    final selectedoption = _prefs.getInt(key) ?? 0;
    return selectedoption;
  }

  /// Remove keys from [sharedPrefs].
  Future<void> removeKeys({@required List tagsList}) async {
    log.i('removeKeys | tagsList: $tagsList');
    await _prefs.remove('selectedOption');
    await _prefs.remove('Police onsite');
    await _prefs.remove('Ambulance onsite');
    await _prefs.remove('Firefighters onsite');
    await _prefs.remove('emergencyTagListKey');

    for (var i = 0; i < tagsList.length; i++) {
      await _prefs.remove(tagsList[i]['option0']);
      await _prefs.remove('${tagsList[i]['option0']}state');
      await _prefs.remove('${tagsList[i]['option0']}int');
      await _prefs.remove(tagsList[i]['option1']);
      await _prefs.remove('${tagsList[i]['option1']}state');
      await _prefs.remove('${tagsList[i]['option1']}int');
      await _prefs.remove(tagsList[i]['option2']);
      await _prefs.remove('${tagsList[i]['option2']}state');
      await _prefs.remove('${tagsList[i]['option2']}int');
    }
    await _prefs.remove('postTagListKey');

    log.d('done removing keys');
  }
}
