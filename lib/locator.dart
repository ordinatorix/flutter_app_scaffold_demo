import 'package:flutter_scaffold/UI/screens/feed_item_details/img_scroller/mdl_image_scroller.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/earth_map_tab/mdl_map_home_scr.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/feed_tab/mdl_feed_item.dart';
import 'package:flutter_scaffold/UI/screens/notification_settings/mdl_alert_settings.dart';
import 'package:flutter_scaffold/UI/screens/camera/mdl_camera_screen.dart';
import 'package:flutter_scaffold/UI/screens/account_settings/mdl_change_phone_number.dart';
import 'package:flutter_scaffold/UI/screens/account_settings/mdl_change_username.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/friends_tab/mdl_community_scr.dart';
import 'package:flutter_scaffold/UI/screens/contacts_display/mdl_contact_display.dart';
import 'package:flutter_scaffold/UI/screens/post_edit/mdl_emergency_response_selector.dart';
import 'package:flutter_scaffold/UI/screens/feed_item_details/mdl_item_card.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/friends_tab/family_tab/mdl_family_group.dart';
import 'package:flutter_scaffold/UI/screens/feed_item_details/mdl_feed_item_detail.dart';
import 'package:flutter_scaffold/UI/screens/general_settings/mdl_general_settings.dart';
import 'package:flutter_scaffold/UI/screens/image_viewer/mdl_image_video_stack.dart';
import 'package:flutter_scaffold/UI/screens/location_input/mdl_location_input.dart';
import 'package:flutter_scaffold/UI/screens/login/mdl_login_screen.dart';
import 'package:flutter_scaffold/UI/widgets/main_drawer/mdl_main_drawer.dart';
import 'package:flutter_scaffold/UI/screens/user_profile/mdl_profile_image_input.dart';
import 'package:flutter_scaffold/UI/screens/post_edit/mdl_post_comment.dart';
import 'package:flutter_scaffold/UI/widgets/date_formater/date_formater_view_model.dart';
import 'package:flutter_scaffold/UI/screens/post_edit/mdl_post_edit.dart';
import 'package:flutter_scaffold/UI/screens/location_input/mdl_select_location_screen.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/mdl_tab_screen.dart';
import 'package:flutter_scaffold/UI/screens/post_edit/mdl_tag_option_selector.dart';
import 'package:flutter_scaffold/UI/screens/splash/mdl_wrapper.dart';
import 'package:get_it/get_it.dart';


import 'services/authentication_service.dart';
import 'services/database_service.dart';
import 'services/analytics_service.dart';
import 'services/url_launcher_service.dart';
import 'services/dialog_service.dart';
import 'services/navigation_service.dart';
import 'services/location_service.dart';
import 'services/fcm_service.dart';
import 'services/camera_service.dart';
import 'services/file_picker_service.dart';
import 'services/connectivity_service.dart';
import 'services/contacts_service.dart';

import 'helpers/share_prefs_helper.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  // register services
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => UrlLauncherService());
  locator.registerLazySingleton(() => AnalyticsService());
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => SharedPrefsHelper());
  locator.registerLazySingleton(() => FcmService());
  locator.registerLazySingleton(() => CameraService());
  locator.registerLazySingleton(() => FilePickerService());
  locator.registerLazySingleton(() => ConnectivityService());
  locator.registerLazySingleton(() => ContactService());

// register view models
  locator.registerFactory(() => WrapperViewModel());
  locator.registerFactory(() => LoginScreenModel());
  locator.registerFactory(() => HomeMapScreenModel());
  locator.registerFactory(() => AlertSettingsScreenModel());
  locator.registerFactory(() => PostEditScreenModel());
  locator.registerFactory(() => ChangeUsernameModel());
  locator.registerFactory(() => ChangePhoneNumberModel());
  locator.registerFactory(() => FeedItemModel());
  locator.registerFactory(() => ItemCardViewModel());
  locator.registerFactory(() => DateFormaterViewModel());
  locator.registerFactory(() => FeedItemDetailViewModel());
  locator.registerFactory(() => GeneralSettingsViewModel());
  locator.registerFactory(() => SelectLocationScreenViewModel());
  locator.registerFactory(() => EmergencyResponseSelectorViewModel());
  locator.registerFactory(() => TagOptionSelectorViewModel());
  locator.registerFactory(() => ImageScrollerViewModel());
  locator.registerFactory(() => LocationInputViewModel());
  locator.registerFactory(() => MainDrawerViewModel());
  locator.registerFactory(() => ProfileImageInputViewModel());
  locator.registerFactory(() => TabScreenViewModel());
  locator.registerFactory(() => PostCommentScreenViewModel());
  locator.registerFactory(() => ImageVideoStackViewModel());
  locator.registerFactory(() => CameraScreenViewModel());
  locator.registerFactory(() => CommunityScreenViewModel());
  locator.registerFactory(() => FamilyGroupViewModel());
  locator.registerFactory(() => ContactsDisplayViewModel());
}
