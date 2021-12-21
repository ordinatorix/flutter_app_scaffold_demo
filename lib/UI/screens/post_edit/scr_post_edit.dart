import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base_view_screen.dart';

import '../location_input/location_input.dart';
import 'status_updater.dart';
import '../../widgets/badge.dart';
import 'post_edit_scr_loader.dart';

import '../../../models/user.dart';
import '../../../models/post.dart';

import 'mdl_post_edit.dart';

import '../../../enums/view_state.dart';

import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('PostEditScreen');

class PostEditScreen extends StatelessWidget {
  static const routeName = '/post-edit-screen';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    ModalRoute modalRoute = ModalRoute.of(context);
    log.i('building post edit screen');

    return BaseView<PostEditScreenModel>(
      onModelDisposing: (model) {
        model.disposer(context);
      },
      onModelReady: (model) {
        model.authUser = Provider.of<User>(context);

        model.args = ModalRoute.of(context).settings.arguments;

        model.tagsList = TagList().getTagList(context: context);

        model.initializeModel();
      },
      onModelDependencyChange: (model) {
        model.currentLocation = Provider.of<DeviceLocation>(context);//TODO: review this stream

        log.d('resetting locations depend ');
        model.updatePublisherLocation();
        model.setLocations();
      },
      onModelUpdate: (model) {
        model.currentLocation = Provider.of<DeviceLocation>(context);
        log.d('current location: ${model.currentLocation}');
        log.d('showEmptyState: ${model.showEmptyState}');
        model.updatePublisherLocation();
        if (model.showEmptyState) {
          // only set locations on update if showEmptyState is true
          log.d('resetting locations');
          model.setLocations();
        }

        // log.wtf('scaffold ket in update: ${model.scaffoldKey.currentState}');
      },
      builder: (context, model, child) {
        log.d('building post edit screen consumer');

        final _appBar = AppBar(
          title: Text(
            model.tagInfo['titleTrans'],
            style: Theme.of(context).textTheme.headline6,
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                tooltip: I18n.of(context).closePageToolTip,
                onPressed: () {
                  model.onClosePage();
                })
          ],
        );
        return WillPopScope(
          onWillPop: () {
            if (!modalRoute.canPop) {
              return model.onWillPop();
            } else {
              return Future.value(true);
            }
          },
          child: ScaffoldMessenger(
            key: model.scaffoldMessengerKey,
            child: Scaffold(
              // key: model.scaffoldMessengerKey,
              appBar: _appBar,
              body: model.state == ViewState.Busy
                  ? Center(
                      child: Consumer<UploadProgress>(
                        builder: (context, uploadProgress, _) {
                          return PostEditScreenLoader(
                            mediaQuery: mediaQuery,
                            uploadProgress: uploadProgress,
                            showEmptyState: model.showEmptyState,
                          );
                        },
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: model.post != null
                              ? StatusUpdater(
                                  status: model.stat,
                                  tagInfo: model.tagInfo,
                                  statusHandler: model.changeStatusValue,
                                )
                              : LocationInput(
                                  onSelectPlace: model.setEventLocation,
                                  initGpsPosition: model.displayLocation,
                                ),
                        ),
                        Container(
                          width: mediaQuery.size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              //check the tagInfo keys to know if the selected tag contains any option
                              model.tagInfo.keys.contains('option0')
                                  ? Container(
                                      decoration: BoxDecoration(
                                        // color: Colors.green,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey[400],
                                          ),
                                          right: BorderSide(
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      height: (mediaQuery.size.height -
                                              mediaQuery.padding.top -
                                              _appBar.preferredSize.height) *
                                          0.15,
                                      width: mediaQuery.size.width * 0.37,
                                      child: TextButton(
                                        onPressed: () {
                                          model.showTagBottomSheet(
                                            showTagWidget: true,
                                            context: context,
                                            screenSize: mediaQuery.size,
                                          );
                                        },
                                        child: Container(
                                          // color: Colors.red,
                                          constraints: BoxConstraints(
                                              maxWidth: mediaQuery.size.width *
                                                  0.37 // set a correct maxWidth
                                              ),
                                          child: Text(
                                            I18n.of(context)
                                                .postEditScreenAddTagsButton,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                            ),
                                            overflow: TextOverflow.fade,
                                            // softWrap: true,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),

                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                  height: (mediaQuery.size.height -
                                          mediaQuery.padding.top -
                                          _appBar.preferredSize.height) *
                                      0.15,
                                  child: TextButton(
                                    onPressed: () {
                                      model.showTagBottomSheet(
                                        showTagWidget: false,
                                        context: context,
                                        screenSize: mediaQuery.size,
                                      );
                                    },
                                    child: Container(
                                      // color: Colors.red,
                                      constraints: BoxConstraints(
                                          maxWidth: mediaQuery.size.width *
                                              0.37 // set a correct maxWidth
                                          ),
                                      child: Text(
                                        I18n.of(context)
                                            .postEditScreenAddEmergencyServices,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: mediaQuery.size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[400],
                                    ),
                                    right: BorderSide(
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                                height: (mediaQuery.size.height -
                                        mediaQuery.padding.top -
                                        _appBar.preferredSize.height) *
                                    0.15,
                                width: mediaQuery.size.width * 0.37,
                                child: Center(
                                  child: model.mediaPathList.length == 0
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.camera_alt,
                                            color: Colors.grey[400],
                                            size: 30,
                                          ),
                                          tooltip: I18n.of(context)
                                              .postEditScreenOpenCameraToolTip,
                                          onPressed: () {
                                            model
                                                .onCameraButtonPressed(context);
                                          },
                                        )
                                      : Badge(
                                          value:
                                              '${model.mediaPathList.length}',
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.camera_alt,
                                              color: Colors.grey[400],
                                              size: 30,
                                            ),
                                            tooltip: I18n.of(context)
                                                .postEditScreenOpenCameraToolTip,
                                            onPressed: () {
                                              model.onCameraButtonPressed(
                                                  context);
                                            },
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                  height: (mediaQuery.size.height -
                                          mediaQuery.padding.top -
                                          _appBar.preferredSize.height) *
                                      0.15,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      model.onCommentButtonPressed(context);
                                    },
                                    icon: Icon(
                                      Icons.comment,
                                      color: Colors.grey[400],
                                      size: 30,
                                    ),
                                    label: Flexible(
                                      fit: FlexFit.loose,
                                      child: Container(
                                        // color: Colors.red,
                                        constraints: BoxConstraints(
                                            maxWidth: mediaQuery.size.width *
                                                0.4 // set a correct maxWidth
                                            ),
                                        child: Text(
                                          model.postComment != null
                                              ? model.postComment[0]['text']
                                              : I18n.of(context)
                                                  .postEditScreenCommentButton,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              color: Colors.grey[400]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              persistentFooterButtons: model.state == ViewState.Idle
                  ? <Widget>[
                      Container(
                        height: (mediaQuery.size.height -
                                mediaQuery.padding.top -
                                _appBar.preferredSize.height) *
                            0.13,
                        width: mediaQuery.size.width,
                        child: ElevatedButton.icon(
                          // padding: EdgeInsets.all(10),
                          onPressed: () {
                            model.onSubmitButtonPressed(context);
                          },
                          icon: Icon(
                            Icons.cloud_upload,
                          ),
                          label: Text(
                            I18n.of(context).postEditScreenSubmitButton,
                          ),
                        ),
                      )
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }
}
