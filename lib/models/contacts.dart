// import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class UserContact {
  // Identification
  final String id;
  final String displayName;
  final String givenName;
  final String middleName;
  final String prefix;
  final String suffix;
  final String familyName;
  final DateTime birthday;

// Company
  final String company;
  final String jobTitle;

// Email addresses
  final Map emails;

// Phone numbers
  final Map phones;

// Post addresses
  final List<Map> postalAddresses;

// Contact avatar/thumbnail
  final Uint8List avatar;
  final String picture;

// Android account info
  final String androidAccountName;

// App presence
  final bool isUser;
  bool inGroup;
  // final bool followMe;
  // // final bool assistMe;

  UserContact({
    @required this.id,
    @required this.displayName,
    @required this.givenName,
    @required this.middleName,
    @required this.familyName,
    this.birthday,
    this.prefix,
    this.suffix,
    this.emails,
    this.isUser = false,
    this.inGroup = false,
    this.company,
    this.jobTitle,
    this.phones,
    this.postalAddresses,
    this.avatar,
    this.androidAccountName,
    this.picture,
  });
  @override
  String toString() {
    return 'id: $id, displayName: $displayName, inGroup: $inGroup, isUser: $isUser, phones: $phones';
  }
}
