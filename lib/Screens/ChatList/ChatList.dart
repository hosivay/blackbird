import 'package:blackbird/Screens/ChatPage/chatpage.dart';
import 'package:blackbird/SettingsFiles/Responsive.dart'; 
import 'package:blackbird/SettingsFiles/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:network_info_plus/network_info_plus.dart';
import 'Widgets/deletepanel.dart';
import 'Widgets/drawer.dart';

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
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();

    setState(() {
      _localIP = wifiIP!;
    });
    return;
  }

  List chats = MyStorage().ReadData(key: "chats") ?? [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blackbird.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
      ),

      drawer: isMobileMode(context: context)
          ? drawerChatList(context, _localIP)
          : null,
      // ignore: unnecessary_null_comparison
      body: chats == null || chats.isEmpty
          ? isMobileMode(context: context)
              ? Center(
                  child: Text(
                  "Your IP : $_localIP",
                ))
              : const Center(
                  child: Text('List of chat participants'),
                )
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    deleteSlide(
                      indexMap: index,
                      child: ListTile(
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
                          trailing: isMobileMode(context: context) == false
                              ? IconButton(
                                  onPressed: () async {
                                    await MyStorage().deletechat(index);
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    CupertinoIcons.delete,
                                    color: Colors.red.withOpacity(0.6),
                                  ))
                              : const Text("")),
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
        backgroundColor: Theme.of(context).textTheme.bodyLarge!.color,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Icon(
          Icons.add,
          color: Theme.of(context).scaffoldBackgroundColor,
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
