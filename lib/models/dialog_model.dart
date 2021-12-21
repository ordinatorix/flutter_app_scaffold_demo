import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DialogRequest {
  final String title;
  final String description;
  final String buttonTitle;
  final String cancelTitle;
  final String dialogType;
  final dynamic error;
  final String publisherId;
  final Widget content;

  DialogRequest({
    @required this.title,
    @required this.description,
    this.content,
    @required this.buttonTitle,
    this.cancelTitle,
    @required this.dialogType,
    this.error,
    this.publisherId,
  });
  @override
  String toString() {
    return 'title: $title, description: $description, buttonTitle: $buttonTitle, cancelTitle: $cancelTitle, dialogType: $dialogType, error: $error, publisherId: $publisherId';
  }
}

class DialogResponse {
  final String fieldOne;
  final String fieldTwo;
  final bool confirmed;
  // final BuildContext context;
  final bool publisherIsUser;

  DialogResponse({
    this.fieldOne,
    this.fieldTwo,
    this.confirmed,
    this.publisherIsUser,
    // this.context,
  });

  @override
  String toString() {
    return 'confirmed: $confirmed, fieldOne: $fieldOne, fieldTwo: $fieldTwo, publisherIsUser: $publisherIsUser';
  }
}
