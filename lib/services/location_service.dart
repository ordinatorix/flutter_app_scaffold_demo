import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../locator.dart';
import '../logger.dart';

import '../helpers/share_prefs_helper.dart';

import '../models/user.dart' show DeviceLocation;
import 'package:flutter_scaffold/keys/key_manager.dart';

final google_api_key = APIKEYS.GOOGLE_API_KEY;

final log = getLogger('LocationService');

class LocationService {
  final SharedPrefsHelper _sharedPrefsHelper = locator<SharedPrefsHelper>();
  static const _checkTime = Duration(
      seconds: 1); // Time to wait before checking location service status.
  static const _timeOut = Duration(
      seconds: 30); // Time to wait before stop trying to get current location.

  StreamController<DeviceLocation> _locationController =
      StreamController<DeviceLocation>.broadcast();

  Stream<DeviceLocation> get locationStream => _locationController.stream;
  Completer locationStatus = Completer<bool>();

  bool justDenied = false; // Used to check if we already asked for permission.

  /// Start location service on app launch.
  ///
  /// Launch a location stream on app launch.
  LocationService() {
    log.i('locationServiceConstructor ');

    checkLocationServiceStatus().then((value) {
      log.d('waiting for future to complete');
      locationStatus.future.then((greenLight) {
        if (greenLight) {
          _streamLocation();
        } else {
          log.w('You are shit out of luck');
        }
      });
    });
  }

  /// Dispose of location service.
  ///
  /// Closes any active controllers.
  void dispose() {
    _locationController?.close();
    log.d('Location controller closed');
  }

  /// Generate a preview image for maps.
  ///
  /// Takes [latitude] & [longitude] as parameters to generate a static map of the location.
  /// This cost MONEY $$$$
  String generateLocationPreviewImage({double latitude, double longitude}) {
    log.i(
        'generateLocationPreviewImage | latitude: $latitude,longitude: $longitude');
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=16&size=300x600&maptype=roadmap&markers=color:red%7Clabel:%7C$latitude,$longitude&key=$google_api_key';
  }

  /// Get address of GPS location.
  ///
  /// Takes [latitude] & [longitude] as parameters to generate a street address.
  /// This cost MONEY $$$$
  Future<String> getPlaceAddress(double latitude, double longitude) async {
    log.i('getPlaceAddress | latitude: $latitude, longitude:$longitude');
    final Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$google_api_key');
    final response = await http.get(url);
    log.d(response.body);
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  /// Get name of nearby places.
  ///
  /// Takes [latitude] & [longitude] as parameters to generate [json] of nearby places.
  /// This cost MONEY $$$$
  Future<void> getNearbyPlaces(double latitude, double longitude) async {
    log.i('getNearbyPlaces | latitude: $latitude, longitude: $longitude');
    log.w('This cost MONEY \$\$\$\$');
    final Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=100&key=$google_api_key');
    log.w('This cost MONEY \$\$\$\$');
    final response = await http.get(url);
    log.w('You just spent MONEY \$\$\$\$');
    log.d(response.body);
    return json.decode(response.body)['results'][1]['name'];
  }

  /// Get current user location.
  ///
  /// Throws a [TimeoutException] when no location is received within the supplied [timeOut] duration.
  Future<DeviceLocation> getCurrentUserLocation() async {
    log.i('getCurrentUserLocation');
    try {
      Position position;

      // check for current location

      position = await Geolocator.getCurrentPosition(
        timeLimit: _timeOut,
      );
      log.d(
          'user position: (${position.latitude}, ${position.longitude} @ ${position.timestamp})');

      final location = DeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        accuracy: position.accuracy,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy,
        altitude: position.altitude,
        floor: position.floor,
        timestamp: position.timestamp,
      );
      return location;
    } catch (error) {
      log.e('error getting user location: $error');
      // TODO: handle permission denied error
      throw error;
    }
  }

