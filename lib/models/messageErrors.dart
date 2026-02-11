import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageRecipients.dart';
import 'package:xml/xml.dart';

class MsgError {  
  static final UNKNOWN = "unknown";
  static final CANCEL = "cancel";
  final id;
  final name;
  final String type;
  final Recipient to;
  const MsgError({required this.id, required this.type, required this.name, required this.to});

  String toXML() {
    String nodeType = "";
    if (type == MsgError.CANCEL) {
      nodeType = "cancel";
    }
    return '''<error id="${id}" type="${nodeType}"><${name} xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/>${to.toXML()}</error>''';
  }

  static MsgError fromXML(String errNodeText) {
    final document = XmlDocument.parse(errNodeText);
    final errNode = document.rootElement;
    final to = errNode.findAllElements("to").firstOrNull;    
    final id = errNode.getAttribute("id") == null ? genId() : int.parse(errNode.getAttribute("id")!); 
    if ("cancel" == errNode.getAttribute("type")) {      
        final ulavailables = errNode.findAllElements("service-unavailable");
        return MsgError(id: id, type: MsgError.CANCEL, name: "service-unavailable", to: Recipient(id: int.parse(to?.getAttribute("id") ?? "-1"), name: to?.innerText ?? "no-name"));
    }
    return MsgError(id: id, type: MsgError.UNKNOWN, name: "unhandled-error", to: Recipient(id: -1, name: "name-err"), );
  }

}