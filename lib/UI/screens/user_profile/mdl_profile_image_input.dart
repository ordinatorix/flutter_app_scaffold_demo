import 'dart:io';

import '../../base_model.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import '../../../enums/view_state.dart';

import '../camera/scr_camera.dart';

import '../../../services/database_service.dart';
import '../../../services/authentication_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/navigation_service.dart';

import '../../../helpers/camera_screen_arguments.dart';

import '../../../models/user.dart';

final log = getLogger('ProfileImageInputViewModel');

class ProfileImageInputViewModel extends BaseModel {
  final AuthService _auth = locator<AuthService>();
  final DatabaseService _database = locator<DatabaseService>();
  final AnalyticsService _analytics = locator<AnalyticsService>();
  final NavigationService _navigationService = locator<NavigationService>();

  List<User> userList;
  File storedImageFile;
  Map<String, List<String>> _storedMediaList = {
    'imagePathList': [],
    'videoPathList': [],
    'thumbnailPathList': [],
  };

  User editedUser = User(
    uid: null,
    displayName: '',
    email: '',
    phone: '',
    photoUrl: null,
    homeLocation: null,
    lastKnownLocation: null,
    fullName: '',
  );

  /// Initialize current user.
  void initializeUser() {
    log.i('initializeUser |  userList: $userList');
    if (userList != null && userList.isNotEmpty) {
      editedUser = userList.first;
    }
  }

  /// Take picture with camera or select from gallery.
  void onEditPictureButtonPressed() async {
    log.i('onEditPictureButtonPressed');
    _storedMediaList = await _navigationService.navigateTo(
      CameraScreen.routeName,
      arguments: CameraScreenArguments(
        mediaList: _storedMediaList,
        onlyPicture: true,
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

    final List<String> _storedImagePathList = _storedMediaList['imagePathList'];

    final String _storedImagePath = _storedImagePathList.isNotEmpty
        ? _storedImagePathList.elementAt(0)
        : '';
    storedImageFile = _storedImagePath.isEmpty ? null : File(_storedImagePath);

    _storedMediaList['videoPathList'] = [];
    _storedMediaList['thumbnailPathList'] = [];

    await _saveImg();
    storedImageFile != null
        ? await _analytics.logCustomEvent(
            name: 'change_profile_picture',
            parameters: {'media_source': 'camera', 'completed': 1})
        : await _analytics.logCustomEvent(
            name: 'change_profile_picture',
            parameters: {'media_source': 'camera', 'completed': 0});
  }

  /// Save new profile picture.
  ///
  /// Upload image to db and update user auth profile.
  Future<void> _saveImg() async {
    log.i('_saveImg');
    setState(ViewState.Busy);

    if (editedUser.uid != null && storedImageFile != null) {
      try {
        // updatedb user
        var photoUrlResult = await _database.updateUser(
            selectedPicture: storedImageFile, user: editedUser);

        await _auth.updateUserAuthProfile(
            photoUrl:
                photoUrlResult); // update auth user using the returned value of the url from db
      } catch (error) {
        log.e('error saving image: $error');
      }

      log.d('done saving img');
    } else {
      log.w('Did not try to save');
    }
    setState(ViewState.Idle);
  }
}
