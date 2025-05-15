import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import '../../../localizations/AppLocalizations.dart';
import '../../../xrint.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
Future<bool> _isImageSizeValid(File imageFile) async {
  final fileSize = await imageFile.length();
  return fileSize <= 15 * 1024 * 1024; // 3MB
}

Future<File?> pickImage(BuildContext context, WidgetRef ref) async {
  // Request photo access permission (for Android <= 12 or if you're being safe)
  final status = await Permission.photos.request();
  final storage_status = await Permission.storage.request();
  if (!status.isGranted &&!storage_status.isGranted) {
    return null;
  }

  // Open file picker
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: false, // if you only need the path
  );

  if (result != null && result.files.isNotEmpty) {
    final file = File(result.files.first.path!);

    if (await _isImageSizeValid(file)) {
      return file;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${AppLocalizations.of(context)!.translate('image_size_exceed')}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
      return null;
    }
  }

  return null; // No file selected
}
Future<void> removeImageFromCache(String imagePath) async {
  final file = File(imagePath);
  if (await file.exists()) {
    await file.delete();
    xrint("Image deleted from cache: $imagePath");
  }
}




Future<XFile?> compressImage(File file) async {
  final dir = await getTemporaryDirectory();
  final targetPath = p.join(dir.path, "compressed_${p.basename(file.path)}");

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 70,
    minWidth: 800,
    minHeight: 800,
    format: file.absolute.path.contains("png")?CompressFormat.png:file.absolute.path.contains("jpeg")?CompressFormat.jpeg:CompressFormat.heic,
  );
  if (result != null) {
    final compressedSize = await result.length();
    xrint("Compressed image size: ${(compressedSize / (1024 * 1024)).toStringAsFixed(2)} MB");
  } else {
    xrint("Compression failed, result is null.");
  }
  return result;
}
