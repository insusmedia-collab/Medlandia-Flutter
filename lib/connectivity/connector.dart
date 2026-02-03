import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:medlandia/connectivity/device.dart';
import 'package:medlandia/http/httpRequest.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/stores/localStore.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


int genId(){
  return int.parse("${DateTime.now().microsecondsSinceEpoch.toString()}${new Random().nextInt(100)}");
}

class Connector {
  static Future<void> connectToChat() async {
    // Implement your connection logic here
   
  }

  static Future<void> disconnect() async {
    // Implement your disconnection logic here
   
  }

static Future<bool> initMainUser({required String id}) async {
   
    List<dynamic> sp = [];
    List<dynamic> wp = [];
    List<dynamic> skills = [];
    late Map<String, dynamic>? user;


   user = await call(null, {'func': 'getUser', 'p1': id});
   
  

    if (user != null) {
      if (user['id'] == null) {
        //Connector.err(codePlace: "Connectior->initMainUser", e: "Custom error.user['id'] == null; But it will be normal server responce ");
        return false;
      }
      

      
      await LocalStore.write(key: 'id', value: user['id'].toString());
      await LocalStore.write(key: 'password', value: user['password']);
      await LocalStore.write(key: 'name', value: user['name']);
      await LocalStore.write(key: 'chatName', value: user['name']);
      await LocalStore.write(key: 'expYear', value: user['expYear'].toString());
      await LocalStore.write(key: 'userType', value: user['userType'].toString());
      await LocalStore.write(key: 'language', value: user['language']);
      await LocalStore.write(key: 'country', value: user['country']);
      await LocalStore.write(
        key: 'avatar',
        value:
            "https://medlandia.org/medlandia.jsp?func=getAvatar&p1=${user['id']}",
      );
      await LocalStore.write(key: 'email', value: user['email'] ?? "");
      await LocalStore.write(key: "specs", value: jsonEncode(user['specs'][0]));
      await LocalStore.write(key: "workplaces", value: jsonEncode(user['workplaces'][0]));      
      await LocalStore.write(key: "skills", value: jsonEncode(user['skills'][0]));

      

      if (user['userType'] == 1) {
        sp = user['specs'][0];
        wp = user['workplaces'][0];
        skills = user['skills'][0];
      }
    } else {
      
      Map<String, dynamic> all = await LocalStore.readAll();
      if (all['id'] == null) {
        print("==> Brocken local store");
        Connector.err(codePlace: "Connector->initMainUser()", e: "Local store is brocken: Look inside initMainUser()");
        return false;
      }
      
      user = <String, dynamic>{};
      user['id'] = int.parse(all['id']);
      user['userType'] = int.parse(all['userType']);
      user['password'] = all['password'];
      user['name'] = all['name'];
      user['avatar'] = all['avatar'];
      user['language'] = all['language'];
      user['country'] = all['country'];

      if (user['userType'] == 1) {
        sp = jsonDecode(all['specs']);
        wp = jsonDecode(all['workplaces']);
        skills = user['skills'];        
      }
      
    }

    /******************** INITIALIZE MAIN USER********************************** */
    
    try {
      LocalStore.buildCurrentUser(user, sp, wp, skills);
    } catch (e) {
      Connector.err(codePlace: "Connector->initMainUser()->LocalStore.buildOwner", e: "${e}");
    }

    return true;
  }

  static Future<void> err({required String codePlace, required String e}) async {
    
    final result = await call(null, {
      'func' : 'userError', 
      'p1' : currentUser != null ?  currentUser!.id.toString() : "37444545250", 
      'p2' : devModel ?? "undefined", 
      'p3' : devVersion ?? "undefined",
      'p4' : appVersion ?? "undefined",
      'p5' : codePlace.toString(),
      'p6' : e.toString()
      });
      
  }

  static Future<void> notify(String type, int toUserId, int fromId, String text) async {
    final result = await call(null, {
      'func' : 'notify', 
      'p1' : toUserId.toString(), 
      'p2' : type, 
      'p3' : fromId.toString(),
      'p4' : text 
      });
    print('Notofied-->$result');
  }



