import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ttt/models/chat_message.dart';
import 'package:ttt/services/authenticate.dart';

import '../../constants.dart';
import '../../helper/my_date_util.dart';
import '../../models/user.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({
    Key? key,
    required this.chat,
    required this.press,
  }) : super(key: key);

  final User chat;
  final VoidCallback press;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  ChatMessage? _message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.press,
      child: StreamBuilder(
          stream: FireStoreUtils.getLastMessage(widget.chat),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatMessage.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];

            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                  vertical: kDefaultPadding * 0.75),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          width: 40,
                          height: 40,
                          imageUrl: widget.chat.profilePictureURL,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/placeholder.jpg"),
                            radius: 24,
                          ),
                        ),
                      ),
                      if (widget.chat.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  width: 3),
                            ),
                          ),
                        )
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chat.fullName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Opacity(
                            opacity: 0.64,
                            child: Text(
                              _message != null
                                  ? _message!.type == Type.image
                                      ? 'image'
                                      : _message!.msg
                                  : "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.64,
                    child: Text(
                      MyDateUtil.getLastMessageTime(
                          context: context, time: _message!.sent),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
