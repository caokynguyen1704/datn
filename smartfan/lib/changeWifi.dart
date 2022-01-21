import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:smartfan/tcp.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:io' show Platform;

Future<List<WifiNetwork>> loadWifiList() async {
  List<WifiNetwork> htResultNetwork;
  try {
    htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
  } on PlatformException {
    htResultNetwork = <WifiNetwork>[];
  }
  return htResultNetwork;
}

class WifiPageChange extends StatefulWidget {
  const WifiPageChange({Key? key, required this.ip}) : super(key: key);

  final String ip;

  @override
  State<WifiPageChange> createState() => _WifiPageState();
}

List<String> listWifi = [""];

class _WifiPageState extends State<WifiPageChange> {
  String dropdownValue = "";
  bool isSearch = false;
  TextEditingController passWifi = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      appBar: AppBar(
        title: Text(widget.ip),
        titleSpacing: 2.0,
        backgroundColor: Colors.white24,
      ),
      body: Container(
          child: Container(
        color: Colors.grey[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Thay đổi kết nối",
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Tên SSID: "),
                isSearch
                    ? DropdownButton<String>(
                        value: dropdownValue,
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: listWifi
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                    : FlatButton(
                        onPressed: () async {
                          List<WifiNetwork> listWNWF = await loadWifiList();
                          listWifi = [""];
                          for (int i = 0; i < listWNWF.length; i++) {
                            print(listWNWF[i].ssid.toString() +
                                "___" +
                                listWNWF[i].capabilities.toString());
                            setState(() {
                              listWifi.add(listWNWF[i].ssid.toString());
                            });
                          }
                          setState(() {
                            isSearch = true;
                          });
                          print(listWifi.length);
                        },
                        child: Text("Nhấn để tìm..."))
              ],
            ),
            isSearch
                ? Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextField(
                      controller: passWifi,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mật khẩu',
                      ),
                    ),
                  )
                : SizedBox(),
            RaisedButton(
              onPressed: () async {
                await send(InternetAddress(widget.ip),
                    '{"mode":99,"name":"${dropdownValue}","pass":"${passWifi.text}"}');
                exit(0);
              },
              child: Text("Đổi"),
            )
          ],
        ),
      )),
    );
  }
}
