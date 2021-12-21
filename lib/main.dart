import 'dart:io';

import 'UI/screens/account_settings/scr_account_settings.dart';
import 'UI/screens/account_settings/scr_change_number_instruction.dart';
import 'UI/screens/camera/scr_camera.dart';
import 'UI/screens/contacts_display/scr_contacts_display.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import './locator.dart';
import './logger.dart';

import './enums/theme_mode.dart';
import './enums/connection_result.dart';

import './managers/dialog_manager.dart';

import './services/authentication_service.dart';
import './services/database_service.dart';
import './services/location_service.dart';
import './services/fcm_service.dart';
import './services/dialog_service.dart';
import './services/navigation_service.dart';
import './services/camera_service.dart';
import './services/analytics_service.dart';
import './services/connectivity_service.dart';

import './helpers/share_prefs_helper.dart';

import './models/user.dart';
import './models/app_themes.dart';
import './models/contacts.dart';
import './models/post.dart';

import './generated/i18n.dart';
import 'UI/screens/feed_item_details/scr_feed_item_details.dart';
import 'UI/screens/general_settings/scr_general_settings.dart';
import 'UI/screens/grid_menu/scr_grid_menu.dart';
import 'UI/screens/image_viewer/scr_image_list_viewer.dart';
import 'UI/screens/login/scr_login.dart';
import 'UI/screens/main_tab_page/tab_screen.dart';
import 'UI/screens/notification_settings/scr_alert_settings.dart';
import 'UI/screens/notification_settings/scr_notification_settings.dart';
import 'UI/screens/post_edit/scr_post_comment.dart';
import 'UI/screens/post_edit/scr_post_edit.dart';
import 'UI/screens/splash/wrapper.dart';
import 'UI/screens/user_profile/scr_profile_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // set orientation of device
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Register all the models and services before the app starts
  setupLocator();

  // set log level to info
  Logger.level = Level.debug;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIOverlays([]);

  // run the app
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final FcmService _fcmService = locator<FcmService>();
  final SharedPrefsHelper _sharedPrefsHelper = locator<SharedPrefsHelper>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();
  final CameraService _cameraService = locator<CameraService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final AuthService _authService = locator<AuthService>();
  final LocationService _locationService = locator<LocationService>();
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final i18n = I18n.delegate;

  final log = getLogger('MyApp');

  @override
  void initState() {
    log.i('initState');
    _fcmService.initialize();
    super.initState();
  }

  @override
  void dispose() {
    log.i('dispose');
    _sharedPrefsHelper?.dispose();
    _locationService.dispose();
    _connectivityService.dispose();
    _cameraService.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    log.i('building MAIN');
    log.d('locale is: ${Platform.localeName.split("_")[0]}');
    precacheImage(AssetImage('assets/images/flutter_logo1.png'), context);
    User _authUser = _authService.currentAuthenticatedUser();
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          value: _authService.user,
          initialData: User(uid: ''),
        ),
        StreamProvider<List<Post>>.value(
          initialData: [],
          value: _databaseService.posts,
        ),
        StreamProvider<SharedPrefsHelper>.value(
          initialData: null,
          value: _sharedPrefsHelper.sharedPrefsStream,
        ),
        StreamProvider<bool>.value(
          value: _sharedPrefsHelper.isReadyStream,
          initialData: false,
        ),
        StreamProvider<DeviceLocation>.value(
          initialData: null,
          value: _locationService.locationStream,
        ),
        StreamProvider<UploadProgress>.value(
          value: _databaseService.storageUploadTaskStream,
          initialData: null,
        ),
        StreamProvider<CameraController>.value(
          initialData: null,
          value: _cameraService.cameraStream,
        ),
        StreamProvider<ConnectionResult>.value(
          initialData: null,
          value: _connectivityService.connectivityStream,
        ),
        StreamProvider<List<UserContact>>.value(
          initialData: [],
          value: _databaseService.getContacts(user: _authUser),
        ),
      ],
      child: StreamBuilder<SharedPrefsHelper>(
          stream: _sharedPrefsHelper?.sharedPrefsStream,
          builder: (context, snapshot) {
            log.d('sharedprefs snapshot is : $snapshot');
            log.w('is sharedprefs ready? ${snapshot?.data?.isReady}');
            log.w('sharedprefs connection state${snapshot?.connectionState}');

            return MaterialApp(
              debugShowCheckedModeBanner: _sharedPrefsHelper.isFresh,
              navigatorObservers: [
                // MyRouteObserver(),
                FirebaseAnalyticsObserver(
                  analytics: _analyticsService.firebaseAnalyticsService,
                ),
              ],
              title: 'Scaffold',
              navigatorKey: _navigationService.navigationKey,
              builder: (context, widget) => Navigator(
                key: _dialogService.dialogNavigationKey,
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (context) =>
                      Consumer<User>(builder: (context, user, _) {
                    log.w(
                        'user given to dialog manager: ${user != null ? user.uid : 'null'}');
                    return DialogManager(
                      child: widget,
                      publisherID: user != null ? user.uid : '',
                    );
                  }),
                ),
              ),
              themeMode: ScaffoldThemeMode
                          .values[_sharedPrefsHelper.whatThemeMode] ==
                      ScaffoldThemeMode.Auto
                  ? ThemeMode.system
                  : ScaffoldThemeMode
                              .values[_sharedPrefsHelper.whatThemeMode] ==
                          ScaffoldThemeMode.Dark
                      ? ThemeMode.dark
                      : ScaffoldThemeMode
                                  .values[_sharedPrefsHelper.whatThemeMode] ==
                              ScaffoldThemeMode.Light
                          ? ThemeMode.light
                          : ThemeMode.system,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: Wrapper(),
              routes: {
                TabsScreen.routeName: (ctx) => TabsScreen(),
                LoginScreen.routeName: (ctx) => LoginScreen(),
                CameraScreen.routeName: (ctx) => CameraScreen(),
                GridMenuScreen.routeName: (ctx) => GridMenuScreen(),
                PostEditScreen.routeName: (ctx) => PostEditScreen(),
                PostCommentScreen.routeName: (ctx) => PostCommentScreen(),
                FeedItemDetailsScreen.routeName: (ctx) =>
                    FeedItemDetailsScreen(),
                ImageListViewerScreen.routeName: (ctx) =>
                    ImageListViewerScreen(),
                NotificationSettingsScreen.routeName: (ctx) =>
                    NotificationSettingsScreen(),
                ProfileSettingsScreen.routeName: (ctx) =>
                    ProfileSettingsScreen(),
                GeneralSettingsScreen.routeName: (ctx) =>
                    GeneralSettingsScreen(),
                AlertSettingsScreen.routeName: (ctx) => AlertSettingsScreen(),
                AccountSettingScreen.routeName: (ctx) => AccountSettingScreen(),
                ChangeNumberInstructionScreen.routeName: (ctx) =>
                    ChangeNumberInstructionScreen(),
                ContactsDisplayScreen.routeName: (ctx) =>
                    ContactsDisplayScreen(),
              },
              onUnknownRoute: (settings) {
                return MaterialPageRoute(builder: (ctx) => Wrapper());
              },
              locale: Locale(Platform.localeName.split("_")[0],
                  Platform.localeName.split("_")[1]),
              localizationsDelegates: [
                i18n,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: i18n.supportedLocales,
              localeResolutionCallback: i18n.resolution(
                fallback: Locale('en', 'US'),
              ),
            );
          }),
    );
  }
}
