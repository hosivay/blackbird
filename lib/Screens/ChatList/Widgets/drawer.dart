import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:blackbird/SettingsFiles/Update.dart';
import 'package:blackbird/SettingsFiles/Version.dart'; 
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme =
    FlexThemeData.light(scheme: FlexScheme.shark, useMaterial3: true);

ThemeData darkTheme =
    FlexThemeData.dark(scheme: FlexScheme.shark, useMaterial3: true);

Widget drawerChatList(BuildContext context, String localip) {
  return Drawer(
    child: Stack(
      children: [
        ListView(
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
              title: Text("Your IP : $localip"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
             
             FutureBuilder(
              future: getLatestRelease(),
              builder: (context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.hasData) {
                  // print("New : ${snapshot.data!} / Old : $version");
                  return ListTile(
                    leading: const Icon(CupertinoIcons.cloud_download),
                    title: snapshot.data!.compareTo(version) > 0
                        ? Text("New version released! ${snapshot.data!}")
                        : const Text("Your version is up to date"),
                    onTap: () {
                     if(snapshot.data!.compareTo(version) > 0){
                      launchURL();
                     }
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Text("");
                } else {
                  return const Text("");
                }
              },
            ),

            SizedBox(
              height: MediaQuery.sizeOf(context).height / 2.1,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 40, 5, 5),
          child: Align(
            alignment: Alignment.topRight,
            child: ThemeSwitcher.withTheme(
              builder: (_, switcher, theme) {
                return IconButton(
                  onPressed: () {
                    switcher.changeTheme(
                      theme: theme.brightness == Brightness.light
                          ? darkTheme
                          : lightTheme,
                    );
                  },
                  icon: Icon(
                    theme.brightness == Brightness.light
                        ? Icons.brightness_3
                        : Icons.sunny,
                    size: 25,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}
