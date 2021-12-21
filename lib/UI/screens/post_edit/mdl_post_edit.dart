import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../base_model.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import '../../../enums/view_state.dart';

import '../../../services/database_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/dialog_service.dart';
import '../../../services/navigation_service.dart';
import '../../../services/location_service.dart';

import '../../../models/user.dart';
import '../../../models/post.dart';

import '../../../helpers/share_prefs_helper.dart';
import '../../../helpers/custom_exceptions.dart';
import '../../../helpers/tab_screen_arguments.dart';
import '../../../helpers/camera_screen_arguments.dart';
import '../../../helpers/post_screen_arguments.dart';

import '../../../generated/i18n.dart';

import 'scr_post_comment.dart';
import '../camera/scr_camera.dart';

import 'tag_option_selector.dart';
import 'emergency_response_selector.dart';

final log = getLogger('PostEditScreenModel');

class PostEditScreenModel extends BaseModel {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final SharedPrefsHelper _prefs = locator<SharedPrefsHelper>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final LocationService _locationService = locator<LocationService>();
  // final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  PostEditScreenArguments args;
  List<String> _eventTags = [];
  bool showEmptyState = false;
  Map tagInfo;
  List<String> _pickedImageList = [];
  List<String> _pickedVideoList = [];
  List<String> mediaPathList = [];
  Map<String, List<String>> _storedMediaList = {
    'imagePathList': [],
    'videoPathList': [],
    'thumbnailPathList': [],
  };

  /// Minimal distance to omit location sharing warning.
  double _safeDistance = 50.0;

  EventLocation _pickedLocation;
  DeviceLocation currentLocation;
  EventLocation displayLocation;
  var postComment;
  User authUser = User();
  EventLocation selectedLocation;
  bool _proceed;
  Post post;
  Post editedPost;
  String stat;
  bool submited = false;
  String verificationType = 'submission';
  List tagsList;

  /// Initialize post edit screen model.
  ///
  /// Sets [ViewState.Busy]. [ViewState] must be changed once location is acquired.
  void initializeModel() async {
    log.i('initializeModel');
    removeKeys();
    tagInfo = args.tags;

    post = args.post;

    selectedLocation = args.selectedLocation;

    editedPost = Post(
      id: null,
      title: args.tags['title'],
      status: null,
      comment: null,
      location: null,
      tags: null,
      publisherId: '',
      imageUrlList: [],
      videoUrlList: [],
      isPublished: true,
      publisherLocation: null,
    );

    post != null
        ? verificationType = 'verification'
        : verificationType = verificationType;

    setState(ViewState.Busy);
  }

  /// Dispose of post edit screen view model.
  void disposer(BuildContext context) async {
    log.i('disposer | context: $context');
    log.d(_prefs);
    await removeKeys();
  }

  /// Remove all keys from [tagsList].
  Future<void> removeKeys() async {
    log.i('removeKeys');
    _prefs?.removeKeys(tagsList: tagsList)?.whenComplete(() {
      log.d('done removing keys');
    })?.catchError(
      (onError) {
        log.e('error removing sharedprefs keys: $onError');
        throw onError;
      },
    );
  }

  /// Set publisher location
  void updatePublisherLocation() {
    log.i('updatePublisherLocation');
    if (currentLocation != null) {
      editedPost.publisherLocation = DeviceLocation(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        heading: currentLocation.heading,
        accuracy: currentLocation.accuracy,
        speed: currentLocation.speed,
        speedAccuracy: currentLocation.speedAccuracy,
        altitude: currentLocation.altitude,
        floor: currentLocation.floor,
        timestamp: currentLocation.timestamp,
      );
    }
  }

