

import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const Bubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    double radiusbubble = 20;
    return Align(
      alignment: isMe == false ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.green,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(isMe == false ? 0 : radiusbubble),
              bottomRight: Radius.circular(isMe == false ? radiusbubble : 0),
              topLeft: Radius.circular(radiusbubble),
              topRight: Radius.circular(radiusbubble)),
        ),
        child: Text(
          message.split(':').sublist(1).join(':').trim(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
