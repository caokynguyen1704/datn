import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:smartfan/control_screen.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

String getIP(String str, int i) {
  int count = 0;
  String res = "";
  for (int j = 0; j < str.length; j++) {
    res = res + str[j];
    if (str[j] == '.') {
      count++;
    }
    if (count >= 3) {
      return res + i.toString();
    }
  }
  return "";
}

String getGate(String str) {
  int count = 0;
  String res = "";
  for (int j = 0; j < str.length; j++) {
    if (str[j] == '.') {
      count++;
    }
    if (count >= 3) {
      return res;
    }
    res = res + str[j];
  }
  return "";
}

canConnect(String ip, String gate) {
  if (gate == "192.168.4.1") {
    return true;
  }
  if ((ip == gate) || (ip == "Chưa kết nối")) {
    return false;
  }
  return true;
}

Future getList() async {
  List<String> res = ["Chưa kết nối"];
  final info = NetworkInfo();
  var wifiGateway = await info.getWifiGatewayIP();
  var gate = getGate(wifiGateway.toString());
  print(gate);
  const port = 80;
  final stream = NetworkAnalyzer.discover2(
    gate,
    port,
    timeout: Duration(milliseconds: 4000),
  );

  int found = 0;
  stream.listen((NetworkAddress addr) {
    if (addr.exists) {
      res.add(addr.ip);
      found++;
      print('Found device: ${addr.ip}:$port');
    }
  });
  print("object");

  return res;
}

class WifiPage extends StatefulWidget {
  const WifiPage({Key? key}) : super(key: key);
  @override
  State<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  String _dropdownValue = "Chưa kết nối";
  List<String> listDevice = ["Chưa kết nối"];
  bool isLoading = false;
  bool isFirstLoad = true;
  String gate = "";
  bool isConnect = false;
  initState() {
    super.initState();
    final info = NetworkInfo();
    Future.delayed(Duration.zero, () async {
      var wifiGateway = await info.getWifiGatewayIP();
      setState(() {
        gate = wifiGateway.toString();
        print(gate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  "SmartFan",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 50),
                child: Material(
                  elevation: 10,
                  shadowColor: Colors.grey[100],
                  type: MaterialType.card,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(33)),
                  child: Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                        Container(
                          padding: EdgeInsets.only(right: 4),
                          child: FloatingActionButton(
                            backgroundColor: Colors.white,
                            heroTag: "_MAIN_FAB_0",
                            mini: true,
                            elevation: 0,
                            onPressed: () async {
                              setState(() {
                                listDevice = ["Chưa kết nối"];
                                _dropdownValue = "Chưa kết nối";
                                isLoading = true;
                              });

                              const port = 80;
                              print(getGate(gate));
                              final stream = NetworkAnalyzer.discover2(
                                getGate(gate),
                                port,
                                timeout: Duration(milliseconds: 4000),
                              );

                              stream.listen((NetworkAddress addr) {
                                if (addr.exists) {
                                  setState(() {
                                    listDevice.add(addr.ip);
                                  });

                                  print('Found device: ${addr.ip}:$port');
                                }
                              }).onDone(() {
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            },
                            child: isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                    strokeWidth: 2,
                                  )
                                : Icon(
                                    Icons.wifi,
                                    color: Colors.blue,
                                  ),
                          ),
                        ),
                        isLoading
                            ? Text("Đang quét...")
                            : isFirstLoad
                                ? FlatButton(
                                    onPressed: () async {
                                      setState(() {
                                        isLoading = true;
                                        isFirstLoad = false;
                                      });
                                      listDevice = ["Chưa kết nối"];

                                      const port = 80;
                                      final stream = NetworkAnalyzer.discover2(
                                        getGate(gate),
                                        port,
                                        timeout: Duration(milliseconds: 8000),
                                      );

                                      stream.listen((NetworkAddress addr) {
                                        if (addr.exists) {
                                          setState(() {
                                            listDevice.add(addr.ip);
                                          });

                                          print(
                                              'Found device: ${addr.ip}:$port');
                                        }
                                      }).onDone(() {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      });
                                    },
                                    child: Text("Nhấn để tìm!"))
                                : DropdownButton<String>(
                                    value: _dropdownValue,
                                    iconSize: 24,
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.deepPurple),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.white,
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _dropdownValue = newValue!;
                                      });
                                    },
                                    items: listDevice
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                        canConnect(_dropdownValue, gate)
                            ? Container(
                                padding: EdgeInsets.only(right: 4),
                                child: FloatingActionButton(
                                  backgroundColor: Colors.blue,
                                  heroTag: "_MAIN_FAB_1",
                                  mini: true,
                                  elevation: 0,
                                  onPressed: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RemotePage(ip: _dropdownValue),
                                        ));
                                  },
                                  child: isConnect
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2,
                                        )
                                      : Icon(Icons.arrow_forward),
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.only(right: 4),
                                child: FloatingActionButton(
                                  backgroundColor: Colors.grey,
                                  heroTag: "_MAIN_FAB_1",
                                  mini: true,
                                  elevation: 0,
                                  onPressed: () {},
                                  child: Icon(Icons.arrow_forward),
                                ),
                              ),
                      ])),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
