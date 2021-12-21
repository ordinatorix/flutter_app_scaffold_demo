import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../base_view_screen.dart';

import 'mdl_image_video_stack.dart';

import '../../../logger.dart';

final log = getLogger('ImageVideoStack');

class ImageVideoStack extends StatelessWidget {
  final bool imageFilterMatch;
  final bool videoFilterMatch;
  final int currentIndex;
  final List imageUrlList; //change to media list

  final CachedVideoPlayerController videoController;
  ImageVideoStack({
    @required this.imageFilterMatch,
    @required this.videoFilterMatch,
    @required this.videoController,
    @required this.currentIndex,
    @required this.imageUrlList,
  });
  @override
  Widget build(BuildContext context) {
    log.i('building ImageVideoStack');

    final mediaQuery = MediaQuery.of(context);

    return BaseView<ImageVideoStackViewModel>(
      builder: (context, model, child) {
        return imageFilterMatch
            ? Container(
                width: double.infinity,
                height:
                    (mediaQuery.size.height - mediaQuery.padding.top) * 0.6,
                child: InkWell(
                  key: UniqueKey(),
                  onTap: () {
                    model.onImageButtonPressed(
                      imageUrlList: imageUrlList,
                      currentIndex: currentIndex,
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: imageUrlList[currentIndex],
                    fit: BoxFit.cover,
                    placeholder: (conext, url) => Container(
                      child: Center(
                        child: SpinKitCubeGrid(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: mediaQuery.size.width * 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : videoFilterMatch && videoController != null
                ? Stack(
                    alignment: AlignmentDirectional.topCenter,
                    fit: StackFit.expand,
                    children: [
                      AspectRatio(
                        aspectRatio: videoController.value.size != null
                            ? videoController.value.aspectRatio
                            : mediaQuery.size.width / mediaQuery.size.height,
                        child: CachedVideoPlayer(videoController),
                      ),
                      model.showVideoButtons
                          ? Container(
                              height: mediaQuery.size.height * 0.73,
                              width: mediaQuery.size.width,
                              color: !model.showVideoButtons
                                  ? Colors.transparent
                                  : Colors.black38,
                              child: Stack(
                                children: [
                                  Container(
                                    width: mediaQuery.size.width,
                                    height: mediaQuery.size.height * 0.5,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        videoController.value.isPlaying
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_filled,
                                        color: Colors.white60,
                                        size: 70,
                                      ),
                                      onPressed: () =>
                                          model.onVideoButtonPressed(
                                        videoController,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          videoController.value.volume == 0.0
                                              ? Icons.volume_off
                                              : Icons.volume_up,
                                          color: Colors.white60,
                                        ),
                                        onPressed: () =>
                                            model.onMuteButtonPressed(
                                          videoController,
                                        ),
                                      ),
                                      //TODO: unable fullscreen iconbutton
                                       
                                      // Spacer(),
                                      // IconButton(
                                      //   icon: Icon(
                                      //     Icons.fullscreen,
                                      //     color: Colors.white60,
                                      //   ),
                                      //   onPressed: () =>
                                      //       model.onFullScreenButtonPressed(),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              key: UniqueKey(),
                              onTap: () => model.onShowVideoButtonPressed(),
                            ),
                    ],
                  )
                : Center(
                    child: SpinKitCubeGrid(
                      color: Theme.of(context).accentColor,
                    ),
                  );
      },
    );
  }
}
