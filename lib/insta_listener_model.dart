class InstaListenerModel {
  Function(bool)? onCameraStatusChanged;
  Function(int)? onCameraConnectError;

  InstaListenerModel({
    this.onCameraStatusChanged,
    this.onCameraConnectError,
  });
}