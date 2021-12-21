import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'mdl_main_drawer.dart';

import 'drawer_menu_items.dart';
import 'drawer_userdashboard.dart';

import '../../base_view_screen.dart';

import '../../../models/post.dart';

import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('MainDrawer');

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log.i('building Main drawer');

    return BaseView<MainDrawerViewModel>(
      onModelReady: (model) {
        model.initializeModel();
      },
      builder: (context, model, child) {
        model.initializeUser();
        return model.authUser != null
            ? MultiProvider(
                providers: [
                  StreamProvider<List<Post>>.value(
                    initialData: [],
                    // TODO: test this
                    value: model.databaseService
                        .getUserPosts(uid: model.authUser.uid),
                    // catchError: (_, error){post();
                    // log.e('error is: $error');
                    //   throw error;},
                  )
                ],
                child: Drawer(
                  child: Scaffold(
                    body: Container(
                      // color: Colors.blue,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          UserDashBoard(
                            databaseUser: model.authUser,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                DrawerMenuItems(
                                  title: I18n.of(context).drawerMyProfile,
                                  icon: Icons.account_circle,
                                  onTapHandler: () {
                                    model.onMyProfileButtonTap();
                                  },
                                ),
                                DrawerMenuItems(
                                  title: I18n.of(context).drawerShareApp,
                                  icon: Icons.share,
                                  onTapHandler: () async {
                                    model.onShareButtonTap(context);
                                  },
                                ),
                                DrawerMenuItems(
                                  title: I18n.of(context).drawerFeedback,
                                  icon: Icons.feedback,
                                  onTapHandler: () {
                                    model.onFeedbackButtonTap();
                                  },
                                ),
                                DrawerMenuItems(
                                  title: I18n.of(context).drawerRelease,
                                  icon: Icons.system_update,
                                  onTapHandler: () {
                                    model.onNewReleaseButtonTap();
                                  },
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            alignment: Alignment.center,
                            child: Text('Version: ${model.appVersion}'),
                            // color: Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                    persistentFooterButtons: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Container(
                              child: TextButton.icon(
                                icon: Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                                label: Flexible(
                                  child: Container(
                                    child: Text(
                                      I18n.of(context).drawerSettings,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                // textColor: Colors.grey,
                                onPressed: () {
                                  model.onSettingsButtonPressed();
                                },
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              child: TextButton.icon(
                                icon: Icon(
                                  Icons.exit_to_app,
                                  color: Theme.of(context).errorColor,
                                ),
                                label: Flexible(
                                  child: Container(
                                    child: Text(
                                      I18n.of(context).drawerLogout,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ),
                                ),
                                // textColor: Colors.grey,
                                onPressed: () {
                                  model.onLogoutButtonTap(context);
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: SpinKitCubeGrid(
                  color: Theme.of(context).accentColor,
                ),
              );
      },
    );
  }
}
