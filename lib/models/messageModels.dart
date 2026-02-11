import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/http/httpRequest.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageErrors.dart';
import 'package:medlandia/models/messageFileWrapper.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageRecipients.dart';
import 'package:medlandia/xmpp/XMPP.dart';
import 'package:xml/xml.dart';

abstract class Message {
  final id;
  final messageUniqueId;
  final DateTime timestamp;
  final String subject;
  final String? text;
  List<FileWrapper> files = [];
  final List<Recipient> _reciviers;
  List<MsgError> error = [];
  ValueNotifier<bool> errorListChaned = ValueNotifier(false);
  Message({required this.id, required this.messageUniqueId, required this.timestamp, required this.subject, required this.text}) :  _reciviers = [];

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

  void setSendResult(MsgStatus status);
  Future<void> send();
  Future<String> toXML(int recivier, {required bool parseForLocal});
}

class HeadlineMessage extends Message {
  final String level;
  final String area;  
  final int lifetime;
  HeadlineMessage({required super.id, 
                    required super.messageUniqueId, 
                    required super.timestamp, 
                    required this.level, 
                    required this.area, 
                    required super.subject, 
                    required super.text, this.lifetime=-1});

  void setSendResult(MsgStatus status) {}

  Future<void> send() async {}
  Future<String> toXML(int recivier, {required bool parseForLocal}) async {
    Map<String, dynamic> data = {
    'area': area,
    'level': level,
    'text': text,
    'timestamp' : timestamp.millisecondsSinceEpoch,
    'messageUniqueId' : messageUniqueId
  };
  if (lifetime > -1) {
    data['lifetime'] = lifetime;
  }

    return '''<message xmlns='jabber:client' to='${currentUser!.id}@chat.medlandia.org' from='admin@chat.medlandia.org' type='headline' id='${id}'><body>${jsonEncode(data)}</body><subject>${subject}</subject></message>''';
  }

  static HeadlineMessage? fromXML(XmlNode node) {
    final id = node.getAttribute("id");
    final body = node.findAllElements("body").firstOrNull;
    final subject = node.findAllElements("subject").firstOrNull;
    if (body == null || id == null || subject == null) {
      print("--Error-- Headline message=${body} id=${id} subject=${subject}");
      Connector.err(codePlace: "HeadlineMessage->fromXML()", e: "==Error-- Headline message=${body} id=${id} subject=${subject}");
      return null;
    }
    final obj = jsonDecode(body.innerText);
    if (obj == null || obj['messageUniqueId'] == null || obj['timestamp'] == null) {
      print("--Error-- object=${obj}");
      Connector.err(codePlace: "HeadlineMessage->fromXML", e: "object=${obj}");
      return null;
    }
    return HeadlineMessage(id: id, 
                            messageUniqueId: obj['messageUniqueId'], 
                            timestamp: DateTime.fromMillisecondsSinceEpoch(obj['timestamp']),
                            level: obj['level'], 
                            area: obj['area'], 
                            subject: subject.innerText, 
                            text: obj['text'], 
                            lifetime: obj['lifetime'] == null ? -1 : obj['lifetime']);
  }
}

class BaseMessageModel extends Message{   
  final Recipient sender;
  final List<Recipient> linkedMembers;
  final ValueNotifier<MsgStatus> sendStatus = new ValueNotifier(MsgStatus.UNSEND);
  final ValueNotifier linkedMembersChange = ValueNotifier(false);
  
  

  //final ValueNotifier<bool> allUploading = ValueNotifier(false);
  //final List<FileWrapper> uploaders = [];

  BaseMessageModel({
    required super.id,
    required this.sender,    
    required super.messageUniqueId,
    required super.subject,
    required super.text,
    required super.timestamp,    
  }) : linkedMembers = [];

  void addLinkedMember(Recipient r) {
    bool has = false;
    for (Recipient f in linkedMembers) {
      if (f.id == r.id) {
        has = true;
        break;
      }
    }
    if (!has) {
      linkedMembers.add(r);
    }
  }

  void addLinledMember(List<Recipient> all) {
    for (Recipient r in all) {
      addLinkedMember(r);
    }
  }

  void removeLinkedMember(Recipient r) {
    for (int i = linkedMembers.length - 1; i >= 0; i--) {
      if (linkedMembers[i].id == r.id) {
        linkedMembers.removeAt(i);
        break;
      }
    }
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
  @override
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

 

  @override
  Future<String> toXML(int recivier, {required bool parseForLocal}) async {
    String atachment = "";
    for (FileWrapper fw in files) {
      atachment += fw.toXML(parseForLocal: parseForLocal);
          
    }
    String linkedMemberXml="";
    for (Recipient r in linkedMembers) {
      linkedMemberXml += r.linkedMemberXML();
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
        <messageUniqueId>$messageUniqueId</messageUniqueId>${atachment}${linkedMemberXml}
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
    final memLinkXml = document.findAllElements('memlink').toList();
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

    List<Recipient> memlinked = [];
    for (XmlNode ml in memLinkXml) {
      if (ml.getAttribute("id") == null) continue;
      memlinked.add(Recipient(id: int.parse(ml.getAttribute("id")!), name: ml.innerText));
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
    msg.addLinledMember(memlinked);
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

