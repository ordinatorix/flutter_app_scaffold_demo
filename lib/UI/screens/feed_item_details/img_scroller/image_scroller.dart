import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_scaffold/UI/base_view_screen.dart';
import 'package:flutter_scaffold/logger.dart';

import 'mdl_image_scroller.dart';

final log = getLogger('ImageScroller');

class ImageScroller extends StatelessWidget {
  final List mediaList;
  final Function(int) onSelectImage;
  final bool loadingState;

  ImageScroller({this.mediaList, this.onSelectImage, this.loadingState});

  @override
  Widget build(BuildContext context) {
    log.i('building imagescroller');
    final mediaQuery = MediaQuery.of(context);
    return BaseView<ImageScrollerViewModel>(onModelReady: (model) {
      model.initializeModel(mediaList);
    }, builder: (context, model, child) {
      return Container(
        height: mediaQuery.size.height * 0.065,
        width: mediaQuery.size.width,
        child: ListView.builder(
          key: Key(Random(20).toString()),
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            return Padding(
              padding: EdgeInsets.only(
                left: 10,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  border: Border.all(
                      color: model.selectedIndex != index
                          ? Colors.white
                          : Theme.of(context).accentColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                width: mediaQuery.size.width * 0.125,
                child: InkWell(
                  onTap: () {
                    model.onImageTap(index, onSelectImage, loadingState);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: model.imageFilter.hasMatch(model.scrollerList[index])
                        ? CachedNetworkImage(
                            imageUrl: model.scrollerList[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                            errorWidget: (context, url, error) {
                              log.e('error caching network image: $error');
                              return Container(
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                  ),
                                ),
                              );
                            })
                        : model.mapFilter.hasMatch(model.scrollerList[index])
                            ? Icon(
                                Icons.location_on,
                                color: Colors.white,
                              )
                            : model.thumbnailFilter
                                    .hasMatch(model.scrollerList[index])
                                ? Image.file(
                                    File(model.scrollerList[index]),
                                  )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),
                  ),
                ),
              ),
            );
          },
          itemCount: model.scrollerList.length,
        ),
      );
    });
  }
}
