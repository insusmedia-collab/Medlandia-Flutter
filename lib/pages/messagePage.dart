import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medlandia/MedlandiaHome.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/connectivity/database.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/messages/normalMessagePageItem.dart';
import 'package:medlandia/messages/systemMessagePageItem.dart';
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

class _MessagePageState extends State<MessagePage> with RouteAware {
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
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      List<MessageQuee> list = await db_loadMessageQueeList(
        from: MSG_QUEE_LOAD_INDEX,
        count: MSG_QUEE_LOAD_COUNT,
      );
      messageQuees.addAll(list);
      print(
        "--MSG_QUEE_UNDEX=$MSG_QUEE_LOAD_INDEX MSG_QUEE_COUNT=$MSG_QUEE_LOAD_COUNT",
      );
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
          builder:
              (context, _, __) => ListView.builder(
                controller: _scrollController,
                itemCount: messageQuees.length,
                itemBuilder: (context, i) {
                  return Column(
                    children: [
                      //--------------------------------------------------------
                      if (!idDaySame(
                        messageQuees[i].lastActivity.value,
                        (i == 0
                            ? DateTime(2000)
                            : messageQuees[i - 1].lastActivity.value),
                      ))
                        Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 187, 168, 239),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            DateFormat(
                              'dd-MMMM-yyyy',
                            ).format(messageQuees[i].lastActivity.value),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      //------------------------------------------------------------
                      if (messageQuees[i].messages.length > 0 && messageQuees[i].type == MQtypes.NORMAL)
                        GestureDetector(
                          onTap: () {
                            MessageScreen.openedQuee = messageQuees[i].copy();
                            messageQuees[i].unrededMessagesCount.value = 0;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MessageScreen()),
                            );
                          },
                          child: NormalMessagePageItem(quee: messageQuees[i]),
                        ),
                      if (messageQuees[i].messages.length > 0 && messageQuees[i].type == MQtypes.SYSTEM)
                        GestureDetector(
                          onTap: () {},
                          child: SystemMessagePaheItem(quee: messageQuees[i]),
                        )
                    ],
                  );
                },
              ),
        ),
      ],
    );
  }

  
 
  

  

  

  bool idDaySame(DateTime a, DateTime b) {
    if (a.year != b.year || a.month != b.month || a.day != b.day) {
      return false;
    }
    return true;
  }
}
