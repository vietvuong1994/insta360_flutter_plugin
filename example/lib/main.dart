
import 'package:flutter/material.dart';
import 'package:insta360_flutter_plugin/insta360_flutter_plugin.dart';
import 'dart:async';
import 'package:insta360_flutter_plugin/insta_listener_model.dart';
import 'package:insta360_flutter_plugin_example/preview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _insta360PluginFlutterPlugin = Insta360FlutterPlugin();
  bool connected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    InstaListenerModel callbacks = InstaListenerModel(
        onCameraStatusChanged:(bool enabled){
          setState(() {
            connected = enabled;
          });
        },
        onCameraConnectError:(int error){
          setState(() {
            connected = false;
          });
        }
    );
    _insta360PluginFlutterPlugin.listener(callbacks);
  }

  connectWifi(){
    _insta360PluginFlutterPlugin.connectByWifi();
  }

  disconnectWifi(){
    _insta360PluginFlutterPlugin.closeCamera();
  }

  navToPreview(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Preview()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Connection Status: ${connected ? "Connected" : "Not Connected"}"),
          const SizedBox(height: 30,),
          if(connected)
            ElevatedButton(onPressed: disconnectWifi, child: const Text('Disconnect'),)
          else
            ElevatedButton(onPressed: connectWifi, child: const Text('Connect Wifi'),),
          ElevatedButton(onPressed: connected ? (){
            navToPreview(context);
          } : null, child: const Text('Preview'),),
        ],
      ),),
    );
  }
}

