import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:blackbird/Screens/ChatPage/Widgets/Bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:network_info_plus/network_info_plus.dart';

class ChatScreen extends StatefulWidget {
  final String remoteIP;
  final String name;

  ChatScreen({required this.remoteIP, required this.name});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  RawDatagramSocket? _socket;
  String _localIP = '';
  bool _chatStarted = false;

  @override
  void initState() {
    super.initState();
    _getLocalIP();
    _initSocket();
    _startChatAfterDelay();
  }

  Future<void> _getLocalIP() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP(); 
    setState(() {
      _localIP = wifiIP!;
    });
    return;
  }

  void _sendMessage() {
    try {
      if (_controller.text.isNotEmpty && _socket != null) {
        DateTime date = DateTime.now();
        String message = '$_localIP ~ ${_controller.text} ~ $date';
        List<int> encodedMessage = utf8.encode(message);
        _socket!.send(
          encodedMessage,
          InternetAddress(widget.remoteIP, type: InternetAddressType.IPv4),
          12345,
        );

        setState(() {
          _messages.add(message);
        });
        _controller.clear();
      }
    } catch (e) {
      print("error : $e");
    }
  }

  Future<void> _initSocket() async {
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 12345);
      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = _socket!.receive();
          if (dg != null) {
            String decodedMessage = utf8.decode(dg.data);
            setState(() {
              _messages.add(decodedMessage);
            });
          }
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chat Information'),
          content: SizedBox(
              height: MediaQuery.sizeOf(context).height / 4,
              child: Text(
                  "Name : ${widget.name} \nip Address : ${widget.remoteIP}")),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.name}'),
        actions: [
          IconButton(
              onPressed: () {
                _showInfoDialog(context);
              },
              icon: const Icon(CupertinoIcons.info))
        ],
      ),
      body: !_chatStarted ? _buildWaitingPage() : _buildChatPage(),
    );
  }

  Widget _buildWaitingPage() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildChatPage() {
    final isDarkMode =
        // ignore: deprecated_member_use
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark;

        print(isDarkMode);
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              StreamBuilder(
                stream: _streamMessages(),
                builder: (context, snapshot) { 
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: _messages.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          SizedBox(height: index == 0 ? 65 : 0),
                          ListTile(
                            title: Bubble(
                              message: _messages[index],
                              isMe: _messages[index].startsWith(_localIP),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                 color: Theme.of(context).focusColor,
                  child: ListTile(
                    title: Text('Your Local IP: $_localIP'),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Enter your message...',
                          ),
                          keyboardType: TextInputType.text,
                          onSubmitted: (String value) {
                            _sendMessage();
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.paperplane_fill),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Stream<List<String>> _streamMessages() async* {
    while (true) {
      yield _messages;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void _startChatAfterDelay() {
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _chatStarted = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _socket?.close();
  }
}
