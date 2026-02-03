import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

Future<dynamic> call(BuildContext? context, Map<String, dynamic> params) async {
  if (currentUser != null) {
    params['lang'] = currentUser!.language;
  } else {
    params['lang'] = 'eng';
  }
  var result;
  try {
    var url = Uri.https('medlandia.org', 'medlandia.jsp');
    var response = await http.post(url, body: params);
    result = jsonDecode(response.body);
    if (result is Map && result['error'] != null) {
      throw ArgumentError(result['error']);
    }
  } catch (e) {
    print(
      "==============================EXCEPTION================================",
    );
    print(e);

    if (context != null) {
      Toast(context: context, text: e.toString(), seconds: 5);
    }
  }
  return result;
}

Future<void> uploadFileInChunks({
  required File file,
  required String putUrl,
  void Function(double progress)? onProgress,
  void Function(int status, String body)? onError,
}) async {
  final fileBytes = await file.readAsBytes();
  final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

  final request = http.Request("PUT", Uri.parse(putUrl));
  request.headers.addAll({
    "Content-Type": mimeType,
    "Content-Length": fileBytes.length.toString(),
  });
  request.bodyBytes = fileBytes;

  final response = await request.send();

  if (response.statusCode == 201 || response.statusCode == 200) {
    print("Upload successful!");
    if (onProgress != null) onProgress(1);
  } else {
    print("Upload failed: ${response.statusCode}");
    final body = await response.stream.bytesToString();
    if (onError != null) onError(response.statusCode, body);
  }
}

Future<String> downloadFile(String url, File file, {Function(int received, int total)? onProgress, Function(String error)? onError, int totalLenght=0}) async {
    // Check storage permission
    // Create the request
    final response = await http.Client().send(http.Request('GET', Uri.parse(url)));
    
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
        if (onError != null) onError(e);
        throw e;
      },
      cancelOnError: true,
    ).asFuture();

    return file.path;
  }

  String xmlEscape(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

String xmlUnescape(String text) {
  return text
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&');
}