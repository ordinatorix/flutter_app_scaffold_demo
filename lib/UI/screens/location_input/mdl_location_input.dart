import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../base_model.dart';
import '../../../locator.dart';
import '../../../enums/view_state.dart';
import '../../../models/post.dart' show EventLocation;
import 'scr_select_location.dart';
import '../../../services/location_service.dart';
import '../../../services/analytics_service.dart';

import '../../../logger.dart';

final log = getLogger('LocationInputViewModel');

class LocationInputViewModel extends BaseModel {
  final AnalyticsService _analytics = locator<AnalyticsService>();
  final LocationService _locationHelper = locator<LocationService>();
  String previewImageUrl;

  EventLocation _initPosition;

  void initializeModel(EventLocation initGpsPosition) {
    log.i('initializeModel | initGpsPosition: $initGpsPosition');
    if (initGpsPosition != null) {
      setState(ViewState.Busy);
      _initPosition = initGpsPosition;

      _showPreview(_initPosition.latitude, _initPosition.longitude);
    }
  }

  void _showPreview(double latitude, double longitude) {
    log.i('_showPreview | latitude: $latitude , longitude: $longitude');
    final staticMapImageUrl = _locationHelper.generateLocationPreviewImage(
        latitude: latitude, longitude: longitude);
    // log.w('setting new map url: $staticMapImageUrl');
    // imageCache.clear();
    
    previewImageUrl = staticMapImageUrl;

    setState(ViewState.Idle);
  }

  Future<void> selectOnMap(
    BuildContext context,
    Function onSelectPlace,
  ) async {
    log.i('selectOnMap | context: $context, onSelectPlace: $onSelectPlace');
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => SelectLocationScreen(
          initialLocation: _initPosition,
          isSelecting: true,
        ),
      ),
    );
    if (selectedLocation == null) {
      _analytics.logCustomEvent(
          name: 'tap_modify_post_location', parameters: {'completed': 0});
      return;
    }
    _showPreview(selectedLocation.latitude, selectedLocation.longitude);
    onSelectPlace(
      latitude: selectedLocation.latitude,
      longitude: selectedLocation.longitude,
      altitude: 0.0,
      heading: 0.0,
      accuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      locationTimestamp: DateTime.now(),
    );
    _analytics.logCustomEvent(
        name: 'tap_modify_post_location', parameters: {'completed': 1});
    setState(ViewState.Idle);
  }
}
