class CapturePlayerListenerModel {
  Function(bool) onPlayerStatusChanged;
  Function(CaptureState) onCaptureStatusChanged;
  Function(int) onCaptureTimeChanged;
  Function(List<String>) onCaptureFinish;

  CapturePlayerListenerModel({
    required this.onPlayerStatusChanged,
    required this.onCaptureStatusChanged,
    required this.onCaptureTimeChanged,
    required this.onCaptureFinish,
  });
}

enum CaptureState {
  start,
  loading,
  stop,
}
