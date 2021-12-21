import 'package:flutter/material.dart';

import 'tag_item.dart';

import '../../../models/user.dart';
import '../../../models/post.dart' show EventLocation;

import '../../../logger.dart';

final log = getLogger('MenuTag');

class MenuTag extends StatefulWidget {
  final List<Map<String, dynamic>> tagsList;
  final AppBar appBar;
  final User authUser;
  final EventLocation selectedLocation;
  MenuTag({
    @required this.tagsList,
    @required this.appBar,
    @required this.authUser,
    this.selectedLocation,
  });

  @override
  _MenuTagState createState() => _MenuTagState();
}

class _MenuTagState extends State<MenuTag> {
  @override
  Widget build(BuildContext context) {
    log.i('building post tag widget');

    final mediaQuery = MediaQuery.of(context);

    return GridView.builder(
      padding: const EdgeInsets.only(top: 10, right: 15, left: 15),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: mediaQuery.size.width / 3,
        // childAspectRatio: mediaQuery.size.aspectRatio * 1.35,
        mainAxisSpacing: 1,
        // crossAxisSpacing: mediaQuery.size.width * 0.04,
      ),
      itemBuilder: (ctx, index) => TagItem(
        tagMap: widget.tagsList[index],
        selectedLocation: widget.selectedLocation,
      ),
      itemCount: widget.tagsList.length,
    );
  }
}
