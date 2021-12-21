import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/earth_map_tab/pin_info_pill/marker_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../base_view_screen.dart';

import '../../../../enums/view_state.dart';

import '../../../../models/post.dart';
import '../../../../models/user.dart' show DeviceLocation;

import '../../../../logger.dart';
import 'mdl_map_home_scr.dart';

final log = getLogger('HomeScreen');

class HomeMapScreen extends StatelessWidget {
  final List<Post> post;

  HomeMapScreen({this.post});

  @override
  Widget build(BuildContext context) {
    log.i('building home screen');
    final postSnapShotData = post;

    log.d('postsnapshot: $postSnapShotData');

    return BaseView<HomeMapScreenModel>(
      onModelReady: (model) {
        model.theme = Theme.of(context);
        model.mediaQuery = MediaQuery.of(context);
        model.tagsList = TagList().getTagList(context: context);
        model.namedRoute = ModalRoute.of(context).settings.name;
        log.d('on home model ready');
        log.d('theme brightness: ${model.isDark} & ${model.theme.brightness}');
        model.initializeModel();
      },
      
      onModelDisposing: (model) {
        model.disposer();
      },
      builder: (context, model, child) {
        model.streamedLocation =
            Provider.of<DeviceLocation>(context, listen: false);// listen is set to false so that the whole screen does not rebuild

        log.d('streamedPostion: ${model.streamedLocation}');
        log.d('lastMapPosition: ${model.lastMapPosition}');
        log.d('mapKey: ${model.mapKey}');
        log.d('gpsStatus: ${model.gpsStatus}');

        model.setMapPosition();
        model.markers.clear();
        model.addMarkers(
            postSnapShotData: postSnapShotData, alerts: model.tagsList);

        return model.state == ViewState.Busy
            ? Center(
                child: SpinKitCubeGrid(
                  color: Theme.of(context).accentColor,
                ),
              )
            : Stack(
                children: [
                  GoogleMap(
                    key: model.mapKey,
                    onMapCreated: model.onMapCreated,
                    mapToolbarEnabled: false,
                    initialCameraPosition: model.initialMapPosition,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: model.currentMapType,
                    markers: model.markers,
                    onCameraMove: model.onCameraMove,
                    onCameraMoveStarted: model.onCameraMoveStarted,
                    onCameraIdle: model.onCameraIdle,
                    onTap: (LatLng location) {
                      model.onMapTap();
                    },
                    onLongPress: (LatLng location) {
                      model.onMapLongPress(location);
                    },
                  ),
                  Positioned(
                    child: Consumer<DeviceLocation>(
                      builder: (_, value, __) {
                        return Text(
                          '$value',
                          style: TextStyle(color: Colors.red),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: model.mediaQuery.size.height * 0.15,
                    right: model.mediaQuery.size.width * 0.055,
                    child: Container(
                      // color: Colors.purple,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer<DeviceLocation>(builder: (_, value, __) {
                            log.d('rebuilding position FAB');
                            return FloatingActionButton(
                              backgroundColor: Colors.white70,
                              mini: true,
                              onPressed: () {
                                model.setMapPosition(
                                  zoom: 15,
                                  forceSet: true,
                                  deviceLocation: value,
                                );
                              },
                              child: Icon(
                                Icons.my_location,
                                color: Colors.grey[700],
                              ),
                            );
                          }
                              // child:
                              ),
                          SizedBox(
                            height: model.mediaQuery.size.height * 0.03,
                          ),
                          FloatingActionButton(
                            backgroundColor: Colors.white70,
                            mini: true,
                            onPressed: model.onMapTypeChange,
                            child: Icon(
                              Icons.layers,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    top: model.pinPillPosition,
                    right: 0,
                    left: 0,
                    duration: Duration(milliseconds: 200),
                    child: MarkerInfo(
                      currentlySelectedPin: model.currentlySelectedPin,
                      markerTapHandler: model.pillTapHandler,
                      verifyTapHandler: model.pillVerifyButtonTapHandler,
                    ),
                  )
                ],
              );
      },
    );
  }
}
