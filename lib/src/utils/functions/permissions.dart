import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart'; // Needed for Android version check
import 'package:url_launcher/url_launcher.dart';

Future<bool> requestCameraAndGalleryPermissions() async {
  bool granted = true;

  // 📸 Camera permission
  var cameraStatus = await Permission.camera.status;
  debugPrint("🔎 Current camera permission status: $cameraStatus");

  if (cameraStatus.isDenied || cameraStatus.isRestricted) {
    cameraStatus = await Permission.camera.request();
    debugPrint(cameraStatus.isGranted
        ? "✅ Camera permission granted"
        : "❌ Camera permission denied");
  }

  if (cameraStatus.isPermanentlyDenied) {
    debugPrint("⚠️ Camera permission permanently denied—directing user to settings.");
    openAppSettings();
    granted = false;
  }

  // 🖼️ Gallery / Photos permission (Handle Android 14 correctly)
  PermissionStatus galleryStatus;
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    int sdkVersion = androidInfo.version.sdkInt;

    if (sdkVersion <= 32) {
      galleryStatus = await Permission.storage.request();
      debugPrint(galleryStatus.isGranted
          ? "✅ Storage permission granted (Android <=32)"
          : "❌ Storage permission denied");
    } else {
      galleryStatus = await Permission.photos.request();
      debugPrint(galleryStatus.isGranted
          ? "✅ Photos permission granted (Android 13+)"
          : "❌ Photos permission denied");
    }
  } else if (Platform.isIOS) {
    galleryStatus = await Permission.photos.request();
    debugPrint(galleryStatus.isGranted ? "✅ Photos permission granted" : "❌ Photos permission denied");
  } else {
    galleryStatus = PermissionStatus.granted; // Fallback (Web/Desktop)
  }

  if (!galleryStatus.isGranted) {
    granted = false;
    debugPrint("⚠️ Gallery access denied, might need manual approval.");
  }

  // Final permission check before returning
  if (granted) {
    debugPrint("🎉 All permissions granted!");
  } else {
    debugPrint("🚨 Some permissions are missing, functionality may be limited.");
  }

  return granted;
}



