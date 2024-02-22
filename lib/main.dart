import 'dart:io';

import 'package:blackbird/chatpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';

void main() {
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
          : const test(),
    );
  }
}

class test extends StatefulWidget {
  const test({Key? key}) : super(key: key);

  @override
  State<test> createState() => _testState();
}

class _testState extends State<test> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blackbird.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
      ),
      body: isMobileMode(context: context)
          ? Center(
              child: Text(
              "Your IP : $_localIP",
              style: const TextStyle(color: Colors.black),
            ))
          : const Center(
              child: Text('List of chat participants'),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Remote IP Address'),
          content: TextField(
            onChanged: (value) {
              _remoteIP = value;
            },
            decoration: const InputDecoration(hintText: 'IP Address'),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_remoteIP != null && _remoteIP!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(remoteIP: _remoteIP!),
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


//102.90.127.162