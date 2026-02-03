import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/connectivity/database.dart';
import 'package:medlandia/http/httpRequest.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageErrors.dart';
import 'package:medlandia/models/messageFileWrapper.dart';
import 'package:medlandia/models/messageModels.dart';
import 'package:medlandia/models/messageQuee.dart';
import 'package:medlandia/pages/messagePage.dart';
import 'package:medlandia/screens/messageScreen.dart';
import 'package:medlandia/xmpp/XMPP.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

enum MsgStatus { UNSEND, SENDING, SENT, DELEYED, REJECTED }






List<MessageQuee> messageQuees = [];
ValueNotifier<bool> messageQueesChanged = ValueNotifier<bool>(false);
ValueNotifier<int> totalUnreadedMessages = ValueNotifier(0);


BaseMessageModel? findMessageEnywhere({required int messageQueeId, required int messageId}) {
  for (MessageQuee quee in messageQuees) {
            if (quee.messageUniqId == messageQueeId) {
              for (BaseMessageModel m in quee.messages) {
                if (messageId == m.id) {
                  return m;
                }
              }
            }
          }
          return null;
}

void incomeMessages(message) {
  //Isolate.run(() => manageIncomeMessage(message));
  manageIncomeMessage(message);
}



Future<void> manageIncomeMessage(message) async {

  final document = XmlDocument.parse(message);
  final msgNode = document.findAllElements('message').firstOrNull;
  final type = msgNode?.getAttribute("type");
  if (type == "error") {
    manageErrorMessage(msgNode!);
  } else if (type == "chat") {

  } else if (type == "groupchat") {

  } else if (type == "headline") { // notifications
    print("Income ${msgNode}");
  } else { // assumes normal
    BaseMessageModel? msg = BaseMessageModel.fromXML(message, parseFromLocal: false);
    manageNormalMessage(msg!);
  }

}

Future<void> manageErrorMessage(XmlNode msgNode) async {
  final errNode = msgNode.findAllElements('error').firstOrNull;
  final idText = msgNode.getAttribute("id");
  final queeIdNode = msgNode.findAllElements("messageUniqueId").firstOrNull;
  
  if (idText == null || queeIdNode == null || queeIdNode.innerText.trim().length == 0 || errNode == null) {
    print("---Critical-- msgId=${idText} queeId=${queeIdNode} errorNode=null");  
    return;
  }

  final int id = int.parse(idText);
  final int queeId = int.parse(queeIdNode.innerText);
  final to = msgNode.getAttribute("to")!.split("@")[0];
  final from = msgNode.getAttribute("from")!.split("@")[0];
  
    
  final toChildren = msgNode.findAllElements("to");

  /* create error node 'to' element and append to local error save*/
  /* From and to for income messages is vicecerce from=to to=from. Becose unswer come by unavailable user to me. */
  var errToNode;
  for (XmlNode node in toChildren) {
    if (node.getAttribute("id") == from) {
      errToNode = node.copy();
    }
  }
  if (errToNode != null) {
    errNode.children.add(errToNode);
  }
  
  MsgError error = MsgError.fromXML(errNode.toString());
  BaseMessageModel? realMessage = findMessageEnywhere(messageQueeId: queeId, messageId: id);
    if (realMessage != null) { // find in memory
      realMessage.addError(error);//  MsgError(type: MsgErrTypes.CANCEL, name: "service-unavailable");
      realMessage.sendStatus.value = MsgStatus.REJECTED;
    }
    db_setErrorToMessage(messageUniqueId: queeId, msgId: id, error: error);
}

Future<void> manageNormalMessage(BaseMessageModel msg) async {

  if (msg == null) {
    print("--Error-- parsing income message");
    return;
  }


  if (msg.files.length > 0) {
    Directory newDir = Directory("${appDocDirectory.path}/${msg.messageUniqueId}");

    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
    }

    for (FileWrapper fw in msg.files) {
      await fw.download(newDir);
    }
  }



  MessageQuee? quee;
  for (int i = messageQuees.length-1; i >= 0; i--) {
    if (messageQuees[i].messageUniqId == msg.messageUniqueId) {
      print("--quee finded");
      quee = messageQuees[i];
      quee.appendMessage(msg);
      //messageQueesChanged.value = !messageQueesChanged.value;
      break;
    }
  }

  
  // ignore: prefer_conditional_assignment
  if (quee == null) {
    // try to search int database
    quee = await db_loadMessageQuee(messageQueeId: msg.messageUniqueId);
  }

  if (quee == null) {
    print("--quee not finded");
    quee = MessageQuee(
      messageUniqId: msg.messageUniqueId,
      subject: msg.subject ?? "",
    );
    quee.addAllUsers(msg.getReciviers());
    quee.addUser(msg.sender);
    quee.appendMessage(msg);
    messageQuees.add(quee);// it will become at first when open page    
  }

  quee.unrededMessagesCount.value+=1;
  totalUnreadedMessages.value++;
  quee.lastActivity.value = DateTime.now();

  if (MessageScreen.openedQuee.messageUniqId == quee.messageUniqId) {
    MessageScreen.openedQuee.appendMessage(msg);
  }

  () async {
        await db_createQuee(quee!);
        db_appendMessage(messageUniqueId: msg!.messageUniqueId, content: await msg.toXML(0, parseForLocal: true));
        db_addUnreadedCount(uniqId: msg!.messageUniqueId);
        db_UpdateLastActivity(uniqId: msg!.messageUniqueId);
    }(); 

  print("--Is opened = ${MessagePage.isOpened}");
  //if (MessagePage.isOpened) { // can change list order, if true -> will change in just show    
    messageQuees.sort(messageQueeSorterByDate);
    messageQueesChanged.value = !messageQueesChanged.value;
  //}


  if (Xmpp.isConnected.value == XmppState.CONNECTED) {
    AudioPlayer().play(AssetSource('voice/001.aac'));
  } else {
    AudioPlayer().play(AssetSource('voice/004.aac'));
  }
}

int messageQueeSorterByDate(a, b) {
      return  b.lastActivity.value.compareTo(a.lastActivity.value);
}

int messageQueeSorterByUnreaded(a, b) {
      if (b.unrededMessagesCount.value < a.unrededMessagesCount.value) {
        return -1;
      } else if (b.unrededMessagesCount.value > a.unrededMessagesCount.value) {
        return 1;
      } else { 
        return 0;
      }
}