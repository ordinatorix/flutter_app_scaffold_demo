import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:camera/camera.dart';

import '../../base_model.dart';

import '../../../generated/i18n.dart';

import '../../../enums/view_state.dart';

import '../../../services/camera_service.dart';
import '../../../services/navigation_service.dart';

import '../../../helpers/camera_screen_arguments.dart';

import '../../../locator.dart';
import '../../../logger.dart';

final log = getLogger('CameraScreenViewModel');

class CameraScreenViewModel extends BaseModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final CameraService _cameraService = locator<CameraService>();
  // final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  CameraController control;
  String videoPath; // stores the path of the current video being recorded
  Timer _timer;
  int timerCount = 0;
  bool onlyPicture;
  final RegExp thumbnailFilter = RegExp(r'videoThumbnail');
  CameraScreenArguments args;
  List<String> _imagePathList = []; // stores the path of images
  List<String> _videoPathList = []; // stores the path of videos
  List<String> thumbnailPathList = []; // stores the path of thumbnails
  Map<String, List<String>> storedMediaList = {
    'imagePathList': [],
    'videoPathList': [],
    'thumbnailPathList': [],
  };
  get ready => _cameraService.isReady;

  /// Initialize camera screen view model.
  ///
  /// Camera is initialize with the selfie camera if taking a profile picture.
  void initializeModel() async {
    setState(ViewState.Busy);
    log.i('initializeModel');
    _imagePathList = storedMediaList['imagePathList'];
    _videoPathList = storedMediaList['videoPathList'];
    thumbnailPathList = storedMediaList['thumbnailPathList'];
    log.d('local camera controller: $control');
    await _cameraService.setupCameras(cameraIndex: onlyPicture ? 1 : 0);

    setState(ViewState.Idle);
    log.d('local camera controller: $control');
    log.d('service camera controller: ${_cameraService.controller}');
  }

  /// Dispose of camera screen view model.
  void disposer() async {
    log.i('disposer');
    _cameraService.disposeController(); // Dispose of active camera controller.
    control?.dispose(); // Dispose of local camera controller.
    _timer?.cancel();
  }

  /// Change between cameras
  void changeLensDirection() {
    log.i('changeLensDirection');
    final description = control?.description;

    _cameraService.onNewCameraSelected(description);
  }

  /// Select media from phone gallery.
  void onSelectFromGallery() {
    log.i('onSelectFromGallery');
    _cameraService.selectFromGallery().then((Map listpath) {
      thumbnailPathList.addAll(
        listpath['thumbnail'] + listpath['image'],
      );
      _imagePathList.addAll(listpath['image']);
      _videoPathList.addAll(listpath['video']);
      setState(ViewState.Idle);
    });
  }

  /// Unselect media from thumbnail list.
  void onUnselectMedia(int index) async {
    log.i('onUnselectMedia | index: $index');
    String tempDir = (await syspath.getTemporaryDirectory()).path;
    String thumbnailcacheDir = '$tempDir/videoThumbnail';
    thumbnailPathList.removeAt(index);
    _imagePathList.retainWhere((imageFilePath) {
      return thumbnailPathList.contains(imageFilePath);
    });
    _videoPathList.retainWhere((videoFilePath) {
      return thumbnailPathList.contains(
          '$thumbnailcacheDir/${path.basenameWithoutExtension(videoFilePath)}.jpg');
    });
    setState(ViewState.Idle);
  }

  /// Take picture with the camera.
  ///
  /// When taking a profile picture, only the lastest image is stored,
  /// any others are overwritten.
  void onTakePictureButtonPressed() {
    log.i('onTakePictureButtonPressed');
    log.d('control is: $control');
    if (control != null &&
        control.value.isInitialized &&
        !control.value.isRecordingVideo) {
      _cameraService.takePicture().then((String filePath) {
        if (filePath != null) {
          // if (mounted) {
          if (onlyPicture) {
            if (thumbnailPathList.isNotEmpty) {
              thumbnailPathList.clear();
              _imagePathList.clear();
            }
          }
          _imagePathList.add(filePath);
          thumbnailPathList.add(filePath);
          log.d(_imagePathList);
          log.d(thumbnailPathList);
        }
        // }
        setState(ViewState.Idle);
      });
    }
  }

  /// Start Recording video using phone camera.
  void onVideoRecordButtonPressed() {
    log.i('onVideoRecordButtonPressed');
    if (control != null &&
        control.value.isInitialized &&
        !control.value.isRecordingVideo) {
      log.d('recording');

      _cameraService.startVideoRecording().then((_) {
        // if (mounted)
        // videoPath = filePath;
        // log.d('filepath of recorded video: $filePath');

        log.d('started recording');
        _startTimer();
      });
    }
  }

  /// Start video timer.
  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (timerCount > 10) {
          onStopButtonPressed();
        } else {
          timerCount = timerCount + 1;
        }
        setState(ViewState.Idle);
      },
    );
  }

  /// Stop recording video.
  void onStopButtonPressed() {
    log.i('onStopButtonPressed');
    if (control != null &&
        control.value.isInitialized &&
        control.value.isRecordingVideo) {
      _cameraService.stopVideoRecording().then((pathMap) {
        _timer.cancel();
        log.d('stopped video recording');
        log.d('thumbnailPath is:${pathMap['thumbnailPath']}');
        thumbnailPathList.add(pathMap['thumbnailPath']);
        log.w('Fix: make sure this works');
        log.d('videoPath is:${pathMap['videoPath']}');
        _videoPathList.add(pathMap['videoPath']);
        log.d('added to vidoepathlist');
        log.w('Fix: make sure this works');
        // if (mounted)

        timerCount = 0;
        setState(ViewState.Idle);
        _showInSnackBar(
            // context: context,
            message: 'I18n.of(context).cameraScreenRecordingPaused');
      });
    }
  }

  /// Pause video recording.
  void onPauseButtonPressed(BuildContext context) {
    log.i('onPauseButtonPressed');
    _cameraService.pauseVideoRecording().then((_) {
      // if (mounted)
      setState(ViewState.Idle);
      _showInSnackBar(
          // context: context,
          message: I18n.of(context).cameraScreenRecordingPaused);
    });
  }

  /// Resume video recording.
  void onResumeButtonPressed(BuildContext context) {
    log.i('onResumeButtonPressed');
    _cameraService.resumeVideoRecording().then((_) {
      // if (mounted)
      setState(ViewState.Idle);
      _showInSnackBar(
          // context: context,
          message: I18n.of(context).cameraScreenRecordingResumed);
    });
  }

  /// Retake profile picture.
  ///
  /// Set mediaPathList to empty [List]
  void retakeProfilePicture() {
    log.i('retakeProfilePicture');
    _imagePathList = [];
    _videoPathList = [];
    thumbnailPathList = [];
    setState(ViewState.Idle);
  }

  /// Cancel taking profile picture.
  ///
  /// Navigates to the next screen with an empty [map] as result.
  void onCancelProfilePicture() {
    log.i('onCancelProfilePicture');
    _imagePathList = [];
    _videoPathList = [];
    thumbnailPathList = [];

    storedMediaList = {
      'imagePathList': _imagePathList,
      'videoPathList': _videoPathList,
      'thumbnailPathList': thumbnailPathList,
    };
    _navigationService.pop(storedMediaList);
  }

  /// Navigate away from camera screen.
  ///
  /// Return the stored media to the next screen.
  void onNavigateNextButtonPressed() {
    log.i('onNavigateNextButtonPressed');

    storedMediaList = {
      'imagePathList': _imagePathList,
      'videoPathList': _videoPathList,
      'thumbnailPathList': thumbnailPathList,
    };
    _navigationService.pop(storedMediaList);
  }

  /// Show message in snackbar.
  void _showInSnackBar({String message}) {
    log.i('showInSnackBar | message: $message');
    scaffoldMessengerKey.currentState
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