  static Future<void> notifyWhatsInvite(int toUserId) async {
    final result = await call(null, {'func' : 'notifyWhatsAppSchedule', 'p1' : toUserId.toString(), 'p2' : currentUser!.id.toString()});    
    //print('Notofied-->$result');
  }

  static Future<dynamic> getLatestVersion() async {
    final result = await call(null, {'func' : 'getLatest'});  
    return result;
  }

  static Future<void> updateEnterDate() async {
    call(null, {
      'func' : 'updateUserLastVisitTime',
      'p1' : currentUser!.id.toString()
    });
  }

static Future<void> deleteAccount() async {
   
    try {

      final response =  await call(null, {'func': 'deleteUser', 'p1': currentUser!.id.toString()});
      if (response == null) {
        throw "Error deletion";
      }
      await LocalStore.deleteAll();
     
    } catch (e) {
      print("==> Delete account  error $e");
      //Toast(context: context, text: e.toString())
    }
  }

static Future<void> loadUser2User() async {
    
    final response = await call(null, {
                    'func'  : 'loadUser2User',
                    'p1'    : currentUser!.id.toString()
                  });       
    if (response == null) {
      print("==> CAnt load user2user");
      return;
    }
    
    List<dynamic> list = response as List<dynamic>;    
    dummyChatItems.clear();
    dummyFriendsItems.clear();    
    for (int i = 0; i < list.length; i++)  {         
      BaseMemberModel mm = toMember(list[i]);
      if (mm.isFriend) {
        dummyFriendsItems.add(mm);
      }
      if (mm.isChat) {
        dummyChatItems.add(mm);
      }
    }
    dummyChatItemsChanged.value = !dummyChatItemsChanged.value;
    dummyFriendsItemsChanged.value = !dummyFriendsItemsChanged.value;
  }

static Future<bool> deleteUser2User(BaseMemberModel member) async {
    final result = await call(null, {
      'func'  : 'deleteUser2User',
      'p1'    : currentUser!.id.toString(),
      'p2'    : member.id.toString()
    });
    if (result == null) return false;
    clearMemberFromItems(member);
    dummyDeletedItems.add(member);
    dummDeletedItemsChanged.value = !dummDeletedItemsChanged.value;
    return true;
  }

 static Future<bool> setUser2UserChat(BaseMemberModel member) async {
    final response = await call(null, {
      'func'  : 'setUser2UserChat',
      'p1'    : currentUser!.id.toString(),
      'p2'    : member.id.toString(),
      'p3'    : member.isChat ? 'true' : 'false'
    });
    if (response == null) return false;
    updateItemsLists(member);
    return true;
 }

 static Future<bool> setUser2UsersChat(List<int> ids) async {
    String queryStr = "";
    for (int i = 0; i < ids.length; i++) {    
      queryStr += ids[i].toString();
      if (i + 1 < ids.length) {
        queryStr += ",";
      }
    }
    final response = await call(null, {
        'func'  : 'setManyUser2UserChat',
        'p1'    : currentUser!.id.toString(),
        'p2'    : queryStr
      });
      if (response == null) return false;
      return true;
 }

 static Future<bool> setUser2UserBlock(BaseMemberModel member) async {
    final response = await call(null, {
      'func'  : 'setUser2UserBlock',
      'p1'    : currentUser!.id.toString(),
      'p2'    : member.id.toString(),
      'p3'    : member.isBlock ? 'true' : 'false'
    });
    if (response == null) return false;
    updateItemsLists(member);
    return true;
 }

 static Future<bool> setUser2UserFixed(BaseMemberModel member) async {
    final response = await call(null, {
      'func'  : 'setUser2UserFixed',
      'p1'    : currentUser!.id.toString(),
      'p2'    : member.id.toString(),
      'p3'    : member.isFixed ? 'true' : 'false'
    });
    if (response == null) return false;
    updateItemsLists(member);
    return true;
 }

 static Future<bool> setUser2UserFriend(BaseMemberModel member) async {
    final response = await call(null, {
      'func'  : 'setUser2UserFriend',
      'p1'    : currentUser!.id.toString(),
      'p2'    : member.id.toString(),
      'p3'    : member.isFriend ? 'true' : 'false'
    });
    if (response == null) return false;
    updateItemsLists(member);
    return true;
 }

