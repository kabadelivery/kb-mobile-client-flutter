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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
Future<bool> _isImageSizeValid(File imageFile) async {
  final fileSize = await imageFile.length();
  return fileSize <= 15 * 1024 * 1024; // 3MB
}

Future<File?> pickImageIOS(BuildContext context, WidgetRef ref) async {
  final ImagePicker picker = ImagePicker();
  if (Platform.isAndroid && Platform.version.compareTo('13') < 0) {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      return null;
    }
  }
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
  );
  if (image != null) {
    final file = File(image.path);

    if (await _isImageSizeValid(file)) {
      return file;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('image_size_exceed'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  return null; // No file selected or invalid image
}
Future<File?> pickImageAndroid(BuildContext context, WidgetRef ref) async {
  if (Platform.isAndroid && Platform.version.compareTo('13') >= 0) {
    const MethodChannel methodChannel = MethodChannel('photo_picker_method_channel');

    try {
      final String? path = await methodChannel.invokeMethod('pickMedia', <String, String>{
        'file_type': 'image',
      });

      if (path != null) {
        final file = File(path);
        if (await _isImageSizeValid(file)) {
          return file;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.translate('image_size_exceed'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Error picking image: ${e.message}');
    }

    return null;
  } else {
    // Use image_picker on Android <13 or iOS
    final ImagePicker picker = ImagePicker();

    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) return null;
    }

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);

      if (await _isImageSizeValid(file)) {
        return file;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('image_size_exceed'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }

    return null;
  }
}


Future<void> removeImageFromCache(String imagePath) async {
  final file = File(imagePath);
  if (await file.exists()) {
    await file.delete();
    xrint("Image deleted from cache: $imagePath");
  }
}
Future<XFile?> compressImage(File file) async {
  try{
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
  }catch(e){
    return null;
  }

}
