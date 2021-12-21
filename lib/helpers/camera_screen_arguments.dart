import 'package:flutter/foundation.dart';

class CameraScreenArguments {
  // TODO: use route observer?
  final Map<String, List<String>> mediaList;
  final bool onlyPicture;

  CameraScreenArguments({
    @required this.mediaList,
    @required this.onlyPicture,
  });
}