  static Future<void> clearMemberFromItems(BaseMemberModel member) async {
    for (int i = dummyChatItems.length-1; i >= 0; i--) {
      if (dummyChatItems[i].id == member.id) {
          dummyChatItems.removeAt(i);
          dummyChatItemsChanged.value = !dummyChatItemsChanged.value;
          break;
      }
    }
    for (int i = dummyFriendsItems.length-1; i >= 0; i--) {
      if (dummyFriendsItems[i].id == member.id) {
        dummyFriendsItems.removeAt(i);
        dummyChatItemsChanged.value = !dummyChatItemsChanged.value;
        break;
      }
    }
  }
 static Future<void> updateItemsLists(BaseMemberModel member) async {
    bool isFind = false;
    if (member.isChat) {
      for (BaseMemberModel m in dummyChatItems) {
        if (m.id == member.id) {
          m.isChat = member.isChat;
          isFind = true;
          break;
        }
      }
      if (!isFind) {
        dummyChatItems.add(member);
        dummyChatItemsChanged.value = !dummyChatItemsChanged.value;
      }
    }
    isFind = false;
    if (member.isFriend) {
      for (BaseMemberModel m in dummyFriendsItems) {
        if (m.id == member.id) {
          m.isFriend = member.isFriend;
          isFind = true;
          break;
        }
      }
      if (!isFind) {
        dummyFriendsItems.add(member);
        dummyFriendsItemsChanged.value = !dummyFriendsItemsChanged.value;
      }
    }
 } 

static Future<bool> lockUnlock(BaseMemberModel member) async {
    //late bool response;
    member.isBlock = !member.isBlock;
    bool locked = await setUser2UserBlock(member);
    if (locked) {
      member.blockChanged.value = member.isBlock;
    } else {
      print("==> Error, user cant lock");
    }    
    
    return true;
  }

static Future<void> updateDevice(String token) async {
  if (token == null)  {
    print("==>Token is NULL");
    return;
  }
  final result = await call(null, {
    'func'    :   'updateDevice',
    'p1'      :   currentUser!.id.toString(),
    'p2'      :   token
  });
  if (result == null) {
      print("==> Not registered token");
      return;
  }
}

static Future<void> clearUnreaded({required int userTo}) async {
  final result = await call(null, {
    'func'    :   'clearUnreaded',
    'p1'      :   userTo.toString(),
    'p2'      :   currentUser!.id.toString()
  });
} 

static Future<void> clearAllUnreadedOnServer() async {
  final result = await call(null, {
    'func'    :   'clearAllUnreaded',
    'p1'      :   currentUser!.id.toString()
  });
} 

static Future<void> increaseUnreaded({required int userTo}) async {
  final result = await call(null, {
    'func'    :   'updateUnreaded',
    'p1'      :   currentUser!.id.toString(),
    'p2'      :   userTo.toString()
  });
} 

static Future<bool> createNewUser(int id, int userType, String country, String language) async {
    final responce = await call(null, {
        'func': 'createUser',
        'p1': id.toString(),
        'p2': userType.toString(),
        'p3': '',
        'p4': '',
        'p5'  : country,
        'p6' : language
      });
      if (responce == null) return false;
      
      return true;
  }

/*
static Future<void> loadArchive(int id) async {
    List<BaseMessageModel> result = await db.loadChat(from: id, to: currentUser?.id,);
    for (var row in result) {
      await addMessageBuffer(row);
    }
    updateMessageBufferView();

    for (var m in messageBuffer) {
      m.reactionChanged.value = !m.reactionChanged.value;
      if (m is Uploadable) {
        m.showResource();
      }
    }
    checkUnreadedUsersMessages().then((v) async {
      /*
      final request = await call(null, {
        'func'    :   'syncMsgList',
        ''
      });*/
    }
    );

    /*========================== Synck with other user ========================= */
    
    // this.mam.queryByTime( start: DateTime(2023, 01,01), end: DateTime(2025, 06, 15), jid: Jid.fromFullJid("root@medlandia.org") );
  }
*/
 
}

