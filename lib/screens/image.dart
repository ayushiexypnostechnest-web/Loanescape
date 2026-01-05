import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

Future<File> savePickedImagePermanently(XFile pickedFile) async {
  final directory = await getApplicationDocumentsDirectory();
  final newPath = join(directory.path, basename(pickedFile.path));
  return File(pickedFile.path).copy(newPath);
}
  