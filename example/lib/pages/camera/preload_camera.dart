import 'package:flutter/material.dart';
import 'camera.dart';

class PreloadPreview extends StatefulWidget {
  const PreloadPreview({Key? key}) : super(key: key);

  @override
  State<PreloadPreview> createState() => _PreloadPreviewState();
}

class _PreloadPreviewState extends State<PreloadPreview> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const Camera(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
      ),
    );
  }
}
