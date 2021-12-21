// TODO: create a standalone map widget
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../base_model.dart';

import '../../../../locator.dart';
import '../../../../logger.dart';

import '../../../../models/post.dart';
import '../../../../models/user.dart' show DeviceLocation;

import '../../../../enums/view_state.dart';

import '../../../../services/analytics_service.dart';
import '../../../../services/navigation_service.dart';

import '../../../../helpers/share_prefs_helper.dart';
import '../../../../helpers/feed_item_detail_screen_arguments.dart';
import '../../../../helpers/post_screen_arguments.dart';
import '../../../../helpers/initial_location.dart';

import '../../grid_menu/scr_grid_menu.dart';
import '../../feed_item_details/scr_feed_item_details.dart';
import '../../post_edit/scr_post_edit.dart';

final log = getLogger('HomeMapScreenModel');

class HomeMapScreenModel extends BaseModel {
  final Key mapKey = UniqueKey();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final SharedPrefsHelper _sharedPrefsHelper = locator<SharedPrefsHelper>();
  final NavigationService _navigationService = locator<NavigationService>();
  final CountryISOCode _isoCodes = CountryISOCode();
  // GoogleMapController mapComp;
  Completer<GoogleMapController> _controller = Completer();
  Completer _mapMoveStart = Completer();
  String _countryCode;
  MapType currentMapType = MapType.normal;
  DeviceLocation streamedLocation;
  LatLng lastMapPosition;
  CameraPosition initialMapPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 5.0,
  );

  bool isDark = false;
  ThemeData theme = ThemeData();
  double pinPillPosition;
  String _darkMapStyle;
  String _lightMapStyle;
  String namedRoute;
  List tagsList;
  bool gpsStatus = true;
  Set<Marker> markers = {};
  MediaQueryData mediaQuery;
  PinInformation currentlySelectedPin = PinInformation(
    address: '',
    location: LatLng(0, 0),
    postTitle: '',
    labelColor: Colors.grey,
    postTimestamp: null,
    post: null,
    pinIcon: Icons.local_offer,
  );

  /// Initialize home screen model.
  void initializeModel() {
    log.i('initializeModel');
    setState(ViewState.Busy);
    loadMapStyle();
    _countryCode = _sharedPrefsHelper.countryCode;
    log.d('country code: $_countryCode');
    setAnalyticsScreenName();

    initialMapPosition = CameraPosition(
      target: _isoCodes.isoLocation[_countryCode],
      zoom: 5.0,
    );
    log.w('init position latitude: ${initialMapPosition.target.latitude}');
    pinPillPosition = -mediaQuery.size.height * 0.5;
    setState(ViewState.Idle);
  }

  /// Dispose home page.
  void disposer() async {
    log.i('disposer');
    // log.wtf('before: ${mapComp.mapId}');
    // log.wtf(mapComp.)
    // mapComp?.dispose();
    final GoogleMapController controller = await _controller.future;
    controller.dispose();
    // log.wtf('after: ${mapComp.mapId}');
  }

  /// Set analytice screen name.
  void setAnalyticsScreenName() async {
    log.i('setAnalyticsScreenName');
    await _analyticsService.setCurrentScreen(screenName: '/home-screen');
  }

  /// Set analytices events
  void _setAnalyticsCustomEvent(
      {String name, Map<String, dynamic> parameters}) async {
    log.i('setAnalyticsCustomEvent | name: $name, parameters: $parameters');
    await _analyticsService.logCustomEvent(name: name, parameters: parameters);
  }

  /// Animate map to specified location.
  void _animateToLocation({
    @required LatLng location,
    double zoom = 10.0,
  }) async {
    //11 give awhole city view ; 14 give neighboorhood view
    log.i(
        'animateToLocation | latitude:${location.latitude}, longitude:${location.longitude}, zoom: $zoom');
    final GoogleMapController controller = await _controller
        .future; // This waits for a result from the controller.

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(location.latitude, location.longitude),
        zoom: zoom,
      ),
    ));
  }

  /// Dismiss marker info.
  void _dismissMarkerInfo() {
    log.i('_dismissMarkerInfo');
    if (pinPillPosition == 0) {
      _setPillPosition(-mediaQuery.size.height * 0.5);
      _setAnalyticsCustomEvent(name: 'dismissed_marker_info');
    }
  }

  /// Load map theme.
  ///
  /// Theme varies between dark & light themes.
  void loadMapStyle() {
    log.i('loadMapStyle');

    rootBundle
        .loadString('assets/map_styles/dark_map_style.json')
        .then((string) {
      _darkMapStyle = string;
    });
    rootBundle
        .loadString('assets/map_styles/light_map_style.json')
        .then((string) {
      _lightMapStyle = string;
    });
  }

  /// Set map position.
  ///
  /// Will default to setting the map position to the current location.
  /// if current location is not available,
  /// Will the map position to [lastMapPosition] if not null && if [forceSet]
  void setMapPosition({
    double zoom = 11,
    bool forceSet = false,
    DeviceLocation deviceLocation,
  }) async {
    log.i(
        'setMapPosition | zoom: $zoom, foceSet: $forceSet, location: $deviceLocation');
    gpsStatus = _sharedPrefsHelper.isLocationEnabled;
    if (deviceLocation != null) {
      streamedLocation = deviceLocation;
    }
    if (lastMapPosition == null) {
      if (streamedLocation != null) {
        if (gpsStatus == false) {
          _sharedPrefsHelper.updateIsLocationEnabled(true);
          gpsStatus = true;
        }
        lastMapPosition =
            LatLng(streamedLocation.latitude, streamedLocation.longitude);
        _animateToLocation(location: lastMapPosition, zoom: zoom);

        log.d('lastMapPosition: $lastMapPosition');
        log.d('gpsStatus: $gpsStatus');
      } else {
        log.d('(streamed location & last known location) == null');

        /// should check for [forceSet]
        log.w('location not found');
        return;
      }
    } else {
      log.d('lastMapPosition is !=null: $lastMapPosition');
      if (forceSet) {
        if (streamedLocation != null) {
          if (gpsStatus == false) {
            _sharedPrefsHelper.updateIsLocationEnabled(true);
            gpsStatus = true;
          }
          lastMapPosition =
              LatLng(streamedLocation.latitude, streamedLocation.longitude);
          _animateToLocation(location: lastMapPosition, zoom: zoom);

          log.d('lastMapPosition: $lastMapPosition');
          log.d('gpsStatus: $gpsStatus');
        } else {
          log.d('streamed location is null');
          log.d('_animating to last known location');
          _animateToLocation(location: lastMapPosition, zoom: zoom);
          log.w('location not found');
          return;
        }
      }
    }
  }

  /// Change map type.
  void onMapTypeChange() {
    log.i('onMapTypeChange');
    _setAnalyticsCustomEvent(name: 'tap_change_map_type');
    currentMapType =
        currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    setState(ViewState.Idle);
  }

  /// User tap on map.
  void onMapTap() {
    log.i('onMapTap');
    _setAnalyticsCustomEvent(
        name: 'tap_on_map', parameters: {'action': 'cleared_marker_info'});

    _dismissMarkerInfo();
  }

  /// User long press on map.
  void onMapLongPress(LatLng location) {
    log.i('onMapLongPress');
    log.d('on long press on map: ${location.latitude}');
    _setAnalyticsCustomEvent(name: 'Long_press_on_map');

    _navigationService.replaceWith(
      GridMenuScreen.routeName,
      arguments: EventLocation(
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: 0.0,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Map camera move started handler.
  ///
  /// Dismisses the marker info if present.
  void onCameraMoveStarted() async {
    log.i('onCameraMoveStarted');
    _dismissMarkerInfo();
    _mapMoveStart.complete();
  }

  /// Map camera move handler.
  void onCameraMove(CameraPosition position) {
    log.i('onCameraMove | position: $position');

    lastMapPosition = position.target;
  }

  /// Camera has become idle.
  ///
  /// Reset [_mapMoveStart] completer.
  void onCameraIdle() {
    log.i('onCameraIdle');
    _mapMoveStart = Completer();
  }

  /// Set the position of the marker info pill.
  void _setPillPosition(double position) {
    log.i('setPillPosition | position: $position');
    pinPillPosition = position;
    log.d('done setting pill position');
    setState(ViewState.Idle);
  }

  /// User tapped on pill.
  void pillTapHandler() async {
    _setAnalyticsCustomEvent(name: 'marker_info_details_tap', parameters: {
      'post_type':
          '${currentlySelectedPin.post.status}_${currentlySelectedPin.post.title}'
    });

    _navigationService.removeUntil(
      FeedItemDetailsScreen.routeName,
      arguments: FeedItemDetailScreenArguments(
          post: currentlySelectedPin.post,
          returnPage: 0,
          referalPage: namedRoute),
    );
  }

  /// User tap pill verify button.
  void pillVerifyButtonTapHandler() async {
    log.d('confirmation button pressed');
    _setAnalyticsCustomEvent(name: 'marker_info_verify_tap', parameters: {
      'post_type':
          '${currentlySelectedPin.post.status}_${currentlySelectedPin.post.title}'
    });

    _navigationService.removeUntil(
      PostEditScreen.routeName,
      arguments: PostEditScreenArguments(
        tags: tagsList.firstWhere(
            (map) => map['title'] == currentlySelectedPin.post.title),
        post: currentlySelectedPin.post,
      ),
    );
  }

  /// Add post markers to map.
  void addMarkers({
    List<Post> postSnapShotData,
    List alerts,
  }) {
    log.i('addMarkers | postSnapShotData: $postSnapShotData, alerts: $alerts');
    log.w('passing a long list. call it within the model');
    if (postSnapShotData != null && postSnapShotData.isNotEmpty) {
      for (var i = 0; i < postSnapShotData.length; i++) {
        final _selectedPost = postSnapShotData[i];
        log.d('adding marker');
        markers.add(
          Marker(
            infoWindow: InfoWindow(),
            markerId: MarkerId(
              _selectedPost.id,
            ),
            position: LatLng(_selectedPost.location.latitude,
                _selectedPost.location.longitude),
            icon: _selectedPost.status == 'Rumored'
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow)
                : _selectedPost.status == 'Confirmed'
                    ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed)
                    : _selectedPost.status == 'Cleared'
                        ? BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen)
                        : _selectedPost.status == 'Fake'
                            ? BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueCyan)
                            : BitmapDescriptor.defaultMarker,
            onTap: () {
              _onMarkerTap(alerts, _selectedPost);
            },
          ),
        );
      }
    }
  }

  /// Marker onTap handler
  ///
  /// Sets the the relevant information for the marker to display before updating the markers position.
  void _onMarkerTap(List alerts, Post selectedPost) {
    log.i('_onMarkerTap');
    _setAnalyticsCustomEvent(
        name: 'tap_on_map', parameters: {'action': 'select_marker'});

    currentlySelectedPin = PinInformation(
      postTitle: alerts
          .firstWhere((element) => element.containsValue(selectedPost.title))[
              'titleTrans']
          .toUpperCase(),
      location: LatLng(
          selectedPost.location.latitude, selectedPost.location.longitude),
      address: selectedPost.namedLocation,
      labelColor: Colors.amber,
      postTimestamp: selectedPost.timestamp,
      post: selectedPost,
      pinIcon: alerts.firstWhere(
          (element) => element.containsValue(selectedPost.title))['icon'],
    );

    _mapMoveStart.future.then(
      (_) => _setPillPosition(0),
    ); // wait for map to begin moving then set pill position.

    log.d('done adding marker info to pin info');
    setState(ViewState.Idle);
  }

  /// Map creation handler.
  void onMapCreated(GoogleMapController controller) async {
    log.i('onMapCreated | controller: ${controller.toString()}');

    if (!_controller.isCompleted) {
      _controller.complete(controller);
    
    }
    // mapComp = controller;
    
    log.wtf('mapID: ${controller.mapId}');

    // setState(ViewState.Idle);
    // if (mounted) {
    if (controller != null) {
      log.d('setting map theme');
      bool isDark = theme.brightness == Brightness.dark;
      // set the map theme based on the app theme brightness.
      if (isDark) {
        controller.setMapStyle(_darkMapStyle);
      } else {
        controller.setMapStyle(_lightMapStyle);
      }
      setState(ViewState.Idle);
    }
    // }
    log.d('done creating map');
  }
}
