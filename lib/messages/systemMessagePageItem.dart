import 'package:flutter/material.dart';
import 'package:medlandia/connectivity/database.dart';
import 'package:medlandia/messages/normalMessagePageItem.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageModels.dart';
import 'package:medlandia/models/messageQuee.dart';
import 'package:medlandia/style.dart';

class SystemMessagePaheItem extends StatefulWidget {
  final MessageQuee quee;
  const SystemMessagePaheItem({super.key, required this.quee});

  @override
  State<SystemMessagePaheItem> createState() => _SystemMessagePaheItemState();
}

class _SystemMessagePaheItemState extends State<SystemMessagePaheItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: getColor(), // const Color.fromARGB(255, 235, 235, 236),
                              border: Border.all(
                                color: const Color.fromARGB(207, 211, 211, 213), // Border color
                                width: 1.0, // Border thickness
                              ),
                            ),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  //if ((messageQuees[index].messages.last as HeadlineMessage).level == "info")
                  getIcon(),
                  SizedBox(width: 5,),
                  Expanded(child: getTitle()),
                  buildTitleMenu(widget.quee)
                ],
              ),
              SizedBox(height: 3,),
              Container(
                margin: EdgeInsets.all(4),
                padding: EdgeInsets.all(4),
                child: Text(widget.quee.messages.last.text == null  ? "" : widget.quee.messages.last.text!),
              ),
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
                  valueListenable: widget.quee.lastActivity,
                  builder:
                      (context, value, _) => Text(
                        "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                ),
              ],
            )
            ],
          ),
    );
  }

  Color getColor() {
    if ((widget.quee.messages.last as HeadlineMessage).level == "critical") {
      return Color.fromARGB(255, 246, 217, 218);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "error") {
      return Color.fromARGB(255, 252, 220, 243);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "warning") {
      return Color.fromARGB(255, 247, 247, 209);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "wellcome") {
      return Color.fromARGB(255, 214, 247, 223);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "goodnews") {
      return Color.fromARGB(255, 215, 248, 224);
    } else {
      return Color.fromARGB(255, 250, 239, 223);
    }
  }

  Widget getIcon() {
    if ((widget.quee.messages.last as HeadlineMessage).level == "critical") {
      return Icon(Icons.stop_circle_sharp, size: 35, color: const Color.fromARGB(255, 240, 14, 2));
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "error") {
      return Icon(Icons.error, size: 35, color: const Color.fromARGB(255, 240, 2, 169),);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "warning") {
      return Icon(Icons.warning, size: 35, color: const Color.fromARGB(255, 240, 224, 2),);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "goodnews") {
      return Icon(Icons.emoji_emotions, size: 35, color: const Color.fromARGB(255, 64, 255, 115),);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "wellcome") {
      return Icon(Icons.accessibility_new_sharp, size: 35, color: const Color.fromARGB(255, 64, 255, 115),);
    } else {
      return Icon(Icons.info, size: 35, color: Colors.orangeAccent,);
    }
  }

  Widget getTitle() {
    if ((widget.quee.messages.last as HeadlineMessage).level == "critical") {
      return Text("Critical", style: TextStyle(color: BASIC_HEADER_COLOR, fontSize: 16, fontWeight: FontWeight.bold),);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "error") {
      return Text("Error", style: TextStyle(color: BASIC_HEADER_COLOR, fontSize: 16, fontWeight: FontWeight.bold),);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "warning") {
      return Text("Warning", style: TextStyle(color: BASIC_HEADER_COLOR, fontSize: 16,  fontWeight: FontWeight.bold),);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "wellcome") {
      return Text("Wellcome", style: TextStyle(color: BASIC_HEADER_COLOR, fontSize: 16,  fontWeight: FontWeight.bold),);
    } else if ((widget.quee.messages.last as HeadlineMessage).level == "goodnews") {
      return Text("Good news", style: TextStyle(color: BASIC_HEADER_COLOR, fontSize: 16,  fontWeight: FontWeight.bold),);
    } else {
      return Text("Information", style: TextStyle(color: BASIC_HEADER_COLOR, fontSize: 16,  fontWeight: FontWeight.bold),);
    }
    return SizedBox();
  }

  Widget buildTitleMenu(MessageQuee q) {
    return PopupMenuButton(
      icon: Icon(Icons.more_horiz),
      onSelected: (value) {},
      itemBuilder:
          (BuildContext context) => [            
            PopupMenuItem(
              value: "Delete",
              child: Text("Delete"),
              onTap: () async {
                final result = await showDeleteYesNoDialog(context);
                if (result == true) {
                  for (int i = messageQuees.length - 1; i >= 0; i--) {
                    if (messageQuees[i].messageUniqId == q.messageUniqId) {
                      messageQuees.removeAt(i);
                      messageQueesChanged.value = !messageQueesChanged.value;
                      break;
                    }
                  }
                  db_deleteMessageQuee(messageQueeId: q.messageUniqId);
                }
              },
            ),
          ],
    );
  }
}