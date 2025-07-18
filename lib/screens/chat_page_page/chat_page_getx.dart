import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:math';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
class ChatPageController extends GetxController {
  final TextEditingController controller = TextEditingController();
  final List<String> messages = [];
  RawDatagramSocket? socket;
  String localIP = '';

  Future<void> getLocalIP() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();

    localIP = wifiIP!;

    update();
  }

  Stream<List<String>> streamMessages() async* {
    while (true) {
      yield messages;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void sendMessage({required String remoteIP}) {
    try {
      if (controller.text.isNotEmpty && socket != null) {
        DateTime date = DateTime.now();
        String message = '$localIP ~ ${controller.text} ~ $date';
        List<int> encodedMessage = utf8.encode(message);
        socket!.send(
          encodedMessage,
          InternetAddress(remoteIP, type: InternetAddressType.IPv4),
          12345,
        );

        messages.add(message);
        update();
        controller.clear();
      }
    } catch (e) {
      print("error : $e");
    }
  }

  Future<void> initSocket() async {
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 12345);
      socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = socket!.receive();
          if (dg != null) {
            String decodedMessage = utf8.decode(dg.data);

            messages.add(decodedMessage);
            update();
          }
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void showInfoDialog(
      {required BuildContext context,
      required String name,
      required String remoteIP}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chat Information'),
          content: SizedBox(
              height: MediaQuery.sizeOf(context).height / 4,
              child: Text("Name : $name \nip Address : $remoteIP")),
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


  // send and receive files 

// Future<void> pickFile(String remoteIP) async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles();
//   if (result != null) {
//     File file = File(result.files.single.path!);
//     print("result.files.single.name : ${result.files.single.name}");
//     await sendFile(file, remoteIP, '${result.files.single.name}');
//   }
// }

// Future<void> sendFile(File file, String remoteIP, String filename) async {
//   try {
//     if (socket != null) {
//       List<int> bytes = await file.readAsBytes();

//       socket!.send(
//         bytes,
//         InternetAddress(remoteIP, type: InternetAddressType.IPv4),
//         12345,
//       );
//       DateTime date = DateTime.now();
//       String message = '$localIP ~ $filename\nFile sent successfully ~ $date';
//       List<int> encodedMessage = utf8.encode(message);
//       socket!.send(
//         encodedMessage,
//         InternetAddress(remoteIP, type: InternetAddressType.IPv4),
//         12345,
//       );
//       messages.add(message);
//       update();
//       print('$filename File sent successfully');
//     }
//   } catch (e) {
//     print("Error sending file: $e");
//   }
// }

// void receiveFile(List<int> data, String fileName) {
//   try {
//     String platformPath = Platform.isAndroid
//         ? '/storage/emulated/0/Download/'
//         : Platform.isWindows
//             ? 'C:\\BlackBird files\\'
//             : ''; // اضافه کردن مسیرهای دیگر برای سایر سیستم‌عامل‌ها
//     print("platformPath : $platformPath");
//     File file = File('$platformPath$fileName');
//     file.writeAsBytes(data, flush: true);
//     print('File received and saved as ${file.path}');
//   } catch (e) {
//     print("Error receiving file: $e");
//   }
// }
// void startFileReceiver() {
//   ServerSocket.bind(InternetAddress.anyIPv4, 12345).then((ServerSocket serverSocket) {
//     serverSocket.listen((Socket clientSocket) {
//       clientSocket.listen((List<int> data) {
//         String randomFileName = generateRandomFileName();
//         receiveFile(data, randomFileName);
//       });
//     });
//   });
// }
// String generateRandomFileName() {
//   const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
//   final random = Random.secure();
//   return List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
// }
}
