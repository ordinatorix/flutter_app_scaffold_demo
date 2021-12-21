import 'dart:io';

import 'package:flutter/material.dart';
import '../../../generated/i18n.dart';

class CameraProfilePictureDisplay extends StatelessWidget {
  final String imageTaken;
  final Function retakeProfilePictureHandler;
  final Function cancelProfilePictureHandler;
  final Function saveProfilePictureHandler;

  CameraProfilePictureDisplay({
    @required this.imageTaken,
    @required this.retakeProfilePictureHandler,
    @required this.saveProfilePictureHandler,
    @required this.cancelProfilePictureHandler,
  });
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Stack(
      children: [
        Container(
          height: mediaQuery.size.height,
          width: double.infinity,
          child: Center(
            child: Image.file(
              File(imageTaken),
              filterQuality: FilterQuality.high,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
          child: Align(
            alignment: Alignment.center,
            child: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(
                  Icons.replay,
                  color: Colors.white,
                  size: 50,
                ),
                onPressed: retakeProfilePictureHandler),
          ),
        ),
        Positioned(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  onPressed: cancelProfilePictureHandler,
                  child: Text(
                    I18n.of(context).buttonsCancelButton,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  // color: Colors.white,
                  onPressed: saveProfilePictureHandler,
                  child: Text(
                    I18n.of(context).buttonsSaveButton,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
