import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartfan/changeWifi.dart';
import 'package:smartfan/tcp.dart';
import 'package:smartfan/wifiConnect_screen.dart';

class RemotePage extends StatefulWidget {
  const RemotePage({Key? key, required this.ip}) : super(key: key);

  final String ip;

  @override
  State<RemotePage> createState() => _RemotePageState();
}

late Future<FanInform> futureData;

class _RemotePageState extends State<RemotePage> {
  int speed = 0;
  int timer = 0;

  @override
  @override
  void initState() {
    super.initState();
    futureData = fetchData(widget.ip);
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        futureData = fetchData(widget.ip);
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      appBar: AppBar(
        title: Text(widget.ip),
        // titleSpacing: 2.0,
        backgroundColor: Colors.white24,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                FutureBuilder<FanInform>(
                  future: futureData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              color: snapshot.data!.mode == 1
                                  ? Colors.white
                                  : Colors.grey,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.ac_unit,
                                    size: 40,
                                  ),
                                  Text(snapshot.data!.speed.toString())
                                ],
                              ),
                            ),
                            Container(
                                color: snapshot.data!.mode == 2
                                    ? Colors.white
                                    : Colors.grey,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.grass,
                                      size: 40,
                                    ),
                                    Text("Tự Nhiên")
                                  ],
                                )),
                            Container(
                                color: snapshot.data!.mode == 3
                                    ? Colors.white
                                    : Colors.grey,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      size: 40,
                                    ),
                                    Text(snapshot.data!.timer.toString())
                                  ],
                                )),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return FlatButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WifiPage(),
                                ));
                          },
                          child: Text(
                              "Lỗi cấu hình, vui lòng chọn thiết bị khác"));
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: ClipOval(
                    child: Material(
                      child: InkWell(
                        splashColor: Colors.white24,
                        child: SizedBox(
                          height: 56,
                          width: 56,
                          child: Icon(Icons.settings),
                        ),
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WifiPageChange(ip: widget.ip),
                              ));
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  child: ClipOval(
                    child: Material(
                      color: Colors.red,
                      child: InkWell(
                        splashColor: Colors.white24,
                        child: SizedBox(
                          height: 56,
                          width: 56,
                          child: Icon(Icons.power_settings_new),
                        ),
                        onTap: () async {
                          await send(InternetAddress(widget.ip),
                              '{"mode":1,"timer":0,"wind":0}');
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  child: ClipOval(
                    child: Material(
                      child: InkWell(
                        splashColor: Colors.white24,
                        child: SizedBox(
                          height: 56,
                          width: 56,
                          child: Icon(Icons.bubble_chart),
                        ),
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: ClipOval(
                    child: Material(
                      child: InkWell(
                        splashColor: Colors.white24,
                        child: SizedBox(
                          height: 56,
                          width: 56,
                          child: Icon(Icons.ac_unit),
                        ),
                        onTap: () async {
                          await send(InternetAddress(widget.ip),
                              '{"mode":1,"timer":${timer},"wind":${speed}}');
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  child: ClipOval(
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: Colors.white24,
                        child: SizedBox(
                          height: 56,
                          width: 56,
                          child: Icon(Icons.grass),
                        ),
                        onTap: () async {
                          await send(InternetAddress(widget.ip),
                              '{"mode":2,"timer":${timer},"wind":${speed}}');
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  child: ClipOval(
                    child: Material(
                      child: InkWell(
                        splashColor: Colors.white24,
                        child: SizedBox(
                          height: 56,
                          width: 56,
                          child: Icon(Icons.timer),
                        ),
                        onTap: () async {
                          await send(InternetAddress(widget.ip),
                              '{"mode":3,"timer":${timer},"wind":${speed}}');
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.height / 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              speed++;
                              if (speed > 13) {
                                speed = 13;
                              }
                            });
                          },
                          icon: Icon(Icons.arrow_drop_up)),
                      Text(
                        'Tốc độ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        speed.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              speed--;
                              if (speed < 0) {
                                speed = 0;
                              }
                            });
                          },
                          icon: Icon(Icons.arrow_drop_down)),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.height / 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: []),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.height / 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              timer++;
                              if (timer > 99) {
                                timer = 99;
                              }
                            });
                          },
                          icon: Icon(Icons.arrow_drop_up)),
                      Text(
                        'Hẹn giờ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timer.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              timer--;
                              if (timer < 0) {
                                timer = 0;
                              }
                            });
                          },
                          icon: Icon(Icons.arrow_drop_up)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
