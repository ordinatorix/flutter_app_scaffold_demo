import 'dart:io';

import 'package:flutter_scaffold/enums/view_state.dart';
import 'package:flutter_scaffold/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:video_thumbnail/video_thumbnail.dart' as thumbnail;

import 'package:flutter_scaffold/UI/base_model.dart';

final log = getLogger('ImageScrollerViewModel');

class ImageScrollerViewModel extends BaseModel {
  final imageFilter = RegExp(r'images');
  final mapFilter = RegExp(r'maps');
  final videoFilter = RegExp(r'videos');
  final thumbnailFilter = RegExp(r'cache');
  int selectedIndex = 0;
  String _thumbnailpath;
  List scrollerList = [];

  void initializeModel(List mediaList) async {
    log.i('initializeModel | mediaList: $mediaList');
    //initialize the view model by loading the thumbnails if any videos are to be displayed

    if (mediaList != null) {
      _addThumbnail(mediaList);
    }
  }

  Future<void> _addThumbnail(List mediaList) async {
    log.i('_addThumbnail | mediaList: $mediaList');
    try {
      String _videoThumbnail;
      var tempDir = await syspath.getTemporaryDirectory();

      scrollerList.addAll(mediaList);
      // check if media list has any video
      for (var i = 0; i < scrollerList.length; i++) {
        if (videoFilter.hasMatch(scrollerList[i]) == true) {
          // check to see if a thumbnail already exist or create one.
          _thumbnailpath =
              '${tempDir.path}/${path.basenameWithoutExtension(scrollerList[i])}.jpg';

          final File _thumbnailFile = File(_thumbnailpath);

          if (await _thumbnailFile.exists()) {
            // Use the cached thumbnail if it exists
            _videoThumbnail = _thumbnailpath;
            log.d('thumbnail exist');
          } else {
            // if thumbnail doesn't exist in cache create thumbnail

            _videoThumbnail = await thumbnail.VideoThumbnail.thumbnailFile(
              video: scrollerList[i],
              thumbnailPath: _thumbnailpath,
              imageFormat: thumbnail.ImageFormat.JPEG,
              maxHeight: 700,
              maxWidth: 700,
              quality: 30,
            );
          }
          scrollerList.replaceRange(i, i + 1, [_videoThumbnail]);
        }
      }

      setState(ViewState.Idle);
    } catch (error) {
      log.e('thumbnail error: $error');
      throw error;
    }
  }

  void onImageTap(int index, Function onSelectImage, bool loadingState) {
    log.i(
        'onImageTap | index: $index, onSelectImage: $onSelectImage, loadingState: $loadingState');
    loadingState ? onSelectImage(null) : onSelectImage(index);

    loadingState ? selectedIndex = selectedIndex : selectedIndex = index;
  }
}
