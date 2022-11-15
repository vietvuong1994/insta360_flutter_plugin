import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static final DownloadService _singleton = DownloadService._internal();

  factory DownloadService() {
    return _singleton;
  }

  DownloadService._internal();

  static Future<String?> download(String url) async {
    String externalDir = "";
    String filename = url.split('/').last;
    if (Platform.isAndroid) {
      externalDir = "/storage/emulated/0/Download";
    } else {
      Directory directory = await getApplicationDocumentsDirectory();
      externalDir = directory.path;
    }
    var httpClient = http.Client();
    var request = http.Request('GET', Uri.parse(url));
    var response = httpClient.send(request);
    String dir = externalDir;

    List<List<int>> chunks = [];
    int downloaded = 0;

    response.asStream().listen((http.StreamedResponse r) {
      r.stream.listen((List<int> chunk) {
        // Display percentage of completion
        print('downloadPercentage: ${downloaded / (r.contentLength ?? 0) * 100}');

        chunks.add(chunk);
        downloaded += chunk.length;
      }, onDone: () async {
        // Display percentage of completion
        print('downloadPercentage: ${downloaded / (r.contentLength ?? 0) * 100}');
        print('$dir/$filename');
        // Save the file
        File file = File('$dir/$filename');
        final Uint8List bytes = Uint8List(r.contentLength ?? 0);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        await file.writeAsBytes(bytes);
        return;
      });
    });
  }
}
