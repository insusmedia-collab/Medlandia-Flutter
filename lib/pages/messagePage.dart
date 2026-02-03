import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medlandia/MedlandiaHome.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/connectivity/database.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageFileWrapper.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:file_icon/file_icon.dart';
import 'package:medlandia/models/messageModels.dart';
import 'package:medlandia/models/messageQuee.dart';
import 'package:medlandia/models/messageRecipients.dart';
import 'package:medlandia/screens/messageScreen.dart';
import 'package:medlandia/style.dart';


int MSG_QUEE_LOAD_INDEX = 0;
int MSG_QUEE_LOAD_COUNT = 50;



class MessagePage extends StatefulWidget {
  static bool isOpened = false;
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>   with RouteAware {
  final ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  messageQuees.sort(messageQueeSorterByUnreaded);  
   _scrollController.addListener(_scrollListener);   
   messageQuees.sort(messageQueeSorterByDate);
}

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //routeObserver.subscribe(this, ModalRoute.of(context)!);
  }
/*
  @override
  void didPopNext() {
    // 🔥 CALLED when returning to this page
    print("***************8HomePage is shown again");
    // refresh data, call API, update UI, etc.
    setState(() {
      messageQuees.sort(messageQueeSorterByDate);  
      messageQueesChanged.value = !messageQueesChanged.value;
      print("*******************REFRESHING");
    });
    MessagePage.isOpened = true;
  }

  @override
  void didPush() {
    print("***************HomePage pushed first time");
    MessagePage.isOpened = true;
  }

  @override
  void didPushNext() {
    MessagePage.isOpened = false;
    print("*****************MessageList CLOSED (covered)");
  }
*/
@override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    //routeObserver.unsubscribe(this);
    //MessagePage.isOpened = false;
    super.dispose();
  }

void _scrollListener() async {
    // Detect when scrolled to the bottom
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      List<MessageQuee> list = await db_loadMessageQueeList(from: MSG_QUEE_LOAD_INDEX, count: MSG_QUEE_LOAD_COUNT );
      messageQuees.addAll(list);
      print("--MSG_QUEE_UNDEX=$MSG_QUEE_LOAD_INDEX MSG_QUEE_COUNT=$MSG_QUEE_LOAD_COUNT");
      if (list.length > 0) {
        MSG_QUEE_LOAD_INDEX += MSG_QUEE_LOAD_COUNT;
      }
      messageQueesChanged.value = !messageQueesChanged.value;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
/* messageQuees.sort(messageQueeSorterByDate);
   messageQueesChanged.value = !messageQueesChanged.value; */
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,     
      children: [
        ValueListenableBuilder(
          valueListenable: messageQueesChanged,
          builder: (context, _, __) => ListView.builder(
            controller: _scrollController,
            itemCount: messageQuees.length,
            itemBuilder:
                (context, i) {
                  return Column(
                        children: [
                        //--------------------------------------------------------
                          if (!idDaySame(
                                messageQuees[i].lastActivity.value,
                                (i == 0 ? DateTime(2000) : messageQuees[i-1].lastActivity.value)))
                            Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 187, 168, 239),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(DateFormat('dd-MMMM-yyyy').format(messageQuees[i].lastActivity.value,), 
                                style: TextStyle(color: Colors.white, fontSize: 14),)
                              ),
                        //------------------------------------------------------------
                          GestureDetector(
                          onTap:
                              () { 
                                  MessageScreen.openedQuee = messageQuees[i].copy();
                                  messageQuees[i].unrededMessagesCount.value = 0;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MessageScreen()) ); 
                                },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 8,
                            ),
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: APP_TAB_COLOR,  // const Color.fromARGB(255, 235, 235, 236),
                              border: Border.all(
                                color: const Color.fromARGB(207,211,211,213), // Border color
                                width: 1.0, // Border thickness
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [                                
                                Row(
                                  children: [
                                    buildTitleImages(messageQuees[i]),
                                    Expanded(child: buildTitleText(messageQuees[i])),
                                    buildTitleMenu(messageQuees[i])
                                  ],
                                ),
                                SizedBox(height: 5),
                                //Divider(height: 0.5, color: APP_BORDER_COLOR),
                                SizedBox(height: 5),
                          
                                Container(
                                  padding: EdgeInsets.only(top: 1, left: 3, right: 5, bottom: 2),
                                  alignment: Alignment.centerLeft,
                                  child: Text("Subject: " + (messageQuees[i].subject.length > 30 ? (messageQuees[i].subject.substring(0, 30) + "...") : messageQuees[i].subject), 
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: BASIC_HEADER_COLOR), softWrap: true, )
                                  ),    

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3.0,
                                    vertical: 5.0,
                                  ),
                                  child: Text(
                                    messageQuees[i].messages.length > 0 ? messageQuees[i].messages.last.text ?? "Empty message" : "",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(80, 80, 80, 20),
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                          
                                getImages(messageQuees[i].messages.length > 0 ? messageQuees[i].messages.last : null),
                                getFiles(messageQuees[i].messages.length > 0 ? messageQuees[i].messages.last : null),
                          
                                SizedBox(height: 3),
                                Divider(height: 2),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    SizedBox(width: 20),
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Color.fromRGBO(80, 80, 80, 20),
                                    ),
                                    SizedBox(width: 5),
                                    ValueListenableBuilder(
                                      valueListenable: messageQuees[i].lastActivity, 
                                      builder: (context, value, _) => 
                                        Text(                                    
                                            "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}",
                                            style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                        ),
                                      )
                                      )
                                    
                                      
                                  ],
                                ),
                              ],
                            ),
                          ),
                                              ),
                        ],
                      );
                }
          ),
        ),
      ],
    );
  }

  Widget buildTitleMenu(MessageQuee q) {
    return PopupMenuButton(
        icon: Icon(Icons.more_horiz),
        onSelected: (value) {},
        itemBuilder:
            (BuildContext context) => [
              PopupMenuItem(value: "Readed", child: Text("Readed"), onTap: () {
                db_clearUnreadedCount(uniqId: q.messageUniqId);                
                totalUnreadedMessages.value -= q.unrededMessagesCount.value;
                q.unrededMessagesCount.value = 0;
              }, ),
              PopupMenuItem(value: "Delete", child: Text("Delete"), onTap: () async {
                final result = await showDeleteYesNoDialog(context);
                if (result == true) {
                  for(int i = messageQuees.length-1; i >= 0; i--) {
                    if (messageQuees[i].messageUniqId == q.messageUniqId) {
                      messageQuees.removeAt(i);
                      messageQueesChanged.value = !messageQueesChanged.value;
                      break;
                    }
                  }
                  db_deleteMessageQuee(messageQueeId: q.messageUniqId);
                }
              },),
            ],
      );
  }

  Widget buildTitleText(MessageQuee quee) {
    String text="";
    if (quee.getUsers().length > 3) {
      text = " + ${quee.getUsers().length-1} others";
    } else if (quee.getUsers().length == 1) {
      text = "You and " + quee.getUsers()[0].name;
    } else {
      text = "You,  ";
      for (int i = 0; i < quee.getUsers().length; i++) {
        Recipient r = quee.getUsers()[i];
        if (r.id == currentUser!.id) continue;
        text += r.name;
        if (i + 1 == quee.getUsers().length-1) {
          text += " and ";
        } else {
          text += ", ";
        }
      }
    }
    return Padding(padding: EdgeInsetsGeometry.all(8), child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: BASIC_HEADER_COLOR),));
  }

  Widget buildTitleImages(MessageQuee q) {

    return Row(
      children: [
        Stack(
          children: <Widget>[
            for (int i = 0; i < (q.getUsers().length > 3 ? 3 : q.getUsers().length); i++)
            Container(
              padding: EdgeInsets.only(left: i*30),
              child: CircleAvatar(
                foregroundColor: Colors.amber,
                backgroundColor: Colors.blue,
                backgroundImage: NetworkImage("https://medlandia.org/medlandia.jsp?func=getAvatar&p1=${q.getUsers()[i].id}") ?? AssetImage("assets/images/unknown.jpeg"),
                radius: 22,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: q.unrededMessagesCount,
              builder: (context, count, _) {
                if (count == 0) return SizedBox.shrink();
                return Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  constraints: BoxConstraints(
                    minHeight: 20,
                    minWidth: 20
                  ),
                  child: Text(count.toString(), style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center),
                )
              );
              } ,
            ),
            
          ],
        )
      ],
    );
