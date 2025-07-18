import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String myip , remoteip;

  const Bubble({
    required this.message,
    required this.isMe, required this.myip, required this.remoteip,
  });
  @override
  Widget build(BuildContext context) {
    var parts = message.split('~').sublist(1);

    double radiusbubble = 20;
    return SingleChildScrollView(
      child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CupertinoContextMenu(
            actions: [
              CupertinoContextMenuAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Time : ${TimeMessege(
                  message: message,
                )}"),
              ),
              CupertinoContextMenuAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child:   Text("IP : ${isMe ? myip : remoteip}  ME: $isMe"),
              ),
            ],
            child: Align(
              alignment:
                  isMe == false ? Alignment.centerLeft : Alignment.centerRight,
              child: Column(
                crossAxisAlignment: isMe == false
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: isMe == false
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey.shade800,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                    isMe == false ? 0 : radiusbubble),
                                bottomRight: Radius.circular(
                                    isMe == false ? radiusbubble : 0),
                                topLeft: Radius.circular(radiusbubble),
                                topRight: Radius.circular(radiusbubble)),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary
                                      .withOpacity(0.5),
                                  blurRadius: 6)
                            ]),
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            parts[0].trim(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      TimeMessege(
                        message: message,
                      ),
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .color!
                              .withOpacity(0.4),
                          fontSize: 8),
                    ),
                  )
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}

// ignore: non_constant_identifier_names
String TimeMessege({required String message}) {
  var parts = message.split('~').sublist(1);
  var datemessege = parts[1].split(".").sublist(0);

  return datemessege[0].toString();
}
