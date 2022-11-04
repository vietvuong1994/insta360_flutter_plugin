import 'package:flutter_test/flutter_test.dart';
import 'package:insta360_flutter_plugin/insta360_flutter_plugin.dart';
import 'package:insta360_flutter_plugin/insta360_flutter_plugin_platform_interface.dart';
import 'package:insta360_flutter_plugin/insta360_flutter_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInsta360FlutterPluginPlatform
    with MockPlatformInterfaceMixin
    implements Insta360FlutterPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Insta360FlutterPluginPlatform initialPlatform = Insta360FlutterPluginPlatform.instance;

  test('$MethodChannelInsta360FlutterPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInsta360FlutterPlugin>());
  });

  test('getPlatformVersion', () async {
    Insta360FlutterPlugin insta360FlutterPlugin = Insta360FlutterPlugin();
    MockInsta360FlutterPluginPlatform fakePlatform = MockInsta360FlutterPluginPlatform();
    Insta360FlutterPluginPlatform.instance = fakePlatform;

    expect(await insta360FlutterPlugin.getPlatformVersion(), '42');
  });
}
