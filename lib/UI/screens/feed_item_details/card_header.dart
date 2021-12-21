import 'package:flutter/material.dart';

import '../../widgets/card_status.dart';
import '../../widgets/date_formater/date_formater.dart';
import '../../../models/post.dart';
import '../../../logger.dart';

final log = getLogger('ItemCardHeader');

class ItemCardHeader extends StatelessWidget {
  final Post event;
  final String titleTrans;

  ItemCardHeader({
    @required this.event,
    @required this.titleTrans,
  });

  @override
  Widget build(BuildContext context) {
    log.i('building Itemcard header');
    final mediaQuery = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (ctx, constraint) {
        return Column(
          children: <Widget>[
            Divider(
              // color: Colors.red,
              thickness: 2,
              indent: constraint.maxWidth * 0.4,
              endIndent: constraint.maxWidth * 0.4,
            ),
            Container(
              decoration: BoxDecoration(
                  // color: Colors.green,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(30)),
              width: double.infinity,
              child: Row(
                children: <Widget>[
                  Container(
                    // color: Colors.pink,
                    width: constraint.maxWidth * 0.6,
                    padding: EdgeInsets.only(
                      left: constraint.maxWidth * 0.05,
                    ),
                    child: DateFormater(
                      eventTimestamp: event.timestamp,
                      showDistance: true,
                    ),
                  ),
                  Container(
                    // color: Colors.purple,
                    width: constraint.maxWidth * 0.4,
                    child: CardStatus(
                      status: event.status,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: constraint.maxWidth * 0.05,
                left: constraint.maxWidth * 0.05,
                top: mediaQuery.size.height * 0.01,
              ),
              child: Text(
                titleTrans.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: constraint.maxWidth * 0.05,
                left: constraint.maxWidth * 0.05,
                top: mediaQuery.size.height * 0.01,
              ),
              child: Text(
                '${event.namedLocation}',
                style: Theme.of(context).textTheme.bodyText2,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Divider(
              color: Theme.of(context).accentColor,
              indent: constraint.maxWidth * 0.05,
              endIndent: constraint.maxWidth * 0.05,
              thickness: 3,
            ),
          ],
        );
      },
    );
  }
}
