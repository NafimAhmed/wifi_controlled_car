


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class Home extends StatefulWidget{

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late bool ledstatus;
 //boolean value to track LED status, if its ON or OFF
  late IOWebSocketChannel channel;

  late bool connected;
 //boolean value to track if WebSocket is connected
  @override
  void initState() {
    ledstatus = false; //initially leadstatus is off so its FALSE
    connected = false; //initially connection status is "NO" so its FALSE

    Future.delayed(Duration.zero, () async {
      channelconnect(); //connect to WebSocket wth NodeMCU
    });

    super.initState();
  }

  channelconnect() {
    //function to connect
    try {
      channel = IOWebSocketChannel.connect("ws://192.168.0.1:81"); //channel IP : Port
      channel.stream.listen(
            (message) {
          print(message);
          setState(() {
            if (message == "connected") {
              connected = true; //message is "connected" from NodeMCU
            } else if (message == "poweron:success") {
              ledstatus = true;
            } else if (message == "poweroff:success") {
              ledstatus = false;
            }
          });
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      if (ledstatus == false && cmd != "poweron" && cmd != "poweroff") {
        print("Send the valid command");
      } else {
        channel.sink.add(cmd); //sending Command to NodeMCU
      }
    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Remote"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [


          Container(
              child: connected
                  ? Text("WEBSOCKET: CONNECTED")
                  : Text("DISCONNECTED")),

          Row(
            children: [
              ElevatedButton(onPressed: (){
                sendcmd("fronton");
              }, child: Text(" font on")),
              ElevatedButton(onPressed: (){

                sendcmd("frontoff");
              }, child: Text(" font off")),
            ],
          ),
          Row(
            children: [
              ElevatedButton(onPressed: (){

                sendcmd("backon");

              }, child: Text("Back on")),
              ElevatedButton(onPressed: (){
                sendcmd("backoff");
              }, child: Text("back off")),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                  onPressed: (){
                sendcmd("lefton");},
                  child: Text("Left on")),
              ElevatedButton(
                  onPressed: (){
                    sendcmd("leftoff");
                    },
                  child: Text("Left off")),
            ],
          ),
          Row(
            children: [
              ElevatedButton(onPressed: (){sendcmd("righton");}, child: Text("Right on")),
              ElevatedButton(onPressed: (){sendcmd("rightoff");}, child: Text("Right off")),
            ],
          ),




        ],
      ),
    );
  }
}