
import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/base_view_screen.dart';
import 'package:flutter_scaffold/UI/widgets/date_formater/date_formater_view_model.dart';
import 'package:intl/intl.dart';

import '../../../generated/i18n.dart';
import '../../../logger.dart';

final log = getLogger('DateFormater');

class DateFormater extends StatelessWidget {
  final DateTime eventTimestamp;
  final bool showDistance;

  DateFormater(
      {@required this.eventTimestamp, @required this.showDistance});

  @override
  Widget build(BuildContext context) {
    log.i('building post_date_formater');

    return BaseView<DateFormaterViewModel>(
      builder: (context, model, child) {
        model.getTimeDifference(eventTimestamp);
        model.convertDistanceUnits(context, showDistance);

        return model.dayDifference > 3
            // more than 3 days old
            ? Text(
                model.distanceInMeters == null
                    ? '${DateFormat.yMMMd().format(eventTimestamp)}'
                    : '${DateFormat.yMMMd().format(eventTimestamp)} - ${model.displayedDistance}',
                style: Theme.of(context).textTheme.subtitle1,
                // textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.fade,
              )
            : model.dayDifference <= 3 && model.dayDifference > 1

                // between 1 and 3 days old
                ? Text(
                    model.distanceInMeters == null
                        ? I18n.of(context)
                            .feedScreenDayAgo(model.dayDifference.toString())
                        : '${I18n.of(context).feedScreenDayAgo(model.dayDifference.toString())} - ${model.displayedDistance}',
                    style: Theme.of(context).textTheme.subtitle1,
                    // textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                  )
                :
                // 1 day old
                model.dayDifference == 1
                    ? Text(
                        model.distanceInMeters == null
                            ? I18n.of(context).feedScreenYesterday
                            : '${I18n.of(context).feedScreenYesterday} - ${model.displayedDistance}',
                        style: Theme.of(context).textTheme.subtitle1,
                        // textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      )
                    : model.hourDifference < 24 && model.minuteDifference >= 60
                        // between 1 & 23:59 h
                        ? Text(
                            model.distanceInMeters == null
                                ? I18n.of(context).feedScreenHoursAgo(
                                    model.hourDifference.toString())
                                : '${I18n.of(context).feedScreenHoursAgo(model.hourDifference.toString())} - ${model.displayedDistance}',
                            style: Theme.of(context).textTheme.subtitle1,
                            // textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          )
                        : model.minuteDifference < 60 &&
                                model.secondDifference >= 60
                            // between 1 & 60 minutes
                            ? Text(
                                model.distanceInMeters == null
                                    ? I18n.of(context).feedScreenMinutesAgo(
                                        model.minuteDifference.toString())
                                    : '${I18n.of(context).feedScreenMinutesAgo(model.minuteDifference.toString())} - ${model.displayedDistance}',
                                style: Theme.of(context).textTheme.subtitle1,
                                // textAlign: TextAlign.center,
                                softWrap: true,
                                overflow: TextOverflow.fade,
                              )
                            : model.secondDifference > 1 &&
                                    model.secondDifference < 60
                                // between 1 && 60 seconds
                                ? Text(
                                    model.distanceInMeters == null
                                        ? I18n.of(context).feedScreenSecondsAgo(
                                            model.secondDifference.toString())
                                        : '${I18n.of(context).feedScreenSecondsAgo(model.secondDifference.toString())} - ${model.displayedDistance}',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                    // textAlign: TextAlign.center,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                  )
                                :
                                // negative time
                                Text(
                                    model.distanceInMeters == null
                                        ? I18n.of(context).feedScreenNow
                                        : '${I18n.of(context).feedScreenNow} - ${model.displayedDistance}',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                    // textAlign: TextAlign.center,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                  );
      },
    );
  }
}
