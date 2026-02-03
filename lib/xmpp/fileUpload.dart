import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';


import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileUpload {
  Future<int> sendFile({
    required String largeText,
    int chunkSize = 50000,
    int maxRetries = 3,
    required String fileType,
    required int fileSizeInBytes,
    Function(int received, int total)? onProgress
  }) async {
    final totalLength = largeText.length;
    int sent = 0;
    int rowId = 0;
    final client = http.Client();

    try {
      while (sent < totalLength) {
        final end =
            (sent + chunkSize) < totalLength ? sent + chunkSize : totalLength;
        final chunk = largeText.substring(sent, end);

        int attempt = 0;
        bool success = false;

        while (attempt < maxRetries && !success) {
          attempt++;
          try {
            var response = await client.post(
              Uri.https('medlandia.org', 'medlandia.jsp'),
              body: {'func': 'upload', 'p1': chunk, 'p2' : rowId.toString(), 'p3' : fileSizeInBytes.toString(), 'p4' : fileType},
            );

            if (response.statusCode == 200) {
              rowId = int.parse(response.body);
              success = true;
              sent = end;
              
            } else {
              throw Exception('Server responded with ${response.statusCode}');
            }
            if (onProgress != null) {
              onProgress(sent, totalLength);
            }
          } catch (e) {
            if (attempt == maxRetries) {
              rethrow;
            }
           
            await Future.delayed(
              Duration(seconds: attempt * 2),
            ); // Exponential backoff
          }
        }
      }

      
    } finally {
      client.close();
    }
    return rowId;
  }

  Future<String> downloadFile(String url, File file, {Function(int received, int total)? onProgress, int totalLenght=0}) async {
    // Check storage permission
    /*
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission not granted');
    }*/
  
    // Create the request
    final response = await http.Client().send(http.Request('GET', Uri.parse(url)));

    // Get the documents directory

    //final directory = await getApplicationDocumentsDirectory();
    
    //final file = File('${directory.path}/$fileName');    
    

    // Track progress
    //final contentLength = response.contentLength ?? 0;
    int received = 0;

    // Open the file for writing
    final sink =  file.openWrite();

    // Process the stream
    await response.stream.listen(
      (List<int> chunk) {
        received += chunk.length;
        sink.add(chunk);
        if (onProgress != null) {
          onProgress(received, totalLenght);
          
        }
      },
      onDone: () async {
       
        await sink.close();        
      },
      onError: (e) {
        print("==>$e");
        sink.close();
        file.deleteSync(); // Remove partially downloaded file
        throw e;
      },
      cancelOnError: true,
    ).asFuture();

    return file.path;
  }

static Future<Uint8List> readFileAsUint8List(String filePath) async {
  try {
    File file = File(filePath);
    Uint8List bytes = await file.readAsBytes();
    return bytes;
  } catch (e) {
    print('==>Error reading file: $e');
    rethrow; // or return Uint8List(0) for empty bytes
  }
}

static Future<String> getBase64String(String filePath) async {
  // Read the file as bytes
  final bytes = await File(filePath).readAsBytes();
  
  // Convert bytes to base64 string
  final base64String = base64Encode(bytes);
  
  return base64String;
}

static Future<Uint8List> zipByteArray(Uint8List input) async {
  // Create an encoder
  final encoder = ZipEncoder();
  
  // Create an archive
  final archive = Archive();
  
  // Add the byte array as a file to the archive
  archive.addFile(ArchiveFile('data.bin', input.length, input));
  
  // Encode the archive to a zip file
  final zipData = encoder.encode(archive);
  
  return Uint8List.fromList(zipData);
}

static Future<int> getFileSize(String filePath) async {
  final file = File(filePath);
  try {
    // Get file size in bytes
    final bytes = await file.length();
    return bytes;
  } catch (e) {
    print('==>Error getting file size: $e');
    return 0;
  }
}
 static String getFileTypeFromUrl(String url) {
    try {
      // Remove query parameters if any
      final withoutQuery = url.split('?').first;

      // Split by dots and get the last part
      final parts = withoutQuery.split('.');
      if (parts.length > 1) {
        return parts.last.toLowerCase();
      }
      return '';
    } catch (e) {
      return '';
    }
  }

}
