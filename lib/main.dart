import 'package:blackbird/Screens/ChatList.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'Screens/DesktopOnly/DesktopPage.dart';
import 'SettingsFiles/Responsive.dart';

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