  /// Set locations once device location is acquired.
  ///
  /// Sets [ViewState] and [showEmptyState] accordingly.
  void setLocations() {
    log.i('setLocations ');
    if (currentLocation != null) {
      showEmptyState = false; //!prefs.isLocationEnabled;
      if (selectedLocation != null) {
        //used when post location is selected from home map
        log.d('selected location is null');

        setEventLocation(
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude,
          accuracy: 0.0,
          locationTimestamp: selectedLocation.timestamp,
        );

        stat = 'new';
      } else if (post != null && post.location != null) {
        //used when verifying a post
        log.d('post != null && post.location != null');

        displayLocation = null;
        editedPost = Post(
          id: post.id,
          status: null,
          title: post.title,
          comment: null,
          location: post.location,
          tags: [],
          publisherId: '',
          imageUrlList: [],
          videoUrlList: [],
          isPublished: post.isPublished,
          publisherLocation: DeviceLocation(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            heading: currentLocation.heading,
            accuracy: currentLocation.accuracy,
            speed: currentLocation.speed,
            speedAccuracy: currentLocation.speedAccuracy,
            altitude: currentLocation.altitude,
            floor: currentLocation.floor,
            timestamp: currentLocation.timestamp,
          ),
        );
        stat = 'existing';
      } else {
        //when using current location
        log.d('using current location');

        if (_pickedLocation == null) {
          log.d('user has not yet selected a location');
          setEventLocation(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            altitude: currentLocation.altitude,
            heading: currentLocation.heading,
            accuracy: currentLocation.accuracy,
            speed: currentLocation.speed,
            speedAccuracy: currentLocation.speedAccuracy,
            locationTimestamp: currentLocation.timestamp,
          );
        }
        stat = 'new';
      }

      setState(ViewState.Idle);
    } else {
      log.d('currentlocation is null, setting empty state to true');
      showEmptyState = true;
      log.d('showEmptyState: $showEmptyState');
      setState(ViewState.Busy);
    }
  }

  /// Measure distance between current user location and the selected event location.
  Future<double> _distanceFromEvent() async {
    log.i('_distanceFromEvent');
    return _locationService.getDistanceBetweenLocation(
        currentLocation.latitude,
        currentLocation.longitude,
        _pickedLocation.latitude,
        _pickedLocation.longitude);
  }

  /// User tap the platform back button.
  Future onWillPop() async {
    log.i('onWillPop');

    onClosePage();

    return Future.value(false);
  }

  /// User tap the close page button.
  void onClosePage() {
    log.i('onClosePage');

    _analyticsService.logCustomEvent(
        name: 'closed_page', parameters: {'screen_name': 'post-edit-screen'});
    _navigationService.removeUntil('/tab-screen');
  }

  /// Add user selected tags to event tag list.
  void _addAllTagsList() {
    log.i('_addAllTagsList');
    _eventTags = _prefs.postTagList + _prefs.emergencyTagList;
    editedPost.tags = _eventTags;
  }

  /// Set event location.
  void setEventLocation({
    double latitude,
    double longitude,
    double altitude,
    double heading,
    double accuracy,
    double speed,
    double speedAccuracy,
    DateTime locationTimestamp,
  }) {
    log.i(
        'selectLocation | latitude: $latitude, longitude: $longitude, accuracy: $accuracy');

    // set display and post location
    _pickedLocation = EventLocation(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      heading: heading,
      accuracy: accuracy,
      speed: speed,
      speedAccuracy: speedAccuracy,
      timestamp: locationTimestamp,
    );
    displayLocation = EventLocation(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      heading: heading,
      accuracy: accuracy,
      speed: speed,
      speedAccuracy: speedAccuracy,
      timestamp: locationTimestamp,
    );

    editedPost.location = _pickedLocation;
    log.d('setting show empty state to false');
    setState(ViewState.Idle);
  }

  /// Change post status
  void changeStatusValue(String status) {
    log.i('changeStatusValue | status: $status');
    editedPost.status = status;
  }

  /// Navigate away from current page.
  ///
  /// Takes optional [TabScreenArguments]
  void _navigateAway(BuildContext context) {
    log.i('_navigateAway | context: $context');
    // if (mounted) {

    TabScreenArguments arguments =
        TabScreenArguments(snackbarMessage: 'test complete');
    _navigationService.removeUntil('/tab-screen', arguments: arguments);
  }

