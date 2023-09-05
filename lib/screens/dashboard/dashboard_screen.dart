import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ttt/screens/chat/chat_screen.dart';
import 'package:ttt/screens/home/home_screen.dart';
import 'package:ttt/screens/mapview/map_screen.dart';
import 'package:ttt/screens/profile/profile_screen.dart';
import 'package:ttt/widget/button_bottom_widget.dart';

import '../../models/user.dart';

class DashBoadScreen extends StatefulWidget {
  const DashBoadScreen({super.key, required this.user});
  final User user;
  @override
  State<DashBoadScreen> createState() => _DashBoadScreenState();
}

class _DashBoadScreenState extends State<DashBoadScreen>
    with SingleTickerProviderStateMixin {
  late User userModel;
  late final User u;

  @override
  void initState() {
    super.initState();
    userModel = widget.user;
  }

  @override
  void dispose() {
    userModel = widget.user;
    super.dispose();
  }

  bool isActiveColor = false;
  int activeButtonIndex = 0; // Index của nút hiện tại

  // Mảng lưu trạng thái màu của từng nút
  List<bool> buttonColors = [true, false, false, false];

  List<Map<String, dynamic>> titleIcon = [
    {
      'title': 'Home',
      'icon': const Icon(CupertinoIcons.home),
      'iconActive': const Icon(CupertinoIcons.house_fill)
    },
    {
      'title': 'Bản đồ',
      'icon': const Icon(CupertinoIcons.map),
      'iconActive': const Icon(CupertinoIcons.map_fill)
    },
    {
      'title': 'Nhắn tin',
      'icon': const Icon(CupertinoIcons.chat_bubble),
      'iconActive': const Icon(CupertinoIcons.chat_bubble_fill)
    },
    {
      'title': 'Tôi',
      'icon': const Icon(CupertinoIcons.person),
      'iconActive': const Icon(CupertinoIcons.person_fill)
    },
  ];
  // Hàm để cập nhật trạng thái màu của các nút
  void updateButtonColors(int index) {
    for (int i = 0; i < buttonColors.length; i++) {
      buttonColors[i] = (i == index);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listPage = [
      HomeScreen(user: widget.user),
      const MapScreen(),
      const ChatScreen(),
      const ProfileScreen()
    ];
    
    return Scaffold(
      body: listPage[activeButtonIndex],
        bottomNavigationBar: SizedBox(
            height: 70,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < buttonColors.length; i++)
                    ButtonBottomWidget(
                        isActiveColor: buttonColors[i],
                        function: () {
                          setState(() {
                            activeButtonIndex = i;
                            updateButtonColors(i);
                          });
                        },
                        title: Text(titleIcon[i]['title']),
                        iconData: activeButtonIndex == i
                            ? titleIcon[i]['iconActive']
                            : titleIcon[i]['icon'])
                ])));
  }
}
