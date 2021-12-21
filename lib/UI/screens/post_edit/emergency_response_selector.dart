import 'package:flutter/material.dart';

import '../../base_view_screen.dart';
import 'mdl_emergency_response_selector.dart';
import '../../../logger.dart';

final log = getLogger('EmergencyResponseSelector');

class EmergencyResponseSelector extends StatelessWidget {
  final String verificationType;
  final String stat;
  final String title;

  EmergencyResponseSelector({
    @required this.verificationType,
    @required this.stat,
    @required this.title,
  });
  @override
  Widget build(BuildContext context) {
    log.i('building Emergency Response Selector');
    return BaseView<EmergencyResponseSelectorViewModel>(
      onModelReady: (model) {
        model.initializeModel(context);
      },
      builder: (context, model, child) {
        return Container(
          height: 150,
          child: ListView.separated(
            separatorBuilder: (context, index) => Container(
              height: 150,
              child: VerticalDivider(
                color: Colors.grey[400],
              ),
            ),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              model.getState(index);
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.5),
                color: model.options[index]['state']
                    ? Theme.of(context).accentColor.withOpacity(0.4)
                    : null,
                height: 100,
                width: 100,
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        model.options[index]['icon'],
                      ),
                      Text(
                        model.options[index]['titleTrans'],
                        textAlign: TextAlign.center,
                        // style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                  onTap: () {
                    model.onTagSelected(
                      index: index,
                      verificationType: verificationType,
                      stat: stat,
                      title: title,
                    );
                  },
                ),
              );
            },
            itemCount: model.options.length,
          ),
        );
      },
    );
  }
}
