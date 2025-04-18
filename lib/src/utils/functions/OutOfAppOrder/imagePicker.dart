import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import '../../../localizations/AppLocalizations.dart';
import '../../../xrint.dart';

Future<bool> _isImageSizeValid(File imageFile) async {
  final fileSize = await imageFile.length();
  return fileSize <= 3 * 1024 * 1024; // 3MB
}

Future<File> pickImage(BuildContext context, WidgetRef ref) async {
  final _picker = ImagePicker();

  PermissionStatus status = await Permission.photos.request();
  if (!status.isGranted) {
    return null;
  }

  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    File imageFile = File(pickedFile.path);

    if (await _isImageSizeValid(imageFile)) {
      return imageFile;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "${AppLocalizations.of(context).translate('image_size_exceed')}",
            style: TextStyle(color: Colors.white)),
      ));
      return null;
    }
  }

  return null; // Return null if no file was picked
}

Future<void> removeImageFromCache(String imagePath) async {
  final file = File(imagePath);
  if (await file.exists()) {
    await file.delete();
    xrint("Image deleted from cache: $imagePath");
  }
}
