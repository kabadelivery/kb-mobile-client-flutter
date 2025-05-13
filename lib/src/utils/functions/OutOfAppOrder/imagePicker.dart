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

Future<bool> _isImageSizeValid(File imageFile) async {
  final fileSize = await imageFile.length();
  return fileSize <= 3 * 1024 * 1024; // 3MB
}

Future<File?> pickImage(BuildContext context, WidgetRef ref) async {
  // Request photo access permission (for Android <= 12 or if you're being safe)
  final status = await Permission.photos.request();
  if (!status.isGranted) {
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
