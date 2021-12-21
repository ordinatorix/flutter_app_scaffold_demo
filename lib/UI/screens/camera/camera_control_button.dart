import 'package:flutter/material.dart';

import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('CameraControlButtons');

class CameraControlButtons extends StatelessWidget {
  final Function onSelectFromGalleryHandler;
  final Function onTakePictureButtonPressedHandler;
  final Function onVideoRecordButtonPressedHandler;
  final Function onStopButtonPressedHandler;
  final Function onNavigateNextButtonPressedHandler;
  final bool recordingState;
  final bool onlyPicture;
  final List imagePathList;

  CameraControlButtons({
    @required this.onSelectFromGalleryHandler,
    @required this.onTakePictureButtonPressedHandler,
    @required this.onVideoRecordButtonPressedHandler,
    @required this.onStopButtonPressedHandler,
    @required this.onNavigateNextButtonPressedHandler,
    @required this.recordingState,
    @required this.onlyPicture,
    @required this.imagePathList,
  });

  @override
  Widget build(BuildContext context) {
    log.d('building widget');
    log.d('recording state: $recordingState');

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // library button
              IconButton(
                padding: const EdgeInsets.all(0),
                icon: Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: onSelectFromGalleryHandler,
              ),
              // Shutter button
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black26,
                  ),
                  child: Icon(
                    Icons.camera,
                    color: recordingState ? Colors.red : Colors.white,
                    size: 90,
                  ),
                ),
                onTap: onTakePictureButtonPressedHandler,
                onLongPress:
                    onlyPicture ? null : onVideoRecordButtonPressedHandler,
                onLongPressEnd: onlyPicture
                    ? null
                    : (_) {
                        onStopButtonPressedHandler();
                      },
              ),
              //Navigation Button
              !onlyPicture && imagePathList.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        child: Icon(
                          Icons.navigate_next,
                          size: 50,
                        ),
                        tooltip: I18n.of(context).cameraScreenCameraFABTooltip,
                        onPressed: onNavigateNextButtonPressedHandler,
                      ),
                    )
                  : SizedBox(
                      width: 50,
                      height: 40,
                    ),
            ],
          ),
        ),
        onlyPicture
            ? SizedBox(
                height: 15,
              )
            : Container(
                color: Colors.black45,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    I18n.of(context).cameraScreenActionButtonInfo,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ],
    );
  }
}
