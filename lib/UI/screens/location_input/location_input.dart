import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../models/post.dart' show EventLocation;

import 'mdl_location_input.dart';

import '../../base_view_screen.dart';

import '../../../enums/view_state.dart';

import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('LocationInput');

class LocationInput extends StatelessWidget {
  final Function onSelectPlace;
  final EventLocation initGpsPosition;
  LocationInput({
    this.onSelectPlace,
    this.initGpsPosition,
  });

  @override
  Widget build(BuildContext context) {
    log.i('building location input');
    final mediaQuery = MediaQuery.of(context);

    return BaseView<LocationInputViewModel>(
      onModelReady: (model) {
        model.initializeModel(initGpsPosition);
      },
      builder: (context, model, child) {
        return model.state == ViewState.Busy
            ? Center(
                child: SpinKitCubeGrid(
                  color: Theme.of(context).accentColor,
                ),
              )
            : Container(
                height: (mediaQuery.size.height - mediaQuery.padding.top) * 0.3,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                child: model.previewImageUrl == null
                    ? Text(
                        I18n.of(context).postEditScreenNoLocationChosen,
                        textAlign: TextAlign.center,
                      )
                    : InkWell(
                        child: Stack(children: <Widget>[
                          Image.network(
                            model.previewImageUrl,
                            key: ValueKey(new Random().nextInt(100)),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace stackTrace) {
                              log.e(
                                  'error occured while showing map image: $exception; trace: $stackTrace, link: ${model.previewImageUrl}');
                              return Center(child: Text('😢'));
                            },
                          ),
                          Container(
                            width: double.infinity,
                            color: Colors.black38,
                            child: Text(
                              I18n.of(context)
                                  .postEditScreenTapToModifyLocation,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ]),
                        onTap: () {
                          model.selectOnMap(context, onSelectPlace);
                        },
                      ),
              );
      },
    );
  }
}
