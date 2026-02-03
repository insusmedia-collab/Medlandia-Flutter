
import 'package:flutter/material.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageModels.dart';
import 'package:medlandia/models/messageRecipients.dart';

class MessageQuee {
  final int messageUniqId;
  String subject = "";
   
  //DateTime lastActivity = DateTime.now(); 

  final List<Recipient> _users = [];
  final List<BaseMessageModel> messages = [];
  final ValueNotifier<bool> userListChanged = ValueNotifier(false);
  final ValueNotifier<bool> messageListChanged = ValueNotifier(false);
  final ValueNotifier<int> unrededMessagesCount = ValueNotifier(0);
  final ValueNotifier<DateTime> lastActivity = ValueNotifier(DateTime.now());


  MessageQuee({required this.messageUniqId, this.subject = ""});

  MessageQuee copy() {
    MessageQuee q = MessageQuee(messageUniqId: messageUniqId);
    q.subject = subject;
    q.addAllUsers(_users);
    for (BaseMessageModel m in messages) {
      q.messages.add(m);
    }
    q.userListChanged.value = userListChanged.value;
    q.messageListChanged.value = messageListChanged.value;
    q.unrededMessagesCount.value = unrededMessagesCount.value;
    q.lastActivity.value = lastActivity.value;
    return q;
  }

  bool hasUser(BaseMemberModel user) {
    for (Recipient m in _users) {
      if (m.id == user.id) return true;
    }
    return false;
  }

  Recipient? getRecipient(int to) {
    for (Recipient r in _users) {
      if (r.id == to) return r;
    }
    return null;
  }

  List<Recipient> getUsers() {
    return _users;
  }

  void addAllUsers(List<Recipient> ulist) {
    for (Recipient r in ulist) {
      addUser(r);
    }
  }

  void addUser(Recipient user) {
    bool has = false;
    for (Recipient u in _users) {
      if (user.id == u.id) {
        has = true;
      }
    }
    if (!has) {
      _users.add(user);
      userListChanged.value = !userListChanged.value;
    }
  }

   BaseMessageModel? getLastMessage() {
    return messages.length > 0 ? messages[messages.length-1] : null;
  }

  void removeUser(int userId) {
    _users.removeWhere((item) => item.id == userId);
    userListChanged.value = !userListChanged.value;
  }

  MessageQuee prependMessage(BaseMessageModel message) {
    messages.insert(0, message);
    messageListChanged.value = !messageListChanged.value;
    return this;
  }

  MessageQuee appendMessage(BaseMessageModel message) {
    messages.add(message);
    messageListChanged.value = !messageListChanged.value;
    return this;
  }

  List<BaseMessageModel> getMessages() {
    return messages;
  }
}