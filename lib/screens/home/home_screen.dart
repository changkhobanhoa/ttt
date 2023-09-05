import 'package:flutter/material.dart';
import 'package:ttt/services/authenticate.dart';

import '../../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
  });
  final User user;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: StreamBuilder(
          stream: FireStoreUtils.firestore.collection('users').snapshots(),
          builder: (c, s) {
            final list = [];
            if (s.hasData) {
              final data = s.data?.docs;
             
              for (var i in data!) {
                debugPrint('Data: ${i.data()}');
                list.add(i.data()['fullName']);
              }
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Text('Name :${list[index]}');
              },
            );
          }),
    );
  }
}
