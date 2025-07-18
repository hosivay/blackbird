import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:blackbird/screens/chat_list_page/chat_list.dart';
import 'package:blackbird/screens/chat_list_page/chat_list_getx.dart';
import 'package:blackbird/settings_files/update.dart';
import 'package:blackbird/settings_files/version.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';

ThemeData lightTheme =
    FlexThemeData.light(scheme: FlexScheme.shark, useMaterial3: true);

ThemeData darkTheme =
    FlexThemeData.dark(scheme: FlexScheme.shark, useMaterial3: true);

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({Key? key}) : super(key: key);

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  final _controller = SideMenuController();
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
                            onTap: () {},
                            title: "   Your IP : ${controller.localIP}",
                            hasSelectedLine: false,
                            hoverColor: Colors.grey.shade800,
                            icon: const Padding(
                              padding: EdgeInsets.fromLTRB(5, 2, 0, 0),
                              child: Icon(CupertinoIcons.device_desktop),
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
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      onPressed: () {
                                        launchURL();
                                      },
                                    )
                                  : TextButton(
                                      child: const Text(
                                        "Your version is up to date\nVersion : $version",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        launchURL(update: false);
                                      },
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
                  padding: const EdgeInsets.fromLTRB(9, 150, 5, 5),
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
                                padding:
                                    const EdgeInsets.fromLTRB(10, 6, 10, 6),
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
      ),
    );
  }
}
