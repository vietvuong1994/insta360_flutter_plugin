import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:insta360_flutter_plugin/insta360_flutter_plugin.dart';
import 'package:insta360_flutter_plugin/models/gallery_item_model.dart';
import 'package:insta360_flutter_plugin/views/thumbnail.dart';
import 'package:insta360_flutter_plugin_example/pages/video_preview.dart';
import 'image_preview.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  Insta360FlutterPlugin instaPlugin = Insta360FlutterPlugin();
  List<GalleryItemModel> images = [];
  bool showCheck = false;
  List<int> indexChecked = [];

  @override
  void initState() {
    super.initState();
    getImages();
  }

  getImages() async {
    images = await instaPlugin.getGallery() ?? [];
    setState(() {});
  }

  deleteImages() async {
    try {
      if (indexChecked.isNotEmpty) {
        EasyLoading.show();
        List<String> urls = [];
        for (var index in indexChecked) {
          if (images[index].deleteUrls != null) {
            urls.addAll(images[index].deleteUrls!);
          }
        }
        await instaPlugin.deleteImages(urls);
        for (var element in indexChecked) {
          images.removeAt(element);
        }
        showCheck = false;
        indexChecked = [];
        setState(() {});
        EasyLoading.dismiss();
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  Widget _buildItem(int index) {
    GalleryItemModel data = images[index];
    return InkWell(
      onTap: () {
        if (showCheck) {
          if (indexChecked.contains(index)) {
            indexChecked.remove(index);
          } else {
            indexChecked.add(index);
          }
          setState(() {});
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => data.isVideo! ? VideoPreview(data: data) : ImagePreview(data: data)),
          );
        }
      },
      onLongPress: () {
        setState(() {
          indexChecked.add(index);
          showCheck = true;
        });
      },
      child: Stack(
        key: Key(data.urls!.first),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: ThumbnailView(
                onViewCreated: (ThumbnailViewController controller) {
                  controller.setUrls(data.urls!);
                },
              ),
            ),
          ),
          if (showCheck)
            Positioned(
              top: 25,
              right: 25,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: Colors.white,
                ),
                child: Icon(
                  indexChecked.contains(index) ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Device Gallery'),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          actions: [
            if (indexChecked.isNotEmpty)
              IconButton(
                onPressed: deleteImages,
                icon: const Icon(
                  Icons.delete_forever,
                  size: 30,
                ),
                color: Colors.white,
              ),
            if (showCheck)
              IconButton(
                onPressed: () {
                  setState(() {
                    showCheck = false;
                    indexChecked = [];
                  });
                },
                icon: const Icon(
                  Icons.close,
                  size: 30,
                ),
                color: Colors.white,
              )
          ],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index) {
            return _buildItem(index);
          },
        ),
      ),
    );
  }
}
