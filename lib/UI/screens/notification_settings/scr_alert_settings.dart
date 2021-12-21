import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base_view_screen.dart';

import '../../../models/user.dart';

import 'mdl_alert_settings.dart';

import '../../../logger.dart';

final log = getLogger('AlertSettingsScreen');

class AlertSettingsScreen extends StatelessWidget {
  static const routeName = '/alert-setting-screen';

  @override
  Widget build(BuildContext context) {
    log.i('building alert settings screen');
    final Map argument = ModalRoute.of(context).settings.arguments as Map;
    User _user = Provider.of<User>(context);
    return BaseView<AlertSettingsScreenModel>(
      onModelReady: (model) {
        model.getTranslatedStatus(context);
        model.loadSettings();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(argument['title']),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    model.onAppbarCloseButtonPressed();
                  })
            ],
          ),
          body: ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.white,
              );
            },
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text('${model.statusTranslated[index]}'.toUpperCase()),
                onChanged: (bool value) {
                  model.onBoxChecked(index, value, argument, _user);
                },
                value: model.loadedAlerts[
                    argument['${model.status[index]}Subscription']],
              );
            },
            itemCount: model.statusTranslated.length,
          ),
        );
      },
    );
  }
}
