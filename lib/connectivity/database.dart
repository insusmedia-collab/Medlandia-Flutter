import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/models/messageErrors.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageModels.dart';
import 'package:medlandia/models/messageQuee.dart';
import 'package:medlandia/models/messageRecipients.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';

class Dbase {
    static final Dbase instance = Dbase._init();
    static Database? _database;
    Dbase._init();

Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

// unsendCount INTEGER DEFAULT 0,        

 Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY, 
        unrededCount INTEGER DEFAULT 0,       
        users TEXT DEFAULT '',
        subject TEXT DEFAULT '',
        content TEXT DEFAULT '',
        lastActivity INTEGER DEFAULT CURRENT_TIMESTAMP
      )
    ''');
} 
}

Future<void> dump() async {
  final db = await Dbase.instance.database;
  List<Map<String, dynamic>> rows = await db.query('messages');

for (dynamic line in rows) {
  print("---------------------------------------");
  print("messageUniqId=${line['id']}");
  print("unrededCount=${line['unrededCount']}");
  print("lastActivity=${DateTime.fromMillisecondsSinceEpoch(line['lastActivity'])}");
}

  /*
  for (dynamic row in messages) {
    print("--------- Messagew id=${row['id']}--------------");
    print("   unreadedcout=${row['unrededCount']}");
    print("   unsendCount=${row['unsendCount']}");
    print("   subject=${row['subject']}");
    print("   ------------------users----------------------");
    print("   ${row['users']}");
    print("   ----------------------------------------------");
    print("   ${row['content']}");
    print("   ----------------------------------------------");
    print("   ${row['lastActivity']}");
  }*/
}

Future<void> db_addUnreadedCount({required int uniqId}) async {
  final db = await Dbase.instance.database;
  await db.rawUpdate("UPDATE messages SET unrededCount=unrededCount+1 WHERE id=?",[uniqId]);
}

Future<void> db_clearUnreadedCount({required int uniqId}) async {
  final db = await Dbase.instance.database;
  await db.rawUpdate("UPDATE messages SET unrededCount=0 WHERE id=?",[uniqId]);
}

Future<void> db_UpdateLastActivity({required int uniqId}) async {
  final db = await Dbase.instance.database;
  //strftime('%s','now')
  int r = await db.rawUpdate("UPDATE messages SET lastActivity=strftime('%s','now')*1000 WHERE id=?",[uniqId]);
  
  //MessageQuee? q = await db_loadMessageQuee(messageQueeId: uniqId);
  //print("--MessageQuee database update $r -- ${q?.lastActivity.value}");
}

Future<void> dropDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'app.db');

  await deleteDatabase(path);
}

MessageQuee wrapMessageQuee(Map<String, dynamic> row) {
  MessageQuee q = MessageQuee(messageUniqId: row['id']);
    q.subject = row['subject'];    
    print("--LAstactivity---${row['lastActivity']}");
    q.lastActivity.value = DateTime.fromMillisecondsSinceEpoch(row['lastActivity']); //DateTime.parse(row['lastActivity']);    
    q.unrededMessagesCount.value = row['unrededCount'];

    /*-- get children--*/
    String usersText = '''<users>${row['users']}</users>''';
    final children = XmlDocument.parse(usersText).rootElement.childElements;

    for (var r in children) {
      q.addUser(Recipient(id: int.parse(r.getAttribute("id")!), name: r.innerText));
    }

    String msgs = '''<msgs>${row['content']}</msgs>''';
    final msgChildren = XmlDocument.parse(msgs).rootElement.childElements;

    for (var r in msgChildren) {
      BaseMessageModel? m = BaseMessageModel.fromXML(r.toXmlString(), parseFromLocal: true);
      if (m == null) {
        print("--Error-- parsing message from database ${r.toXmlString()}");
        continue;
      }
      q.messages.add(m);
    }
    return q;
}

Future<List<MessageQuee>> db_loadMessageQueeList({required int from, required int count}) async {
  final db = await Dbase.instance.database;
  List<Map<String, dynamic>> messages = await db.query('messages', orderBy: "unrededCount DESC, lastActivity DESC", offset: from, limit: count,);
  List<MessageQuee> quees = [];
  for (dynamic row in messages) {
    quees.add(wrapMessageQuee(row));
  }
  return quees;
}

Future<List<MessageQuee>> db_loadUnreadedMessageQueeList({required int from, required int count}) async {
  final db = await Dbase.instance.database;
  List<Map<String, dynamic>> messages = await db.query('messages', where: "unrededCount>0", orderBy: "lastActivity DESC", offset: from, limit: count,);
  List<MessageQuee> quees = [];
  for (dynamic row in messages) {
    quees.add(wrapMessageQuee(row));
  }
  return quees;
}

Future<List<MessageQuee>>  db_searchMessageQueeByUserName({required String serach}) async {
  final db = await Dbase.instance.database;
  List<Map<String, dynamic>> messages = await db.query('messages', where: "users LIKE ? COLLATE NOCASE ", whereArgs: ['%${serach}%'], orderBy: "lastActivity DESC");
  List<MessageQuee> quees = [];
  for (dynamic row in messages) {
    quees.add(wrapMessageQuee(row));
  }
  return quees;
}

Future<List<MessageQuee>> db_loadMessageQueeByDate(DateTime from, DateTime to) async {
  final db = await Dbase.instance.database;  
  List<Map<String, dynamic>> messages = await db.query('messages', where: "lastActivity >= ? AND lastActivity < ?", 
  whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch]);
  List<MessageQuee> quees = [];
  for (dynamic row in messages) {
    quees.add(wrapMessageQuee(row));
  }
  return quees;
}

Future<MessageQuee?> db_loadMessageQuee({required int messageQueeId}) async {
  final db = await Dbase.instance.database;
  List<Map<String, dynamic>> quee = await db.query('messages', where: "id=$messageQueeId");
  if (quee.length == 0) return null;
  return wrapMessageQuee(quee[0]);
}

Future<void> db_deleteMessageQuee({ required int messageQueeId}) async {
  final db = await Dbase.instance.database;
  await db.delete('messages', where: 'id = ?',whereArgs: [messageQueeId],);
}

Future<int> db_createQuee(MessageQuee mq) async {
  final db = await Dbase.instance.database;
  String userList = "";
  for (Recipient r in mq.getUsers()) {
    userList += r.toXML();
  }
  List<Map<String, dynamic>> hasIt = await db.query('messages', where: "id=${mq.messageUniqId}" );
  if (hasIt.length > 0) {
    return -1;
  }
  int result = 0;
  try {
   result = await db.insert(
    'messages',
    {
      'id': mq.messageUniqId, 
      'users' : userList,
      'subject' : mq.subject
    },
  ); 
  } catch (e) {
    Connector.err(codePlace: "db_createQuee", e: e.toString());
  }
  return result;
}

Future<void> db_appendMessage({required int messageUniqueId, required String content}) async {
  final db = await Dbase.instance.database;
  try {
    await db.rawUpdate('''UPDATE messages SET content=COALESCE(content, '') || ? WHERE id = ?''', [content, messageUniqueId]);
  } catch (e) {
    Connector.err(codePlace: "db_appendMessage", e: e.toString());
  }
}

Future<MessageQuee?> loadMessageQuee({required int messageUniqueId}) async {
  final db = await Dbase.instance.database;
  List<Map<String, dynamic>> quee = await db.query('messages',where: "id=${messageUniqueId}");

  return quee.length == 0 ? null : wrapMessageQuee(quee[0]);
}

Future<void> db_setErrorToMessage({required int messageUniqueId, required int msgId, required MsgError error}) async {
    final db = await Dbase.instance.database;

    List<Map<String, dynamic>> quee = await db.query('messages', columns: ["content"], where: "id=${messageUniqueId}");
    if (quee.length == 0) return;
    String content = quee[0]['content'];
    final document = XmlDocument.parse("<root>${content}</root>");
    final root = document.rootElement;
    final children = root.children;
    for (XmlNode msg in children) {
      try {
        if (int.parse(msg.getAttribute("id")!.trim()) == msgId) {
          final enode = XmlDocument.parse(error.toXML()).rootElement.copy();
          msg.children.add(enode);
          break;
        }
      } catch (e) {
        print("--Error-- $e");
      }
    }
    
    db.update("messages", {'content': root.innerXml}, where: "id=${messageUniqueId}");
      
}

Future<void> db_clearErrorToMessage({required int messageUniqueId, required int msgId, required MsgError error}) async {
    final db = await Dbase.instance.database;

    List<Map<String, dynamic>> quee = await db.query('messages', columns: ["content"], where: "id=${messageUniqueId}");
    if (quee.length == 0) return;
    String content = quee[0]['content'];
    final document = XmlDocument.parse("<root>${content}</root>");
    final root = document.rootElement;
    final children = root.children;
    for (XmlNode msg in children) {
      try {
        if (int.parse(msg.getAttribute("id")!.trim()) == msgId) {
          //print("----Start err node finding");
          final errIndexNode = msg.findAllElements("error").firstWhere((e) {
              return int.parse(e.getAttribute('id') ?? "-1") == error.id;
            });
            print("---- $errIndexNode");
          errIndexNode.parent?.children.remove(errIndexNode);
          //print(msg.toString());
          break;
        }
      } catch (e) {
        print("--Error-- $e");
      }
    }

    print(root.innerXml);  
    db.update("messages", {'content': root.innerXml}, where: "id=${messageUniqueId}");
      
}

/*
Future<int> insertUser(String name, int age) async {
  final db = await Dbase.instance.database;

  return await db.insert(
    'users',
    {'name': name, 'age': age},
  );
}

Future<List<Map<String, dynamic>>> getUsers() async {
  final db = await Dbase.instance.database;
  return await db.query('users');
}
Future<int> updateUser(int id, String name, int age) async {
  final db = await Dbase.instance.database;

  return await db.update(
    'users',
    {'name': name, 'age': age},
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> deleteUser(int id) async {
  final db = await Dbase.instance.database;

  return await db.delete(
    'users',
    where: 'id = ?',
    whereArgs: [id],
  );
}*/