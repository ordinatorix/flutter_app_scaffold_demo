import 'package:flutter_scaffold/locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../base_model.dart';
import '../../../enums/view_state.dart';
import '../../../models/post.dart';
import '../../../models/user.dart' show DeviceLocation;
import '../../../services/location_service.dart';
import '../../../logger.dart';

final log = getLogger('ItemCardViewModel');

class ItemCardViewModel extends BaseModel {
  final LocationService gps = locator<LocationService>();
  // ScrollController scrollController;

  double distanceToEvent;

  String comment = '';
  List alerts;
  String titleTrans;
  DeviceLocation streamedLocation;

  void initializeModel(BuildContext context, Post post) {
    log.i('initializeModel | context: $context, post title: ${post.title}');
    alerts = TagList().getTagList(context: context);
    titleTrans = alerts
        .firstWhere((map) => map.containsValue(post.title))['titleTrans'];
    // scrollController = ScrollController();
  }

  void disposer() {
    log.i('disposer');
    //  _scrollController.dispose();
  }

  void parseComments(Post post) {
    log.i('parseComments | post: ${post.comment}');
    var sortedComments = post.comment;
    sortedComments.sort((a, b) {
      var aparse = DateTime.parse(a['timestamp'].toDate().toString())
          .compareTo(DateTime.parse(b['timestamp'].toDate().toString()));

      return aparse;
    });

    sortedComments.forEach((_comment) {
      DateTime parsedDate =
          DateTime.parse(_comment['timestamp'].toDate().toString());
      String formatedDate = DateFormat.Hm().format(parsedDate);

      comment = comment + '[$formatedDate]: ' + '${_comment['text']} \n';
    });
  }

  void getDistance(double latitude, double longitude) async {
    log.i('getDistance | latitude: $latitude, longitude: $longitude');
    setState(ViewState.Busy);
    if (streamedLocation != null) {
      var distanceInMeters = await gps.getDistanceBetweenLocation(
          // TODO: figure out setter/ getter
          streamedLocation.latitude,
          streamedLocation.longitude,
          latitude,
          longitude);

      distanceToEvent = distanceInMeters;
    } else {
      log.d('no location received');
    }
    setState(ViewState.Idle);
  }
}
