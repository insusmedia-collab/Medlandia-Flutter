

/*
abstract class Xmpp  {
  late xmpp.Connection connection;
  //late var messageHandler;
  late xmpp.RosterManager _rosterManager;
  late xmpp.MessageArchiveManager _archiveManager;
  late xmpp.PresenceManager presenceManager;
  late xmpp.MessageArchiveManager mam;
  List<ControllerItem> controllers = [];
  //final Map<bool Function(xml.XmlElement income), Function()> comarators = Map<bool Function(xml.XmlElement income), Function()>();

  Future<void> connect() async {
    xmpp.XmppAccountSettings accountSettings = xmpp.XmppAccountSettings.fromJid(
      '${mainUser!.id}@medlandia.org/resource',
      mainUser!.chatPassword,
    );
    accountSettings.port = false ? 5291 : 5222;
    accountSettings.wsPath =
        null; //'xmpp-websocket'; // null or your custom xmpp path
    accountSettings.wsProtocols = ['xmpp']; // or your custom protocols

    connection = xmpp.Connection.getInstance(accountSettings);
    connection.reconnectionManager?.initialTimeout = 100;

    addConnectionStateListener((state) {
      if (state == xmpp.XmppConnectionState.Ready) {
        controllers.clear();
        _rosterManager = xmpp.RosterManager.getInstance(connection);
        //messageHandler = xmpp.MessageHandler.getInstance(connection);
        presenceManager = xmpp.PresenceManager.getInstance(connection);
        _archiveManager = connection.getMamModule();
        mam = connection.getMamModule();

        addNonzasListener((onData) {
          print("Come nonza");
          //print("==--== ${onData.buildXmlString()}");
          innerStream(onData.buildXmlString());
        });

        addStanzaListener((onData) {
          print("come stanza");
          //print("--==-- ${onData?.buildXmlString()}");
          innerStream(onData.buildXmlString());
        });

        initMessageRecivier();

        addPresenceListener((xmpp.PresenceData event) {
          //innerStream(event.buildXmlString());
          //print("Presene --> ${event.jid!.fullJid}  ${event.showElement.toString()}");
        });

        addRosterManager((onData) {
          //listGroups(0, 50);
          //doAddRoster("__222100", xmpp.SubscriptionType.BOTH);
        });

connection.write('''<iq type='set' id='register1'>
  <query xmlns='jabber:iq:register'>
    <username>newuser</username>
    <password>mypassword</password>
    <email>user@example.com</email> <!-- Optional -->
    <name>John Doe</name> <!-- Optional -->
  </query>
</iq>''');

      } else if (state == xmpp.XmppConnectionState.Authenticated) {
        print("--Authenticated--");
      } else if (state == xmpp.XmppConnectionState.Authenticating) {
        print("--Authenticating");
      } else if (state == xmpp.XmppConnectionState.AuthenticationFailure) {
        print("--AuthenticationFailure");
      } else if (state == xmpp.XmppConnectionState.AuthenticationNotSupported) {
        print("--AuthenticationNotSupported");
      } else if (state == xmpp.XmppConnectionState.ForcefullyClosed) {

        print("--ForcefullyClosed");
        connection.reconnect();
      } else if (state == xmpp.XmppConnectionState.Closing) {
        print("--Closing");
        connection.reconnect();
      } else if (state == xmpp.XmppConnectionState.Closed) {
        print("--Closed");
      } else if (state == xmpp.XmppConnectionState.DoneParsingFeatures) {
        print("--DoneParsingFeatures");
      }
    });
    connection.connect();
  }

  void addPresenceListener(
    Function(xmpp.PresenceData presence) onPresenceListener,
  ) {
    presenceManager.presenceStream.listen(onPresenceListener);
  }

  void addRosterManager(Function(dynamic roster) onRosterListener) {
    _rosterManager.rosterStream.listen(onRosterListener);
  }

  /*
  void addMesageListener(Function(dynamic message) onMessageListener) {
    messageHandler.messagesStream.listen(onMessageListener);
  }*/
  StreamSubscription<dynamic> addStanzaListener(
    Function(dynamic stanza) onStanzaListener,
  ) {
    return connection.inStanzasStream.listen(onStanzaListener);
  }

  StreamSubscription<dynamic> addNonzasListener(
    Function(dynamic nonza) onNonzaListener,
  ) {
    return connection.inNonzasStream.listen(onNonzaListener);
  }

  void addConnectionStateListener(
    Function(xmpp.XmppConnectionState state) onConnectionState,
  ) {
    connection.connectionStateStream.listen(onConnectionState);
  }

  void doAddRoster(String name, xmpp.SubscriptionType type) async {
    /*
    xmpp.Buddy addable = xmpp.Buddy(xmpp.Jid.fromFullJid("$name@medlandia.org/resource"));
    addable.subscriptionType =  type;//xmpp.SubscriptionType.BOTH;
    await _rosterManager.addRosterItem(addable);
    _rosterManager.getRoster();*/

    final id = Xmpp.uniqId();
    ControllerItem item = ControllerItem(
      id: id,
      inspector: (xmlRoot) {
        late xml.XmlElement? query;
        return xmlRoot.name.toString() == "iq" &&
            xmlRoot.getAttribute("type")?.trim().toLowerCase().toString() ==
                "set" &&
            xmlRoot.getAttribute("to")?.trim().toLowerCase().toString() ==
                "${mainUser!.id}@medlandia.org/resource" &&
            (query = xmlRoot.getElement("query"))
                    ?.getAttribute("xmlns")
                    ?.toLowerCase()
                    .trim() ==
                "jabber:iq:roster" &&
            query?.getElement("item")?.getAttribute("jid")?.trim() ==
                "$name@medlandia.org";
      },
      handler: (xmlRoot) {
        print("Roster addded by XMLLLLLL---------------");
        /*
                      final subId = Xmpp.uniqId();
                      ControllerItem sub = ControllerItem(
                                      id: subId, 
                                      inspector: (xmlSub){
                                        return xmlSub.name.toString() == "presence"
                                               && xmlSub.getAttribute("to")?.toLowerCase().trim() == "${name}@medlandia.org"
                                               && xmlSub.getAttribute("type")?.toLowerCase().trim() == "subscribed"; 
                                      }, 
                                      handler: (xmlSub){
                                        print("Subscribed!!!!!!!!!!!!!!!!!!");
                                        controllers.removeWhere((stest) {
                                          
                                          return stest.id == subId;
                                        });
                                      });
                      controllers.add(sub);
                      connection.write('''<presence to='${name}@medlandia.org' type='subscribe'/>''');
                      */

        controllers.removeWhere((test) {
          return test.id == id;
        });
      },
    );

    controllers.add(item);
    connection.write('''
      <iq type='set' id='${Xmpp.uniqId()}'>
  <query xmlns='jabber:iq:roster'>
    <item jid='$name@medlandia.org' name='Jane Doe' subscription='both'>
      
    </item>
  </query>
</iq>
    ''');
  }

  void doRemoveRoster(String name) async {
    await _rosterManager.removeRosterItem(
      xmpp.Buddy(xmpp.Jid.fromFullJid("$name@medlandia.org")),
    );
    _rosterManager.getRoster();
  }

  void doUpdateRosterItem(String name) async {
    xmpp.Buddy updatable = xmpp.Buddy(
      xmpp.Jid.fromFullJid("$name@medlandia.org/resource"),
    );
    updatable.subscriptionType = xmpp.SubscriptionType.BOTH;
    //updatable.accountJid = xmpp.Jid.fromFullJid("aliktravma@medlandia.org/resource");
    await _rosterManager.updateRosterItem(updatable);
    _rosterManager.getRoster();
  }

  void doSendMessage(int id, int to, int from, String body, bool isStore) async {
    final xmpp.MessageStanza messageStanza = xmpp.MessageStanza(
      uniqId().toString(),
      xmpp.MessageStanzaType.CHAT,
    ); // From is set by the client
    messageStanza.toJid = xmpp.Jid.fromFullJid("$to@medlandia.org");
    messageStanza.body = body;
    messageStanza.id = id.toString();

    if (!isStore) {
      /*
      final op = xmpp.XmppElement();
      op.name = "openfire";
      op.addAttribute(xmpp.XmppAttribute("xmlns", "http://www.igniterealtime.org/protocol"));
      final e = xmpp.XmppElement();
      e.name = "no-archive";
      e.textValue = "true";
      op.addChild(e);
      messageStanza.addChild(op);
*/
      /*
      final elem = xmpp.XmppElement();
      elem.name = "no-store";
      elem.addAttribute(xmpp.XmppAttribute("xmlns", "urn:xmpp:hints"));
      messageStanza.addChild(elem);
*/
      final elem2 = xmpp.XmppElement();
      elem2.name = "no-permanent-store";
      elem2.addAttribute(xmpp.XmppAttribute("xmlns", "urn:xmpp:hints"));
      messageStanza.addChild(elem2);
      /*
      final elem3 = xmpp.XmppElement();
      elem3.name = "store";
      elem3.addAttribute(xmpp.XmppAttribute("xmlns", "urn:xmpp:sid:0"));
      elem3.textValue = "false";
      messageStanza.addChild(elem3);
    */
    }

    connection.writeStanza(messageStanza);
    //messageHandler.sendMessage(xmpp.Jid.fromFullJid("${to}@medlandia.org"), body);
  }

  void initMessageRecivier() {
    //print("Should be onse");
    ControllerItem item = ControllerItem(
      id: Xmpp.uniqId(),
      inspector: (xmlroot) {
        return xmlroot.name.toString().toLowerCase().trim() == "message";
        // && xmlroot.getAttribute("type").toLowerCase().trim() == "chat"
      },
      handler: (xmlRoot) {
        xml.XmlElement? msg = xmlRoot;
        if (xmlRoot.getAttribute("type") == "null") {
          // MAM
          final child = xmlRoot.getElement("result")?.getElement("forwarded");
          final stamp = child?.getElement("delay")?.getAttribute("stamp");
          msg = child?.getElement("message");
        }
        if (msg == null) {
          print("--Error-- MAM");
          return;
        }
        //print("should be once  ${xmlRoot.getElement("body")?.innerText}");
        String? to = msg.getAttribute("to");
        String? from = msg.getAttribute("from");
        String? body = msg.getElement("body")?.innerText;
        String? type = msg.getAttribute("type");
        String? id = msg.getAttribute("id");

        onMessage(type, DB.unDomain(name: from!), DB.unDomain(name: to!), body);
      },
    );
    item.name = "Messagerecivier";
    controllers.add(item);
  }

  void innerStream(String xmlString) {
    print("---inner--");
    print(xmlString);
    xml.XmlDocument doc = xml.XmlDocument.parse(xmlString);

    for (int i = controllers.length - 1; i >= 0; i--) {
      controllers[i].excute(doc.rootElement);
      //print("Here ->  ${controllers[i].name}");
    }
  }
