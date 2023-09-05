import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;

import 'package:http/http.dart';

import '../constants.dart';
import '../models/chat_message.dart';
import '../models/user.dart';
import 'helper.dart';

class FireStoreUtils {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static auth.FirebaseAuth autht = auth.FirebaseAuth.instance;
  static auth.User get userModel => auth.FirebaseAuth.instance.currentUser!;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  final timeNow = DateTime.now().millisecondsSinceEpoch.toString();
  static User me = User(
    userID: userModel.uid,
    fullName: userModel.displayName.toString(),
    email: userModel.email.toString(),
    profilePictureURL: userModel.photoURL.toString(),
    isOnline: false,
    lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
  );
  static String getConversationID(String id) =>
      userModel.uid.hashCode <= id.hashCode
          ? '${userModel.uid}_$id'
          : '${id}_${userModel.uid}';
  static Future<User?> getCurrentUser(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await firestore.collection(usersCollection).doc(uid).get();
    if (userDocument.data() != null && userDocument.exists) {
      return User.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(User user) {
    return firestore
        .collection('chats/${getConversationID(user.userID)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(userModel.uid)
        .collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(User user) {
    return firestore
        .collection('chats/${getConversationID(user.userID)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${userModel.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {});

    //updating image in firestore database
    me.profilePictureURL = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(userModel.uid)
        .update({'image': me.profilePictureURL});
  }

  static Future<void> sendChatImage(User chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.userID)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {});

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Future<void> sendMessage(User chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final ChatMessage message = ChatMessage(
        toId: chatUser.userID,
        msg: msg,
        read: '',
        type: type,
        fromId: userModel.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.userID)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  static Future<void> sendFirstMessage(
      User chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.userID)
        .collection('my_users')
        .doc(userModel.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  static Future<void> updateMessage(
      ChatMessage message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  static Future<void> deleteMessage(ChatMessage message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessageReadStatus(ChatMessage message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Future<void> sendPushNotification(User chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.fullName, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAHLSA5Fk:APA91bF6Km-0ETPkWx1bYuwXK7Oeg9S8fhKgc1sTbFIJLIKUrkkce39cLPLKg4aVjk--MBlPcUystMZLkROyC_KNz-nX-S1-kE4bg8J0dW24D8LowP5kXT--biFR6KZv86JwNriE46qX'
          },
          body: jsonEncode(body));
    } catch (e) {}
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: userModel.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      User chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.userID)
        .snapshots();
  }

  static Future<User> updateCurrentUser(User user) async {
    return await firestore
        .collection(usersCollection)
        .doc(user.userID)
        .set(user.toJson())
        .then((document) {
      return user;
    });
  }

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print("Push token"+t);
      }
    });
  }

  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(userModel.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = User.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        FireStoreUtils.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = User(
      userID: userModel.uid,
      fullName: userModel.displayName.toString(),
      email: userModel.email.toString(),
      profilePictureURL: userModel.photoURL.toString(),
      isOnline: false,
      lastActive: time,
    );

    return await firestore
        .collection('users')
        .doc(userModel.uid)
        .set(chatUser.toJson());
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(userModel.uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      'pushToken': me.pushToken
    });
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != userModel.uid) {
      //user exists

      firestore
          .collection('users')
          .doc(userModel.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  static Future<String> uploadUserImageToServer(
      Uint8List imageData, String userID) async {
    Reference upload = storage.ref().child("images/$userID.png");
    UploadTask uploadTask =
        upload.putData(imageData, SettableMetadata(contentType: 'image/jpeg'));
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  /// login with email and password with firebase
  /// @param email user email
  /// @param password user password
  static Future<dynamic> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firestore
          .collection(usersCollection)
          .doc(result.user?.uid ?? '')
          .get();
      User? user;
      if (documentSnapshot.exists) {
        user = User.fromJson(documentSnapshot.data() ?? {});
        user.isOnline = true;
        user.lastActive = DateTime.now().millisecondsSinceEpoch.toString();
      }
      return user;
    } on auth.FirebaseAuthException catch (exception, s) {
      debugPrint('$exception$s');
      switch ((exception).code) {
        case 'invalid-email':
          return 'Email address is malformed.';
        case 'wrong-password':
          return 'Wrong password.';
        case 'user-not-found':
          return 'No user corresponding to the given email address.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts to sign in as this user.';
      }
      return 'Unexpected firebase error, Please try again.';
    } catch (e, s) {
      debugPrint('$e$s');
      return 'Login failed, Please try again.';
    }
  }

  static loginWithFacebook() async {
    FacebookAuth facebookAuth = FacebookAuth.instance;
    bool isLogged = await facebookAuth.accessToken != null;
    if (!isLogged) {
      LoginResult result = await facebookAuth
          .login(); // by default we request the email and the public profile
      if (result.status == LoginStatus.success) {
        // you are logged
        AccessToken? token = await facebookAuth.accessToken;
        return await handleFacebookLogin(
            await facebookAuth.getUserData(), token!);
      }
    } else {
      AccessToken? token = await facebookAuth.accessToken;
      return await handleFacebookLogin(
          await facebookAuth.getUserData(), token!);
    }
  }

  static handleFacebookLogin(
      Map<String, dynamic> userData, AccessToken token) async {
    auth.UserCredential authResult = await auth.FirebaseAuth.instance
        .signInWithCredential(
            auth.FacebookAuthProvider.credential(token.token));
    User? user = await getCurrentUser(authResult.user?.uid ?? '');

    if (user != null) {
      user.profilePictureURL = userData['picture']['data']['url'];
      user.isOnline = true;

      user.lastActive = DateTime.now().millisecondsSinceEpoch.toString();
      user.fullName = userData['name'] as String;
      user.email = userData['email'];
      dynamic result = await updateCurrentUser(user);
      return result;
    } else {
      user = User(
          email: userData['email'] ?? '',
          isOnline: true,
          lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
          fullName: userData['name'] as String,
          profilePictureURL: userData['picture']['data']['url'] ?? '',
          userID: authResult.user?.uid ?? '');
      String? errorMessage = await createNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  /// save a new user document in the USERS table in firebase firestore
  /// returns an error message on failure or null on success
  static Future<String?> createNewUser(User user) async => await firestore
      .collection(usersCollection)
      .doc(user.userID)
      .set(user.toJson())
      .then((value) => null, onError: (e) => e);

  static signUpWithEmailAndPassword(
      {required String emailAddress,
      required String password,
      Uint8List? imageData,
      fullName = 'User'}) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailAddress, password: password);
      String profilePicUrl = '';
      if (imageData != null) {
        updateProgress('Uploading image, Please wait...');
        profilePicUrl =
            await uploadUserImageToServer(imageData, result.user?.uid ?? '');
      }
      User user = User(
          isOnline: false,
          lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
          email: emailAddress,
          userID: result.user?.uid ?? '',
          fullName: fullName,
          profilePictureURL: profilePicUrl);
      String? errorMessage = await createNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t sign up for firebase, Please try again.';
      }
    } on auth.FirebaseAuthException catch (error) {
      debugPrint('$error${error.stackTrace}');
      String message = 'Couldn\'t sign up';
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Email already in use, Please pick another email!';
          break;
        case 'invalid-email':
          message = 'Enter valid e-mail';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          message = 'Password must be more than 5 characters';
          break;
        case 'too-many-requests':
          message = 'Too many requests, Please try again later.';
          break;
      }
      return message;
    } catch (e, s) {
      debugPrint('FireStoreUtils.signUpWithEmailAndPassword $e $s');
      return 'Couldn\'t sign up';
    }
  }

  static logout() async {
    await auth.FirebaseAuth.instance.signOut();
  }

  static Future<User?> getAuthUser() async {
    auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      User? user = await getCurrentUser(firebaseUser.uid);
      return user;
    } else {
      return null;
    }
  }

  static Future<dynamic> loginOrCreateUserWithPhoneNumberCredential({
    required auth.PhoneAuthCredential credential,
    required String phoneNumber,
    String? fullName = 'User',
    Uint8List? imageData,
  }) async {
    auth.UserCredential userCredential =
        await auth.FirebaseAuth.instance.signInWithCredential(credential);
    User? user = await getCurrentUser(userCredential.user?.uid ?? '');
    if (user != null) {
      return user;
    } else {
      /// create a new user from phone login
      String profileImageUrl = '';
      if (imageData != null) {
        profileImageUrl = await uploadUserImageToServer(
            imageData, userCredential.user?.uid ?? '');
      }
      User user = User(
          isOnline: true,
          lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
          fullName: fullName!.trim().isNotEmpty ? fullName.trim() : 'User',
          email: '',
          profilePictureURL: profileImageUrl,
          userID: userCredential.user?.uid ?? '');
      String? errorMessage = await createNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t create new user with phone number.';
      }
    }
  }

  static loginWithApple() async {
    final appleCredential = await apple.TheAppleSignIn.performRequests([
      const apple.AppleIdRequest(
          requestedScopes: [apple.Scope.email, apple.Scope.fullName])
    ]);
    if (appleCredential.error != null) {
      return 'Couldn\'t login with apple.';
    }

    if (appleCredential.status == apple.AuthorizationStatus.authorized) {
      final auth.AuthCredential credential =
          auth.OAuthProvider('apple.com').credential(
        accessToken: String.fromCharCodes(
            appleCredential.credential?.authorizationCode ?? []),
        idToken: String.fromCharCodes(
            appleCredential.credential?.identityToken ?? []),
      );
      return await handleAppleLogin(credential, appleCredential.credential!);
    } else {
      return 'Couldn\'t login with apple.';
    }
  }

  static handleAppleLogin(
    auth.AuthCredential credential,
    apple.AppleIdCredential appleIdCredential,
  ) async {
    auth.UserCredential authResult =
        await auth.FirebaseAuth.instance.signInWithCredential(credential);
    User? user = await getCurrentUser(authResult.user?.uid ?? '');
    if (user != null) {
      return user;
    } else {
      user = User(
        email: appleIdCredential.email ?? '',
        isOnline: true,
        lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
        profilePictureURL: '',
        userID: authResult.user?.uid ?? '',
        fullName: appleIdCredential.fullName?.familyName ?? '',
      );
      String? errorMessage = await createNewUser(user);
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  static resetPassword(String emailAddress) async =>
      await auth.FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailAddress);
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(userModel.uid).get())
        .exists;
  }

  static signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = auth.GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    auth.UserCredential authResult =
        await auth.FirebaseAuth.instance.signInWithCredential(credential);

    if ((await firestore.collection('users').doc(authResult.user!.uid).get())
        .exists) {
      User? user = await getCurrentUser(authResult.user?.uid ?? '');
      return user;
    }

    User user = User(
        fullName: authResult.user!.displayName!,
        isOnline: true,
        lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
        email: authResult.user!.email!,
        profilePictureURL: authResult.user!.photoURL!,
        userID: authResult.user?.uid ?? '');
    String? errorMessage = await createNewUser(user);
    if (errorMessage == null) {
      return user;
    } else {}
  }
}
