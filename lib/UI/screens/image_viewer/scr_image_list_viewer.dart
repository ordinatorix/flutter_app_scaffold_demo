// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('ImageListViewerScreen');

class ImageListViewerScreen extends StatefulWidget {
  static const routeName = '/image-list-viewer';

  @override
  _ImageListViewerScreenState createState() => _ImageListViewerScreenState();
}

class _ImageListViewerScreenState extends State<ImageListViewerScreen> {
  bool _showAppBar = true;
//  TODO: implement
  // void _showAppBarWidget() {
  //   print('_showAppBarWidget');
  //   setState(() {
  //     _showAppBar = true;
  //   });
  //   Timer(Duration(seconds: 5), _hideAppBarWidget);
  // }

  // void _hideAppBarWidget() {
  //   print('_hideAppBarWidget');
  //   if (mounted) {
  //     setState(() {
  //       _showAppBar = false;
  //     });
  //   }
  // }

  /// TODO: finish hide appbar logic
  /// tap only happens around the edges
  /// bug posted and being fixed

  @override
  Widget build(BuildContext context) {
    log.i('building ImageListViewerScreen');
    Map args = ModalRoute.of(context).settings.arguments;
    List imageList = args['imgList'];
    int firstPage = args['currentIndex'];

    PageController _pageController = PageController(initialPage: firstPage);
    return Scaffold(
      appBar: _showAppBar
          ? AppBar(
              title: Text(
                I18n.of(context).imageListViewerScreenTitle,
                style: Theme.of(context).textTheme.headline6,
              ),
            )
          : null,
      body: Container(
        // color: Colors.red,
        child: PhotoViewGallery.builder(
          // onPageChanged: (int index) {
          //   log.d('new page: index: $index');
          //   if (index - 1 > imageList.length) {
          //     log.d('navigate to a diferent view');
          //   }
          // },
          scrollPhysics: const BouncingScrollPhysics(),
          pageController: _pageController,
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              // onTapDown: (context, details, value) {
              //   log.d('PhotoViewGalery tapdown');
              //   log.d('context: $context');
              //   log.d('details global position: ${details.globalPosition}');
              //   log.d('details kind: ${details.kind}');
              //   log.d('details local position: ${details.localPosition}');
              //   log.d('value: $value');
              //   // TODO: fix issue when bug is resolved
              //   //   _showAppBarWidget();
              // },
              imageProvider: CachedNetworkImageProvider(imageList[index]),
              initialScale: PhotoViewComputedScale.contained * 1,
              minScale: PhotoViewComputedScale.contained * 0.9,
              maxScale: PhotoViewComputedScale.contained * 3,
              // heroAttributes: PhotoViewHeroAttributes(tag: imageList[index]),
            );
          },
          itemCount: imageList.length,
          loadingBuilder: (context, progress) => Center(
            child: Center(
              child: SpinKitCubeGrid(
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
          backgroundDecoration: BoxDecoration(color: Colors.black54),
        ),
      ),
    );
  }
}
