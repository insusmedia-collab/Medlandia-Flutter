import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageFileWrapper.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageModels.dart';
import 'package:medlandia/xmpp/scramclient.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as path;

enum XmppState {DISCONNECTED, CONNECTED }

class Xmpp {
  static late WebSocketChannel channel;
  static late ScramClient scram;
  static final ValueNotifier<bool> isAuthenticated = ValueNotifier(false);
  static final ValueNotifier<XmppState> isConnected = ValueNotifier(XmppState.DISCONNECTED);
  static final List<void Function(String)> messageListeners = [];
  static final List<FileWrapper> fileUploadWaiters = [];
  static late String username;
  static late String password;

  static Timer? ping; 
    static final List<int> pingWaiters = [];    

  Xmpp() {}

  static void init({required String user, required String password}) {
    Xmpp.username = user;
    Xmpp.password = password;
  }

  static Future<void> connect() async {
    final wsUrl = Uri.parse('wss://chat.medlandia.org/ws/');
    
    channel = WebSocketChannel.connect(wsUrl);
    
    if (isConnected.value == XmppState.CONNECTED) {
      await disconnect(isConnectAfter: false);
    }
    

    channel.stream.listen((message) {
      print("<== $message");

      if (message.toString().contains('open') && !isAuthenticated.value) {
        //print("==> send <stream:stream auth=${isAuthenticated.value}");
        //channel.sink.add('''<stream:stream to="chat.medlandia.org" xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams" version="1.0">''');
      }

      if (message.toString().contains('stream:features') &&
          !isAuthenticated.value) {
        scram = ScramClient(username, password, mechanism: 'SCRAM-SHA-1');
        final initialMessage = scram.initialMessage;
        final a =
            "<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='SCRAM-SHA-1'>$initialMessage</auth>";
        print("==> $a");
        channel.sink.add(a);
      }

      if (message.toString().contains('challenge') &&
          message.toString().contains('urn:ietf:params:xml:ns:xmpp-sasl')) {
        final document = XmlDocument.parse(message.toString());
        final challengeElement = document.findAllElements('challenge').first;
        final body = challengeElement.text.trim();
        final ch = scram?.processChallenge(body);
        final a =
            "<response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>$ch</response>";
        print("==> $a");
        channel.sink.add(a);
      }

      if (message.toString().contains('success')) {
        isAuthenticated.value = true;
        final a =
            "<open xmlns='urn:ietf:params:xml:ns:xmpp-framing' to='chat.medlandia.org' version='1.0'/>";
        print("==> $a");
        channel.sink.add(a);
      }

      if (message.toString().contains('stream:features') &&
          isAuthenticated.value) {
        final a =
            "<iq type='set' id='bind1'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/></iq>";
        print("==> $a");
        channel.sink.add(a);
      }

      if (message.toString().contains('bind') && isAuthenticated.value) {
        final a = "<bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/>";
        print("==> $a");
        isConnected.value = XmppState.CONNECTED;
        channel.sink.add(a);
        channel.sink.add(
          '''<presence from="$username@chat.medlandia.org"><show>chat</show></presence>''',
        );
        /*--add pinging meckansm */
        if (ping != null) {
          ping!.cancel();
          ping = null;          
        }
        pingWaiters.clear();
        ping = Timer.periodic(Duration(seconds: 10), (timer) async { sendPing(); });        
      }

      if (message.toString().contains('<message') && isAuthenticated.value) {
        for (int i = 0; i < messageListeners.length; i++) {
          messageListeners[i](message);
        }
      }

      if (message.toString().contains('<stream:error')) {

        if (message.toString().contains("system-shutdown")) {
          disconnect(isConnectAfter: true);
        } else {
          //final document = XmlDocument.parse(message);
          //final textElement = document.findAllElements('text').firstWhere((_) => true);
          print("--Error--${message}");
          //throw textElement.innerText.trim();
        }
      }

      if (message.toString().contains("<iq") && message.toString().contains("from='upload.chat.medlandia.org'") && message.toString().contains("__upl_")) {
          for (int i = fileUploadWaiters.length-1; i >= 0; i--) {
            FileWrapper f = fileUploadWaiters[i];
            final document = XmlDocument.parse(message.toString());
            final iq = document.findAllElements('iq').first;            
            final putXml = document.findAllElements('put').first;
            final getXml = document.findAllElements('put').first;
            String? xmlFileName = iq.getAttribute("id");
            String? put = putXml.getAttribute("url");
            String? get = getXml.getAttribute("url");
            if (put == null || get == null) throw "It is a not url data. You missed!";
            f.put = put;
            f.get = get;
            if ("__upl_${f.getFileName()}" == xmlFileName) {
              fileUploadWaiters.removeAt(i);
              f.upload();
            }
          }
      }

      if (message.toString().contains('<close')) {
        disconnect(isConnectAfter: true);
      }

      if (message.toString().contains("<presence")) {
        if (message.toString().contains("unavailable")) {
          () async {
            await disconnect(isConnectAfter: false);  
            await connect();
          }();
        } else {
          sendLocalBufferMessages();
        }
      }

      for (int pingId in pingWaiters) {
          if (message.toString().contains("id='${pingId}'")) {
            print("-ping answer");
            pingWaiters.clear();            
            break;
          }
      }
      
    }, 
    onError: (error) {
      print("--Error--(WebSocket)=> $error");
    }, 
    onDone: () async {
      print("----Connection clodes onDone");
      isConnected.value = XmppState.DISCONNECTED;
      isAuthenticated.value = false;
      /*
      try {
        Future.delayed(const Duration(seconds: 5), () async {
          print('--- Connect-disconnect Runs after 5 seconds');
          await disconnect(isConnectAfter: true);
          await connect(); 
        });         
      } catch(e) {
        print(e);
      }*/
    });
    try {
      await channel.ready;
    } catch(e) {
      print("--Error-- System connection error: $e");
      //inform to user      
      return;
    }
    
    //print("State: ${isConnected.value} ${isAuthenticated.value}");

    final open = '<open xmlns="urn:ietf:params:xml:ns:xmpp-framing" to="chat.medlandia.org" version="1.0"/>';
    print("==> $open");

    try {
      channel.sink.add(open);
    } catch (e) {
      print("--Error-- $e ${isConnected.value}");
    }
    
  } // Add your XMPP related methods and properties here

  

