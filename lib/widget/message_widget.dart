import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ttt/services/authenticate.dart';

import '../../../constants.dart';
import '../models/chat_message.dart';
import '../models/user.dart';
import 'text_message.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget({
    Key? key,
    required this.message,
    required this.userModel,
  }) : super(key: key);

  final ChatMessage message;
  final User userModel;

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    bool isMe = FireStoreUtils.userModel.uid == widget.message.fromId;
    print(isMe);

    Widget messageContaint(ChatMessage message) {
      switch (message.type) {
        case Type.text:
          return TextMessage(message: message);
        case Type.image:
          return SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.45, // 45% of total width
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.image, size: 70),
              ),
            ),
          );

        default:
          return const SizedBox();
      }
    }

    if (widget.message.read.isEmpty) {
      FireStoreUtils.updateMessageReadStatus(widget.message);
    }
    return InkWell(
      onLongPress: () {
        //  _showBottomSheet(isMe);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: kDefaultPadding),
        child: Row(
          mainAxisAlignment: !isMe
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (!isMe) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  width: 40,
                  height: 40,
                  imageUrl: widget.userModel.profilePictureURL,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black,
                    backgroundImage:
                        AssetImage("assets/images/placeholder.jpg"),
                  ),
                ),
              ),
              const SizedBox(width: kDefaultPadding / 2),
            ],
            messageContaint(widget.message),
            if (isMe) MessageStatusDot(status: widget.message.read)
          ],
        ),
      ),
    );
  }
}

class MessageStatusDot extends StatelessWidget {
  final String? status;

  const MessageStatusDot({Key? key, this.status}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color dotColor(String status) {
      if (status.isEmpty) {
        return Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1);
      } else {
        return kPrimaryColor;
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: kDefaultPadding / 2),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: dotColor(status!),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.done,
        size: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
