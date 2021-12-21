import 'package:flutter/material.dart';

import '../../base_view_screen.dart';
import 'mdl_tag_option_selector.dart';
import '../../../logger.dart';

final log = getLogger('TagOptionSelector');

class TagOptionSelector extends StatelessWidget {
  final Map tagInfo;
  final Function showSnackbar;
  final String verificationType;
  final String stat;

  TagOptionSelector({
    @required this.tagInfo,
    @required this.showSnackbar,
    @required this.verificationType,
    @required this.stat,
  });

  @override
  Widget build(BuildContext context) {
    log.i('building tag option selector widget');
    return BaseView<TagOptionSelectorViewModel>(
      onModelReady: (model) {
        model.initializeModel(context);
      },
      builder: (context, model, child) {
        return Container(
          // color: Colors.red,
          height: 150,
          width: double.infinity,
          child: Center(
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
                model.getState(index, tagInfo['option$index']);
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
                          tagInfo['optionIcon$index'],
                          size: 51,
                        ),
                        Text(
                          tagInfo['optionTrans$index'],
                          textAlign: TextAlign.center,
                          // style: TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                    onTap: () {
                      model.onTagSelected(
                        context: context,
                        index: index,
                        tagInfo: tagInfo,
                        showSnackbar: showSnackbar,
                        verificationType: verificationType,
                        stat: stat,
                      );
                    },
                  ),
                );
              },
              itemCount:
                  // ((all tags) - (key values not containing "option"))-( (all tags) - (key values not containing "option"))/(differnt type of option)
                  // 9-9*2/3
                  ((tagInfo.length - 7) - ((tagInfo.length - 7) * 2) / 3)
                      .toInt(),
            ),
          ),
        );
      },
    );
  }
}
