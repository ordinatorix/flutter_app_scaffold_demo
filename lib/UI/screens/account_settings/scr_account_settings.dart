import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'scr_change_phone_number.dart';
import 'scr_change_username.dart';

import '../../../locator.dart';

import '../../../models/user.dart';

import '../../../services/database_service.dart';

import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('AccountSettingScreen');

class AccountSettingScreen extends StatelessWidget {
  static const routeName = '/account-settings-screen';
  final DatabaseService _database = locator<DatabaseService>();

  @override
  Widget build(BuildContext context) {
    log.i('building account setting screen');
    final _args = ModalRoute.of(context).settings.arguments as String;
    final _authUser = Provider.of<User>(context);

    final appBar = AppBar(
      title: Text(
        _args == 'phoneNumber'
            ? I18n.of(context).accountSettingsScreenChangeNumber
            : I18n.of(context).accountSettingsScreenChangeUsername,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
    return _authUser != null
        ? MultiProvider(
            providers: [
              StreamProvider<List<User>>.value(
                initialData: [],
                value: _database.getUser(user: _authUser),
              ),
            ],
            child: Scaffold(
              appBar: appBar,
              body: _args == 'phoneNumber'
                  ? ChangePhoneNumberScreen(authUser: _authUser)
                  : ChangeUsernameScreen(authUser: _authUser),
            ),
          )
        : Center(
            child: SpinKitCubeGrid(
              color: Theme.of(context).accentColor,
            ),
          );
  }
}
