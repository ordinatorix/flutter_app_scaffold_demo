import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/feed_tab/feed_item.dart';
import 'package:flutter_scaffold/UI/widgets/empty_state.dart';
import 'package:flutter_scaffold/generated/i18n.dart';
import 'package:flutter_scaffold/locator.dart';
import 'package:flutter_scaffold/logger.dart';
import 'package:flutter_scaffold/models/post.dart';
import 'package:flutter_scaffold/services/analytics_service.dart';


final log = getLogger('FeedScreen');

class FeedScreen extends StatelessWidget {
  final List<Post> post;

  FeedScreen({this.post});

  final AnalyticsService _analytics = locator<AnalyticsService>();

  @override
  Widget build(BuildContext context) {
    log.i('rebuild feed screen');
    _analytics.setCurrentScreen(screenName: '/feed-screen');

    final postSnapShotData = post;

    if (postSnapShotData != null && postSnapShotData.isNotEmpty) {
      return ListView.builder(
        itemBuilder: (ctx, index) {
          return FeedItem(
            post: postSnapShotData[index],
          );
        },
        itemCount: postSnapShotData.length,
      );
    } else {
      return EmptyState(
        icon: Icons.rss_feed,
        iconText: I18n.of(context).feedScreenNoActivity,
      );
    }
  }
}
