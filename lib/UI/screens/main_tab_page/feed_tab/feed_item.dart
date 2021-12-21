import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/base_view_screen.dart';
import 'package:flutter_scaffold/UI/widgets/date_formater/date_formater.dart';
import 'package:flutter_scaffold/UI/widgets/card_status.dart';
import 'package:flutter_scaffold/logger.dart';
import 'package:flutter_scaffold/models/post.dart';
import 'package:flutter_scaffold/models/user.dart' show DeviceLocation;
import 'package:provider/provider.dart';

import 'mdl_feed_item.dart';

final log = getLogger('FeedItem');

class FeedItem extends StatelessWidget {
  final Post post;

  FeedItem({
    this.post,
  });

  @override
  Widget build(BuildContext context) {
    log.i('building feed item');

    final String namedRoute = ModalRoute.of(context).settings.name;

    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return BaseView<FeedItemModel>(
      onModelReady: (model) {
        model.initializeModel(context, post);
        model.coordList = Provider.of<DeviceLocation>(context, listen: false);
        model.getPostDistanceFromUser(model.coordList, post.location);
      },
      builder: (context, model, child) {
        return Provider.value(
          // Provide the distance value to children widgets that are listenning
          value: model.distanceToEvent,
          updateShouldNotify: (oldValue, newValue) {
            return oldValue != newValue;
          },
          child: LayoutBuilder(
            builder: (ctx, constraint) {
              return Container(
                // color: Colors.white,
                padding: EdgeInsets.all(5),

                width: double.infinity,
                child: InkWell(
                  child: Card(
                    color: Theme.of(context).cardColor,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                            top: mediaQuery.size.height * 0.01,
                          ),
                          decoration: BoxDecoration(
                              // color: Colors.green,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(30)),
                          width: double.infinity,
                          // height: mediaQuery.size.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                // color: Colors.pink,
                                width: constraint.maxWidth * 0.6,
                                padding: EdgeInsets.only(
                                  left: constraint.maxWidth * 0.05,
                                  right: constraint.maxWidth * 0.05,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    DateFormater(
                                      eventTimestamp: post.timestamp,
                                      showDistance: true,
                                    ),
                                    Text(
                                      '${post.namedLocation}',
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                // color: Colors.purple,
                                width: constraint.maxWidth * 0.3,
                                child: CardStatus(
                                  status: post.status,
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          endIndent: constraint.maxWidth * 0.05,
                          indent: constraint.maxWidth * 0.05,
                          color: Theme.of(context).accentColor,
                          thickness: 1,
                        ),
                        Text(
                          model.titleTrans.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            post.tags.join(', '),
                            softWrap: true,
                            style: Theme.of(context).textTheme.subtitle2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    model.selectFeedItem(context, post, namedRoute);
                    model.logAnalyticsViewItem(
                        post.title, 'post', post.id);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
