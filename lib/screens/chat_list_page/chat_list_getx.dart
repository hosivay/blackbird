import 'package:blackbird/screens/chat_page_page/chatpage.dart';
import 'package:blackbird/settings_files/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ChatListController extends GetxController {
  String? remoteIP;
  String localIP = '';
  List chats = MyStorage().ReadData(key: "chats") ?? [];
  Future<void> getLocalIP() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();

    localIP = wifiIP!;

    update();
  }

  removeChat(index) {
    MyStorage().deletechat(index);
    update();
  }

  void showIPDialog(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
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
                      remoteIP = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'IP Address',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                update();
                Navigator.of(context).pop();

                if (remoteIP != null && remoteIP!.isNotEmpty) {
                  MyStorage()
                      .addChat(name: _namecontroller.text, ip: remoteIP!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          remoteIP: remoteIP!, name: _namecontroller.text),
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
