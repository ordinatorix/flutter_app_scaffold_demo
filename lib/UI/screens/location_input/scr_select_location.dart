import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../generated/i18n.dart';

import '../../../models/post.dart' show EventLocation;

import '../../base_view_screen.dart';

import 'mdl_select_location_screen.dart';

import '../../../logger.dart';

final log = getLogger('SelectLocationScreen');

class SelectLocationScreen extends StatelessWidget {
  final EventLocation initialLocation;
  final bool isSelecting;
  SelectLocationScreen({
    this.initialLocation,
    this.isSelecting = false,
  });

  @override
  Widget build(BuildContext context) {
    log.i('building select location map screen');
    final mediaQuery = MediaQuery.of(context);
    return BaseView<SelectLocationScreenViewModel>(
      onModelReady: (model) {
        model.loadMapStyle(context: context);
        model.setMapPosition(initialLocation);
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              I18n.of(context).selectLocationScreenTitle,
              style: Theme.of(context).textTheme.headline6,
            ),
            actions: <Widget>[
              isSelecting
                  ? IconButton(
                      icon: Icon(Icons.check),
                      onPressed: model.pickedLocation == null
                          ? null
                          : () {
                              Navigator.of(context).pop(model.pickedLocation);
                            })
                  : Container(),
            ],
          ),
          body: Stack(
            children: [
              GoogleMap(
                key: model.mapKey,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: model.onMapCreated,
                onCameraMove: model.onCameraMove,
                mapType: model.currentMapType,
                initialCameraPosition: CameraPosition(
                  target: model.lastMapPosition,
                  zoom: 14,
                ),
                markers: (model.lastMapPosition == null && isSelecting)
                    ? null
                    : {
                        Marker(
                            markerId: MarkerId('m1'),
                            position: model.lastMapPosition),
                      },
              ),
              Positioned(
                bottom: mediaQuery.size.height * 0.15,
                right: mediaQuery.size.width * 0.055,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white70,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(0, 5),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.layers,
                      color: Colors.grey[700],
                    ),
                    onPressed: model.onMapTypeChange,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
