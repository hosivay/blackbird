import 'package:blackbird/Screens/ChatList.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'Screens/DesktopOnly/DesktopPage.dart';
import 'SettingsFiles/Responsive.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
void main() async {
  await Hive.initFlutter();

  // ignore: unused_local_variable
  var box = await Hive.openBox('myBox');
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlackBird',
      theme: FlexThemeData.light(scheme: FlexScheme.shark,useMaterial3: true), 
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.shark,useMaterial3: true), 
      themeMode: ThemeMode.system, 
      debugShowCheckedModeBanner: false,
      home: isMobileMode(context: context)
          ? const ChatListScreen()
          : const desktopHome(),
    );
  }
}
