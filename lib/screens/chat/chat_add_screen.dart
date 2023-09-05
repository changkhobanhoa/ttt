import 'package:flutter/material.dart';
import 'package:ttt/screens/chat/chat_card.dart';
import 'package:ttt/services/authenticate.dart';

import '../../models/user.dart';

class ChatAddScreen extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<User> _list = [];

    return StreamBuilder(
      stream: FireStoreUtils.getMyUsersId(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          //if data is loading
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const Center(child: CircularProgressIndicator());

          //if some or all data is loaded then show it
          case ConnectionState.active:
          case ConnectionState.done:
            return StreamBuilder(
              stream: FireStoreUtils.getAllUsers(
                  ),

              //get only those user, who's ids are provided
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list =
                        data?.map((e) => User.fromJson(e.data())).toList() ??
                            [];
                    List<User> matchQuery = [];
                    for (var item in _list) {
                      if (item.fullName
                          .toLowerCase()
                          .contains(query.toLowerCase())) {
                        matchQuery.add(item);
                      }
                    }
                    if (matchQuery.isNotEmpty) {
                      return ListView.builder(
                          itemCount: matchQuery.length,
                          padding: const EdgeInsets.only(top: 10),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatCard(
                                chat: matchQuery[index], press: () {});
                          });
                    } else if (query.isEmpty) {
                      return ListView.builder(
                          itemCount: _list.length,
                          padding: const EdgeInsets.only(top: 10),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatCard(chat: _list[index], press: () {});
                          });
                    } else {
                      return const Center(
                        child: Text('No Connections Found!',
                            style: TextStyle(fontSize: 20)),
                      );
                    }
                }
              },
            );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<User> _list = [];

    return StreamBuilder(
      stream:
          FireStoreUtils.getAllUsers( ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          //if data is loading
          case ConnectionState.waiting:
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.done:
            final data = snapshot.data?.docs;
            _list = data?.map((e) => User.fromJson(e.data())).toList() ?? [];
            List<User> matchQuery = [];
            print(_list.length);
            for (var item in _list) {
              if (item.fullName.toLowerCase().contains(query.toLowerCase())) {
                matchQuery.add(item);
              }
            }
            if (matchQuery.isNotEmpty) {
              return ListView.builder(
                  itemCount: matchQuery.length,
                  padding: const EdgeInsets.only(top: 10),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatCard(chat: matchQuery[index], press: () {});
                  });
            }
            if (query.isEmpty) {
              return ListView.builder(
                  itemCount: _list.length,
                  padding: const EdgeInsets.only(top: 10),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatCard(chat: _list[index], press: () {});
                  });
            } else {
              return const Center(
                child: Text('Not Found!', style: TextStyle(fontSize: 20)),
              );
            }
        }
      },
    );
  }
}
