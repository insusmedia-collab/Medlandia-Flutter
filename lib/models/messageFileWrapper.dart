import 'dart:io';
import 'package:medlandia/xmpp/XMPP.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:medlandia/http/httpRequest.dart';
import 'package:medlandia/main.dart';
import 'package:mime/mime.dart';
import 'package:xml/xml.dart';

enum UploadStatus { NOT_STARTED, UPLOADING, SUCCESSED, ERROR }

class FileWrapper {
  File file;
  String put = "";
  String get;  
  final int size;
  int loadSize = 0;
  final mimeType;
  final messageUniqueId;

  final ValueNotifier<double> progress = ValueNotifier(0);
  final ValueNotifier<UploadStatus> uploadStatus = ValueNotifier(
    UploadStatus.NOT_STARTED,
  );

  FileWrapper({required this.messageUniqueId, required this.file, required this.size, this.get="", required this.mimeType});

  String getFileName() {
    return path.basename(file.path);
  }

  int getFileSize() {
    return size;
  }



  String getMimeType() {
    String? mimeType = lookupMimeType(file.path);
    return mimeType ?? "application/octet-stream";
  }

  void cancelUpload() {
    Xmpp.fileUploadWaiters.remove(this);
  }

  Future<void> download(Directory path) async {
      uploadStatus.value = UploadStatus.UPLOADING;
      if (!await file.exists()) {
        await file.create();
      }

    String f = await downloadFile(
      get,
      file,
      onProgress: (received, total) {
        if (received == total) {
          loadSize = received;
          //print("Download $received $total");
          uploadStatus.value = UploadStatus.SUCCESSED;
        }
      },
      onError: (error) {
        print("--Error-- downloading file $error");
        uploadStatus.value = UploadStatus.ERROR;
      },
      totalLenght: size,
    );
    print("It is a file $f");
  }

  Future<void> upload() async {
    progress.value = 0;
    uploadStatus.value = UploadStatus.UPLOADING;    
    uploadFileInChunks(
      file: file,
      putUrl: put,
      onProgress: (p) {
        progress.value = p;
        if (p == 1) {
          uploadStatus.value = UploadStatus.SUCCESSED;
          print("${file.path} is uploaded");
        }
      },
      onError: (code, errText) {
        progress.value = 0;
        uploadStatus.value = UploadStatus.ERROR;
      },
    );
  }

  String toXML({required bool parseForLocal})  {
    String f = parseForLocal ? file.path : path.basename(file.path);
    return '''<attachment xmlns="urn:xmpp:attachment">
                <filename>${f}</filename>
                <size>${size}</size>
                <media-type>${mimeType}</media-type>
                <url>${get}</url></attachment>''';
  }

  static FileWrapper fromXML(XmlNode xml, int messageUniqId, {required bool parseFromLocal}) {
    final fileName = xml.getElement('filename')?.innerText;
      final size = xml.getElement('size') == null ? -1 : int.parse(xml.getElement('size')!.innerText);
      final url = xml.getElement('url')?.innerText;
      final mimeType = xml.getElement('media-type')?.innerText;
      if (url == null || size == null || size == -1 || fileName == null) {
        print("--Error-- $fileName $size $url");
      }
      late File file;
      if (parseFromLocal) {
        file = File(fileName!);
      } else {
        file = File("${appDocDirectory.path}/${messageUniqId}/${fileName}");
      }
      return FileWrapper(
                    messageUniqueId: messageUniqId,                    
                    file: file,
                    size: size,
                    get: url!,
                    mimeType: mimeType);
  }

}