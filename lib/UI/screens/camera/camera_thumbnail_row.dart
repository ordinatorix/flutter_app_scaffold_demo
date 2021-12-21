import 'dart:io';
import 'package:flutter/material.dart';
import '../../../logger.dart';

final log = getLogger('CameraThumbnailRow');

class CameraThumbnailRow extends StatelessWidget {
  final List thumbnailPathList;
  final Function onUnseleceMediaHandler;
  final RegExp thumbnailFilter;

  CameraThumbnailRow({
    this.thumbnailPathList,
    this.onUnseleceMediaHandler,
    @required this.thumbnailFilter,
  });
  @override
  Widget build(BuildContext context) {
    log.d('building thumbnail widget');
    log.d('thumbnail list: $thumbnailPathList');
    final mediaQuery = MediaQuery.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          color: Colors.black45,
          width: mediaQuery.size.width,
          height: 64.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2.5,
                  vertical: 2.5,
                ),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      color: Colors.black26,
                      height: mediaQuery.size.width * 0.2,
                      width: mediaQuery.size.width * 0.2,
                      child: Image.file(
                        File(thumbnailPathList[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: thumbnailFilter.hasMatch(thumbnailPathList[index])
                          ? Icon(
                              Icons.videocam,
                              color: Colors.white,
                            )
                          : Container(),
                    ),
                    InkWell(
                      onTap: () {
                        onUnseleceMediaHandler(index);
                      },
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: mediaQuery.size.width * 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            itemCount: thumbnailPathList.length,
          ),
        ),
      ],
    );
  }
}