/*
    return ListTile(
      leading: ,
      title:
          q.getUsers().length > 1
              ? Text(
                q.getUsers()[0].name + " and " + (q.getUsers().length-1).toString() + " others",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(40, 40, 40, 20),
                ),
              )
              : Text(
                q.getUsers()[0].name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(40, 40, 40, 20),
                ),
              ),
      subtitle: Text(
        q.subject ?? "",
        style: TextStyle(fontSize: 14, color: Color.fromRGBO(40, 40, 40, 20)),
      ),
      trailing: ,
    );*/
  }

  Widget getFiles(BaseMessageModel? m) {
    if (m == null) {
      return Container();
    }
if (m.files.length == 0) {
      return Container();
    }
    
List<File> files = [];
    for (FileWrapper src in m.files) {
      if (!src.file.path.endsWith("jpg") &&
          !src.file.path.endsWith("jpeg") &&
          !src.file.path.endsWith("png") &&
          !src.file.path.endsWith("gif") &&
          !src.file.path.endsWith("tiff")) {
        files.add(src.file);
      }
    }
    int filesCount = files.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Container(padding: EdgeInsets.all(8), child: Text("Attachment ($filesCount)", textAlign: TextAlign.left, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(40, 40, 40, 20),),)),
        for (int i = 0; i < (files.length > 5 ? 5 : files.length); i++)
        Row(
          children: [
            FileIcon(files[i].path, size: 32,),
            Text(files[i].path.split('/').last,  style: TextStyle(fontSize: 14, color: Color.fromRGBO(40, 40, 40, 20),),)
          ],
        ),
      ],
    );
  }

  Widget getImages(BaseMessageModel? m)  {
    if (m == null) {
      return Container();
    }
    if (m.files.length == 0) {
      return Container();
    }
    List<File> images = [];
    for (FileWrapper src in m.files) {
      if (src.file.path.endsWith("jpg") ||
          src.file.path.endsWith("jpeg") ||
          src.file.path.endsWith("png") ||
          src.file.path.endsWith("gif") ||
          src.file.path.endsWith("tiff")) {
        images.add(src.file);
      }
    }

    return  GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: images.length > 5 ? 5 : images.length,
      shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 70, // max width per item
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(images[index], fit: BoxFit.cover),
        );
      },
    );
  }

Future<bool?> showDeleteYesNoDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // user must tap a button
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

bool idDaySame(DateTime a, DateTime b) {
  if (a.year != b.year || a.month != b.month || a.day != b.day) {
    return false;
  } 
  return true;
}

}
