class GalleryItemModel {
  List<String>? urls;
  List<String>? deleteUrls;
  bool? isVideo;
  int? duration;

  GalleryItemModel({this.urls, this.deleteUrls, this.isVideo = false, this.duration});

  GalleryItemModel.fromJson(Map<String, dynamic> json) {
    urls = json['urls'].cast<String>();
    deleteUrls = json['deleteUrls'].cast<String>();
    isVideo = json['isVideo'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['urls'] = urls;
    data['deleteUrls'] = deleteUrls;
    data['isVideo'] = isVideo;
    data['duration'] = duration;
    return data;
  }
}
