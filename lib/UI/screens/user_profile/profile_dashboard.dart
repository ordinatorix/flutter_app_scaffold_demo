import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/post.dart';
import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('ProfileDashBoard');

class ProfileDashBoard extends StatefulWidget {
  const ProfileDashBoard({Key key, this.size});

  final String size;

  @override
  _ProfileDashBoardState createState() => _ProfileDashBoardState();
}

class _ProfileDashBoardState extends State<ProfileDashBoard> {
  Iterable<Post> _verifiedPostList;
  double factor = 0.015;

  @override
  Widget build(BuildContext context) {
    log.i('building profile dashboard');
    if (widget.size == 'large') {
      factor = 0;
    }

    final _submittedPostsList = Provider.of<List<Post>>(context);
    if (_submittedPostsList != null) {
      _verifiedPostList = _submittedPostsList.where((post) =>
          post.status == 'Confirmed' || post.status == 'Cleared');
    }
    final mediaQuery = MediaQuery.of(context);
    return Container(
      height: mediaQuery.size.height * 0.08,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).accentColor),
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            // color: Colors.purpleAccent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Icon(
                //   Icons.send,
                //   color: Theme.of(context).accentColor,
                // ),
                _submittedPostsList == null
                    ? Text(I18n.of(context).profileSettingScreenDefaultPosted)
                    : Text(
                        '${I18n.of(context).profileSettingScreenPostedCount} ${_submittedPostsList.length}',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
              ],
            ),
          ),
          Container(
            // color: Colors.greenAccent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Icon(Icons.verified_user, color: Theme.of(context).accentColor),
                _verifiedPostList == null
                    ? Text(I18n.of(context).profileSettingScreenDefaultVerified)
                    : Text(
                        '${I18n.of(context).profileSettingScreenVerifiedCount} ${_verifiedPostList.length}',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
