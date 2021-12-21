import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../base_model.dart';
import '../../../enums/view_state.dart';

import '../../../models/post.dart' show EventLocation;
import '../../../logger.dart';

final log = getLogger('SelectLocationScreenViewModel');

class SelectLocationScreenViewModel extends BaseModel {
  BuildContext _context;
  Completer<GoogleMapController> _controller = Completer();
  String _darkMapStyle;
  String _lightMapStyle;
  LatLng lastMapPosition;
  LatLng pickedLocation;

  Key mapKey = UniqueKey();
  MapType currentMapType = MapType.normal;

// load style use on mad for dark & light mode
  void loadMapStyle({@required BuildContext context}) {
    log.i('loadMapStyle | context: $context');
    _context = context;
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

  void onMapCreated(GoogleMapController controller) {
    log.i('onMapCreated | controller: $controller');

    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }
    // if (mounted) {
    if (controller != null) {
      bool isDark =
          MediaQuery.of(_context).platformBrightness == Brightness.dark;
      final ThemeData theme = Theme.of(_context);
      if (isDark || theme.brightness == Brightness.dark) {
        controller.setMapStyle(_darkMapStyle);
      } else {
        controller.setMapStyle(_lightMapStyle);
      }
    }
    // }
    log.d('done creating map');
  }

// what happens when the map is moved
  void onCameraMove(CameraPosition position) {
    log.i('onCameraMove | position: $position');
    lastMapPosition = position.target;
    pickedLocation =
        LatLng(lastMapPosition.latitude, lastMapPosition.longitude);

    setState(ViewState.Idle);
  }

// change map type
  void onMapTypeChange() {
    log.i('onMapTypeChange');
    currentMapType =
        currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    setState(ViewState.Idle);
  }

  void setMapPosition(EventLocation position) {
    log.i('setMapPosition | position: $position');
    if (position != null) {
      lastMapPosition = LatLng(position.latitude, position.longitude);
    } else {
      log.w('streamed location is null');
      return;
    }
  }
}
