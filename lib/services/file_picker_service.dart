import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../logger.dart';

final log = getLogger('FilePickerService');

/// Service giving access to device library.
/// Uses [file_picker] package.
class FilePickerService {
  /// Select custom type files from library.
  ///
  /// Select only allowed extensions from phone library.
  /// Selection of multiple is allowed.
  /// Returns a [List] of [File].
  /// If no files are selected, returns [null].

  Future<List<File>> selectCustomTypeFromLibrary() async {
    log.i('selectCustomTypeFromGallery');

    List<File> files = [];
    FilePickerResult _pickedFiles;
    try {
      _pickedFiles = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: [
          'mp4',
          '3gp',
          'webm',
          'mkv',
          'jpg',
          'bmp',
          'gif',
          'webp',
          'heic',
          'heif',
          'jpeg',
        ],
      );
      if (_pickedFiles != null) {
        log.d('pickedFiles : ${_pickedFiles.paths.toString()}');
        _pickedFiles.paths.forEach((element) {
          final newFile = File(element);
          files.add(newFile);
        });
      }
    } catch (error) {
      // TODO:handle permission denied error and other errors
      log.e('permissions denied: $error');
      throw error;
    }

    return files;
  }

  /// Select single image from phone library.
  ///
  /// Returns selected option as [File].
  Future<File> selectSingleImageFromLibrary() async {
    log.i('selectSingleImageFromLibrary');
    File imageFile;
    final FilePickerResult _pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
      // allowedExtensions: [
      //   'jpg',
      //   'bmp',
      //   'gif',
      //   'webp',
      //   'heic',
      //   'heif',
      //   'jpeg',
      // ],
    );
    if (_pickedFile != null) {
      imageFile = File(_pickedFile.paths.first);
    }
    return imageFile;
  }

  /// Select a single video from phone library.
  ///
  /// Only specific extensions are allowed.
  Future<File> selectSingleVideoFromLibrary() async {
    log.i('selectSingleVideoFromLibrary');
    File videoFile;
    final FilePickerResult _pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp4',
        '3gp',
        'webm',
        'mkv',
      ],
    );
    if (_pickedFile != null) {
      videoFile = File(_pickedFile.paths.first);
    }
    return videoFile;
  }

  /// Select a single audio from phone library.
  ///
  /// Returns selected option as [File].
  Future<File> selectSingleAudioFromLibrary() async {
    log.i('selectSingleAudioFromLibrary');
    File audioFile;
    final FilePickerResult _pickedFile =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (_pickedFile != null) {
      audioFile = File(_pickedFile.paths.first);
    }
    return audioFile;
  }
}
