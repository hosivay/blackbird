import 'package:blackbird/Screens/ChatPage/ChatPage_Getx.dart';
import 'package:blackbird/Screens/ChatPage/Widgets/Bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  final String remoteIP;
  final String name;

  const ChatScreen({super.key, required this.remoteIP, required this.name});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatPageController chatPageController;

  @override
  void initState() {
    super.initState();
    chatPageController = Get.put(ChatPageController());
    chatPageController.getLocalIP();
    chatPageController.initSocket();
    // chatPageController.startFileReceiver();
  }

  @override
  void dispose() {
    super.dispose();
    chatPageController.socket?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.name}'),
        actions: [
          IconButton(
            onPressed: () {
              chatPageController.showInfoDialog(
                  context: context,
                  name: widget.name,
                  remoteIP: widget.remoteIP);
            },
            icon: const Icon(CupertinoIcons.info),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                StreamBuilder(
                  stream: chatPageController.streamMessages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: chatPageController.messages.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            SizedBox(height: index == 0 ? 65 : 0),
                            ListTile(
                              title: Bubble(
                                message: chatPageController.messages[index],
                                isMe: chatPageController.messages[index]
                                    .startsWith(chatPageController.localIP),
                                    myip: chatPageController.localIP,
                                    remoteip: widget.remoteIP,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Theme.of(context).focusColor,
                    child: ListTile(
                      title: GetBuilder<ChatPageController>(
                        builder: (controller) =>
                            Text('Your Local IP: ${controller.localIP}'),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: chatPageController.controller,
                            decoration: const InputDecoration(
                              hintText: 'Enter your message...',
                            ),
                            keyboardType: TextInputType.text,
                            onSubmitted: (String value) {
                              chatPageController.sendMessage(
                                  remoteIP: widget.remoteIP);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.paperplane_fill),
                          onPressed: () {
                            chatPageController.sendMessage(
                                remoteIP: widget.remoteIP);
                          },
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.attach_file),
                        //   onPressed: () {
                        //     chatPageController.pickFile(widget.remoteIP);
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
