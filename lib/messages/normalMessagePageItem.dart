import 'dart:io';

import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:medlandia/connectivity/database.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageFileWrapper.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageModels.dart';
import 'package:medlandia/models/messageQuee.dart';
import 'package:medlandia/models/messageRecipients.dart';
import 'package:medlandia/style.dart';

class NormalMessagePageItem extends StatefulWidget {
  final MessageQuee quee;
  const NormalMessagePageItem({super.key, required this.quee});

  @override
  State<NormalMessagePageItem> createState() => _NormalMessagePageItemState();
}

class _NormalMessagePageItemState extends State<NormalMessagePageItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 3, vertical: 8),
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: APP_TAB_COLOR, // const Color.fromARGB(255, 235, 235, 236),
          border:  Border.all(
            color: const Color.fromARGB(207, 211, 211, 213), // Border color
            width: 1.0, // Border thickness
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                buildTitleImages(widget.quee),
                Expanded(child: buildTitleText(widget.quee)),
                buildTitleMenu(widget.quee),
              ],
            ),
            SizedBox(height: 5),
            //Divider(height: 0.5, color: APP_BORDER_COLOR),
            SizedBox(height: 5),

            Container(
              padding: EdgeInsets.only(top: 1, left: 3, right: 5, bottom: 2),
              alignment: Alignment.centerLeft,
              child: Text(
                "Subject: " +
                    (widget.quee.subject.length > 30
                        ? (widget.quee.subject.substring(0, 30) + "...")
                        : widget.quee.subject),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: BASIC_HEADER_COLOR,
                ),
                softWrap: true,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 3.0,
                vertical: 5.0,
              ),
              child: Text(
                widget.quee.messages.length > 0
                    ? widget.quee.messages.last.text ?? "Empty message"
                    : "",
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(80, 80, 80, 20),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.quee.messages.length > 0 &&
                widget.quee.messages.last is BaseMessageModel)
              getImages(widget.quee.messages.last as BaseMessageModel),
            if (widget.quee.messages.length > 0 &&
                widget.quee.messages.last is BaseMessageModel)
              getFiles(widget.quee.messages.last as BaseMessageModel),

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
                  valueListenable: widget.quee.lastActivity,
                  builder:
                      (context, value, _) => Text(
                        "${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  

  Widget buildTitleMenu(MessageQuee q) {
    return PopupMenuButton(
      icon: Icon(Icons.more_horiz),
      onSelected: (value) {},
      itemBuilder:
          (BuildContext context) => [
            PopupMenuItem(
              value: "Readed",
              child: Text("Readed"),
              onTap: () {
                db_clearUnreadedCount(uniqId: q.messageUniqId);
                totalUnreadedMessages.value -= q.unrededMessagesCount.value;
                q.unrededMessagesCount.value = 0;
              },
            ),
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

  Widget buildTitleText(MessageQuee quee) {
    String text = "";
    if (quee.getUsers().length > 3) {
      text = " + ${quee.getUsers().length - 1} others";
    } else if (quee.getUsers().length == 1) {
      text = "You and " + quee.getUsers()[0].name;
    } else {
      text = "You,  ";
      for (int i = 0; i < quee.getUsers().length; i++) {
        Recipient r = quee.getUsers()[i];
        if (r.id == currentUser!.id) continue;
        text += r.name;
        if (i + 1 == quee.getUsers().length - 1) {
          text += " and ";
        } else {
          text += ", ";
        }
      }
    }
    return Padding(
      padding: EdgeInsetsGeometry.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: BASIC_HEADER_COLOR,
        ),
      ),
    );
  }

  Widget buildTitleImages(MessageQuee q) {
    return Row(
      children: [
        Stack(
          children: <Widget>[
            for (
              int i = 0;
              i < (q.getUsers().length > 3 ? 3 : q.getUsers().length);
              i++
            )
              Container(
                padding: EdgeInsets.only(left: i * 30),
                child: CircleAvatar(
                  foregroundColor: Colors.amber,
                  backgroundColor: Colors.blue,
                  backgroundImage:
                      NetworkImage(
                        "https://medlandia.org/medlandia.jsp?func=getAvatar&p1=${q.getUsers()[i].id}",
                      ) ??
                      AssetImage("assets/images/unknown.jpeg"),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minHeight: 20, minWidth: 20),
                    child: Text(
                      count.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
     
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
              FileIcon(files[i].path, size: 32),
              Text(
                files[i].path.split('/').last,
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(40, 40, 40, 20),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget getImages(BaseMessageModel? m) {
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

    return GridView.builder(
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