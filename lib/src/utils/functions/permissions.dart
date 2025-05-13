import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraAndGalleryPermissions() async {
  bool granted = true;

  // 📸 Camera permission
  var cameraStatus = await Permission.camera.status;

  if (!cameraStatus.isGranted) {
    cameraStatus = await Permission.camera.request();
  }
  if (!cameraStatus.isGranted) {
    print("❌ Camera permission denied");
    granted = false;
  }

  // 🖼️ Gallery / Photos permission
  var photosStatus = await Permission.photos.status;
  if (!photosStatus.isGranted) {
    photosStatus = await Permission.photos.request();
  }
  if (!photosStatus.isGranted) {
    print("❌ Gallery access denied");
    granted = false;
  }

  if (granted) {
    print("✅ All permissions granted");
  }

  return granted;
}
