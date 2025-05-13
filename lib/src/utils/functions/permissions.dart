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
  PermissionStatus galleryStatus;

  if (Platform.isAndroid) {
    // Android 13+ prefers these specific permissions
    if (await Permission.photos.isGranted) {
      galleryStatus = await Permission.photos.status;
    } else {
      galleryStatus = await Permission.photos.request();
    }
  } else if (Platform.isIOS) {
    final cameraStatus = await Permission.camera.request();
    final photosStatus = await Permission.photos.request();

    return cameraStatus.isGranted && photosStatus.isGranted;
  }else {
    galleryStatus = PermissionStatus.granted; // fallback (e.g., web or desktop)
  }

  if (!galleryStatus.isGranted) {
    print("❌ Gallery access denied");
    granted = false;
  }

  if (granted) {
    print("✅ All permissions granted");
  }

  return granted;
}
