import 'package:hive_flutter/hive_flutter.dart';

class MyStorage {
  final _mybox = Hive.box('myBox');

  WriteData({required String key, required var value}) {
    // ignore: unused_local_variable
    var add = _mybox.put(key, value);
  }
//

  ReadData({required String key}) {
    return _mybox.get(key);
  }

  deleteHive({required String key}) {
    _mybox.delete(key);
  }


deletechat(index){
   List _chats = MyStorage().ReadData(key: "chats");
   _chats.removeAt(index);
    List chatsnew = _chats;
      MyStorage().deleteHive(key: "chats");
      MyStorage().WriteData(key: "chats" ,value: chatsnew);
}

  addChat({required String name, required String ip}) {
    if (MyStorage().ReadData(key: "chats") == null ) {
      MyStorage().WriteData(key: "chats", value: [
        {
          "name": name,
          "ip": ip,
        },
      ]);
    } else {
      List _chats = MyStorage().ReadData(key: "chats");
      _chats.add(
        {
          "name": name,
          "ip": ip,
        },
      );
      MyStorage().WriteData(key: "chats", value: _chats);
    
    }
  }
}
