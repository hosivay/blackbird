import 'dart:io';

import 'package:blackbird/chatpage.dart';
import 'package:blackbird/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart'; 

void main() async {
  await Hive.initFlutter();

  // ignore: unused_local_variable
  var box = await Hive.openBox('myBox');
  runApp(const MyApp());
}

bool isMobileMode({required BuildContext context}) {
  if (MediaQuery.of(context).size.width < 650) {
    return true;
  } else {
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlackBird',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: isMobileMode(context: context)
          ? const ChatListScreen()
          : const desktopHome(),
    );
  }
}

// ignore: camel_case_types
class desktopHome extends StatefulWidget {
  const desktopHome({Key? key}) : super(key: key);

  @override
  State<desktopHome> createState() => _desktopHomeState();
}

class _desktopHomeState extends State<desktopHome> {
  final _controller = SideMenuController();
  int _currentIndex = 0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            controller: _controller,
            backgroundColor: const Color.fromARGB(255, 10, 10, 10),
            mode: SideMenuMode.open,
            builder: (data) {
              return SideMenuData(
                header: Image.asset(
                  "lib/assets/blackbirdlogo.png",
                  width: 75,
                  height: 75,
                  color: Colors.grey.shade300,
                ),
                items: [
                  // const SideMenuItemDataTitle(title: 'Section Header',titleStyle: TextStyle(color: Colors.white)),
                  SideMenuItemDataTile(
                      isSelected: _currentIndex == 0,
                      onTap: () => setState(() => _currentIndex = 0),
                      title: "   Your IP : $_localIP",
                      hasSelectedLine: false,
                      hoverColor: Colors.white,
                      titleStyle: const TextStyle(color: Colors.white),
                      margin: const EdgeInsetsDirectional.all(15)),
                ],
                footer: const Text('Footer'),
              );
            },
          ),
          const Expanded(child: ChatListScreen()),
        ],
      ),
    );
  }
}

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

  var chats = MyStorage().ReadData(key: "chats");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blackbird.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
      ),
      body: chats == null
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
                    ListTile(
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
                      trailing: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            CupertinoIcons.delete,
                            color: Colors.red.withOpacity(0.6),
                          )),
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
