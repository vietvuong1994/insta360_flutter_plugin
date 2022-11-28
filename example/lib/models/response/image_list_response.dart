class ImageListResponse {
  Error? error;
  List<Data>? data;

  ImageListResponse({this.error, this.data});

  ImageListResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'] != null ? Error.fromJson(json['error']) : null;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (error != null) {
      data['error'] = error!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Error {
  bool? status;
  String? message;

  Error({this.status, this.message});

  Error.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Data {
  int? id;
  String? path;
  String? name;
  int? status;

  Data({this.id, this.path, this.name, this.status});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    path = json['path'];
    name = json['name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['path'] = path;
    data['name'] = name;
    data['status'] = status;
    return data;
  }
}
