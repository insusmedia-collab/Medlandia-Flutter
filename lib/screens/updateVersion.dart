import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medlandia/MedlandiaHome.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/style.dart';
import 'package:url_launcher/url_launcher.dart';

class Updater extends StatefulWidget {
  final dynamic version;
  const Updater({super.key, required this.version});

  @override
  State<Updater> createState() => _UpdaterState();
}

class _UpdaterState extends State<Updater> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: APP_BACKGROUND_COLOR,
       appBar: AppBar(
        backgroundColor: APP_TAB_COLOR,
        leading: CircleAvatar(
          radius: 25,
          child: Icon(Icons.update),
        ),
        title: Text("Update new version"),
       ),
       body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset("assets/images/logo-512.jpg",width: 100,height: 100,fit: BoxFit.cover,),
            ),
            Padding(
              padding: EdgeInsetsGeometry.only(top: 20, bottom: 20, left: 40, right: 40),
              child: Text("Medlandia ${widget.version['version']}:${widget.version['buildNumber']} is now available. Upgrade newest version?",
              style: TextStyle(color: BASIC_HEADER_COLOR, fontSize: 14), softWrap: true,
              ),
            ),
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
            )
          ],
        )
       ),
    );
  }

  Future<void> openStore() async {
    /*
     final Uri url = Platform.isAndroid
    ? Uri.parse('market://details?id=org.insus.medlandia')
    : Uri.parse('itms-apps://apps.apple.com/app/id6686405548'); */
    
  final Uri url = Platform.isAndroid
      ? Uri.parse(
          'https://play.google.com/store/apps/details?id=org.insus.medlandia')
      : Uri.parse(
          'https://apps.apple.com/am/app/medlandia/id6686405548');
  try {
    if (!await launchUrl(url,mode: LaunchMode.externalApplication,)) {}
  } catch (e) {
    Connector.err(codePlace: "updateVersion->openStore", e: e.toString());
    Toast(context: context, text: "Error on lunching store.");
  } finally {
    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MedlandiaHome()),
                      );
  }
}

}