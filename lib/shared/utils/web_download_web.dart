import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void downloadFile(Uint8List bytes, String filename, String mime) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: mime),
  );
  final url = web.URL.createObjectURL(blob);
  web.HTMLAnchorElement()
    ..href = url
    ..setAttribute('download', filename)
    ..click();
  web.URL.revokeObjectURL(url);
}
