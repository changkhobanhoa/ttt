import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ttt/widget/message_widget.dart';

import '../../constants.dart';
import '../../helper/my_date_util.dart';
import '../../models/chat_message.dart';
import '../../models/user.dart';
import '../../services/authenticate.dart';

class ChatUserScreen extends StatefulWidget {
  const ChatUserScreen({super.key, required this.user});
  final User user;
  @override
  State<ChatUserScreen> createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
  List<ChatMessage> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: StreamBuilder(
                  stream: FireStoreUtils.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => ChatMessage.fromJson(e.data()))
                                .toList() ??
                            [];
                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: const EdgeInsets.only(top: 10),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageWidget(
                                  message: _list[index],
                                  userModel: widget.user,
                                );
                              });
                        } else {
                          return const Center(
                            child: Text('Say Hii! 👋',
                                style: TextStyle(fontSize: 20)),
                          );
                        }
                    }
                  },
                ),
              ),
            ),
            if (_isUploading)
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            _chatInput(),
            if (_showEmoji)
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      bgColor: const Color.fromARGB(255, 234, 248, 255),
                      columns: 8,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: StreamBuilder(
          stream: FireStoreUtils.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => User.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                InkWell(
                    onTap: () => Navigator.pop(context),
                    child:const Padding(
                      padding:   EdgeInsets.symmetric(vertical: 10,horizontal: 2),
                      child:   Icon(Icons.arrow_back, color: Colors.black54),
                    )),
                const SizedBox(
                  width: 5,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    width: 40,
                    height: 40,
                    imageUrl: list.isNotEmpty
                        ? list[0].profilePictureURL
                        : widget.user.profilePictureURL,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      backgroundImage:
                          AssetImage("assets/images/placeholder.jpg"),
                      radius: 24,
                    ),
                  ),
                ),
                const SizedBox(width: kDefaultPadding * 0.75),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        list.isNotEmpty
                            ? list[0].fullName
                            : widget.user.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500)),

                    //for adding some space
                    const SizedBox(height: 2),

                    //last seen time of user
                    Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ],
                )
              ],
            );
          }),
      actions: [
        IconButton(
          icon: const Icon(Icons.local_phone),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {},
        ),
        const SizedBox(width: kDefaultPadding / 2),
      ],
    );
  }

  Widget _chatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding * 0.75,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      child: Icon(
                        Icons.sentiment_satisfied_alt_outlined,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(0.64),
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding / 4),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onTap: () {
                          if (_showEmoji)
                            setState(() => _showEmoji = !_showEmoji);
                        },
                        decoration: const InputDecoration(
                          hintText: "Aa",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        // uploading & sending image one by one
                        for (var i in images) {
                          setState(() => _isUploading = true);
                          await FireStoreUtils.sendChatImage(
                              widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      child: Icon(
                        Icons.image,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(0.64),
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding / 4),
                    InkWell(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          setState(() => _isUploading = true);

                          await FireStoreUtils.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(0.64),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: kDefaultPadding),
            InkWell(
                onTap: () {
                  if (_textController.text.isNotEmpty) {
                    if (_list.isEmpty) {
                      //on first message (add user to my_user collection of chat user)
                      FireStoreUtils.sendFirstMessage(
                          widget.user, _textController.text, Type.text);
                    } else {
                      //simply send message
                      FireStoreUtils.sendMessage(
                          widget.user, _textController.text, Type.text);
                    }
                    _textController.text = '';
                  }
                },
                child: const Icon(CupertinoIcons.location,
                    color: kPrimaryColor, size: 28)),
          ],
        ),
      ),
    );
  }
}
