import 'package:flutter/foundation.dart';

import '../models/post.dart';

class PostEditScreenArguments {
  final Map tags;
  final Post post;
  final EventLocation selectedLocation;

  PostEditScreenArguments({
    @required this.tags,
    this.post,
    this.selectedLocation,
  });
}
