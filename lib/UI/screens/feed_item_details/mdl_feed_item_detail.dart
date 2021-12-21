import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';

import '../../base_model.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import '../../../enums/view_state.dart';

import '../../../models/post.dart';

import '../../../services/analytics_service.dart';
import '../../../services/navigation_service.dart';

import '../../../helpers/tab_screen_arguments.dart';
import '../../../helpers/feed_item_detail_screen_arguments.dart';
import '../../../helpers/post_screen_arguments.dart';

import '../user_profile/scr_profile_settings.dart';
import '../post_edit/scr_post_edit.dart';

final log = getLogger('FeedItemDetailViewModel');

class FeedItemDetailViewModel extends BaseModel {
  final AnalyticsService analytics = locator<AnalyticsService>();
  final NavigationService _navigationService = locator<NavigationService>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List tagsList;
  int returnPage = 1;
  String referalPage;
  Post selectedPost = Post();
  String notificationPostId;
  List<Post> postData;
  bool showVideoButtons = false;
  FeedItemDetailScreenArguments args;
  MediaQueryData mediaQuery;
  CachedVideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  List mediaList = [];

  int localImageIndex = 0;
  final RegExp imageFilter = RegExp(r'images|maps');
  final RegExp videoFilter = RegExp(r'videos');

  /// Dispose of view model
  void disposer() async {
    log.i('disposer');
    await videoController?.pause();
    await videoController?.dispose()?.catchError((error) {
      log.e(
          'disposed of feed screen detail video controller ended with the following error: $error');
      throw error;
    })?.then((_) {
      log.d('disposed of feed screen detail video controller properly.');
      videoController = null;
    });
  }

  /// Initialize view model
  void initializeModel(BuildContext context) {
    log.i('initializeModel | context: $context');
    tagsList = TagList().getTagList(context: context);

    args = ModalRoute.of(context).settings.arguments;

    selectedPost = args.post;
    returnPage = args.returnPage;
    referalPage = args.referalPage;
    notificationPostId = args.postId;

    if (selectedPost != null) {
      if (selectedPost.videoUrlList != null &&
          selectedPost.videoUrlList.isNotEmpty) {
        mediaList = selectedPost.imageUrlList + selectedPost.videoUrlList;
      } else {
        mediaList = selectedPost.imageUrlList;
      }
    } else {
      log.d('no post given in initializer');
    }
  }

  /// Query post by the post id given in the notification received.
  void fetchFCMPost() {
    log.i('fetchFCMPost');
    if (notificationPostId != null) {
      log.d('postData: $postData');
      if (postData != null) {
        if (postData.isNotEmpty) {
          selectedPost = postData.firstWhere(
            (post) => post.id == notificationPostId,
            orElse: () => Post(),
          );
        } else {
          log.d('postData is empty');
          selectedPost = Post();
        }

        if (selectedPost != null) {
          if (selectedPost.id != null) {
            if (selectedPost.videoUrlList != null &&
                selectedPost.videoUrlList.isNotEmpty) {
              mediaList =
                  selectedPost.imageUrlList + selectedPost.videoUrlList;
            } else {
              mediaList = selectedPost.imageUrlList;
            }
          } else {
            log.w('no post found, showing empty state page');
          }
        } else {
          log.w('no post found to display navigating away');
        }
      } else {
        log.w('postData is null');
      }
    }
  }

  /// Back navigation button handler
  ///
  /// navigate back to the home screen or the profile page, depending on the [referalPage].
  void onArrowBackButtonPressed() async {
    log.i('onArrowBackButtonPressed');
    if (referalPage == '/profile-settings') {
      _navigationService.replaceWith(ProfileSettingsScreen.routeName);
    } else {
      TabScreenArguments arguments = TabScreenArguments(returnPage: returnPage);
      _navigationService.removeUntil('/tab-screen', arguments: arguments);
    }
  }

  /// Appbar action button handler.
  ///
  /// Navigates to post edit screen.
  void onActionButtonPressed() async {
    log.i('onActionButtonPressed');
    await videoController?.pause();
    selectedPost.status == 'Confirmed'
        ? await analytics
            .logCustomEvent(name: 'tap_verify_button', parameters: {
            'verification_type': 'clear',
            'post_type': '${selectedPost.status}_${selectedPost.title}'
          })
        : await analytics
            .logCustomEvent(name: 'tap_verify_button', parameters: {
            'verification_type': 'verify',
            'post_type': '${selectedPost.status}_${selectedPost.title}'
          });
    _navigationService.navigateTo(
      PostEditScreen.routeName,
      arguments: PostEditScreenArguments(
        tags:
            tagsList.firstWhere((map) => map['title'] == selectedPost.title),
        post: selectedPost,
      ),
    );
  }

  /// On Select Image.
  ///
  /// Handles when an image is selected from the image scroller.
  Future<void> onSelectImage(int imageIndex) async {
    log.i('onSelectImage | imageIndex: $imageIndex');
    //TODO: change this to using an async cancelable completer
    setState(ViewState.Busy);
    log.d('activated onSelectImage function');
    if (imageIndex == null) {
      return;
    } else {
      await videoController?.pause()?.then((value) => log.d('paused video'));

      try {
        /// if imageIndex is the one that contains video => startvideoplayer
        if (videoFilter.hasMatch(mediaList[imageIndex])) {
          /// send analytics post
          await analytics.logViewItem(
              itemName: '${selectedPost.status}${selectedPost.title}',
              itemId: '${selectedPost.id}',
              itemCategory: 'video');
          log.d('videoFilter has match');

          await _startVideoPlayer(mediaList[imageIndex]);
        } else {
          log.d('no videoFilter match ');
          log.d('on image select vid controller: $videoController');

          videoController?.removeListener(videoPlayerListener);
          await videoController?.dispose()?.then((_) {
            videoController = null;

            log.d('disposed of old video controller');
          });
          //send analytics post
          await analytics.logViewItem(
              itemName: '${selectedPost.status}${selectedPost.title}',
              itemId: '${selectedPost.id}',
              itemCategory: 'image');
        }
      } catch (error) {
        throw error;
      }

      log.d('setting state after selecting image');
      log.d('controller: $videoController');
      localImageIndex = imageIndex;

      log.d('done setting state');
    }
    setState(ViewState.Idle);
  }

  /// Start video player.
  Future<void> _startVideoPlayer(url) async {
    log.i('_startVideoPlayer | url: $url');
    final CachedVideoPlayerController vcontroller =
        CachedVideoPlayerController.network(url);

    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.

        videoController.removeListener(videoPlayerListener);
      }
    };

    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    log.d('muting video');
    await vcontroller.setVolume(0.0);
    await vcontroller.initialize();
    log.d('disposing of controller: $videoController');
    await videoController?.dispose()?.then((_) {
      log.d('disposed of old video controller');
    });

    log.d('setting state');
    videoController = null;
    videoController = vcontroller;

    log.d('playing');
    await vcontroller.play();
  }
}
