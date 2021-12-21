import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base_model.dart';
import '../../../locator.dart';
import '../../../helpers/share_prefs_helper.dart';

import '../../../logger.dart';

final log = getLogger('DateFormaterViewModel');

class DateFormaterViewModel extends BaseModel {
  final DateTime currentTime = DateTime.now();
  final SharedPrefsHelper settings = locator<SharedPrefsHelper>();
  bool unit;
  double distanceInMeters;
  double distanceInFeet;
  double distanceInKm;
  double distanceInMiles;
  String displayedDistance;
  int dayDifference;
  int hourDifference;
  int minuteDifference;
  int secondDifference;

  void getTimeDifference(DateTime eventTimestamp) {
    log.i('getTimeDifference | $eventTimestamp');
    unit = settings.isMetric;

    dayDifference = currentTime.difference(eventTimestamp).inDays;
    hourDifference = currentTime.difference(eventTimestamp).inHours;
    minuteDifference = currentTime.difference(eventTimestamp).inMinutes;
    secondDifference = currentTime.difference(eventTimestamp).inSeconds;
  }

  void convertDistanceUnits(BuildContext context, bool showDistance) {
    log.i(
        'convertDistanceUnits | context: $context, showDistance: $showDistance');
    if (showDistance) {
      distanceInMeters = Provider.of<double>(context, listen: false);
    }

    // handle needed unit conversions
    if (distanceInMeters != null) {
      distanceInKm = distanceInMeters / 1000;
      distanceInFeet = distanceInMeters * 3.28084;
      distanceInMiles = distanceInMeters * 0.000621371;
      if (unit) {
        if (distanceInMeters.toStringAsFixed(0).length > 3) {
          displayedDistance = '${distanceInKm.toStringAsFixed(0)} km';
        } else {
          displayedDistance = '${distanceInMeters.toStringAsFixed(0)} m';
        }
      } else {
        if (distanceInMeters.toStringAsFixed(0).length > 3) {
          displayedDistance = '${distanceInMiles.toStringAsFixed(0)} mi';
        } else {
          displayedDistance = '${distanceInFeet.toStringAsFixed(0)} ft';
        }
      }
    }
  }
}
