import 'package:flutter/material.dart';
import '../../../logger.dart';

final log = getLogger('DrawerMenuItems');

class DrawerMenuItems extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTapHandler;

  DrawerMenuItems(
      {@required this.title, @required this.icon, @required this.onTapHandler});

  @override
  Widget build(BuildContext context) {
    log.i('building drawer menu items');
    // final mediaQuery = MediaQuery.of(context);
    return ListTile(
      visualDensity: VisualDensity(
        horizontal: VisualDensity.minimumDensity,
        vertical: -2,
      ),
      onTap: onTapHandler,
      leading: Icon(
        icon,
        color: Theme.of(context).accentColor,
        // size: mediaQuery.size.height * 0.06,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }
}
