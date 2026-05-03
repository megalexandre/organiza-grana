import 'dart:io';
import 'dart:typed_data';

void downloadFile(Uint8List bytes, String filename, String mime) {
  final home = Platform.environment['HOME'] ?? '.';
  final downloadsDir = Directory('$home/Downloads');
  final dir = downloadsDir.existsSync() ? downloadsDir : Directory(home);
  final file = File('${dir.path}/$filename');
  file.writeAsBytesSync(bytes);
}
