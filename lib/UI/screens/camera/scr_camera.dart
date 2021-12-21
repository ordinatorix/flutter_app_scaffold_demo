import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../base_view_screen.dart';

import 'mdl_camera_screen.dart';

import 'camera_control_button.dart';
import 'camera_thumbnail_row.dart';
import 'camera_profile_picture_display.dart';
import 'camera_display.dart';
import 'camera_toggle.dart';

import '../../../enums/view_state.dart';

import '../../../logger.dart';

final log = getLogger('CameraScreen');

class CameraScreen extends StatelessWidget {
  static const routeName = '/camera-screen';

// with WidgetsBindingObserver

  @override
  Widget build(BuildContext context) {
    log.d('building camera screen');

    final mediaQuery = MediaQuery.of(context);

    return BaseView<CameraScreenViewModel>(
      onModelReady: (model) {
        model.args = ModalRoute.of(context).settings.arguments;
        model.storedMediaList = model.args.mediaList;
        model.onlyPicture = model.args.onlyPicture;
        model.initializeModel();
        log.d('args: ${model.args.onlyPicture}; ${model.args.mediaList}');
      },
      onModelDisposing: (model) {
        model.disposer();
      },
      builder: (context, model, child) {
        model.control = Provider.of<CameraController>(context);
        log.d('stored media list: ${model.storedMediaList}');
        return ScaffoldMessenger(
          key: model.scaffoldMessengerKey,
          child: Scaffold(
            // key: model.scaffoldMessengerKey,
            body: model.state == ViewState.Busy
                ? Center(
                    child: SpinKitCubeGrid(
                      color: Theme.of(context).accentColor,
                    ),
                  )
                : Stack(
                    children: [
                      Container(
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Center(
                            child: model.onlyPicture &&
                                    model.thumbnailPathList.isNotEmpty
                                ? CameraProfilePictureDisplay(
                                    imageTaken: model.thumbnailPathList[0],
                                    retakeProfilePictureHandler:
                                        model.retakeProfilePicture,
                                    saveProfilePictureHandler:
                                        model.onNavigateNextButtonPressed,
                                    cancelProfilePictureHandler:
                                        model.onCancelProfilePicture,
                                  )
                                : CameraDisplay(
                                    ready: model.ready,
                                    control: model.control,
                                    timerCount: model.timerCount,
                                  ),
                          ),
                        ),
                      ),
                      model.onlyPicture && model.thumbnailPathList.isNotEmpty
                          ? Container()
                          : Positioned(
                              top: MediaQuery.of(context).padding.top,
                              left: 0,
                              child: CameraToogle(
                                onNewCameraSelectedHandler:
                                    model.changeLensDirection,
                              ),
                            ),
                      Positioned(
                        child: Container(
                          // color: Colors.brown,
                          width: mediaQuery.size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              !model.onlyPicture &&
                                      model.thumbnailPathList.isNotEmpty
                                  ? CameraThumbnailRow(
                                      thumbnailPathList:
                                          model.thumbnailPathList,
                                      onUnseleceMediaHandler:
                                          model.onUnselectMedia,
                                      thumbnailFilter: model.thumbnailFilter,
                                    )
                                  : Container(),
                              model.onlyPicture &&
                                      model.thumbnailPathList.isNotEmpty
                                  ? Container()
                                  : CameraControlButtons(
                                      onlyPicture: model.onlyPicture,
                                      onSelectFromGalleryHandler:
                                          model.onSelectFromGallery,
                                      onTakePictureButtonPressedHandler:
                                          model.onTakePictureButtonPressed,
                                      onVideoRecordButtonPressedHandler:
                                          model.onVideoRecordButtonPressed,
                                      onStopButtonPressedHandler:
                                          model.onStopButtonPressed,
                                      recordingState: model.ready &&
                                          model.control.value.isRecordingVideo,
                                      imagePathList: model.thumbnailPathList,
                                      onNavigateNextButtonPressedHandler:
                                          model.onNavigateNextButtonPressed,
                                    ),
                            ],
                          ),
                        ),
                        bottom: 0,
                        left: 0,
                      )
                    ],
                  ),
          ),
        );
      },
    );
  }
}