  /// Show message in snackbar
  void _showInSnackBar({String message}) {
    log.i('_showInSnackBar | message: $message');
    // log.wtf('snack scafold key: ${scaffoldKey.currentContext}');
    scaffoldMessengerKey.currentState.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Show error dialog.
  ///
  /// This cancels the post submital process
  /// and prompts the user to check the device configuration
  Future<void> _showErrorDialog({
    @required dynamic error,
    @required BuildContext context,
    @required String title,
  }) async {
    log.e('error verifying post: $error');
    var dialogResponse = await _dialogService.showErrorDialog(
      title: title,
      description: I18n.of(context).dialogsPostFailed,
      buttonTitle: I18n.of(context).buttonsOkayButton,
      dialogType: 'post_saving_failed',
    );

    log.d(
        'value returned from post failed saving dialog: ${dialogResponse.confirmed}');
    if (!dialogResponse.confirmed) {
      submited = dialogResponse.confirmed;
      setState(ViewState.Idle);
    }
  }

  /// User tap tag button.
  void showTagBottomSheet(
      {bool showTagWidget, BuildContext context, Size screenSize}) {
    log.i(
        'showTagBottomSheet | showTagWidget: $showTagWidget, context: $context, screenSize: $screenSize');
    showModalBottomSheet(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        context: context,
        builder: (ctx) {
          return Container(
            child: Container(
              height: screenSize.height * 0.55,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    height: (screenSize.height) * 0.05,
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(15.0),
                        topRight: const Radius.circular(15.0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        showTagWidget
                            ? I18n.of(context).postEditScreenBottomSheetTagTitle
                            : I18n.of(context)
                                .postEditScreenBottomSheetEmergencyTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey[400],
                  ),
                  Expanded(
                    child: Container(
                      child: Center(
                        child: showTagWidget
                            ? TagOptionSelector(
                                tagInfo: tagInfo,
                                showSnackbar: _showInSnackBar,
                                verificationType: verificationType,
                                stat: stat,
                              )
                            : EmergencyResponseSelector(
                                verificationType: verificationType,
                                stat: stat,
                                title: editedPost.title,
                              ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          width: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 25),
                    child: ElevatedButton(
                      onPressed: () {
                        _analyticsService.logCustomEvent(
                            name: 'closed_tags_elector',
                            parameters: {
                              'verification_type': verificationType,
                              'post_type': '${stat}_${editedPost.title}',
                              'tag_type': 'event_descriptor'
                            });
                        _navigationService.pop();
                      },
                      child: SizedBox(
                        child: Center(
                          child: Text(
                            I18n.of(context).buttonsCloseButton,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        width: screenSize.width * 0.7,
                        height: (screenSize.height) * 0.08,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
    if (showTagWidget == true) {
      _analyticsService.logCustomEvent(name: 'open_tag_selector', parameters: {
        'verification_type': verificationType,
        'post_type': '${stat}_${editedPost.title}',
        'tag_type': 'event_descriptor'
      });
    } else {
      _analyticsService.logCustomEvent(name: 'open_tag_selector', parameters: {
        'verification_type': verificationType,
        'post_type': '${stat}_${editedPost.title}',
        'tag_type': 'emergency_services'
      });
    }
  }

  /// User tap camera button
  void onCameraButtonPressed(BuildContext context) async {
    log.i('onCameraButtonPressed | context: $context');
    // Check camera permissions.
    bool cameraIsDenied = await Permission.camera.isDenied;
    // bool cameraIsUndefined = await Permission.camera. .isUndetermined;
    bool microphoneIsDenied = await Permission.microphone.isDenied;
    // bool microphoneIsUndefined = await Permission.microphone.isUndetermined;
    bool storageIsDenied = await Permission.storage.isDenied;
    // bool storageIsUndefined = await Permission.storage.isUndetermined;
    if (cameraIsDenied) {
      // || cameraIsUndefined) {
      await Permission.camera.request();
    }
    if (microphoneIsDenied) {
      // || microphoneIsUndefined) {
      await Permission.microphone.request();
    }
    if (storageIsDenied) {
      //|| storageIsUndefined) {
      await Permission.storage.request();
    }
    log.d('stored media before going in: $_storedMediaList');

    _storedMediaList = await _navigationService.navigateTo(
      CameraScreen.routeName,
      arguments: CameraScreenArguments(
        mediaList: _storedMediaList,
        onlyPicture: false,
      ),
    );
    if (_storedMediaList == null) {
      log.d('value returned from camera: $_storedMediaList');
      _storedMediaList = {
        'imagePathList': [],
        'videoPathList': [],
        'thumbnailPathList': [],
      };
    }

    _pickedImageList = _storedMediaList['imagePathList'];
    _pickedVideoList = _storedMediaList['videoPathList'];
    mediaPathList = _storedMediaList['thumbnailPathList'];

    (_pickedVideoList.isNotEmpty && _pickedImageList.isNotEmpty)
        ? _analyticsService
            .logCustomEvent(name: 'tap_camera_button', parameters: {
            'length': mediaPathList.length,
            'verification_type': verificationType,
            'completed': 1,
            'post_type': '${stat}_${editedPost.title}',
            'media_type': 'image_&_video'
          })
        : _pickedImageList.isNotEmpty
            ? _analyticsService
                .logCustomEvent(name: 'tap_camera_button', parameters: {
                'length': mediaPathList.length,
                'verification_type': verificationType,
                'completed': 1,
                'post_type': '${stat}_${editedPost.title}',
                'media_type': 'image'
              })
            : _pickedVideoList.isNotEmpty
                ? _analyticsService
                    .logCustomEvent(name: 'tap_camera_button', parameters: {
                    'length': mediaPathList.length,
                    'verification_type': verificationType,
                    'completed': 1,
                    'post_type': '${stat}_${editedPost.title}',
                    'media_type': 'video'
                  })
                : _analyticsService
                    .logCustomEvent(name: 'tap_camera_button', parameters: {
                    'length': 'null',
                    'verification_type': verificationType,
                    'completed': 0,
                    'post_type': '${stat}_${editedPost.title}',
                    'media_type': 'null'
                  });
    setState(ViewState.Idle);
  }

  /// User tap comment button.
  void onCommentButtonPressed(BuildContext context) async {
    log.i('onCommentButtonPressed | context: $context');
    postComment = await _navigationService
        .navigateTo(PostCommentScreen.routeName, arguments: editedPost.comment);

    editedPost = Post(
      id: editedPost.id,
      title: editedPost.title,
      comment: postComment,
      status: editedPost.status,
      location: editedPost.location,
      timestamp: editedPost.timestamp,
      tags: editedPost.tags,
      publisherId: editedPost.publisherId,
      imageUrlList: editedPost.imageUrlList,
      isPublished: editedPost.isPublished,
      publisherLocation: editedPost.publisherLocation,
    );

    postComment != null
        ? _analyticsService
            .logCustomEvent(name: 'tap_comment_button', parameters: {
            'verification_type': verificationType,
            'completed': 1,
            'post_type': '${stat}_${editedPost.title}'
          })
        : _analyticsService
            .logCustomEvent(name: 'tap_comment_button', parameters: {
            'verification_type': verificationType,
            'completed': 0,
            'post_type': '${stat}_${editedPost.title}'
          });
  }

  /// User tap submit button.
  ///
  /// Checks to see if all requirements are met.
  void onSubmitButtonPressed(BuildContext context) async {
    log.i('onSubmitButtonPressed | context: $context');

    if (submited) {
      log.d('user already submited a post');
      _showInSnackBar(
          // context: context,
          message: I18n.of(context).postEditScreenAlreadySubmittedSnackBar);
    } else {
      // check to see if user is submitting a new post and that they selected a tag.
      if (_prefs.postTagList.isEmpty &
          (_prefs.postTagList.length < tagInfo['selectable']) &
          (post == null)) {
        log.d('not tag selected, showing snackbar');
        _showInSnackBar(
            // context: context,
            message: I18n.of(context).postEditScreenSelectTagSnackBar);
        return;
      } else if (!_prefs.isLocationEnabled) {
        log.d('location is not enabled. showing error dialog.');
        // Check to see if location service is enabled.

        await _showErrorDialog(
          error: ScaffoldException(
              code: 'location_disabled',
              message: 'Location service status is disabled.'),
          context: context,
          title: I18n.of(context).dialogsPostFailedSubmitTitle,
        );

        return;
      } else if (currentLocation == null) {
        log.d('location is null, showing snackbar');
        _showInSnackBar(
            // context: context,
            message:
                'No GPS Reception. Make sure you\'re outdoors and have a clear view of the sky.'); //TODO:translate
        return;
      } else {
        submited = true;
        _addAllTagsList();
        _submitPost(context);
      }
    }
  }

  void _submitPost(BuildContext context) async {
    log.i('_submitPost | context: $context');

    setState(ViewState.Busy);

    if (editedPost.id != null) {
      // if postID !=null => its a verification
      log.d('REPORT ID not null');
      if (editedPost.status != null) {
        try {
          //add updated info to the post subcollection
          await _databaseService.updatePostData(
            uid: authUser.uid,
            post: editedPost,
            selectedImageList: _pickedImageList,
            selectedVideoList: _pickedVideoList,
            tagInfo: tagInfo,
          );
          log.d('DONE UPDATING REPORT');

          await _analyticsService
              .logCustomEvent(name: 'tap_submit_post_button', parameters: {
            'verification_type': verificationType,
            'completed': 1,
            'post_type': '${stat}_${editedPost.title}'
          });

          await removeKeys();
          var dialogResponse = await _dialogService.showSuccessDialog(
            title: I18n.of(context).dialogsPostSuccessReviewTitle,
            description: I18n.of(context).dialogsPostSuccessReviewMessage,
            buttonTitle: I18n.of(context).buttonsOkayButton,
            dialogType: 'post_success',
          );
          log.d(
              'success dialog response returned with: ${dialogResponse.confirmed}');
          if (dialogResponse.confirmed) {
            _navigateAway(context);
          }
        } catch (error) {
          await _showErrorDialog(
            error: error,
            context: context,
            title: I18n.of(context).dialogsPostFailedReviewTitle,
          );
        }
      } else {
        await _analyticsService
            .logCustomEvent(name: 'tap_submit_post_button', parameters: {
          'verification_type': verificationType,
          'completed': 0,
          'post_type': '${stat}_${editedPost.title}'
        });

        submited = false;

        setState(ViewState.Idle);
        _showInSnackBar(
            // context: context,
            message: I18n.of(context).postEditScreenSelectStatusWarning);
      }
    } else {
      if (currentLocation != null || _pickedLocation != null) {
        //check if location have been found
        double _distance = await _distanceFromEvent();
        log.d('distance: $_distance');
        if (_distance <= _safeDistance) {
          //check if current location is within a safe distance from the post location
          //display warning dialog about posting current location

          _proceed = false;
          var warningResponse = await _dialogService.showWarningDialog(
            title: I18n.of(context).dialogsWarningTitle,
            description: I18n.of(context).dialogsWarningMessage,
            confirmationTitle: I18n.of(context).buttonsProceedButton,
            cancelTitle: I18n.of(context).buttonsAbortButton,
            dialogType: 'warning_dialog',
          );

          log.d(
              'value returned from warning dialog: ${warningResponse.confirmed}');
          if (warningResponse.confirmed) {
            // user chose to proceed

            _proceed = warningResponse.confirmed;
          } else {
            submited = warningResponse.confirmed;
            _proceed = warningResponse.confirmed;

            setState(ViewState.Idle);
          }
        } else {
          // if current location is not post location
          _proceed = true;
        }

        if (!_proceed) {
          // log analytics that user did not complete submit process
          submited = false;
          await _analyticsService
              .logCustomEvent(name: 'tap_submit_post_button', parameters: {
            'verification_type': verificationType,
            'completed': 0,
            'post_type': '${stat}_${editedPost.title}'
          });
          return;
        } else {
          try {
            await _databaseService.addPostData(
              uid: authUser.uid,
              post: editedPost,
              selectedImageList: _pickedImageList,
              selectedVideoList: _pickedVideoList,
              tagInfo: tagInfo,
            );
            log.d('DONE ADDING REPORT');

            await _analyticsService
                .logCustomEvent(name: 'tap_submit_post_button', parameters: {
              'verification_type': verificationType,
              'completed': 1,
              'post_type': '${stat}_${editedPost.title}'
            });

            await removeKeys();
            var successDialogResponse = await _dialogService.showSuccessDialog(
              title: I18n.of(context).dialogsPostSuccessSubmitTitle,
              description: I18n.of(context).dialogsPostSuccessSubmitMessage,
              buttonTitle: I18n.of(context).buttonsOkayButton,
              dialogType: 'post_success',
            );

            log.d(
                'success dialog returned: ${successDialogResponse.confirmed}');
            if (successDialogResponse.confirmed) {
              _navigateAway(context);
            }
          } catch (error) {
            await _showErrorDialog(
              error: error,
              context: context,
              title: I18n.of(context).dialogsPostFailedSubmitTitle,
            );
          }
        }
      } else {
        await _showErrorDialog(
          error: ScaffoldException(
              code: 'location_null', message: 'Did not receive any location.'),
          context: context,
          title: I18n.of(context).dialogsPostFailedSubmitTitle,
        );
      }
    }
  }
}
