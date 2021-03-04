import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String username;
  final String message;
  final String dpUrl;
  final bool isMe;
  final Key key;

  MessageBubble({this.username, this.message, this.dpUrl, this.isMe, this.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              key: key,
              decoration: BoxDecoration(
                color: Colors.yellow[200],
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                  bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              margin: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              width: 150,
              child: Column(
                children: [
                  Text(
                    username,
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  ),
                  Text(
                    message,
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: isMe ? 120 : null,
          left: isMe ? null : 120,
          child: CircleAvatar(
            backgroundImage: NetworkImage(dpUrl),
          ),
        ),
      ],
      overflow: Overflow.visible,
    );
  }
}
