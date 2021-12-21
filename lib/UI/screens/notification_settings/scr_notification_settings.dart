import 'package:flutter/material.dart';
import 'package:flutter_scaffold/models/post.dart';


import 'scr_alert_settings.dart';
import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('NotificationSettingsScreen');

class NotificationSettingsScreen extends StatelessWidget {
  static const routeName = '/notification-settings-screen';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final _alerts = TagList().getTagList(context: context);
    log.i('building notification screen ');
    final appBar = AppBar(
      title: Text(
        I18n.of(context).notificationSettingsScreenTitle,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: Container(
        height: mediaQuery.size.height,
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return Divider(
              color: Colors.white,
            );
          },
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(
                _alerts[index]['icon'],
                color: Theme.of(context).accentColor,
                size: 50,
              ),
              title: Text(
                _alerts[index]['title'],
              ),
              subtitle: Text(
                I18n.of(context).notificationSettingsScreenListTileSubtitle,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              onTap: () {
                Navigator.of(context).pushNamed(AlertSettingsScreen.routeName,
                    arguments: _alerts[index]);
              },
            );
          },
          itemCount: _alerts.length,
        ),
      ),
    );
  }
}
