import 'package:flutter/material.dart';

import '../../../enums/status_option.dart';
import '../../../generated/i18n.dart';
import 'mdl_status_updater.dart';
import '../../../logger.dart';

final log = getLogger('StatusUpdater');

class StatusUpdater extends StatefulWidget {
  final Map tagInfo;
  final String status;
  final Function statusHandler;

  StatusUpdater({
    @required this.status,
    @required this.tagInfo,
    @required this.statusHandler,
  });

  @override
  _StatusUpdaterState createState() => _StatusUpdaterState();
}

class _StatusUpdaterState extends State<StatusUpdater> {
  final model = StatusUpdaterViewModel();

  @override
  Widget build(BuildContext context) {
    log.i('rebuilding status updater widget');
    model.initializeModel(context, widget.status);

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              widget.tagInfo['icon'],
              size: 78,
              color: Theme.of(context).accentColor,
            ),
          ),
          DropdownButton(
            onChanged: (StatusOptions selectedValue) {
              setState(() {
                model.onDropDownButtonTap(selectedValue, widget.statusHandler);
              });
            },
            hint: Center(
                child: Text(
              I18n.of(context).postEditScreenStatus,
            )),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).accentColor,
            ),
            value: model.dropDownValue,
            items: model.originalStatus == 'Confirmed'
                ? model.option0
                : model.option1,
          ),
        ],
      ),
    );
  }
}
