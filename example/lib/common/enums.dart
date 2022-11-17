enum CameraType {
  capture,
  record,
}

extension CameraTypeExtension on CameraType {
  String get title {
    switch (this) {
      case CameraType.capture:
        return 'Ảnh';
      case CameraType.record:
        return 'Video';
      default:
        return 'Video';
    }
  }
}