  static Future<void> disconnect({required bool isConnectAfter}) async {
    try {      
      try {
        channel.sink.add("<close xmlns='urn:ietf:params:xml:ns:xmpp-framing'/>");
      } catch (f) {}
      await channel.sink.close();
    } catch (e) {
      print("---Error--Diconnecting$e");
    } finally {
      isConnected.value = XmppState.DISCONNECTED;
      isAuthenticated.value = false;
      if (!isConnectAfter) {
        ping?.cancel();
        ping = null;
      }
    }
  }

  static Future<void> sendPing() async {
    
if (isConnected.value == XmppState.DISCONNECTED || pingWaiters.length > 2) { 
      print("--Not connected for ping-- reconnecting");
      await disconnect(isConnectAfter: false);
      await connect();      
    }
          try {
            final id = genId();
            final p = '''<iq type="get" id="${id}" to="chat.medlandia.org"><ping xmlns="urn:xmpp:ping"/></iq>''';
            print("==>$p");
            channel.sink.add(p);
            pingWaiters.add(id);
          } catch (e) {
            print(e);
            //reconnect();
          }

  }
/*
  static void sendNormal(
    int to,
    int queeId,
    String? subject,
    String? text,
    List<String> files,
  ) {
    channel.sink.add('''
      <message from="${currentUser!.id.toString()}" to="$to" type="normal" queeId="$queeId">
        <subject>${subject}</subject>
        <body>${text}</body>
        <order xmlns="urn:insus:xmpp:attachment">
        </order>
      </message>
    ''');
  }
*/
  static void uploadFile(FileWrapper fw) async {
    fileUploadWaiters.add(fw);
    int fileSize = await fw.getFileSize();
    final String a =
        '''<iq from="${currentUser!.id.toString()}@chat.medlandia.org" to="upload.chat.medlandia.org" type="get" id="__upl_${path.basename(fw.file.path)}">
                <request xmlns="urn:xmpp:http:upload:0" filename="${fw.getFileName()}" size="${fileSize}" content-type="${fw.getMimeType()}"/>
            </iq>''';
    print("==>$a");
    send(a);
  }

  static Future<void> send(dynamic data) async {
    VoidCallback? onConnectListener;
    if (isConnected.value == XmppState.DISCONNECTED) {      
      saveMessageToLocalBuffer(data);
    } else {
      channel.sink.add(data);
      print("==>$data");
    }
  }

  static Future<void> saveMessageToLocalBuffer(String msg) async {
    print("--Save data to local buffer");
    File localMessageBuffer = File(appDocDirectory.path + "/localMessageBuffer.txt");
    if (!await localMessageBuffer.exists()) {
      localMessageBuffer.create();
    }
    localMessageBuffer.writeAsString(msg, mode: FileMode.append,flush: true,);
  }

  static Future<void> sendLocalBufferMessages() async {
    if ( isConnected.value != XmppState.CONNECTED) return;    
    File localMessageBuffer = File(appDocDirectory.path + "/localMessageBuffer.txt");
    if (! await localMessageBuffer.exists()) {
      return;
    }
    String msg = await localMessageBuffer.readAsString();
    if (msg.trim().length == 0) {
      return;
    }
      try {
        String xmlStr = "<root>${msg}</root>";
        final document = XmlDocument.parse(xmlStr);
        final root = document.rootElement;
        final children = root.children;        
        print("--Local buffer content ${msg.length}");
        List<XmlNode> sended = [];//children.toList().reversed.toList(        );
        // SEND
        for (int i = 0; i < children.length; i++ ) {
          try {
            channel.sink.add(children[i].toString());          
            sended.add(children[i]); // save sended to buffer
          } catch (v) {
            print("--Error-- Unsend $i message: $v");
          }
        }
        // clear sended from children
        for (XmlNode n in sended) {
          children.remove(n);          
        }
        // Check 
        String unsendMessages = "";
        for (XmlNode u in children) {
          unsendMessages += u.toString();
        }
        if (unsendMessages.trim().length > 0) {
          print("--Oooo-- There is a unusuale state. Not of all mesages could be sensdable.");
        }
        await localMessageBuffer.writeAsString(unsendMessages.trim());
      } catch(e) {
        print("--Error-- Cant send local buffer from file $e");
      }
    
  }
}
