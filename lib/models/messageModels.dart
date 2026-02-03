import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:medlandia/http/httpRequest.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageErrors.dart';
import 'package:medlandia/models/messageFileWrapper.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageRecipients.dart';
import 'package:medlandia/xmpp/XMPP.dart';
import 'package:xml/xml.dart';

class BaseMessageModel {
  final int id;  
  final int messageUniqueId;
  final String? text;
  final String? subject;
  final Recipient sender;
  final List<Recipient> _reciviers;
  List<FileWrapper> files = [];
  final DateTime timestamp;
  final ValueNotifier<MsgStatus> sendStatus = new ValueNotifier(
    MsgStatus.UNSEND,
  );
  List<MsgError> error = [];
  ValueNotifier<bool> errorListChaned = ValueNotifier(false);

  //final ValueNotifier<bool> allUploading = ValueNotifier(false);
  //final List<FileWrapper> uploaders = [];

  BaseMessageModel({
    required this.id,
    required this.sender,    
    required this.messageUniqueId,
    required this.subject,
    required this.text,
    required this.timestamp,
  }) : _reciviers = [];

  void addRecivier(Recipient member) {
    bool has = false;
    for (Recipient r in _reciviers) {
      if (r.id == member.id) {
        has = true;
        break;
      }
    }
    if (!has) {
      _reciviers.add(member);
    }
  }

  void addAllReciviers(List<Recipient> all) {
    for (Recipient r in all) {
      addRecivier(r);
    }
  }

  List<Recipient> getReciviers() {
    return _reciviers;
  }

  void checkAllUploaders() async {
    final allSuccess = false;
    for (FileWrapper f in files) {
      if (f.uploadStatus.value != UploadStatus.SUCCESSED) return;
    }

    //allUploading.value = allSuccess;
    print("all succeeed-------------------");
    dispose();

    List<Recipient> reciviers = getReciviers();
    for (Recipient mem in reciviers) {
      if (mem.id == currentUser!.id) continue;
      String msg = await toXML(mem.id, parseForLocal: false);
      print("==>$msg");
      await Xmpp.send(msg);
    }

    setSendResult(MsgStatus.SENT);
  }

  void dispose() {
    for (FileWrapper uploader in files) {
      uploader.uploadStatus.removeListener(checkAllUploaders);
    }
  }

  void setSendResult(MsgStatus status) {
    sendStatus.value = status;
    AssetSource src = AssetSource('voice/001.aac');
    if (status == MsgStatus.SENT) {
      src = AssetSource('voice/001.aac');
    } else {
      src = AssetSource('voice/002.aac');
    }
    AudioPlayer().play(src);
  }

  Future<void> send() async {
    sendStatus.value = MsgStatus.SENDING;
    if (files.length > 0) {
      for (FileWrapper f in files) {
        f.uploadStatus.addListener(checkAllUploaders);
        Xmpp.uploadFile(f);
      }
      // SEND MESSAGE AFTER, In checkAllUploaders - where all files have been uploaded
    } else {
      List<Recipient> reciviers = getReciviers();
      for (Recipient mem in reciviers) {
        if (mem.id == currentUser!.id) continue;
        String msg = await toXML(mem.id, parseForLocal: false);
        print("==>$msg");
        await Xmpp.send(msg);
      }
      setSendResult(MsgStatus.SENT);
      
    }
  }

  void addError(MsgError err) {
    bool hasError = false;
    for (int i = this.error.length-1; i >= 0; i--) {
      if (err.to.id == error[i].to.id 
          && err.type == error[i].type
          && err.name.toString().toLowerCase().trim() == error[i].name.toString().toLowerCase().trim()) {
            hasError = true;
            break;
          }
    }
    if (!hasError) {
      this.error.add(err);
      errorListChaned.value = !errorListChaned.value;
    }
  }

  void removeError(MsgError err) {
    for (int i = this.error.length-1; i >= 0; i--) {
      if (err.to.id == error[i].to.id 
          && err.type == error[i].type
          && err.name.toString().toLowerCase().trim() == error[i].name.toString().toLowerCase().trim()) {
            this.error.removeAt(i);
            errorListChaned.value = !errorListChaned.value;
            break;
          }
    }
  }

  Future<String> toXML(int recivier, {required bool parseForLocal}) async {
    String atachment = "";
    for (FileWrapper fw in files) {
      atachment += fw.toXML(parseForLocal: parseForLocal);
          
    }
    String to = "";
    List<Recipient> reciviers = getReciviers();
    for (Recipient mem in reciviers) {
      to += mem.toXML();
    }
    String errStr="";
    if (parseForLocal) {
      for (MsgError err in this.error) {
        errStr += err.toXML();
      }      
    }
    return '''<message from="${sender.id.toString()}@chat.medlandia.org" to="${recivier}@chat.medlandia.org" type="normal" id="${id}">
        <body>${xmlEscape(text ?? "")}</body>
        <date>${DateTime.now()}</date>
        <subject>${xmlEscape(subject ?? "")}</subject>
        <sender id="${sender.id}">${sender.name}</sender>
        <messageUniqueId>$messageUniqueId</messageUniqueId>${atachment}
        ${to}${errStr}
      </message>''';
  }

  static BaseMessageModel? fromXML(String message, {required bool parseFromLocal}) {

    final document = XmlDocument.parse(message);    
    final messageNode = document.findAllElements('message').firstOrNull;
    final id = messageNode!.getAttribute("id");
    final bodyXml = document.findAllElements('body').firstOrNull;
    final dateXml = document.findAllElements('date').firstOrNull;
    final subjectXml = document.findAllElements('subject').firstOrNull;
    final attachXml = document.findAllElements('attachment').toList();
    final messageUniqueIdXml = document.findAllElements('messageUniqueId').firstOrNull;
    final toXml = document.findAllElements('to').toList();
    final error = document.findAllElements('error').firstOrNull;

    final text = xmlUnescape(bodyXml?.innerText ?? "");
    final messageUniqueId = messageUniqueIdXml != null ? int.parse(messageUniqueIdXml.innerText) : -1;
    final subject = xmlUnescape(subjectXml?.innerText ?? "");
    final senderName = document.findAllElements('sender').firstOrNull?.innerText;
    final senderId = document.findAllElements('sender').firstOrNull?.getAttribute("id");
    if (senderId == null || senderName == null || messageUniqueId == -1) {      
      print("--Error-- brocken message. No sender $senderId $senderName $messageUniqueId Info",);
      print("--Error parsed-- $message");
      return null;
    }


    List<FileWrapper> files = [];
    for (XmlNode a in attachXml) {
      files.add(FileWrapper.fromXML(a, messageUniqueId, parseFromLocal: parseFromLocal));
    }

    print("--hereee--- ${senderId}  ${senderName}");

    BaseMessageModel msg = BaseMessageModel(
      id: int.parse(id!),
      sender: Recipient(id: int.parse(senderId), name: senderName),
      messageUniqueId: messageUniqueId,
      subject: subject,
      text: text,
      timestamp: DateTime.parse(dateXml!.innerText),
    );
    msg.files = files;
    for (XmlNode t in toXml) {      
      msg.addRecivier(Recipient.fromXML(t));
    }
    if (error != null) {
      final errTo = messageNode.getAttribute("to")!.split("@")[0];
      final errFrom = messageNode.getAttribute("from")!.split("@")[0];
      MsgError err = MsgError.fromXML(error.toString());
      msg.addError(err);
      msg.sendStatus.value = MsgStatus.REJECTED;
    }
   
    return msg;
  }

}