/*
  Future<void> createGroup({
    required String roomName,
    required String ownerName,
    required String roomTitle,
    bool isPublic = true,
    bool isPersistante = true,
    bool isPasswordProtected = false,
    bool isModerator = false,
    bool allowInvite = true,
    Function? onSuccess,
    Function? onError,
  }) async {
    int id = Xmpp.uniqId();

    print("Roomtitle $roomTitle  ");
    print("Room name $roomName");
    ControllerItem item = ControllerItem(
      id: id,
      callCount: 1,
      inspector: (source) {
        //print(" Print -->  $source ");
        return source.name.toString().toLowerCase().trim() == "presence" &&
            source.getAttribute("from")?.toLowerCase().trim() ==
                "$roomName@conference.medlandia.org/$ownerName".toLowerCase() &&
            source.getAttribute("to")?.toLowerCase().trim() ==
                "$ownerName@medlandia.org/resource".toLowerCase();
      },
      handler: (xml) async {
        connection.write(
          '''<iq type='set' to='$roomName@conference.medlandia.org/root' id='create${uniqId()}'>
  <query xmlns='http://jabber.org/protocol/muc#owner'>
    <x xmlns='jabber:x:data' type='submit'>
      <field var='FORM_TYPE' type='hidden'>
        <value>http://jabber.org/protocol/muc#roomconfig</value>
      </field>
      <field var='muc#roomconfig_roomname'>
        <value>$roomTitle</value>
      </field>
      <field var='muc#roomconfig_publicroom'>
        <value>${isPublic ? 1 : 0}</value> <!-- 1 = public, 0 = private -->
      </field>
      <field var='muc#roomconfig_persistentroom'>
        <value>${isPersistante ? 1 : 0}</value> <!-- 1 = persistent, 0 = temporary -->
      </field>
      <field var='muc#roomconfig_passwordprotectedroom'>
        <value>${isPasswordProtected ? 1 : 0}</value> <!-- 1 = password protected, 0 = open -->
      </field>
      <field var='muc#roomconfig_whois'>
        <value>${isModerator ? 'anyone' : 'moderators'}</value> <!-- "anyone" or "moderators" -->
      </field>
      <field var='muc#roomconfig_allowinvites'>
        <value>${allowInvite ? 1 : 0}</value> <!-- 1 = allow invites, 0 = disallow -->
      </field>
       <field var='muc#roomconfig_lockedroom'>
        <value>0</value> <!-- 0 = unlocked -->
      </field>
      <field var='muc#roomconfig_membersonly'>
        <value>0</value> <!-- 0 = open to all -->
      </field>
    </x>
  </query>
</iq>''',
        );

        connection.write(''' 
<presence to='$roomName@conference.medlandia.org/$ownerName'>
  <x xmlns='http://jabber.org/protocol/muc'/>
</presence>
''');

        controllers.removeWhere((test) {
          return test.id == id;
        });

        mainUser!.sendMessage(TextMessage(producer: mainUser!.id, 
                                          message: roomTitle,//['title'], 
                                          type: MessageTypes.SOURCE), int.parse(roomName));
        if (onSuccess != null) onSuccess();
      },
    );

    controllers.add(item);
    await Future.delayed(const Duration(milliseconds: 100));

    connection.write(
      '''<presence to='$roomName@conference.medlandia.org/$ownerName'>
        <x xmlns='http://jabber.org/protocol/muc'/>
      </presence>''',
    );
  }
*/
  Future<void> listRosters(int index, int count) async {
    final id = Xmpp.uniqId();
    final cId = uniqId();
    ControllerItem item = ControllerItem(
      id: cId,
      inspector: (xmlResult) {
        return xmlResult.name.toString().toLowerCase().trim() == "iq" &&
            xmlResult.getAttribute("type")?.toLowerCase().trim() == "result" &&
            xmlResult.getAttribute("id")?.toLowerCase().trim() == id.toString();
      },
      handler: (xmlResult) {
        List<Roster> list = [];
        xmlResult.getElement("query")?.childElements.forEach((node) {
          list.add(
            Roster(
              jid: node.getAttribute("jid"),
              name: node.getAttribute("name"),
            ),
          );
        });
        onRosterList(list);
        controllers.removeWhere((test) {
          return id == test.id;
        });
      },
    );
    controllers.add(item);
    connection.write('''
        <iq type='get' id='$id'>
          <query xmlns='jabber:iq:roster'>
            <set xmlns='http://jabber.org/protocol/rsm'>
              <max>$count</max>
              <index>$index</index>
            </set>
          </query>
        </iq>
''');
  }

  Future<void> listGroups(int index, int count) async {
    final id = Xmpp.uniqId();
    ControllerItem item = ControllerItem(
      id: id,
      inspector: (xml) {
        return xml.name.toString() == "iq" &&
            xml.getAttribute("type")?.toLowerCase().trim() == "result" &&
            xml.getAttribute("from")?.toLowerCase().trim() ==
                "conference.medlandia.org" &&
            xml.getAttribute("to")?.toLowerCase().trim() ==
                "${mainUser!.id}@medlandia.org/resource";
      },
      handler: (xmlRoot) {
        List<Group> groups = [];
        xmlRoot.getElement("query")?.children.forEach((node) {
          String? jid = node.getAttribute("jid");
          String? name = node.getAttribute("name");
          if (name != null && jid != null) {
              print("--> jid=$jid --> text=$name");
              groups.add(Group(jid: jid, text: name));
            }
        });
        onGroupsList(groups);
        controllers.removeWhere((test) {
          return test.id == id;
        });
      },
    );
    controllers.add(item);
    connection.write('''<iq from='${mainUser!.id}@medlandia.org/resource'
                        id='${Xmpp.uniqId()}'
                        to='conference.medlandia.org'
                        type='get'>
                          <query xmlns='http://jabber.org/protocol/disco#items'>
                          <set xmlns='http://jabber.org/protocol/rsm'>
                            <max>$count</max> <!-- Maximum results -->
                            <index>$index</index> <!-- Start index -->
                          </set>
                          </query>
                        </iq>''');
  }

  Future<void> addContact(String jid, {String? name, List<String>? groups});
  void onGroupsList(List<Group> groups);
  void onRosterList(List<Roster> rosters);
  void onMessage(String? type, int fromId, int toId, String? body);

  Xmpp();

  String messageToJson(BaseMessageModel msg) {
    Map<String, dynamic> m = {};
    m["id"] = msg.id;
    m['gType'] = msg.globalType.index;
    m['sendTime'] = msg.sendTime;
    m['replyMessageId'] = msg.replyMessageId;

    if (msg is TextMessage) {
      m['message'] = msg.message;
    }
    if (msg is ResourceMesage) {
      m['resourceUrl'] = msg.resourceUrl;
    }
    if (msg is DocumentMesage) {
      m['resourceUrl'] = msg.resourceUrl;
    }
    if (msg is InvitationMessage) {
      m['memberId'] = 1;
    }
    if (msg is ScheduleMessage) {
      m['date'] = msg.date;
      m['job'] = msg.job;
      m['place'] = msg.place;
    }
    if (msg is MessageReactionMessage) {
      m['reaction'] = msg.reaction;
      m['messageId'] = msg.messageId;
    }
    if (msg is EmojMessage) {
      m['emoj'] = msg.emoj;
    }
    if (msg is MessageStatusMessage) {
      m['status'] = msg.status.index;
      m['messageId'] = msg.messageId;
    }
    if (msg is VoiceMesage) {
      m['resourceUrl'] = msg.resourceUrl;
    }
    return jsonEncode(m);
  }

  BaseMessageModel messageFromJson(String m, int fromId, int toId) {
    if (!isJsonObject(m)) {
      return TextMessage(producer: fromId, message: m, type: MessageTypes.ANSWER);
    }

    Map<String, dynamic> model = jsonDecode(m);
    late BaseMessageModel msg;
    if (model['gType'] == MessageGlobalTypes.SCHEDULE_MESSAGE.index) {
      msg = ScheduleMessage(
        producer: fromId,
        date: model['date'],
        job: model['job'],
        place: model['place'],
        type: MessageTypes.ANSWER,
      );
    } else if (model['gType'] == MessageGlobalTypes.INVITE_MESSAGE.index) {
      late BaseMemberModel mmodel;
      for (BaseMemberModel m in dummyChatItems) {
        if (m.id == model["memberId"]) {
          mmodel = m;
          break;
        }
      }

      msg = InvitationMessage(
        producer: fromId,
        member: mmodel, // model['memberId'],
        avatarUrl: NetworkImage("url"),
        type: MessageTypes.ANSWER,
      );
    } else if (model['gType'] == MessageGlobalTypes.DOCUMENT_MESSAGE.index) {
      msg = DocumentMesage(
        producer: fromId,
        resourceUrl: model['resourceUrl'],
        type: MessageTypes.ANSWER,
        resourceId:  model['resourceId'],
      );
    } else if (model['gType'] == MessageGlobalTypes.RESOURCE_MESSAGE.index) {
      msg = ResourceMesage(
        producer: fromId,
        resourceUrl: model['resourceUrl'],
        type: MessageTypes.ANSWER,
        resourceId:  model['resourceId'],
      );
    } else if (model['gType'] == MessageGlobalTypes.TEXT_MESSAGE.index) {
      msg = TextMessage(
        producer: fromId,
        message: model['message'],
        type: MessageTypes.ANSWER,
      );
    } else if (model['gType'] == MessageGlobalTypes.MESSAGE_REACTION.index) {
      msg = MessageReactionMessage(
        producer: fromId,
        messageId: model['messageId'],
        reaction: model['reaction'],
        type: MessageTypes.ANSWER,
      );
    } else if (model['gType'] ==
        MessageGlobalTypes.MESSAGE_EMOJ_MESSAGE.index) {
      msg = EmojMessage(
        producer: fromId,
        emoj: model['emoj'],
        type: MessageTypes.ANSWER,
      );
    } else if (model['gType'] ==
        MessageGlobalTypes.MESSAGE_STATUS_MESSAGE.index) {
      msg = MessageStatusMessage(
        producer: fromId,
        status: MessageStatus.values[model['status']],
        messageId: model['messageId'],
      );
    } else if (model['gType'] ==
        MessageGlobalTypes.MESSAGE_VOICE_MESSAGE.index) {
      msg = VoiceMesage(
        producer: fromId,
        resourceUrl: model['resourceUrl'],
        type: MessageTypes.ANSWER,
        resourceId:  model['resourceId'],
      );
    } else {
      msg = BaseMessageModel(
        producer: fromId,
        globalType: MessageGlobalTypes.UNDEFINED,
        type: MessageTypes.ANSWER,
        sendTime: model['sendTime'],
      );
    }
    msg.id = model['id'];
    msg.replyMessageId = model['replyMessageId'];
    return msg;
  }

  bool isJsonObject(String str) {
    try {
      final decoded = json.decode(str);
      return decoded is Map<String, dynamic>;
    } catch (e) {
      return false;
    }
  }

  static int uniqId() {
    return DateTime.now().microsecondsSinceEpoch;
  }
}

class Group {
  final String jid;
  final String text;
  Group({required this.jid, required this.text});
}

class Roster {
  final jid;
  final name;
  Roster({required this.jid, required this.name});
  int getId() {
    return int.parse( jid.toString().trim().split('@')[0] );
  }
}

class ControllerItem {
  final int id;
  final bool Function(xml.XmlElement income) inspector;
  final Function(xml.XmlElement income) handler;
  int liveTime = -1;
  late int callCount;
  int callCounter = 0;
  String name = "";
  ControllerItem({
    required this.id,
    required this.inspector,
    required this.handler,
    this.liveTime = -1,
    this.callCount = -1,
  });
  void excute(xml.XmlElement income) {
    if (inspector(income)) {
      //print("Execute ==   $id  ${income.toXmlString()}");
      handler(income);
    }
  }
}
*/