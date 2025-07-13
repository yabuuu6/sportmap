import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<File> saveImageToLocal(XFile pickedImage) async {
  // Dapatkan direktori dokumen aplikasi
  final appDir = await getApplicationDocumentsDirectory();

  // Buat folder 'images' di dalam direktori aplikasi
  final imageFolder = Directory('${appDir.path}/images');
  if (!await imageFolder.exists()) {
    await imageFolder.create(recursive: true);
  }

  // Dapatkan nama file asli dari gambar
  final fileName = path.basename(pickedImage.path);

  // Salin file dari path sementara ke folder aplikasi
  final savedImage = await File(pickedImage.path).copy('${imageFolder.path}/$fileName');

  return savedImage;
}
