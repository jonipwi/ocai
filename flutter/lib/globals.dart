import 'dart:convert';
import 'package:http/http.dart' as http;

String? Question = '';
String? Answer = '';
String? Result = '';

bool loading = false;
bool askHitReady = false;
String? titlePage = 'Project 68AP';
int goToPage = 0;
String? deviceId = 'AndroidX-23';
String? versi = '1.0.0+1';
const serverToken = "[SERVER_BASE_API_TOKEN]";

Future<Null> AskAI(String deviceid, String q) async{

  Map<String, String> qParams = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${serverToken}',
    'x-device': '${deviceid}',
    'x-target': '${q}',
  };

  loading = true;

  String encoded = base64.encode(utf8.encode(q));
  String fetchRequestUrl = "https://dogemazon.net/ocai/gpt.php?cmd=prompt&q=${encoded}";
  try {
    final responseData = await http.get(
        Uri.parse(fetchRequestUrl),
        headers: qParams
    );
    if (responseData.statusCode == 200) {
      //print(responseData.body);
      final data = responseData.body.split('|');
      String decoded = utf8.decode(base64.decode(data[1]));
      Result = decoded;
      Answer = Result;
      loading = false;
    }
  } catch (e) {
    print('Answer: Error Http!');
  }

}