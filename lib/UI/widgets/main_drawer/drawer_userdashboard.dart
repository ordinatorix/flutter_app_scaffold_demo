import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../models/user.dart';
import '../../screens/user_profile/scr_profile_settings.dart';
import '../../screens/user_profile/profile_dashboard.dart';
import '../../../generated/i18n.dart';
import '../../../logger.dart';
import '../../../locator.dart';

import '../../../services/navigation_service.dart';

final log = getLogger('UserDashBoard');

class UserDashBoard extends StatefulWidget {
  final User databaseUser;

  UserDashBoard({@required this.databaseUser});
  @override
  _UserDashBoardState createState() => _UserDashBoardState();
}

class _UserDashBoardState extends State<UserDashBoard> {
  final NavigationService _navigationService = locator<NavigationService>();
  @override
  Widget build(BuildContext context) {
    log.i('building drawer user dashboard');

    return widget.databaseUser != null
        ? Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                margin: EdgeInsets.all(0),
                currentAccountPicture: widget.databaseUser.photoUrl != null &&
                        widget.databaseUser.photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.databaseUser.photoUrl,
                        imageBuilder: (context, imgProvider) => CircleAvatar(
                          child: InkWell(
                            onTap: () {
                              _navigationService
                                  .replaceWith(ProfileSettingsScreen.routeName);
                            },
                          ),
                          backgroundImage: imgProvider,
                        ),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => CircleAvatar(
                          child: InkWell(
                            onTap: () {
                              _navigationService
                                  .replaceWith(ProfileSettingsScreen.routeName);
                            },
                          ),
                          backgroundImage:
                              AssetImage('assets/images/default_avatar.png'),
                        ),
                        errorWidget: (context, url, error) {
                          log.e('Failed to load profile picture');
                          return CircleAvatar(
                            child: InkWell(
                              onTap: () {
                                _navigationService.replaceWith(
                                    ProfileSettingsScreen.routeName);
                              },
                            ),
                            backgroundImage:
                                AssetImage('assets/images/default_avatar.png'),
                          );
                        },
                      )
                    : CircleAvatar(
                        child: InkWell(
                          onTap: () {
                            _navigationService
                                .replaceWith(ProfileSettingsScreen.routeName);
                          },
                        ),
                        backgroundImage:
                            AssetImage('assets/images/default_avatar.png'),
                      ),
                accountName: widget.databaseUser.displayName != null &&
                        widget.databaseUser.displayName.isNotEmpty
                    ? Text('${widget.databaseUser.displayName}')
                    : Text(I18n.of(context).drawerNewUser),
                accountEmail: widget.databaseUser.phone != null &&widget.databaseUser.phone.isNotEmpty
                    ? Text('${widget.databaseUser.phone}')
                    : Text(I18n.of(context).drawerPlaceHolder),
              ),
              ProfileDashBoard(),
            ],
          )
        : Center(
            child: SpinKitCubeGrid(
              color: Theme.of(context).accentColor,
            ),
          );
  }
}
