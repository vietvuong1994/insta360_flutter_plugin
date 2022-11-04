import 'package:flutter/material.dart';
import 'package:insta360_flutter_plugin/capture_player.dart';
import 'package:insta360_flutter_plugin/capture_player_listener.dart';

class Preview extends StatefulWidget {
  const Preview({Key? key}) : super(key: key);

  @override
  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  late CapturePlayerController _controller;
  bool isPlaying = false;

  onCapturePlayerCreated(CapturePlayerController controller) {
    _controller = controller;
    CapturePlayerListenerModel listener = CapturePlayerListenerModel(
        onPlayerStatusChanged: (bool playState){
          setState(() {
            isPlaying = playState;
          });
        }
    );
    _controller.onInit(listener);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play(){
    _controller.play();
  }

  void stop(){
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          leading: IconButton(onPressed: () {
            Navigator.of(context).pop();
          }, icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
        ),
        body:SizedBox(
          width: double.infinity,
          height: double.infinity,
          child:  Stack(
          children:[
            Positioned.fill(child: CapturePlayer(onViewCreated: onCapturePlayerCreated,),),
            Positioned(
              bottom: 20 + MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: isPlaying ? Colors.red : Colors.green,
                  ),
                  child: IconButton(
                    onPressed: () {
                      isPlaying ? stop() : play();
                    },
                    icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 50, color: Colors.white,),
                  ),
                ),
              )


          ),
        ],),
        ),
      ),
    );
  }
}
