import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import 'menu_tags.dart';

import '../../../services/database_service.dart';
import '../../../services/navigation_service.dart';

import '../../../models/user.dart';
import '../../../models/post.dart';

import '../../../generated/i18n.dart';

final log = getLogger('GridMenuScreen');

class GridMenuScreen extends StatelessWidget {
  static const routeName = '/grid-menu-screen';

  final DatabaseService _database = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    log.i('building menu submit screen');
    final modalRoute = ModalRoute.of(context).settings;

    final _tagsList = TagList().getTagList(context: context);
    final _location = modalRoute.arguments as EventLocation;
    final _user = Provider.of<User>(context);
    final appBar = AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: I18n.of(context).navigateBackToolTip,
          onPressed: () {
            _navigationService.removeUntil('/tab-screen');
            //TODO: include tabscreen return page into argument
          }),
      title: Text(
        I18n.of(context).gridMenuScreenTitle,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
    return MultiProvider(
      providers: [
        StreamProvider<List<User>>.value(
          // TODO: add auth user as user?
          initialData: [],
          value: _database.getUser(user: _user),
        ),
      ],
      child: WillPopScope(
        onWillPop: () {
          _navigationService.removeUntil('/tab-screen');

          return Future.value(false);
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: appBar,
          body: MenuTag(
            authUser: _user,
            tagsList: _tagsList,
            appBar: appBar,
            selectedLocation: _location,
          ),
        ),
      ),
    );
  }
}
