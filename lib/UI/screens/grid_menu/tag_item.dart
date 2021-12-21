import 'package:flutter/material.dart';

import '../post_edit/scr_post_edit.dart';

import '../../../services/navigation_service.dart';
import '../../../services/analytics_service.dart';

import '../../../models/post.dart' show EventLocation;

import '../../../helpers/post_screen_arguments.dart';

import '../../../locator.dart';
import '../../../logger.dart';

final log = getLogger('TagItem');

class TagItem extends StatefulWidget {
  final Map<String, dynamic> tagMap;

  final EventLocation selectedLocation;

  TagItem({
    this.tagMap,
    this.selectedLocation,
  });

  @override
  _TagItemState createState() => _TagItemState();
}

class _TagItemState extends State<TagItem> {
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  @override
  Widget build(BuildContext context) {
    log.i('build tag item widget');
    return Container(
      // height: 30,
      // color: Colors.green.withOpacity(0.5),
      child: IconButton(
        color: Theme.of(context).accentColor,
        iconSize: 60,
        alignment: Alignment.topCenter,
        icon: Container(
          // color: Colors.blue,
          // height: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.tagMap['icon']),
              Text(
                widget.tagMap['titleTrans'],
                textAlign: TextAlign.center,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
        tooltip: widget.tagMap['titleTrans'],
        onPressed: () {
          _analyticsService.logSelectContent(
              contentType: 'event_post', itemId: widget.tagMap['title']);
          _navigationService.navigateTo(PostEditScreen.routeName,
              arguments: PostEditScreenArguments(
                tags: widget.tagMap,
                selectedLocation: widget.selectedLocation,
              ));
        },
      ),
    );
  }
}
