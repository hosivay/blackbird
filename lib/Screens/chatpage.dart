import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  Future<void> _initSocket() async {
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 12345);
      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = _socket!.receive();
          if (dg != null) {
            setState(() {
              _messages.add(String.fromCharCodes(dg.data).trim());
            });
          }
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _sendMessage() {
    try{
      if (_controller.text.isNotEmpty && _socket != null) {
      String message = '$_localIP: ${_controller.text}';
      _socket!.send(
        message.codeUnits,
        InternetAddress(widget.remoteIP, type: InternetAddressType.IPv4),
        12345,
      );

      setState(() {
        _messages.add(message);
      });
      _controller.clear();
    }
    }catch(e){
      print("error : $e");
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
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('Your Local IP: $_localIP'),
        ),
        Expanded(
          child: StreamBuilder(
            stream: _streamMessages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: 
                     Bubble(
                      message: _messages[index],
                      isMe: _messages[index].startsWith(_localIP),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter your message...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.paperplane_fill),
                onPressed: _sendMessage,
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

class Bubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const Bubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    double radiusbubble = 20;
    return Align(
      alignment: isMe == false ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.green,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(isMe == false ? 0 : radiusbubble),
              bottomRight: Radius.circular(isMe == false ? radiusbubble : 0),
              topLeft: Radius.circular(radiusbubble),
              topRight: Radius.circular(radiusbubble)),
        ),
        child: Text(
          message.split(':').sublist(1).join(':').trim(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