  /// Get distance(meters) between two location coordinates.
  Future<double> getDistanceBetweenLocation(
    double userLatitude,
    double userLongitude,
    double postLatitude,
    double postLongitude,
  ) async {
    log.i(
        'getDistanceBetweenLocation | userLatitude: $userLatitude, userLongitude: $userLongitude, postLatitude:$postLatitude, postLongitude: $postLongitude');
    try {
      double distanceInMeters = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        postLatitude,
        postLongitude,
      );
      return distanceInMeters;
    } catch (error) {
      log.e('error getting distance between locations: $error');
      throw error;
    }
  }

  /// Check if location service is enabled.
  ///
  /// Completes a [Future] when location service is enabled.
  /// If disabled, wait [checkTime] duration before checking the location service status again.
  void _isLocationActive() async {
    log.i('_isLocationActive');

    log.d('checking location service status');
    bool result = await Geolocator.isLocationServiceEnabled();

    if (result) {
      _sharedPrefsHelper
          .updateIsLocationEnabled(true); // set location shared pref to true
      log.d('location is enabled?: $result');
      // complete with true
      locationStatus.complete(result);
    } else {
      //TODO: show Snackbar notifing user that location is off
      log.d('location is enabled?: $result');
      if (_sharedPrefsHelper.isLocationEnabled) {
        _sharedPrefsHelper.updateIsLocationEnabled(false);
      } // set location shared pref to false
      Future.delayed(_checkTime, () {
        log.d('waited half a second');
        _isLocationActive();
      });
    }
  }

  /// Check the status of the location service.
  ///
  /// First checks if the user has granted permissions.
  /// Checks if location service is enabled when [LocationPermission.always] or [LocationPermission.whileInUse].
  /// Request permission when [LocationPermission.denied].
  /// Show banner when [LocationPermission.deniedForever].
  Future<void> checkLocationServiceStatus() async {
    log.i('checkLocationServiceStatus');

    log.d('checking location permission');
    LocationPermission permissionStatus = await Geolocator.checkPermission();
    switch (permissionStatus) {
      case LocationPermission.always:
        {
          log.d('Location is always permitted.');
          // check to see if service is active
          _isLocationActive();
        }

        break;
      case LocationPermission.whileInUse:
        {
          log.d('Location is permitted while in use.');
          // check to see if service is active
          _isLocationActive();
        }

        break;
      case LocationPermission.denied:
        {
          log.d('Location is denied.');
          // request permissions
          if (!justDenied) {
            Geolocator.requestPermission()
                .then((value) => checkLocationServiceStatus());
          } else {
            locationStatus.complete(false);
            // TODO: show banner indicating that location is not permitted.
          }
          justDenied = true;
        }

        break;
      case LocationPermission.deniedForever:
        {
          log.w('Location is denied FOR EVER.');
          locationStatus.complete(false);
          // TODO: show banner indicating that location is not permitted.
          // let user know that permission is permanatly denied
        }

        break;

      default:
        {
          // request permission if the permision status is unknown
          Geolocator.requestPermission()
              .then((value) => checkLocationServiceStatus());
        }
    }
  }

  /// Stream user current location.
  ///
  /// Updates the stream at the [distanceFilter] specified using the [desiredAcurracy].
  StreamSubscription<Position> _streamLocation() {
    log.i('_streamLocation');

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.best, distanceFilter: 0)
        .listen((Position position) {
      log.d('position: $position');
      if (position != null) {
        if (!_sharedPrefsHelper.isLocationEnabled) {
          log.w('updating location enabled value in shared prefs');
          _sharedPrefsHelper.updateIsLocationEnabled(
              true); // set location shared pref to true
        }
        _locationController.add(DeviceLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          heading: position.heading,
          accuracy: position.accuracy,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
          altitude: position.altitude,
          floor: position.floor,
          timestamp: position.timestamp,
        ));
      }
    }, onError: (error) {
      log.wtf('error is here?: $error');
      bool closed = _locationController.isClosed;
      bool paused = _locationController.isPaused;
      _sharedPrefsHelper
          .updateIsLocationEnabled(false); // set location shared pref to false
      log.e('adding null value to controller');
      _locationController.add(null);
      log.e('handled position error: $error');
      log.e('location controller status: closed: $closed, paused: $paused');
    });

    return positionStream;
  }
}
