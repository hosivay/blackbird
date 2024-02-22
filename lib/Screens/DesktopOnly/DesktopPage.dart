// ignore: camel_case_types
import 'dart:io';

import 'package:blackbird/Screens/ChatList.dart';
import 'package:blackbird/SettingsFiles/Version.dart';
import 'package:blackbird/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';

class desktopHome extends StatefulWidget {
  const desktopHome({Key? key}) : super(key: key);

  @override
  State<desktopHome> createState() => _desktopHomeState();
}

class _desktopHomeState extends State<desktopHome> {
  final _controller = SideMenuController();
  // int _currentIndex = 0;
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
          SideMenu(priority: SideMenuPriority.mode,
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
                      isSelected:false,
                      onTap: () => setState(() {}),
                      title: "   Your IP : $_localIP",
                      hasSelectedLine: false,
                      hoverColor: Colors.grey.shade800,
                      icon:const Padding(
                        padding: EdgeInsets.fromLTRB(5, 2, 0, 0),
                        child: Icon(CupertinoIcons.device_desktop),
                      ),
                      titleStyle: const TextStyle(color: Colors.white),
                      margin: const EdgeInsetsDirectional.all(15)),
                  SideMenuItemDataTile(
                        isSelected:false,
                      onTap: () {
                         Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                      },
                      title: "   Refresh",
                      hasSelectedLine: false,
                       hoverColor: Colors.grey.shade800,
                      icon:const Padding(
                        padding: EdgeInsets.fromLTRB(5, 2, 0, 0),
                        child: Icon(CupertinoIcons.refresh),
                      ),
                      titleStyle: const TextStyle(color: Colors.white),
                      margin: const EdgeInsetsDirectional.all(15)),
                ],
                footer: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Version : $version',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
          const Expanded(child: ChatListScreen()),
        ],
      ),
    );
  }
}
