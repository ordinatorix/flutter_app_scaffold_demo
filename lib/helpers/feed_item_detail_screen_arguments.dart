import 'package:flutter/foundation.dart';
import '../models/post.dart';

class FeedItemDetailScreenArguments {
  final Post post;
  final String postId;
  final int returnPage;
  final String referalPage;

  FeedItemDetailScreenArguments({
    @required this.post,
    @required this.returnPage,
    @required this.referalPage,
    this.postId,
  });
}
