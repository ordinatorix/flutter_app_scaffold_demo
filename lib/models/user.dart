import 'package:flutter/foundation.dart';

class DeviceLocation {
  final double latitude;
  final double longitude;
  final double heading;
  final double accuracy;
  final double speed;
  final double speedAccuracy;
  final double altitude;
  final int floor;
  final DateTime timestamp;
  DeviceLocation({
    @required this.latitude,
    @required this.longitude,
    this.heading,
    @required this.accuracy,
    this.speed = 0.0,
    this.speedAccuracy = 0.0,
    this.altitude = 0.0,
    this.floor = 0,
    @required this.timestamp,
  });
  @override
  String toString() {
    return 'Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}, acc: ${accuracy.toStringAsFixed(4)}, spd: ${speed.toStringAsFixed(4)}, alt: ${altitude.toStringAsFixed(4)}, floor:$floor, timestamp:${timestamp.toIso8601String()}';
  }
}

class User {
  final String uid;
  final String displayName; //is also username
  final String email;
  final String phone;
  final String gender;
  final String language;
  bool isAnonymous;
  bool network;
  bool isSafe;
  final int age;
  final double trustFactor;
  String photoUrl;
  final String fullName; //official first and last name
  final DeviceLocation lastKnownLocation;
  final String homeLocation;
  final String workLocation;
  final DateTime lastSignInTime;
  final DateTime creationTime;
  // final String password;
  final bool isAdmin;

  User({
    this.uid,
    this.displayName,
    this.email,
    this.phone,
    this.gender,
    this.language,
    this.isAnonymous,
    this.network,
    this.isSafe,
    this.age,
    this.trustFactor,
    this.photoUrl,
    this.fullName,
    this.lastKnownLocation,
    this.homeLocation,
    this.workLocation,
    this.isAdmin,
    this.creationTime,
    this.lastSignInTime,

    // this.password,
  });
  @override
  String toString() {
    return 'uid: $uid, display name: $displayName, phone: $phone, photoURL: $photoUrl, isAdmin: $isAdmin';
  }
}
