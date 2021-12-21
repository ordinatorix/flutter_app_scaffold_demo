// TODO: merge this page with feed screen. perhaps turn the screen into a widget
import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/feed_tab/feed_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../models/post.dart';
import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('UserProfileTab');

class UserProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log.i('rebuilding profile tab widget');
    final postData = Provider.of<List<Post>>(context);

    return postData != null && postData.isNotEmpty
        ? ListView.builder(
            itemBuilder: (ctx, index) {
              return FeedItem(
                post: postData[index],
              );
            },
            itemCount: postData.length,
          )
        : postData != null && postData.isEmpty
            ? Center(
                child: Text(
                  I18n.of(context).profileSettingScreenNoSubmittedPosts,
                ),
              )
            : Center(
                child: SpinKitCubeGrid(
                  color: Theme.of(context).accentColor,
                ),
              );
  }
}
