class UploadResponse {
  Error? error;
  Data? data;

  UploadResponse({this.error, this.data});

  UploadResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'] != null ? Error.fromJson(json['error']) : null;
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (error != null) {
      data['error'] = error!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
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
  String? name;

  Data({this.name});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}
