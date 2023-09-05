import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ttt/screens/login/login_screen.dart';
import 'package:ttt/services/authenticate.dart';

import '../../models/user.dart';
import '../../services/helper.dart';
import '../../widget/profile_menu.dart';
import '../../widget/profile_picture.dart';
import '../auth/authentication_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User userModel = FireStoreUtils.me;
  String? _image;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.authState == AuthState.unauthenticated) {
          pushAndRemoveUntil(context, const LoginScreen(), false);
        }
      },
      child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            elevation: 0.0,
            title: const Text(
              "Thông tin cá nhân",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    await FireStoreUtils.updateActiveStatus(false);
                    context.read<AuthenticationBloc>().add(LogoutEvent());
                  },
                  icon: const Icon(Icons.power_settings_new))
            ],
            centerTitle: true,
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(children: [
                ProfilePic(
                    imageUrl: userModel.profilePictureURL,
                    updateImage: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });

                        FireStoreUtils.updateProfilePicture(File(_image!));
                        // for hiding bottom sheet
                        Navigator.pop(context);
                      }else{
                           Navigator.pop(context);
                      }
                    }),
                const SizedBox(height: 20),
                Text(
                  userModel.fullName,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                ProfileMenu(
                  text: "My Account",
                  icon: "assets/icons/User Icon.svg",
                  press: () => {},
                ),
              ]))),
    );
  }
}
