import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'user.dart' show DeviceLocation;

import '../generated/i18n.dart';

class EventLocation {
  final double latitude;
  final double longitude;
  final double altitude;
  final double heading;
  final double accuracy;
  final double speed;
  final double speedAccuracy;
  final DateTime timestamp;
  final String address;

  const EventLocation({
    @required this.latitude,
    @required this.longitude,
    this.altitude = 0.0,
    this.heading = 0.0,
    @required this.accuracy,
    this.speed = 0.0,
    this.speedAccuracy = 0.0,
    @required this.timestamp,
    this.address,
  });

  @override
  String toString() {
    return 'Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}';
  }
}

class UploadProgress {
  final double progress;
  final int currentIndex;
  final int listLength;
  final String mediaType;

  const UploadProgress({
    @required this.progress,
    this.currentIndex,
    this.listLength,
    this.mediaType,
  });
}

class Post {
  final String id;
  final String title;
  final List comment;
  String status;
  List imageUrlList;
  List videoUrlList;
  List tags;
  EventLocation location;
  DeviceLocation publisherLocation;
  String namedLocation;
  final String publisherId;
  final DateTime timestamp;

  bool isPublished;

  Post({
    this.id,
    this.title,
    this.comment,
    this.status,
    this.location,
    this.namedLocation,
    this.imageUrlList,
    this.videoUrlList,
    this.tags,
    this.publisherId,
    this.publisherLocation,
    this.timestamp,
    this.isPublished,
  });
}

class PinInformation {
  String address;
  DateTime postTimestamp;
  LatLng location;
  String postTitle;
  Color labelColor;
  Post post;
  IconData pinIcon;
  PinInformation({
    this.address,
    this.postTimestamp,
    this.location,
    this.postTitle,
    this.labelColor,
    this.post,
    this.pinIcon,
  });
}

class TagList {
  // shared pref key for toggle state is ${tagsList['title]}rumoredSubscription
  List<Map<String, dynamic>> getTagList({BuildContext context}) {
    List<Map<String, dynamic>> tagsList = [
      {
        'titleTrans': I18n.of(context).modelPostFloristTitle,
        'title': 'local_florist',
        'icon': Icons.local_florist,
        'selectable': 3,
        'option0': 'local_florist',
        'optionTrans0': I18n.of(context).modelPostFloristA,
        'optionIcon0': Icons.local_florist,
        'option1': 'local_florist',
        'optionTrans1': I18n.of(context).modelPostFloristA,
        'optionIcon1': Icons.local_florist,
        'option2': 'local_florist',
        'optionTrans2': I18n.of(context).modelPostFloristA,
        'optionIcon2': Icons.local_florist,
        // if using firebase messaging for notification:
        'rumoredSubscription': 'rumored_florist',
        'confirmedSubscription': 'confirmed_florist',
        'clearedSubscription': 'cleared_florist'
      },
      {
        'titleTrans': I18n.of(context).modelPostTrafficTitle,
        'title': 'Traffic',
        'icon': Icons.traffic,
        'selectable': 1,
        'option0': 'Modderate',
        'optionTrans0': I18n.of(context).modelPostModerate,
        'optionIcon0': Icons.traffic_outlined,
        'option1': 'Heavy',
        'optionTrans1': I18n.of(context).modelPostHeavy,
        'optionIcon1': Icons.traffic_rounded,
        'option2': 'Standstill',
        'optionTrans2': I18n.of(context).modelPostStandstill,
        'optionIcon2': Icons.traffic_sharp,
        'rumoredSubscription': 'rumored_traffic',
        'confirmedSubscription': 'confirmed_traffic',
        'clearedSubscription': 'cleared_traffic'
      },
      {
        'titleTrans': I18n.of(context).modelPostCrashTitle,
        'title': 'Crash',
        'icon': Icons.accessibility_new,
        'selectable': 1,
        'option0': 'Minor',
        'optionTrans0': I18n.of(context).modelPostMinor,
        'optionIcon0': Icons.accessible,
        'option1': 'Major',
        'optionTrans1': I18n.of(context).modelPostMajor,
        'optionIcon1': Icons.accessible_forward,
        'rumoredSubscription': 'rumored_crash',
        'confirmedSubscription': 'confirmed_crash',
        'clearedSubscription': 'cleared_crash'
      },
      {
        'titleTrans': I18n.of(context).modelPostHotelTitle,
        'title': 'local_hotel',
        'icon': Icons.local_hotel,
        'selectable': 1,
        'option0': 'local_hotel',
        'optionTrans0': I18n.of(context).modelPostSingleBed,
        'optionIcon0': Icons.local_hotel,
        'option1': 'local_hotel',
        'optionTrans1': I18n.of(context).modelPostMultiBed,
        'optionIcon1': Icons.local_hotel,
        'rumoredSubscription': 'rumored_hotel',
        'confirmedSubscription': 'confirmed_hotel',
        'clearedSubscription': 'cleared_hotel'
      },
      {
        'titleTrans': I18n.of(context).modelPostHazardTitle,
        'title': 'warning',
        'icon': Icons.warning,
        'selectable': 1,
        'option0': 'Debris',
        'optionTrans0': I18n.of(context).modelPostDebris,
        'optionIcon0': Icons.anchor,
        'option1': 'Flood',
        'optionTrans1': I18n.of(context).modelPostFlood,
        'optionIcon1': Icons.local_laundry_service,
        'option2': 'Fire',
        'optionTrans2': I18n.of(context).modelPostFire,
        'optionIcon2': Icons.whatshot,
        'rumoredSubscription': 'rumored_hazard',
        'confirmedSubscription': 'confirmed_hazard',
        'clearedSubscription': 'cleared_hazard'
      },
      {
        'titleTrans': I18n.of(context).modelPostLibraryTitle,
        'title': 'local_library',
        'icon': Icons.local_library,
        'selectable': 1,
        'option0': 'Book Rental',
        'optionTrans0': I18n.of(context).modelPostBookRental,
        'optionIcon0': Icons.directions_car,
        'option1': 'Book Rental',
        'optionTrans1': I18n.of(context).modelPostBookPurchase,
        'optionIcon1': Icons.home,
        'rumoredSubscription': 'rumored_library',
        'confirmedSubscription': 'confirmed_library',
        'clearedSubscription': 'cleared_library'
      },
    ];
    return tagsList;
  }
}
