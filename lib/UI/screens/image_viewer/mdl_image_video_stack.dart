import 'dart:async';

import 'package:cached_video_player/cached_video_player.dart';

import '../../base_model.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import '../../../enums/view_state.dart';

import '../../../services/navigation_service.dart';

import 'scr_image_list_viewer.dart';

final log = getLogger('ImageVideoStackViewModel');

class ImageVideoStackViewModel extends BaseModel {
  final NavigationService _navigationService = locator<NavigationService>();

  bool showVideoButtons = false;

  void onImageButtonPressed({List imageUrlList, int currentIndex}) {
    /// show images in full screen
    log.i('onImageButtonPressed');
    Map<String, dynamic> mapper = {
      'imgList': imageUrlList,
      'currentIndex': currentIndex
    };
    _navigationService.navigateTo(ImageListViewerScreen.routeName,
        arguments: mapper);
  }

  void onFullScreenButtonPressed() {
    log.i('onFullScreenButtonPressed');
    log.d('toogle fullscreen');
    // _navigationService.navigateTo(ImageListViewerScreen.routeName,
    //     arguments: mapper);

    /// TODO: implement full screen logic function
  }

  void onVideoButtonPressed(CachedVideoPlayerController videoController) async {
    /// show video control buttons
    log.i('onVideoButtonPressed');
    if (videoController.value.isPlaying) {
      log.d('video Pause');
      await videoController?.pause();
      setState(ViewState.Idle);
    } else {
      log.d('video Play');
      await videoController?.play();
      setState(ViewState.Idle);
    }
  }

  void onShowVideoButtonPressed() {
    log.i('onShowVideoButtonPressed');
    showVideoButtons = !showVideoButtons;
    setState(ViewState.Idle);
    log.d('showVideoButtons: $showVideoButtons');
    Timer(Duration(seconds: 5), () {
      showVideoButtons = !showVideoButtons;
      log.d('showVideoButton: $showVideoButtons');
      setState(ViewState.Idle);
    });
  }

  void onMuteButtonPressed(CachedVideoPlayerController videoController) async {
    log.i('onMuteButtonPressed');
    if (videoController.value.volume == 0.0) {
      log.d('turn sound on');
      await videoController?.setVolume(1.0);
      setState(ViewState.Idle);
    } else {
      log.d('turn sound off');
      await videoController?.setVolume(0.0);
      setState(ViewState.Idle);
    }
  }
}
