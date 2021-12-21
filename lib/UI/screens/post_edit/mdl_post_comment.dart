import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../../services/navigation_service.dart';

import '../../base_model.dart';

import '../../../logger.dart';
import '../../../locator.dart';

final log = getLogger('PostCommentScreenViewModel');

class PostCommentScreenViewModel extends BaseModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final form = GlobalKey<FormState>();
  List comment;

  /// Validate comment.
  void validateComment() {
    final isValid = form.currentState.validate();
    if (!isValid) {
      log.d('isValid: $isValid');
      log.d('not valid');
      return;
    }
    form.currentState.save();

    _navigationService.pop(comment);
  }

  /// Dispose of post comment screen model.
  void disposer() {
    log.i('disposer');

    SystemChrome.restoreSystemUIOverlays();
  }
}
