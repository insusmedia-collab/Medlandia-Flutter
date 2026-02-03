import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:async';
import 'package:package_info_plus/package_info_plus.dart';

final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

String? appName;
String? appPackageName;
String? appVersion;
String? appBuildNumber;
String? devModel;
String? devVersion;

Future<void> initPlatformState() async {
  devModel = await getModel();
  devVersion = await getVersion();

  final packageInfo = await PackageInfo.fromPlatform();

  appName = packageInfo.appName;
  appPackageName = packageInfo.packageName;
  appVersion = packageInfo.version;
  appBuildNumber = packageInfo.buildNumber;

print("appVersion=$appVersion");
print("appBuildNumber=$appBuildNumber");

}

Future<String?> getModel() async {
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.model;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    return iosInfo.name;
  } else {
    return "Not yet implemented";
  }
}

Future<String?> getVersion() async {
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.version.sdkInt.toString();
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    return iosInfo.systemVersion;
  } else {
    return "Not yet implemented";
  }
}
