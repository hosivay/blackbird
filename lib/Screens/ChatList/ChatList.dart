import 'package:blackbird/Screens/ChatList/ChatList_Getx.dart';
import 'package:blackbird/Screens/ChatPage/chatpage.dart';
import 'package:blackbird/SettingsFiles/Responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Widgets/drawer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatListController chatListController;

  @override
  void initState() {
    chatListController = Get.put(ChatListController());
    chatListController.getLocalIP();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatListController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Blackbird.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
        ),

        drawer: isMobileMode(context: context)
            ? drawerChatList(context, chatListController.localIP)
            : null,
        // ignore: unnecessary_null_comparison
        body: controller.chats == null || controller.chats.isEmpty
            ? isMobileMode(context: context)
                ? Center(
                    child: Text(
                    "Your IP : ${chatListController.localIP}",
                  ))
                : const Center(
                    child: Text('List of chat participants'),
                  )
            : ListView.builder(
                itemCount: controller.chats.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Slidable(
                        closeOnScroll: true,
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.3,
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  controller.removeChat(index),
                              backgroundColor: const Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: CupertinoIcons.delete,
                              label: "Delete",
                              autoClose: true,
                            ),
                          ],
                        ),
                        child: ListTile(
                            title: Text(
                              controller.chats[index]["name"]!,
                            ),
                            subtitle: Text(
                              controller.chats[index]["ip"]!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            leading: const Icon(Icons.computer),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      remoteIP: controller.chats[index]["ip"]!,
                                      name: controller.chats[index]["name"]!),
                                ),
                              );
                            },
                            trailing: isMobileMode(context: context) == false
                                ? IconButton(
                                    onPressed: () =>
                                        controller.removeChat(index),
                                    icon: Icon(
                                      CupertinoIcons.delete,
                                      color: Colors.red.withOpacity(0.6),
                                    ))
                                : const Text("")),
                      ),
                      const Divider(
                        endIndent: 55,
                        indent: 55,
                        thickness: 0.6,
                      )
                    ],
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            chatListController.showIPDialog(context);
          },
          backgroundColor: Theme.of(context).textTheme.bodyLarge!.color,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Icon(
            Icons.add,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }
}
