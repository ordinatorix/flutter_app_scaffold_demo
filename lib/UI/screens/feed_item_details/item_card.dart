import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/screens/feed_item_details/card_header.dart';
import 'package:flutter_scaffold/UI/screens/feed_item_details/img_scroller/image_scroller.dart';
import 'package:provider/provider.dart';

import '../../../models/post.dart';
import '../../../models/user.dart' show DeviceLocation;

import '../../../generated/i18n.dart';

import 'mdl_item_card.dart';

import '../../base_view_screen.dart';

import '../../../logger.dart';

final log = getLogger('ItemCard');

class ItemCard extends StatelessWidget {
  final Post post;
  final List mediaList;
  final Function(int) onSelectImage;
  final bool loadingState;

  ItemCard({
    this.post,
    this.mediaList,
    this.onSelectImage,
    this.loadingState,
  });

  @override
  Widget build(BuildContext context) {
    log.i('building Item card');

    final mediaQuery = MediaQuery.of(context);

    return BaseView<ItemCardViewModel>(
      onModelDisposing: (model) {
        model.disposer();
      },
      onModelReady: (model) {
        model.initializeModel(context, post);

        model.parseComments(post);
        model.streamedLocation =
            Provider.of<DeviceLocation>(context, listen: false);
        model.getDistance(post.location.latitude, post.location.longitude);
      },
      builder: (context, model, child) {
        return Provider.value(
          value: model.distanceToEvent,
          updateShouldNotify: (oldValue, newValue) => oldValue != newValue,
          child: DraggableScrollableSheet(
            initialChildSize: 0.6, //between 0.4 & 0.65
            minChildSize: 0.55, //0.32,
            maxChildSize: 0.98,
            builder: (context, _scrollController) {
              return LayoutBuilder(
                builder: (context, constraint) {
                  return Container(
                    // color: Colors.teal,
                    height: mediaQuery.size.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ImageScroller(
                            mediaList: mediaList,
                            onSelectImage: onSelectImage,
                            loadingState: loadingState,
                          ),
                        ),
                        Expanded(
                          child: Card(
                            margin: EdgeInsets.all(0),
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Container(
                                  // color: Colors.blue,
                                  height: mediaQuery.size.height * 0.8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: ItemCardHeader(
                                          event: post,
                                          titleTrans: model.titleTrans,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          // color: Colors.red,
                                          width: double.infinity,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        constraint.maxWidth *
                                                            0.05,
                                                    vertical:
                                                        mediaQuery.size.height *
                                                            0.01,
                                                  ),
                                                  child: Text(
                                                      I18n.of(context)
                                                          .feedItemDetailScreenEventCardComments,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        constraint.maxWidth *
                                                            0.05,
                                                  ),
                                                  child: Text(
                                                    model.comment,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        constraint.maxWidth *
                                                            0.05,
                                                    vertical:
                                                        mediaQuery.size.height *
                                                            0.01,
                                                  ),
                                                  child: Text(
                                                      I18n.of(context)
                                                          .feedItemDetailScreenEventCardTags,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: constraint.maxWidth *
                                                        0.05,
                                                    left: constraint.maxWidth *
                                                        0.05,
                                                    top:
                                                        mediaQuery.size.height *
                                                            0.01,
                                                    bottom:
                                                        constraint.maxWidth *
                                                            0.1,
                                                  ),
                                                  child: Text(
                                                    post.tags.join(', '),
                                                    softWrap: true,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'ID: ${post.id}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .overline,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
