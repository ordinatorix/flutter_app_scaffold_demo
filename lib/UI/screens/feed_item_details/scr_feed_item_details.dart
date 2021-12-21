import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../base_view_screen.dart';

import 'item_card.dart';
import '../image_viewer/image_video_stack.dart';
import '../../widgets/empty_state.dart';

import '../../../enums/view_state.dart';

import 'mdl_feed_item_detail.dart';

import '../../../generated/i18n.dart';

import '../../../models/post.dart';

import '../../../logger.dart';

final log = getLogger('FeedItemDetailsScreen');

///TODO: increase size of image as card is being dragged down.
class FeedItemDetailsScreen extends StatelessWidget {
  static const routeName = '/feed-item-details';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    List<Post> repList = Provider.of<List<Post>>(context);
    log.i('building feed detail screen');

    return BaseView<FeedItemDetailViewModel>(
      onModelDisposing: (model) {
        model.disposer();
      },
      onModelReady: (model) {
        model.initializeModel(context);
      },
      builder: (context, model, child) {
        model.postData = repList;
        model.fetchFCMPost();

        final appBar = AppBar(
          // backgroundColor: Colors.transparent,
          // shadowColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: I18n.of(context).navigateBackToolTip,
            onPressed: model.onArrowBackButtonPressed,
          ),
          title: Text(
            I18n.of(context).feedItemDetailScreenTitle,
            style: Theme.of(context).textTheme.headline6,
          ),
          actions: <Widget>[
            model.referalPage != '/profile-settings' &&
                    (model.selectedPost.status == 'Rumored' ||
                        model.selectedPost.status == 'Confirmed')
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      // elevation: 5,
                      child: model.selectedPost.status == 'Confirmed'
                          ? Text(
                              I18n.of(context).feedItemDetailScreenClearButton)
                          : Text(I18n.of(context)
                              .feedItemDetailScreenVerifyButton),
                      onPressed: model.onActionButtonPressed,
                    ),
                  )
                : SizedBox(),
          ],
        );

        return WillPopScope(
          onWillPop: () async {
            model.onArrowBackButtonPressed();

            return Future.value(false);
          },
          child: Scaffold(
            // extendBodyBehindAppBar: true,
            key: model.scaffoldKey,
            appBar: appBar,
            body: model.selectedPost.id != null
                ? Container(
                    width: double.infinity,
                    child: Stack(
                      children: <Widget>[
                        model.selectedPost.imageUrlList.isNotEmpty
                            ? model.state == ViewState.Busy
                                ? Center(
                                    child: SpinKitCubeGrid(
                                      color: Theme.of(context).accentColor,
                                    ),
                                  )
                                : ImageVideoStack(
                                    imageFilterMatch: model.imageFilter
                                        .hasMatch(model
                                            .mediaList[model.localImageIndex]),
                                    videoFilterMatch: model.videoFilter
                                        .hasMatch(model
                                            .mediaList[model.localImageIndex]),
                                    currentIndex: model.localImageIndex,
                                    imageUrlList:
                                        model.selectedPost.imageUrlList,
                                    videoController: model.videoController,
                                  )
                            : ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: Image.asset(
                                  'assets/images/waiting.png',
                                  height: (mediaQuery.size.height -
                                          appBar.preferredSize.height -
                                          mediaQuery.padding.top) *
                                      0.73,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        ItemCard(
                          post: model.selectedPost,
                          mediaList: model.mediaList,
                          onSelectImage: model.onSelectImage,
                          loadingState: model.state == ViewState.Busy,
                        ),
                      ],
                    ),
                  )
                : EmptyState(
                    icon: Icons.error_outline,
                    iconText:
                        I18n.of(context).feedItemDetailScreenNoPostFound,
                  ),
          ),
        );
      },
    );
  }
}
