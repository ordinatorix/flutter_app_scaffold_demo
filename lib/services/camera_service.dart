import 'dart:io';
import 'dart:async';

// import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart' as syspath;
import 'package:camera/camera.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as thumbnail;

import './file_picker_service.dart';

import '../locator.dart';
import '../logger.dart';

final log = getLogger('CameraService');

/// Camera service, giving access to device cameras.
/// Uses [Camera] package
class CameraService {
  StreamController<CameraController> _cameraStreamcontroller =
      StreamController<CameraController>.broadcast();

  Stream<CameraController> get cameraStream => _cameraStreamcontroller.stream;

  final FilePickerService _filePickerService = locator<FilePickerService>();
  final videoFileExtensionFilter = RegExp(r'.mp4|.3gp|.webm|.mkv');
  final imageFileExtensionFilter =
      RegExp(r'.jpg|.bmp|.gif|.webp|.heic|.heif|.jpeg');
  List<CameraDescription> cameras = [];
  CameraController controller;
  bool get isReady => (controller != null && controller.value.isInitialized);

  /// Get timestamp for various camera functions and return [String].
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// Log error code.
  void logError(String code, String message) =>
      log.e('Error: $code; Error Message: $message');

  /// Show [CameraException].
  void _showCameraException(CameraException e) {
    log.i('_showCameraException | exception: $e');
    logError(e.code, e.description);
    // showInSnackBar(I18n.of(context).cameraScreenCameraError);
  }

  /// Dispose [CameraController].
  ///
  /// Sets the controller to null and notify listeners.
  void disposeController() async {
    log.d('disposable controller:$controller');
    await controller?.dispose();
    controller = null;
    _cameraStreamcontroller.add(controller);
    log.d('disposed of controller: $controller');
  }

  /// Setup Cameras.
  ///
  /// Select the initial [CameraDescription] from the list of available [CameraDescription].
  /// Then sets-up the [CameraController].
  Future<bool> setupCameras({int cameraIndex = 0}) async {
    log.i('setupCameras');
    try {
      log.d('printing controller: $controller');
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException(
            'camera not found', 'No camera was found on this device');
      }
      log.d('list of camera descriptions: $cameras');
      for (CameraDescription cameraDescription in cameras) {
        log.d('camera lens direction ${cameraDescription.lensDirection}');
        log.d('camera name ${cameraDescription.name}');
        log.d(
            'camera sensor orienttion ${cameraDescription.sensorOrientation}');
      }
      //start the camera in the with the default back camera
      controller =
          new CameraController(cameras[cameraIndex], ResolutionPreset.high);

      await controller.initialize();
      _cameraStreamcontroller.add(controller);
      log.d('Done seting up camera.');
      log.d('New camera controller added to stream: $controller');
    } on CameraException catch (error) {
      log.e('error caught by camera: $error');
    }

