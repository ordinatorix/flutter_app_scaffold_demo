import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../services/dialog_service.dart';
import '../services/url_launcher_service.dart';
import '../services/navigation_service.dart';

import '../UI/screens/feed_item_details/scr_feed_item_details.dart';

import '../helpers/feed_item_detail_screen_arguments.dart';

import '../locator.dart';
import '../logger.dart';

final log = getLogger('FcmService');

/// Background Firebase Cloud Messaging Handler.
///
/// Fires when an FCM is received and the app is not running. Only performs minimal taks.
Future<dynamic> _myBackgroundMessageHandler(
    RemoteMessage message) async {
  log.i('myBackgroundMessageHandler | message: $message');
  await Firebase.initializeApp();

// _onResumeHandler(message);
  if (message.data.isNotEmpty) {
    // Handle data message
    final dynamic data = message.data;
    return data;
  }

  if (message.notification !=null) {
    // Handle notification message
    final dynamic notification = message.notification;
    return notification;
  }

  // Or do other work.
}

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DialogService _dialogService = locator<DialogService>();
  final UrlLauncherService _launcherService = locator<UrlLauncherService>();
  final NavigationService _navigationService = locator<NavigationService>();

  /// Initialize Firebase Cloud Messaging services.
  ///
  /// Configures message handling.
  Future initialize() async {
    log.i('fcm initialize');

    if (Platform.isIOS) {
      _firebaseMessaging.requestPermission();

      // _firebaseMessaging.requestNotificationPermissions(
      //     const IosNotificationSettings(
      //         sound: true, badge: true, alert: true, provisional: true));
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log.d('Got a message whilst in the foreground!');
      log.d('Message data: ${message.data}');
      _onMessageHandler(message);

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    FirebaseMessaging.onBackgroundMessage(
        (message) => _myBackgroundMessageHandler(message));
        
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     log.i('onMessage | message: $message');
    //     _onMessageHandler(message);
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     log.i('onLaunch | message: $message');
    //     _onLauncherHandler(message);
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     log.i('onResume | message: $message');
    //     _onResumeHandler(message);
    //   },
    //   // onBackgroundMessage: myBackgroundMessageHandler,
    // );
  }

  /// Subscribe to FCM topics
  ///
  /// User will receive messages from topics they are subscribed to.
  Future<void> subscribeToTopic(String key) async {
    await _firebaseMessaging.subscribeToTopic(key);
  }

  /// Get the FCM [token] associated with each user.
  Future<String> getToken() async {
    /// TODO: implement onTokenRefresh
    String token = await _firebaseMessaging.getToken();
    return token;
  }

  /// FCM on message handler.
  ///
  /// This function is excecuted when the app is active (i.e.: app in foreground).
  /// Checks for the type of notification received based on the key received.
  ///
  /// If the `message['data']` contains an ['openlink'] key, a dialog prompting the user to open the link is displayed.
  ///
  /// If the `message['data']` contains an ['postId'] key, a dialog prompting the user to open the link is displayed.
  ///
  /// If the `message['data']` does not contains an ['openlink'] or ['postID'] key, a regular dialog is displayed with the notification message.
  Future<void> _onMessageHandler(RemoteMessage message) async {
    log.i('_onMessageHandler | message: $message');
// TODO: make sure empty notificatinos dont cause errors
    if (message.data.isNotEmpty) {
      // Check if message contains data key.
      if (message.data.containsKey('openLink')) {
        // check if message['data'] contains openLink key
        log.d('link in message: ${message.data['openLink']}');
        // Show prompt dialog to open link.
        var dialogResponse = await _dialogService.showFcmPromptDialog(
            title: message.notification.title ?? message.data['title'],
            description: message.notification.body ?? message.data['body'],
            dialogType: 'notification_weblink');
        // Check for the user response and open link if confirmed.
        if (dialogResponse.confirmed) {
          _launchLinkInBrowser(
              url: '${message.data['openLink']}', linkTo: 'fcm_link');
        }
      } else if (message.data.containsKey('postId')) {
        // Check if message['data'] contains a postId key
        if (message.data.containsKey('publisherId')) {
          // Check if message contains a publisher ID

          var dialogResponse = await _dialogService.showFcmPostDialog(
            // Show dialog to user.
            title: message.notification.title ?? message.data['title'],
            description: message.notification.body ?? message.data['body'],
            dialogType: 'notification_post',
            publisherId: message.data['publisherId'],
          );
          // Handle the response given by the user.
          log.d('dialog response received was: ${dialogResponse.confirmed}');
          if (dialogResponse.confirmed) {
            _navigateToPost(message.data['postId']);
          } else {
            // If the current user is the same as the publisher, the dialog is not shown to the user and automatically dismissed.
            log.d(
                'Was publisher the same as user?: ${dialogResponse.publisherIsUser}');
          }
        } else {
          // This case should not happen.
          log.wtf('new post notification received without a publisher ID');
        }
      } else {
        log.d('notification has no post ID nor link');
        // Message received had no relevant keys.
        // Default to showing  regular dialog with message.
        await _dialogService.showDialog(
            title: message.notification.title ?? message.data['title'],
            description: message.notification.body ?? message.data['body'],
            dialogType: 'notification_notice');
      }
    } else {
      log.w('message does not contain any data.');
      // This case should raise flags
    }
  }

  /// Handles messages received when the app is in background.
  ///
  /// `On android:`
  /// `Notification:` Notification is delivered to system tray. When the user clicks on it to open app [onResume] fires if click_action: `FLUTTER_NOTIFICATION_CLICK` is set.
  /// `Data Message:` [onMessage] while app stays in the background.
  ///
  /// `On IOS:`
  /// `Notification:` Notification is delivered to system tray. When the user clicks on it to open app [onResume] fires.
  /// `Data Message:` Message is stored by FCM and delivered to app via [onMessage] when the app is brought back to foreground.
  ///
  /// Opens link in web browser if message contains ['openLink'] or navigate to post page if message contains ['postId'] key.
  Future<void> _onResumeHandler(Map<String, dynamic> message) async {
    log.i('_onResumeHandler | message: $message');
    if (message.containsKey('data')) {
      if (message['data'].containsKey('openLink')) {
        _launchLinkInBrowser(
            url: '${message['data']['openLink']}', linkTo: 'fcm_link');
      } else if (message['data'].containsKey('postId')) {
        _navigateToPost(message['data']['postId']);
      } else {
        // Log user location when oppenning notification.
      }
    } else {
      log.w('message does not contain any data.');
    }
  }

  /// Handles messages received when app is terminated.
  ///
  /// `On Android:`
  /// `Notification:` Notification is delivered to system tray. When the user clicks on it to open app [onLaunch] fires if click_action: `FLUTTER_NOTIFICATION_CLICK` is set
  /// `Data Message:` not supported by plugin, message is lost.
  ///
  /// `On IOS:`
  /// `Notification:` Notification is delivered to system tray. When the user clicks on it to open app [onLaunch] fires.
  /// `Data Message:` Message is stored by FCM and delivered to app via [onMessage] when the app is brought back to foreground.
  ///
  /// Opens link in web browser if message contains ['openLink'] or navigate to post page if message contains ['postId'] key.
  Future<void> _onLauncherHandler(Map<String, dynamic> message) async {
    log.i('_onLaunchHandler | message: $message');
    if (message.containsKey('data')) {
      if (message['data'].containsKey('openLink')) {
        _launchLinkInBrowser(
            url: '${message['data']['openLink']}', linkTo: 'fcm_link');
      } else if (message['data'].containsKey('postId')) {
        _navigateToPost(message['data']['postId']);
      } else {
        // Log user location when oppenning notification.
      }
    } else {
      log.w('message does not contain any data.');
    }
  }

  /// Launch URL in browser.
  void _launchLinkInBrowser({String url, String linkTo}) async {
    try {
      log.d('navigating to link');
      _launcherService.launchInBrowser(url: url, linkTo: linkTo);
    } catch (e) {
      log.e('_launchLinkInBrowser | error: $e');
      throw e;
    }
  }

  /// Navigate to post received in message.
  void _navigateToPost(String postId) {
    try {
      _navigationService.navigateTo(
        FeedItemDetailsScreen.routeName,
        arguments: FeedItemDetailScreenArguments(
          post: null,
          returnPage: 0,
          referalPage: null,
          postId: postId,
        ),
      );
    } catch (e) {
      log.e('_natigateToPost | error: $e');
      _navigationService.removeUntil('/tab-screen');
      // TODO: show page saying post is outdated?
      throw e;
    }
  }
}
