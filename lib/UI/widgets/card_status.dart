import 'package:flutter/material.dart';

import '../../generated/i18n.dart';

import '../../logger.dart';

final log = getLogger('CardStatus');

class CardStatus extends StatelessWidget {
  final String status;

  CardStatus({
    @required this.status,
  });

  @override
  Widget build(BuildContext context) {
    log.i('building Card status widget');
    return LayoutBuilder(
      builder: (ctx, constraint) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              // color: Colors.cyanAccent,
              width: constraint.maxWidth * 0.6,
              child: status == 'Rumored'
                  ? Text(
                      I18n.of(context).feedScreenRumoredOngoing,
                      style: Theme.of(context).textTheme.bodyText2,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                    )
                  : status == 'Confirmed'
                      ? Text(
                          I18n.of(context).feedScreenConfirmedOngoing,
                          style: Theme.of(context).textTheme.bodyText2,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.center,
                        )
                      : status == 'Cleared'
                          ? Text(
                              I18n.of(context).feedScreenAreaCleared,
                              style: Theme.of(context).textTheme.bodyText2,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                            )
                          : status == 'Fake'
                              ? Text(
                                  I18n.of(context).feedScreenFake,
                                  style: Theme.of(context).textTheme.bodyText2,
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  I18n.of(context).feedScreenUnclear,
                                  style: Theme.of(context).textTheme.bodyText2,
                                  softWrap: true,
                                  overflow: TextOverflow.fade,
                                  textAlign: TextAlign.center,
                                ),
            ),
            Container(
              // color: Colors.tealAccent,
              width: constraint.maxWidth * 0.3,
              child: status == 'Rumored'
                  ? Icon(
                      Icons.help,
                      color: Colors.yellow,
                      size: 35,
                    )
                  : status == 'Confirmed'
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.red,
                          size: 35,
                        )
                      : status == 'Cleared'
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 35,
                            )
                          : Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 35,
                            ),
            ),
            Spacer(),
          ],
        );
      },
    );
  }
}
