import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/feed_tab/scr_feed.dart';
import 'package:flutter_scaffold/UI/widgets/empty_state.dart';

import '../../base_model.dart';



import 'earth_map_tab/scr_map_home.dart';
import 'friends_tab/scr_community.dart';
import '../grid_menu/scr_grid_menu.dart';

import '../../../services/database_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/dialog_service.dart';
import '../../../services/navigation_service.dart';

import '../../../helpers/tab_screen_arguments.dart';

import '../../../models/user.dart';
import '../../../models/post.dart';

import '../../../enums/filtered_options.dart';
import '../../../enums/view_state.dart';

import '../../../generated/i18n.dart';

import '../../../locator.dart';
import '../../../logger.dart';

final log = getLogger('TabScreenViewModel');

class TabScreenViewModel extends BaseModel {
  final DatabaseService databaseService = locator<DatabaseService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  FilteredOptions dropDownValue = FilteredOptions.All;
  List<Map<String, Object>> pages;
  int selectedPageIndex = 0;
  User authUser = User();
  List<Post> postData = [];
  List<Post> postSnapShotData;

  TabScreenArguments args;

  // void showInSnackBar(String message) {
  //   log.i('_showInSnackBar | message: $message');
  //   if (message.isNotEmpty) {
  //     scaffoldKey.currentState.removeCurrentSnackBar();
  //     scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  //   }
  // }

  void selectedPage(int index) {
    log.i('selectedPage | index: $index');
    selectedPageIndex = index;
    setState(ViewState.Busy);
  }

  void initializeModel() {
    log.i('initializeModel');
    if (args != null) {
      final initPage = args.returnPage;
      // final initPage = ModalRoute.of(context).settings.arguments as int;
      if (initPage != null) {
        selectedPageIndex = initPage;
      }
      // String message = args.snackbarMessage;
      // if (message.isNotEmpty) {
      //   _showInSnackBar(message);
      // }
    }
  }

  Future onWillPop(BuildContext context) async {
    log.i('onWillPop | context: $context');
    log.d('Is drawer open?: ${scaffoldKey.currentState.isDrawerOpen}');
    if (scaffoldKey.currentState.isDrawerOpen) {
      Navigator.of(context).pop();
      return false;
    } else {
      var dialogResult = await _dialogService.showWarningDialog(
        title: I18n.of(context).dialogsWillPopTitle,
        description: I18n.of(context).dialogsWillPopMessage,
        confirmationTitle: I18n.of(context).buttonsYesButton,
        cancelTitle: I18n.of(context).buttonsNoButton,
        dialogType: 'will_pop_warning',
      );
      return dialogResult.confirmed;
    }
  }

  void reloadPost(BuildContext context) {
    log.i('reloadPost | context: $context');
    if (dropDownValue == FilteredOptions.All) {
      pages = [
        {
          'page': HomeMapScreen(
            post: postData
                .where((post) =>
                    post.status == 'Rumored' ||
                    post.status == 'Confirmed' ||
                    post.status == 'Cleared')
                .toList(),
          ),
          // 'page': EmptyState(icon: Icons.ac_unit, iconText: 'Cold Place'),
          'title': I18n.of(context).homeScreenTitle,
        },
        {
          'page': FeedScreen(
            post: postData
                .where((post) =>
                    post.status == 'Rumored' ||
                    post.status == 'Confirmed' ||
                    post.status == 'Cleared')
                .toList(),
          ),
          'title': I18n.of(context).feedScreenTitle,
        },
        {
          'page': CommunityScreen(),
          'title': I18n.of(context).communityScreenTitle,
        }
      ];
    }
  }

  void onFilterButtonTap(FilteredOptions selectedValue) {
    log.i('onFilterButtonTap | selectedValue: $selectedValue');
    // log.wtf('skaff key: ${scaffoldKey.currentState}');
    if (postData != null) {
      if (selectedValue == FilteredOptions.Confirmed) {
        _analyticsService.logCustomEvent(
            name: 'filtered_feed', parameters: {'filter': 'confirmed'});
        dropDownValue = selectedValue;

        postSnapShotData =
            postData.where((post) => post.status == 'Confirmed').toList();
      } else if (selectedValue == FilteredOptions.Rumored) {
        _analyticsService.logCustomEvent(
            name: 'filtered_feed', parameters: {'filter': 'rumored'});
        dropDownValue = selectedValue;

        postSnapShotData =
            postData.where((post) => post.status == 'Rumored').toList();
      } else if (selectedValue == FilteredOptions.Cleared) {
        _analyticsService.logCustomEvent(
            name: 'filtered_feed', parameters: {'filter': 'cleared'});
        dropDownValue = selectedValue;

        postSnapShotData =
            postData.where((post) => post.status == 'Cleared').toList();
      } else if (selectedValue == FilteredOptions.Fake) {
        _analyticsService.logCustomEvent(
            name: 'filtered_feed', parameters: {'filter': 'fake'});
        dropDownValue = selectedValue;

        postSnapShotData =
            postData.where((post) => post.status == 'Fake').toList();
      } else if (selectedValue == FilteredOptions.All) {
        _analyticsService.logCustomEvent(
            name: 'filtered_feed', parameters: {'filter': 'all'});
        dropDownValue = selectedValue;

        postSnapShotData = postData
            .where((post) =>
                post.status == 'Rumored' ||
                post.status == 'Confirmed' ||
                post.status == 'Cleared')
            .toList();
      } else {
        log.w('unknown FilteredOption received: $selectedValue');
      }
    }

    pages[1]['page'] = FeedScreen(
      post: postSnapShotData,
    );
    pages[0]['page'] = HomeMapScreen(
      post: postSnapShotData,
    );
    setState(ViewState.Idle);
  }

  void onFloatingActionButtonTap() {
    log.i('onFloatingActionButtonTap');
    _analyticsService.logCustomEvent(name: 'tap_FAB');
    _navigationService.replaceWith(GridMenuScreen.routeName);
  }
}
