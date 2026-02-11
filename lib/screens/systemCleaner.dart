import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medlandia/MedlandiaHome.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/connectivity/database.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/pages/messagePage.dart';
import 'package:medlandia/stores/localStore.dart';
import 'package:xml/xml.dart';

class SystemCleaner extends StatefulWidget {
  const SystemCleaner({super.key});

  @override
  State<SystemCleaner> createState() => _SystemCleanerState();
}

class _SystemCleanerState extends State<SystemCleaner> {
  final ValueNotifier<String> titleChanged = ValueNotifier("");
  final ValueNotifier<String> subtitleChanged = ValueNotifier("");
  final ValueNotifier<int> brockenMessages = ValueNotifier(0);
  final ValueNotifier<int> tempMessages = ValueNotifier(0);

  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    clean();
  }

  Future<void> clean() async {
    isRunning = true;
    titleChanged.value = "Cleaning database";
    int totalRows = await db_getAllMesagesCount();
    subtitleChanged.value = "";

    try {
      await cleanDatabase();
      await clearEmptyRows();
      MSG_QUEE_LOAD_INDEX = 0;
      messageQuees = await db_loadMessageQueeList(from: MSG_QUEE_LOAD_INDEX, count: MSG_QUEE_LOAD_COUNT);
      MSG_QUEE_LOAD_INDEX += MSG_QUEE_LOAD_COUNT;
      messageQueesChanged.value = !messageQueesChanged.value;

      await checkDirector(appDocDirectory);
    } catch (e) {
      Connector.err(codePlace: "systemClener->clean()", e: e.toString());
    } finally {
      LocalStore.write(key: "databaseCleanDate", value: DateTime.now().toString());
    }
    setState(() {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MedlandiaHome()));
    });
  }

  Future<void> clearEmptyRows() async {
    final db = await Dbase.instance.database;
    List<Map<String, dynamic>> quee = await db.query('messages',columns: ["id", "content"],);
    for (int index = 0; index < quee.length; index++) {
      Map<String, dynamic> row = quee[index];   
      if (row['content'] == null || row['content'].toString().trim().length == 0) {
        db.delete("messages", where: "id=?", whereArgs: [row['id']]);
      }
    }
  }

  Future<void> cleanDatabase() async {
final db = await Dbase.instance.database;
    List<Map<String, dynamic>> quee = await db.query('messages',columns: ["id", "content"],);
    for (int index = 0; index < quee.length; index++) {
      if (!isRunning) break;
      Map<String, dynamic> row = quee[index];      
      String xmlStr = "<root>${row['content']}</root>";
      final document = XmlDocument.parse(xmlStr);
      final root = document.rootElement;
      final messageNodes = root.children.whereType<XmlElement>();
      String normalMessages = "";
      for (int a = 0; a < messageNodes.length; a++) {
        if (!isRunning) break;

        final nodeType = messageNodes.elementAt(a).getAttribute("type");
        if (nodeType == null) {
          brockenMessages.value = brockenMessages.value + 1;          
          continue;
        }

        if ("headline" == nodeType) {
          final bodyNode = messageNodes.elementAt(a).findAllElements("body").firstOrNull;
          if (bodyNode == null || bodyNode.toString().trim().length == 0) {
            brockenMessages.value = brockenMessages.value + 1;            
            continue;
          }
          try {
            final bodyObj = jsonDecode(bodyNode.innerText);
            if (bodyObj['lifetime'] != null) {
              DateTime lf = DateTime.fromMillisecondsSinceEpoch(bodyObj['lifetime'],);
              //print("--Find lifetime ${lf.toString()}");
              if (lf.isBefore(DateTime.now())) {
                tempMessages.value = tempMessages.value + 1;                
                continue;
              }
            }
          } catch (e) {
            //print("--Error--Database clean $e  $bodyNode");
            Connector.err(codePlace: "headline message clean", e: e.toString());
            continue;
          }
        }
        if ("normal" == nodeType) {
          //print("--Find normal");
        }

        normalMessages += messageNodes.elementAt(a).toString();
      }

 
          try {
            //print("--->>>${row['id']} $normalMessages");
            await db.update('messages', {'content': '$normalMessages'}, where: 'id = ?', whereArgs: [row['id']],);
          } catch (e) {
            Connector.err(codePlace: "message update save", e: e.toString());
          }

      titleChanged.value =
          "Cleaning database (${(((index + 1) * 100) / quee.length).round()}%)";

      await Future.delayed(Duration(milliseconds: 20));
    }

    
  }

  Future<void> checkDirector(Directory dir) async {
    try {
      final List<FileSystemEntity> entities = dir.listSync();
      for (int i = 0; i < entities.length; i++) {
        var entity = entities[i];
        if (!isRunning) break;
        titleChanged.value = "Checking files";
        if (entity is File) {
          await checkFile(File(entity.path));
        } else if (entity is Directory) {
          await checkDirector(entity);
          //subtitleChanged.value = "Directory: ${entity.path}";
        }
        await Future.delayed(Duration(milliseconds: 20));
      }
    } catch (e) {
      Connector.err(
        codePlace: "systemClener->checkDirector()",
        e: e.toString(),
      );
    }
  }

  Future<void> checkFile(File file) async {
    try {
      subtitleChanged.value = "${file.path}";
      DateTime lastAccesed = await file.lastAccessed();
      int lenght = await file.length();
    } catch (e) {
      Connector.err(codePlace: "systemClener->checkFile()", e: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 244),
      appBar: AppBar(
        leading: Icon(Icons.build_rounded, color: Colors.blueGrey),
        title: Text("System clean", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 230, 230, 232),
        actions: [
          IconButton(
            onPressed: () {
              if (isRunning) {
                isRunning = false;
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MedlandiaHome()),
                );
              }
            },
            icon: Icon(Icons.close, color: Colors.blueGrey),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Icon(
                Icons.self_improvement_outlined,
                size: 100,
                color: Colors.blueGrey,
              ), //Image.asset("assets/images/logo-512.jpg",width: 100,height: 100,fit: BoxFit.cover,),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsetsGeometry.only(
                top: 20,
                bottom: 5,
                left: 40,
                right: 40,
              ),
              child: Text(
                "Medlandia is now cleaning, restructuring and optimizing files, stores and system. We are kindly ask you to be a little bit patiently.",
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.only(
                top: 20,
                bottom: 5,
                left: 40,
                right: 40,
              ),
              child: ValueListenableBuilder(
                valueListenable: titleChanged,
                builder: (context, value, child) {
                  return Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.only(
                top: 5,
                bottom: 5,
                left: 40,
                right: 40,
              ),
              child: LinearProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsetsGeometry.only(
                top: 5,
                bottom: 20,
                left: 40,
                right: 40,
              ),
              child: ValueListenableBuilder(
                valueListenable: subtitleChanged,
                builder: (context, value, child) {
                  return Text(value, style: TextStyle(color: Colors.blueGrey));
                },
              ),
            ),
            /*
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                
                children: [
                  TextButton.icon(
                    onPressed: () {                      
                      openStore();
                    },
                    icon: Icon(Icons.update_sharp),
                    label: Text('Upgrade newest'),
                  ),
                  Expanded(child: Container()),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MedlandiaHome()),
                      );
                    },
                    icon: Icon(Icons.run_circle),
                    label: Text('Continue current'),
                  )
                ],
              ),
            )*/
          ],
        ),
      ),
    );
  }
}
