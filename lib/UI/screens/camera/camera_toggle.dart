import 'package:flutter/material.dart';

import '../../../logger.dart';

final log = getLogger('CameraToogle');

class CameraToogle extends StatelessWidget {
  final Function onNewCameraSelectedHandler;

  CameraToogle({
    @required this.onNewCameraSelectedHandler,
  });

  @override
  Widget build(BuildContext context) {
    log.d('building widget');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        icon: Icon(
          Icons.flip_camera_android,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          //TODO: animate icon
          onNewCameraSelectedHandler();
        },
      ),
    );
  }
}
