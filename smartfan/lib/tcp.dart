import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> send(InternetAddress clientAddress, String jsondata) async {
  int port = 17499;
  String rep = "";
  var values = await RawDatagramSocket.bind(InternetAddress.ANY_IP_V4, 0);
  print(jsondata);
  RawDatagramSocket udpSocket = values;
  var i = await udpSocket.listen((RawSocketEvent e) {
    switch (e) {
      case RawSocketEvent.READ:
        udpSocket.writeEventsEnabled = true;
        udpSocket.close();
        break;
      case RawSocketEvent.WRITE:
        udpSocket.send(new Utf8Codec().encode(jsondata), clientAddress, port);
        udpSocket.close();
        break;
      case RawSocketEvent.CLOSED:
        print("close");
    }
  });
}

class FanInform {
  final int mode;
  final int speed;
  final int timer;

  FanInform({
    required this.mode,
    required this.speed,
    required this.timer,
  });

  factory FanInform.fromJson(Map<String, dynamic> json) {
    return FanInform(
      mode: json['mode'],
      speed: json['speed'],
      timer: json['timer'],
    );
  }
}

Future<FanInform> fetchData(String url) async {
  final response = await http.get(Uri.parse("http://" + url));
  if (response.statusCode == 200) {
    return FanInform.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}
