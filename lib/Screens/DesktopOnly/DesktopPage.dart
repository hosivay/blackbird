// ignore: camel_case_types
import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:blackbird/Screens/ChatList/ChatList.dart';
import 'package:blackbird/SettingsFiles/Update.dart';
import 'package:blackbird/SettingsFiles/Version.dart';
import 'package:blackbird/main.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';

ThemeData lightTheme =
    FlexThemeData.light(scheme: FlexScheme.shark, useMaterial3: true);

ThemeData darkTheme =
    FlexThemeData.dark(scheme: FlexScheme.shark, useMaterial3: true);

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
          Stack(
            children: [
              SideMenu(
                priority: SideMenuPriority.mode,
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
                          isSelected: false,
                          onTap: () => setState(() {}),
                          title: "   Your IP : $_localIP",
                          hasSelectedLine: false,
                          hoverColor: Colors.grey.shade800,
                          icon: const Padding(
                            padding: EdgeInsets.fromLTRB(5, 2, 0, 0),
                            child: Icon(CupertinoIcons.device_desktop),
                          ),
                          titleStyle: const TextStyle(color: Colors.white),
                          margin: const EdgeInsetsDirectional.all(15)),
                      SideMenuItemDataTile(
                          isSelected: false,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyApp()),
                            );
                          },
                          title: "   Refresh",
                          hasSelectedLine: false,
                          hoverColor: Colors.grey.shade800,
                          icon: const Padding(
                            padding: EdgeInsets.fromLTRB(5, 2, 0, 0),
                            child: Icon(CupertinoIcons.refresh),
                          ),
                          titleStyle: const TextStyle(color: Colors.white),
                          margin: const EdgeInsetsDirectional.all(15)),
                    ],
                    footer: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder(
                        future: getLatestRelease(),
                        builder: (context, AsyncSnapshot<String?> snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data!.compareTo(version) > 0
                                ? TextButton(
                                    child: Text(
                                      "New version released! ${snapshot.data!}",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      launchURL();
                                    },
                                  )
                                : const Text(
                                    "Your version is up to date\nVersion : $version",
                                    style: TextStyle(color: Colors.white),
                                  );
                          } else if (snapshot.hasError) {
                            return const Text("");
                          } else {
                            return TextButton(
                              child: const Text('Version : $version',
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                launchURL(update: false);
                              },
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 230, 5, 5),
                child: Align(
                  alignment: Alignment.topRight,
                  child: ThemeSwitcher.withTheme(
                    builder: (_, switcher, theme) {
                      return InkWell(
                        onTap: () {
                          switcher.changeTheme(
                            theme: theme.brightness == Brightness.light
                                ? darkTheme
                                : lightTheme,
                          );
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                              child: Icon(
                                theme.brightness == Brightness.light
                                    ? Icons.brightness_3
                                    : Icons.sunny,
                                size: 25,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "${theme.brightness == Brightness.light ? 'Dark' : 'Light'} Mode",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const Expanded(child: ChatListScreen()),
        ],
      ),
    );
  }
}
