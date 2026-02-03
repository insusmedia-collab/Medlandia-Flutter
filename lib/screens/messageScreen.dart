import 'dart:io';

import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/http/httpRequest.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageErrors.dart';
import 'package:medlandia/models/messageFileWrapper.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageModels.dart';
import 'package:medlandia/models/messageQuee.dart';
import 'package:medlandia/models/messageRecipients.dart';
import 'package:medlandia/screens/messageSubjectChooser.dart';
import 'package:medlandia/style.dart';
import 'package:medlandia/xmpp/XMPP.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';
import 'package:medlandia/connectivity/database.dart';



class MessageScreen extends StatefulWidget {  
  static MessageQuee openedQuee = MessageQuee(messageUniqId: -1);
  static ValueNotifier<bool> changeOpenedQuee = ValueNotifier(false);
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  int _minLines = 1;
  final List<File> attachedFiles = [];
  final List<XFile> attachedImages = [];
  final ValueNotifier attachedFilesChanged = ValueNotifier(false);
  final ValueNotifier attachedImageChanged = ValueNotifier(false);
  bool isNotified = false;

  @override
  void initState() {
    super.initState();
    //MessageScreen.isOpened = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start updating after initial build
      if (MessageScreen.openedQuee != null) {
        totalUnreadedMessages.value -= MessageScreen.openedQuee.unrededMessagesCount.value;
        () async {
          db_clearUnreadedCount(uniqId: MessageScreen.openedQuee.messageUniqId);
        }();      
        MessageScreen.openedQuee.unrededMessagesCount.value = 0;
      }

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
      }

    });
      
    // Listen for focus changes
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // When TextField is focused
        setState(() {
          _minLines = 5; // expand input
        });

        // Jump to bottom after a short delay to let UI update
        Future.delayed(Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      } else {
        // Optional: shrink back when unfocused
        setState(() {
          _minLines = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    //MessageScreen.isOpened = false;
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();        
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: APP_BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: APP_TAB_COLOR,
        leading: InkWell(
          onTap: () {        
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
        title: ValueListenableBuilder(
          valueListenable: MessageScreen.openedQuee.userListChanged,
          builder: (a, b, c) => buildTitle(),
        ),
        actions: [
          //if (MessageScreen.openedQuee.getUsers().l.trim().length == 0)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageUserChooser(quee: MessageScreen.openedQuee),
                  ),
                );
              },
              icon: Icon(Icons.person_add),
            ),
        ],
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                child: ValueListenableBuilder(
                  valueListenable: MessageScreen.openedQuee.userListChanged,
                  builder:
                      (_, __, ___) => Wrap(
                        direction: Axis.horizontal,
                        children: [
                          Text(
                            "To:",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          for (Recipient user in MessageScreen.openedQuee.getUsers())
                            Text(
                              " " + user.name + ":",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: MessageScreen.openedQuee.messageListChanged,
                        builder:
                            (a, b, c) =>  ListView.builder(
                              controller: _scrollController,
                              itemCount: MessageScreen.openedQuee.messages.length,
                              itemBuilder:
                                  (context, index) => buildUserArea(MessageScreen.openedQuee.messages[index]),
                            ),
                      ),
                    ),
                    if (attachedFiles.length > 0) Divider(height: 5),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 180),
                        child: SingleChildScrollView(
                          child: ValueListenableBuilder(
                            valueListenable: attachedFilesChanged,
                            builder: (_, __, ___) => buildFilesWidget(),
                          ),
                        ),
                      ),
                    ),
                    if (attachedImages.length > 0) Divider(height: 5),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 180),
                        child: SingleChildScrollView(
                          child: ValueListenableBuilder(
                            valueListenable: attachedImageChanged,
                            builder: (_, __, ___) => buildImagesWidget(),
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 5),
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.all(8.0), child: _buildInput()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    late String title;
    late String subTitle;
    if (MessageScreen.openedQuee.getUsers().length == 0) {
      title = "New message";
    } else {
      title = MessageScreen.openedQuee.subject ?? "";
      subTitle =
          MessageScreen.openedQuee.getUsers().first.name +
          "and " +
          (MessageScreen.openedQuee.getUsers().length - 1).toString() +
          " others";
    }
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (MessageScreen.openedQuee.getUsers().length > 1)
            Text(subTitle, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget buildUserArea(BaseMessageModel m) {

    if (m.error != null) {} 

    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                foregroundColor: Colors.amber,
                backgroundColor: Colors.blue,
                backgroundImage: m.sender.avatar,
                radius: 18,
              ),
              SizedBox(width: 15),
              Column(
                children: [
                  ValueListenableBuilder(
                    valueListenable: m.sendStatus,
                    builder: (context, value, a) {
                      late Color color;

                      return Column(
                        children: [
                          Text(
                            m.sender.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: getMsgStatusTextColor(value),
                            ),
                          ),
                          Text(
                            DateFormat('yyyy-MMM-dd HH:mm').format(m.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: getMsgStatusTextColor(value),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: ValueListenableBuilder(
              valueListenable: m.sendStatus,
              builder: (context, value, _) {

                if (value == MsgStatus.SENDING) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Please wait untill all files will uploaded.", style: TextStyle(color: Colors.red),),
                      for (FileWrapper f in m.files)
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: ValueListenableBuilder(
                                  valueListenable: f.uploadStatus,
                                  builder: (context, value, __) {
                                    if (value == UploadStatus.UPLOADING) {
                                      return Column(
                                        children: [
                                          Text(path.basename(f.file.path)),
                                          LinearProgressIndicator(minHeight: 5),
                                        ],
                                      );
                                    } else if (value == UploadStatus.ERROR) {
                                      return LinearProgressIndicator(
                                        minHeight: 5,
                                      );
                                    } else if (value ==
                                        UploadStatus.SUCCESSED) {
                                      return Row(                                        
                                        children: [
                                          Icon(
                                            Icons.check_rounded,
                                            color: Colors.blue,
                                          ),
                                          Text(path.basename(f.file.path)),
                                        ],
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: f.uploadStatus,
                              builder: (context, value, _) {
                                if (value == UploadStatus.ERROR) {
                                  return IconButton(
                                    onPressed: () {
                                      Xmpp.uploadFile(f);
                                    },
                                    icon: Icon(Icons.refresh),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ],
                        ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          m.text ?? "",
                          style: TextStyle(
                            fontSize: 15,
                            color: getMsgStatusTextColor(value),
                          ),
                        ),
                      ),
                      getImages(m),
                      getFiles(m),                      
                      ValueListenableBuilder(
                        valueListenable: m.errorListChaned,
                        builder: (context, _, __) => Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (MsgError err in m.error)
                              Row(children: [
                                Expanded(
                                  child: Text("Send message to ${err.to?.name} not successed! ${err.name} ", 
                                    softWrap: true,
                                    style: TextStyle(color: Colors.red),),
                                ),
                                IconButton(onPressed: () async {
                                  //print("-------------------------${err.from}");
                                  await Xmpp.send(await m.toXML(err.to.id, parseForLocal: false));                                  
                                  db_clearErrorToMessage(messageUniqueId: m.messageUniqueId, msgId: m.id, error: err);
                                  m.removeError(err);
                                }, icon: Icon(Icons.repeat))
                              ],),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                }
              },
            ),
          ),
          SizedBox(height: 3),
          Divider(height: 2),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget getFiles(BaseMessageModel m) {
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
        for (int i = 0; i < (files.length); i++)
          InkWell(
            onTap: () => OpenFile.open(files[i].path),
            child: Row(
              children: [
                FileIcon(files[i].path, size: 42),
                Text(
                  files[i].path.split('/').last,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(40, 40, 40, 20),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget getImages(BaseMessageModel m) {
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
      itemCount: images.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120, // max width per item
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: InkWell(onTap: () => OpenFile.open(images[index].path), child: Image.file(images[index], fit: BoxFit.cover)),
        );
      },
    );
  }

  Widget _buildInput() {
    return Column(
      children: [
        Row(
          children: [
            Text("Attach:"),
            TextButton.icon(
              icon: Icon(Icons.image),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final List<XFile> images = await picker.pickMultiImage();
                for (XFile file in images) {
                  if (attachedImages.length >= 5) {
                    Toast(
                      context: context,
                      text: "Only 5 images can be attached to letter",
                    );
                    attachedImageChanged.value = !attachedImageChanged.value;
                    return;
                  }
                  bool imageContains = false;
                  for (XFile img in attachedImages) {
                    if (img.name == file.name) {
                      imageContains = true;
                      break;
                    }
                  }
                  if (!imageContains) {
                    attachedImages.add(file);
                  }
                }
                attachedImageChanged.value = !attachedImageChanged.value;
              },
              label: Text(
                "Image",
                style: TextStyle(fontSize: 15, color: Colors.blue),
              ),
            ),

            TextButton.icon(
              icon: Icon(Icons.attach_file),
              onPressed: () async {
                await Xmpp.disconnect(isConnectAfter: false);
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                );
                await Xmpp.connect();
                if (result != null) {
                  List<File> files =
                      result.paths.map((path) => File(path!)).toList();
                  for (File file in files) {
                    if (attachedFiles.length >= 5) {
                      Toast(
                        context: context,
                        text: "Only 5 files can be attached to letter",
                      );
                      attachedFilesChanged.value = !attachedFilesChanged.value;
                      return;
                    }
                    bool fileContains = false;
                    for (File f in attachedFiles) {
                      if (path.basename(f.path) == path.basename(file.path)) {
                        fileContains = true;
                        break;
                      }
                    }
                    if (!fileContains) {
                      attachedFiles.add(file);
                    }
                  }
                  attachedFilesChanged.value = !attachedFilesChanged.value;
                }
              },
              label: Text(
                "File",
                style: TextStyle(fontSize: 15, color: Colors.blue),
              ),
            ),
          ],
        ),

        SizedBox(height: 3),
        Divider(height: 1),
        SizedBox(height: 3),

        if (MessageScreen.openedQuee.messages.length == 0)
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(hintText: "Subject"),
          ),

        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 50,
            maxHeight: 150, // expanded height
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: _minLines,
                      maxLines: null, // allow expanding
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async => send(await toMessage(_subjectController.text, _controller.text, attachedFiles, attachedImages)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFilesWidget() {
    if (attachedFiles.length == 0) {
      return Container();
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: attachedFiles.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 80, // max width per item
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  FileIcon(attachedFiles[index].path, size: 45),
                  Text(
                    path.basename(attachedFiles[index].path),
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () {
                  attachedFiles.removeAt(index);
                  attachedFilesChanged.value = !attachedFilesChanged.value;
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildImagesWidget() {
    if (attachedImages.length == 0) {
      return Container();
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: attachedImages.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 80, // max width per item
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(attachedImages[index].path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () {
                  attachedImages.removeAt(index);
                  attachedImageChanged.value = !attachedImageChanged.value;
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<BaseMessageModel?> toMessage(String? subject, String? text, List<File> files, List<XFile> images) async {

    if (_controller.text.trim().length == 0 &&
        attachedFiles.length == 0 &&
        attachedImages.length == 0) {
      Toast(context: context, text: "Text is empty");
      return null;
    }

    BaseMessageModel m = BaseMessageModel(
      id: genId(),
      sender: Recipient(id: currentUser!.id, name: currentUser!.name),
      messageUniqueId: MessageScreen.openedQuee.messageUniqId,
      text: (text ?? ""),
      subject: subject ?? "",
      timestamp: DateTime.now(),
    );
    m.addAllReciviers(MessageScreen.openedQuee.getUsers());
    for (File f in attachedFiles) {
      m.files.add(FileWrapper(messageUniqueId: MessageScreen.openedQuee.messageUniqId, file: f, get: "", mimeType: lookupMimeType(f.path), size: await f.length()));
    }

    for (XFile file in attachedImages) {
      File f = File(file.path);
      m.files.add(FileWrapper(messageUniqueId: MessageScreen.openedQuee.messageUniqId, file: f, get: "", mimeType: lookupMimeType(f.path), size: await f.length()));
    }

    return m;
  }

  Future<void> send(BaseMessageModel? msg) async {

    if (msg == null) {
      Toast(context: context, text: "Message not created");
      return;
    }

    if (MessageScreen.openedQuee.getUsers().length == 0) {
      Toast(context: context, text: "No recipient added.");
      return;
    }

    /*-- Subject need at first time-- */    
    if (MessageScreen.openedQuee.messages.length == 0 && (msg.subject == null || msg.subject!.trim().length == 0)) {
      Toast(context: context, text: "Need subject");
      return;
    }

    if (MessageScreen.openedQuee.messages.length == 0) {
      MessageScreen.openedQuee.subject = msg.subject ?? "No subject";
    }

    String msgText = _controller.text;
    _controller.clear();    
    String subject = _subjectController.text;
    _subjectController.clear();

    FocusScope.of(context).unfocus();
    
        /*------ Save and send message ---------------- */
        await db_createQuee(MessageScreen.openedQuee);      
        db_appendMessage(messageUniqueId: MessageScreen.openedQuee.messageUniqId, content: await msg.toXML(0, parseForLocal: true));
        MessageScreen.openedQuee.subject = subject;
        MessageScreen.openedQuee.lastActivity.value = DateTime.now();
        db_UpdateLastActivity(uniqId: MessageScreen.openedQuee.messageUniqId);
        MessageScreen.openedQuee.appendMessage(msg);
        await msg.send();
        print("--Alwais send");


        /*----------- Message quee changment ------------------*/
        bool hasInQueeList = false;          
        for (int i = messageQuees.length-1; i >= 0; i--) {
          if (messageQuees[i].messageUniqId == MessageScreen.openedQuee.messageUniqId) {
            messageQuees[i].appendMessage(msg);
            messageQuees[i].lastActivity.value = DateTime.now();
            hasInQueeList = true;
            break;
          }
        }

        if (!hasInQueeList) {
          messageQuees.add(MessageScreen.openedQuee.copy());
        }

        messageQuees.sort(messageQueeSorterByDate);
        messageQueesChanged.value = !messageQueesChanged.value;

        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        
        /*--- Notify users and add as chat--------*/
        if (!isNotified) {
          List<int> updatableIds = []; 

          for (Recipient r in MessageScreen.openedQuee.getUsers()) {
            if (r.id == currentUser!.id) continue;
            print("--------------------->> notify ${r.id}");
            String text = "";
            if (msgText.length > 0) {
              text = (msgText.length > 100 ?msgText.substring(0, 100) : msgText) + "...";
            } 
            if (attachedFiles.length > 0 || attachedImages.length > 0) {
                text += " Send " + (attachedFiles.length + attachedImages.length).toString()  + " files";
            }
            Connector.notify("new_message", r.id, currentUser!.id, text);
            updatableIds.add(r.id);
          }
          if (updatableIds.length > 0) {
            final result = await Connector.setUser2UsersChat(updatableIds);
            print("----Add multiple chat result $result");
          }
          isNotified = true;
        }

        /*------- Increase unreaded messages --------- */
        for (Recipient r in MessageScreen.openedQuee.getUsers()) {
          if (r.id == currentUser!.id) continue;
          Connector.increaseUnreaded(userTo: r.id);
        }
   
    
    attachedImages.clear();
    attachedFiles.clear();    
    attachedFilesChanged.value = !attachedFilesChanged.value;
    attachedImageChanged.value = !attachedImageChanged.value;
  }

  Color getMsgStatusTextColor(MsgStatus value) {
    if (value == MsgStatus.SENDING) {
      return Colors.grey;
    } else {
      return Colors.black;
    }
  }
}
