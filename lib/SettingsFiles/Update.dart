


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
Future<String?> getLatestRelease() async {
  var url = Uri.parse('https://api.github.com/repos/hosivay/blackbird/releases/latest');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var releaseInfo = json.decode(response.body);
    var latestVersion = releaseInfo['tag_name'];
  
    return latestVersion;
  } else {
    return null;
  }
}
  

launchURL({bool update = true}) async {
   var url = update ? 'https://github.com/hosivay/blackbird/releases' : 'https://github.com/hosivay/'; 
  var uri = Uri.parse(url);

  
    // ignore: deprecated_member_use
    await launch(uri.toString());
  
}

