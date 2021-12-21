import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
// import 'package:android_device_info/android_device_info.dart';

import '../enums/connection_result.dart';
import '../logger.dart';

final log = getLogger('ConnectivityService');

class ConnectivityService {
  StreamController<ConnectionResult> _connectivityController =
      StreamController<ConnectionResult>.broadcast();

  Stream<ConnectionResult> get connectivityStream =>
      _connectivityController.stream;

  ConnectivityService() {
    log.i('connectivity service constructor');
    _streamConnectivity();
  }

  /// Dispose of connectivity service.
  ///
  /// Closes any active controllers.
  void dispose() {
    _connectivityController?.close();
    log.d('Connectivity controller closed');
  }

  /// Stream device connection status.
  ///
  /// Updates the stream everytime there is a change in connectivity.
  StreamSubscription<ConnectivityResult> _streamConnectivity() {
    StreamSubscription<ConnectivityResult> connectionStream =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult event) {
      log.d('connectivity result: ${event.index},$event');
      ConnectionResult result;
      switch (event) {
        case ConnectivityResult.wifi:
          result = ConnectionResult.Wifi;

          break;
        case ConnectivityResult.mobile:
          result = ConnectionResult.Mobile;

          break;
        case ConnectivityResult.none:
          result = ConnectionResult.None;

          break;
        default:
          result = ConnectionResult.None;
      }
      log.d('Adding Connection result - $result to controller.');
      _connectivityController.add(result);
    });
    return connectionStream;
  }

  /// Check network status.
  ///
  /// Determines whether user is connected to wifi, mobile or none.
  Future<Map> checkNetworkStatus() async {
    log.i('checkNetworkStatus');
    //check which network device is connected to
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());

      switch (connectivityResult) {
        case ConnectivityResult.mobile: // User connected to a mobile network.
          log.d('connected to mobile network');
          Map wifiInfo = await _getWifiInfo();
          // Map wip = await _getNetworkInfo();
          Map _networkInfo = {
            'mobileNetwork': true,
            'wifiNetwork': false,
            'noNetwork': false,
            'wifiInfo': wifiInfo,
            // 'networkInfo': wip,
          };
          return _networkInfo;

          break;
        case ConnectivityResult.wifi: // User connected to a wifi network.
          log.d('connected to WIFI network');
          Map wifiInfo = await _getWifiInfo();
          // Map wip = await _getNetworkInfo();
          Map _networkInfo = {
            'mobileNetwork': false,
            'wifiNetwork': true,
            'noNetwork': false,
            'wifiInfo': wifiInfo,
            // 'networkInfo': wip,
          };
          return _networkInfo;
          break;
        case ConnectivityResult.none: //User not connected to network.

          // Map wip = await _getNetworkInfo();
          Map _networkInfo = {
            'mobileNetwork': false,
            'wifiNetwork': false,
            'noNetwork': true,
            'wifiInfo': null,
            // 'networkInfo': wip,
          };
          return _networkInfo;
          break;

        default:
          // Map wip = await _getNetworkInfo();
          Map _networkInfo = {
            'mobileNetwork': false,
            'wifiNetwork': false,
            'noNetwork': false,
            'wifiInfo': null,
            // 'networkInfo': wip,
          };
          return _networkInfo;
      }
    } catch (error) {
      log.e('error checking network status: $error');
      throw error;
    }
  }

  /// Get wifi network info.
  ///
  /// Return the BSSID; IP; Access Point Name
  Future<Map> _getWifiInfo() async {
    log.i('_getWifiInfo');
    //get wifi network info
    try {
      var wifiBSSID = await (WifiInfo().getWifiBSSID());

      var wifiIP = await (WifiInfo().getWifiIP());

      var wifiName = await (WifiInfo().getWifiName());

      Map _wifiInfo = {
        'wifi_BSSID': wifiBSSID,
        'wifi_IP': wifiIP,
        'wifi_Name': wifiName,
      };
      return _wifiInfo;
    } catch (error) {
      log.e('error getting wifi info: $error');
      throw error;
    }
  }

  /// Get network info.
  ///
  /// This provides any suplementary network information.
  // Future<Map> _getNetworkInfo() async {
  //   log.i('getNetworkInfo');
  //   try {
  //     var networkInfo =
  //     // var networkInfo = await AndroidDeviceInfo().getNetworkInfo();
  //     return networkInfo;
  //   } catch (error) {
  //     log.e('error getting network info: $error');
  //     throw error;
  //   }
  // }
}