    return isReady;
  }

  /// New camera selected.
  ///
  /// Reset the [CameraController] with new [CameraDesciption] and pass value to [Stream].
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    log.i('onNewCameraSelected | cameraDescription: $cameraDescription');

    CameraDescription newCameraDescription = cameras.firstWhere(
        (element) => element.lensDirection != cameraDescription.lensDirection,
        orElse: () => cameraDescription);

    await controller?.dispose();
    log.d('Camera controller has been disposed.');

    controller = CameraController(
      newCameraDescription,
      ResolutionPreset.high,
    );
    log.d('new controller created: $controller');

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (controller.value.hasError) {
        // TODO: handle this error.

      }
    });

    try {
      await controller.initialize();
      _cameraStreamcontroller.add(controller);
      log.d('new controller added to stream: $controller');
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  /// Take picture.
  ///
  /// Return the file path of the picture as a [String].
  Future<String> takePicture() async {
    log.i('takePicture');
    if (!controller.value.isInitialized) {
      // showInSnackBar(I18n.of(context).cameraScreenCameraError);
      log.e('camera not initialized');
      return null;
    }

    final Directory extDir = await syspath.getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures';
    await Directory(dirPath).create(recursive: true);
    String filePath = '$dirPath/${timestamp()}.jpg';
    log.w('initial path: $filePath may not be needed');
    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      log.w('A capture is already pending, do nothing.');
      return null;
    }

    try {
      XFile xfile = await controller.takePicture();
      _cameraStreamcontroller.add(controller);
      filePath = xfile.path;
      log.w('new path: $filePath just use that');
      final imageFile = File(filePath);
      log.d('imagefile path ${imageFile.path}');
      await ImageGallerySaver.saveFile(imageFile.path);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  /// Start video recording.
  ///
  /// Returns the path of the video as a [String].
  Future<void> startVideoRecording() async {
    log.i('startVideoRecording');
    if (!controller.value.isInitialized) {
      // showInSnackBar(I18n.of(context).cameraScreenCameraError);
      return null;
    }

    final Directory extDir = await syspath.getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies';
    await Directory(dirPath).create(recursive: true);
    // final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      await controller.startVideoRecording();
      _cameraStreamcontroller.add(controller);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  /// Stop video recording.
  ///
  /// Returns the path of the thumbnail created from the video recording as a [String].
  Future<Map> stopVideoRecording({String videoPath}) async {
    log.i('stopVideoRecording | videoPath: $videoPath');
    String thumbnailPath;
    if (!controller.value.isRecordingVideo) {
      return null;
    }
    log.w('FIX: given path:$videoPath');
    try {
      XFile xFile = await controller.stopVideoRecording();
      log.d('stopped recording');
      _cameraStreamcontroller.add(controller);
      videoPath = xFile.path;
      log.w('FIX: new path:$videoPath');
      await ImageGallerySaver.saveFile(videoPath);
      log.d('creating thumbnail');
      thumbnailPath = await _addThumbnail(videoPath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    Map pathMap = {
      "thumbnailPath": thumbnailPath,
      "videoPath": videoPath,
    };
    return pathMap;
  }

  /// Create thumbnail from video file and stores it in cache.
  ///
  /// Returns the file path as a [String].
  Future<String> _addThumbnail(String videoFilePath) async {
    log.i('_addThumbnail | videoFilePath: $videoFilePath');
    String _videoThumbnailPath;
    try {
      final Directory cacheDir = await syspath.getTemporaryDirectory();
      final String thumbnailDirPath = '${cacheDir.path}/videoThumbnail';
      await Directory(thumbnailDirPath).create(recursive: true);

      _videoThumbnailPath = await thumbnail.VideoThumbnail.thumbnailFile(
        video: videoFilePath,
        thumbnailPath: thumbnailDirPath,
        imageFormat: thumbnail.ImageFormat.JPEG,
        maxHeight: 500,
        maxWidth: 500,
        quality: 75,
      );
    } catch (error) {
      log.e('thumbnail error: $error');
      throw error;
    }
    return _videoThumbnailPath;
  }

  /// Pause video recording.
  Future<void> pauseVideoRecording() async {
    log.i('pauseVideoRecording');
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
      _cameraStreamcontroller.add(controller);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  /// Resume video recording.
  Future<void> resumeVideoRecording() async {
    log.i('resumeVideoRecording');
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
      _cameraStreamcontroller.add(controller);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  /// Select media from gallery.
  ///
  /// If video is selected, a thumbnail is aslo created and its path returned.
  /// Returns a [Map] with the path of selected files.
  Future<Map> selectFromGallery() async {
    log.i('_selectFromGallery');
    log.d('selecting from gallery');
    List<File> files = [];
    Map<String, List> filePathsMap;
    List<String> videoPathList = [];
    List<String> imagePathList = [];
    List<String> thumbnailPathList = [];

    try {
      files = await _filePickerService.selectCustomTypeFromLibrary();

      log.d('files : ${files.toString()}');

      await Future.forEach(files, (file) async {
        if (videoFileExtensionFilter.hasMatch(file.path)) {
          videoPathList.add(file.path);
          final String path = await _addThumbnail(file.path);

          thumbnailPathList.add(path);
        } else if (imageFileExtensionFilter.hasMatch(file.path)) {
          imagePathList.add(file.path);
        } else {
          log.w('unsupported file format: ${file.path} ');
        }
      });
    } catch (error) {
      // TODO:handle permission denied error and other errors
      log.e('camera permissions denied: $error');
      throw error;
    }
    filePathsMap = {
      'image': imagePathList,
      'video': videoPathList,
      'thumbnail': thumbnailPathList
    };

    return filePathsMap;
  }
}
