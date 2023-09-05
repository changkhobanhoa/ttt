import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ttt/screens/chat/chat_add_screen.dart';
 import 'package:ttt/screens/chat/chat_user.dart';
import 'package:ttt/services/authenticate.dart';

import '../../models/user.dart';
import 'chat_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isSearch = false;
  final List<User> _searchList = [];
  List<User> list = [];
  @override
  void initState() {
    FireStoreUtils.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (FireStoreUtils.autht.currentUser != null) {
        if (message.toString().contains('resume')) {
          FireStoreUtils.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          FireStoreUtils.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (isSearch) {
            setState(() {
              isSearch = !isSearch;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: isSearch
                ? TextFormField(
                    onChanged: (value) {
                      _searchList.clear();

                      for (var i in list) {
                        if (i.fullName
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(i);
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    },
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Tìm kiếm"),
                  )
                : const Text("Tin nhắn"),
            centerTitle: isSearch,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isSearch = !isSearch;
                  });
                },
                icon: Icon(isSearch
                    ? CupertinoIcons.clear_circled
                    : CupertinoIcons.search),
              ),
              IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: ChatAddScreen());
                },
                icon: const Icon(CupertinoIcons.person_add),
              ),
            ],
          ),
          body: StreamBuilder(
            stream: FireStoreUtils.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  list =
                      data?.map((e) => User.fromJson(e.data())).toList() ?? [];

                  if (list.isNotEmpty) {
                    return ListView.builder(
                      itemCount: list.length,
                      padding: const EdgeInsets.only(top: 10),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatCard(chat: list[index], press: () {
                          Navigator.push(context, MaterialPageRoute(builder: (b)=>ChatUserScreen(user: list[index])));
                        });
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("Not Found"),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
