import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'usr_profile_tab.dart';
import 'profile_dashboard.dart';
import 'profile_image_input.dart';

import '../../../locator.dart';
import '../../../models/user.dart';
import '../../../models/post.dart';

import '../../../services/navigation_service.dart';
import '../../../services/database_service.dart';

import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('ProfileSettingsScreen');

class ProfileSettingsScreen extends StatelessWidget {
  static const routeName = '/profile-settings';

  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    log.i('building profile screen');
    final mediaQuery = MediaQuery.of(context);

    final _authUser = Provider.of<User>(context);
    final appBar = AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _navigationService
                .replaceWith('/tab-screen'); // Navigate back to tab screen.
          }),
      title: Text(
        I18n.of(context).profileSettingScreenTitle,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
    return _authUser != null
        ? MultiProvider(
            providers: [
              StreamProvider<List<User>>.value(
                initialData: [],
                value: _databaseService.getUser(user: _authUser),
              ),
              StreamProvider<List<Post>>.value(
                initialData: [],
                value: _databaseService.getUserPosts(uid: _authUser.uid),
              ),
            ],
            child: WillPopScope(
              onWillPop: () {
                _navigationService
                    .removeUntil('/tab-screen'); // navigate back to tabscreen.

                return Future.value(false);
              },
              child: Scaffold(
                appBar: appBar,
                body: Column(
                  children: <Widget>[
                    Container(
                      // color: Colors.red,
                      width: double.infinity,
                      height: (mediaQuery.size.height -
                              appBar.preferredSize.height -
                              mediaQuery.padding.top) *
                          0.35,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Spacer(),
                          Container(
                            alignment: Alignment.center,
                            // color: Colors.blue,
                            width: (mediaQuery.size.height -
                                    appBar.preferredSize.height -
                                    mediaQuery.padding.top) *
                                0.24,
                            height: (mediaQuery.size.height -
                                    appBar.preferredSize.height -
                                    mediaQuery.padding.top) *
                                0.24,
                            child: ProfileImageInput(),
                          ),
                          Spacer(),
                          ProfileDashBoard(
                            size: 'large',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          height: (mediaQuery.size.height -
                                  appBar.preferredSize.height -
                                  mediaQuery.padding.top) *
                              0.65,
                          child: UserProfileTab(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : Center(
            child: SpinKitCubeGrid(
              color: Theme.of(context).accentColor,
            ),
          );
  }
}
