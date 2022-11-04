# insta360_flutter_plugin

A new Flutter plugin project.

## Getting Started

# Config IOs
Copy files: INSCameraSDK.framework, INSCameraSDK.framework.dSYM, INSCameraSDK.xcframework, INSCoreMedia.framework, XLForm.framework from native SDK to insta360_flutter_plugin/ios folder.

Update your Project/ios/Runner/Info.plist:

```python
<key>UISupportedExternalAccessoryProtocols</key>
<array>
    <string>com.insta360.nanoscontrol</string>
    <string>com.insta360.onecontrol</string>
    <string>com.insta360.onexcontrol</string>
    <string>com.insta360.onex2control</string>
    <string>com.insta360.onercontrol</string>
    <string>com.insta360.camera</string>
</array>
```
