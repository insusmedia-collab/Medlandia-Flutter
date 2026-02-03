import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class Recipient {
  final int id;
  final String name;
  ImageProvider avatar = AssetImage("assets/images/unknown.jpeg");
  Recipient({required this.id, required this.name}) {
    avatar = NetworkImage(
      "https://medlandia.org/medlandia.jsp?func=getAvatar&p1=${id}",
    );
  }
  String toXML() {
    return "<to id='${id.toString()}'>${name}</to>";
  }
  static Recipient fromXML(XmlNode node) {
    return Recipient(id: int.parse(node.getAttribute("id")!), name: node.innerText);
  }
}