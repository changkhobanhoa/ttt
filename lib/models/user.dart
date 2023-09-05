import 'dart:io';

import 'package:flutter/foundation.dart';

class User {
  String email;

  String fullName;

  String userID;
  bool isOnline;
  String lastActive;
  String profilePictureURL;
  String pushToken;
  String appIdentifier;

  User(
      {this.email = '',
      this.fullName = '',
      this.userID = '',
      this.isOnline = false,
      this.lastActive = '',
      this.pushToken = '',
      this.profilePictureURL = ''})
      : appIdentifier =
            'Flutter Login Screen ${kIsWeb ? 'Web' : Platform.operatingSystem}';

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
        email: parsedJson['email'] ?? '',
        fullName: parsedJson['fullName'] ?? '',
        isOnline: parsedJson['isOnline'] ?? false,
        lastActive: parsedJson['lastActive'] ?? '',
        pushToken: parsedJson['pushToken']??'',
        userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
        profilePictureURL: parsedJson['profilePictureURL'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'isOnline': isOnline,
      'lastActive': lastActive,
      'id': userID,
      'pushToken':pushToken,
      'profilePictureURL': profilePictureURL,
      'appIdentifier': appIdentifier
    };
  }
}
