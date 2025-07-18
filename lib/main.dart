import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:blackbird/screens/chat_list_page/chat_list.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'screens/desktop_only/desktop_page.dart';
import 'settings_files/responsive.dart';
import 'package:get/get.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('myBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isPlatformDark =
        // ignore: deprecated_member_use
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark ? darkTheme : lightTheme;

    return ThemeProvider(
      initTheme: initTheme,
      builder: (_, myTheme) => GetMaterialApp(
        title: 'BlackBird',
        theme: myTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: isMobileMode(context: context)
            ? const ChatListScreen()
            : const DesktopHomePage(),
      ),
    );
  }
}
