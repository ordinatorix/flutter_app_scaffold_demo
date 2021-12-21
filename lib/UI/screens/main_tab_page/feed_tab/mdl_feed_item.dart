import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/base_model.dart';
import 'package:flutter_scaffold/UI/screens/feed_item_details/scr_feed_item_details.dart';
import 'package:flutter_scaffold/enums/view_state.dart';
import 'package:flutter_scaffold/helpers/feed_item_detail_screen_arguments.dart';
import 'package:flutter_scaffold/locator.dart';
import 'package:flutter_scaffold/logger.dart';
import 'package:flutter_scaffold/models/post.dart';
import 'package:flutter_scaffold/models/user.dart' show DeviceLocation;
import 'package:flutter_scaffold/services/analytics_service.dart';
import 'package:flutter_scaffold/services/location_service.dart';
import 'package:flutter_scaffold/services/navigation_service.dart';

final log = getLogger('FeedScreenModel');

class FeedItemModel extends BaseModel {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final LocationService _gps = locator<LocationService>();
  final NavigationService _navigationService = locator<NavigationService>();
  List alerts;
  String titleTrans;
  DeviceLocation coordList;
  double distanceToEvent;

  void initializeModel(BuildContext context, Post post) {
    log.i('initializeModel | context: $context, post: ${post.title}');
    alerts = TagList().getTagList(context: context);
    titleTrans = alerts
        .firstWhere((map) => map.containsValue(post.title))['titleTrans'];
  }

  void logAnalyticsViewItem(
      String itemName, String itemCategory, String itemId) async {
    log.i(
        'logAnalyticsViewItem | itemName: $itemName, itemCategory: $itemCategory, itemId: $itemId');
    await _analyticsService.logViewItem(
        itemName: itemName, itemCategory: itemCategory, itemId: itemId);
  }

  void getPostDistanceFromUser(
      DeviceLocation position, EventLocation postPosition) async {
    log.i(
        'getPostDistanceFromUser | position: $position, postPosition: $postPosition');
    setState(ViewState.Busy);
    if (position != null) {
      double distanceInMeters = await _gps.getDistanceBetweenLocation(
        position.latitude,
        position.longitude,
        postPosition.latitude,
        postPosition.longitude,
      );

      distanceToEvent = distanceInMeters;
    } else {
      log.d('no location received');
    }
    setState(ViewState.Idle);
  }

  void selectFeedItem(BuildContext ctx, Post _post, String namedRoute) {
    log.i(
        'selectFeedItem | context: $ctx, post Id: ${_post.id}, namedRoute: $namedRoute');
    _navigationService.removeUntil(
      FeedItemDetailsScreen.routeName,
      arguments: FeedItemDetailScreenArguments(
        post: _post,
        returnPage: 1,
        referalPage: namedRoute,
      ),
    );
  }
}
