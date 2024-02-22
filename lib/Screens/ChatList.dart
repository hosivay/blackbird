import 'dart:io';
import 'package:blackbird/Screens/chatpage.dart';
import 'package:blackbird/SettingsFiles/Responsive.dart';
import 'package:blackbird/SettingsFiles/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../SettingsFiles/Version.dart';
import '../main.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String? _remoteIP;
  String _localIP = '';

  @override
  void initState() {
    _getLocalIP();
    super.initState();
  }

  Future<void> _getLocalIP() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          setState(() {
            _localIP = addr.address;
          });
          return;
        }
      }
    }
  }

  List chats = MyStorage().ReadData(key: "chats");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blackbird.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
      ),

      drawer: isMobileMode(context: context)
          ? Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ), //BoxDecoration
                    child: UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(color: Colors.black),
                      accountName: const Text(
                        "BlackBird.",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      accountEmail: const Text("Developer : Hosivay"),

                      currentAccountPictureSize: const Size.square(60),

                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          "lib/assets/blackbirdlogo.png",
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade900,
                        ), //Text
                      ), //circleAvatar
                    ), //UserAccountDrawerHeader
                  ), //DrawerHeader
                  ListTile(
                    leading: const Icon(CupertinoIcons.device_desktop),
                    title: Text("Your IP : $_localIP"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(CupertinoIcons.refresh),
                    title: const Text("Refresh"),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height / 1.9,
                  ),
                  ListTile(
                    leading: const Icon(CupertinoIcons.info_circle),
                    title: const Text("Version : $version"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            )
          : null,
      // ignore: unnecessary_null_comparison
      body: chats == null || chats.isEmpty
          ? isMobileMode(context: context)
              ? Center(
                  child: Text(
                  "Your IP : $_localIP",
                  style: const TextStyle(color: Colors.black),
                ))
              : const Center(
                  child: Text('List of chat participants'),
                )
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    deleteSlide(
                      indexMap: index,
                      child: ListTile(
                          title: Text(
                            chats[index]["name"]!,
                          ),
                          subtitle: Text(
                            chats[index]["ip"]!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          leading: const Icon(Icons.computer),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                    remoteIP: chats[index]["ip"]!,
                                    name: chats[index]["name"]!),
                              ),
                            );
                          },
                          trailing: isMobileMode(context: context) == false
                              ? IconButton(
                                  onPressed: () async {
                                    await MyStorage().deletechat(index);
                                    setState(() {});
                                  },
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
          _showIPDialog(context);
        },
        backgroundColor: Colors.black.withOpacity(0.7),
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showIPDialog(BuildContext context) {
    final _namecontroller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Remote IP Address'),
          content: SizedBox(
            height: MediaQuery.sizeOf(context).height / 4,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _namecontroller,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      _remoteIP = value;
                    },
                    decoration: const InputDecoration(hintText: 'IP Address'),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
                if (_remoteIP != null && _remoteIP!.isNotEmpty) {
                  MyStorage()
                      .addChat(name: _namecontroller.text, ip: _remoteIP!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          remoteIP: _remoteIP!, name: _namecontroller.text),
                    ),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class deleteSlide extends StatefulWidget {
  const deleteSlide({super.key, required this.child, required this.indexMap});
  final Widget child;
  final int indexMap;
  @override
  State<deleteSlide> createState() => _deleteSlideState();
}

class _deleteSlideState extends State<deleteSlide> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
      closeOnScroll: true,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (context) async {
              MyStorage().deletechat(widget.indexMap);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: CupertinoIcons.delete,
            label: "Delete",
            autoClose: true,
          ),
        ],
      ),
      child: widget.child,
    );
  }
}
