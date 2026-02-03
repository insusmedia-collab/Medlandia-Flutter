import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/connectivity/database.dart';
import 'package:medlandia/connectivity/device.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/pages/messagePage.dart';
import 'package:medlandia/screens/updateVersion.dart';
import 'package:medlandia/stores/localStore.dart';
import 'package:medlandia/xmpp/XMPP.dart';
import 'package:medlandia/xmpp/notofocation_service.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:medlandia/MedlandiaHome.dart';
import 'package:medlandia/models/DoctorSkillsModel.dart';
import 'package:medlandia/models/countryModel.dart';
import 'package:medlandia/models/scheduleModel.dart';
import 'package:medlandia/models/spetialityModel.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/wellcomeHome.dart';
import 'package:medlandia/http/httpRequest.dart';

late Directory appDocDirectory;
late dynamic version; 

void main() async {
  
  
  MainApp mApp = MainApp();
  runApp(mApp);
}

Future<void> initLocalDevice() async {   
    try {
      appDocDirectory = await getApplicationDocumentsDirectory();
      await initPlatformState();
    } catch(e) {
      Connector.err(codePlace: "main->initLocalDevice", e: e.toString());
    }
}

Future<void> initFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationServise =  NotificationService();
  await notificationServise.initFCM();

  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessages);
  //await Firebase.initializeApp(options: DefaultFirebaseOptions )
}

Future<void> handleBackgroundMessages(RemoteMessage msg) async {
  print("Background message ${msg.notification?.title}");
  final player = AudioPlayer();
            player.play(AssetSource('voice/001.aac'));
}

void Toast({required BuildContext context, required String text, int seconds = 2}) {
  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(text),
                        duration: Duration(seconds: seconds),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {
                            // Action when pressed
                          },
                        ),
                      ),
                    ); 
                    } catch (e) {
                      print("==> Toast error $e");
                    }
}

Future<void> loadContent() async {    
    await loadSpetialities(currentUser!.language);
    await loadDeletedMembers();
    doctorLoadIndex = 0;
    doctors.clear();    
    await loadDoctors(index: doctorLoadIndex);
    await Connector.loadUser2User();
    await loadSchedules();
    await loadSkills(currentUser!.language);
    version = await Connector.getLatestVersion();
}

class MainApp extends StatelessWidget  /*with WidgetsBindingObserver */ {
  const MainApp({super.key});

  Future<String> getStartWidget() async {    
    initCountries();
    /*-- try load user data locally--- */
    String? idStr = await LocalStore.read("id"); 
    if (idStr == null) {
      print("==> MainUser id is not in store, First time? or error.");
      currentUser = null;
      return "";
    }

    /*-- local finded, but update data from server-- */

    bool loaded = false;
    try {
     loaded = await Connector.initMainUser(id: idStr);
    } catch(e) {
      Connector.err(codePlace: "main.dart->initMainUser", e: e.toString());      
    }
    /*--- server not responde (internet error) */
    if (!loaded) {
        currentUser = null;
        print("==> CANT LOAD MAIN USER!!!");
        return "";
    }
    initLocalDevice();
    initFirebase();

    /*-- everything OK. cintinue load all data--*/  
    await loadContent();
    
    //await dropDatabase();
    //await dump();
    /*-- Connect to XMPP server --*/
    String? id = await LocalStore.read("id");
    String? password = await LocalStore.read("password");
    Xmpp.init(user: id!, password: password!);
    Xmpp.messageListeners.clear();
    Xmpp.messageListeners.add(incomeMessages);
    await Xmpp.connect();

    /*--- init load messages database --*/ 
    MSG_QUEE_LOAD_INDEX = 0;
    messageQuees = await db_loadMessageQueeList(from: MSG_QUEE_LOAD_INDEX, count: MSG_QUEE_LOAD_COUNT);
    MSG_QUEE_LOAD_INDEX += MSG_QUEE_LOAD_COUNT;
    
    /*-- finish start realisation--*/
    if (tocken != null) {
      Connector.updateDevice(tocken!);
    } else {
      print("--Error-----------------Cant get tocken");
    }
    Connector.updateEnterDate();    

    return "ok";
  }

  @override
  Widget build(BuildContext context) {
    

    return MaterialApp(
      title: "Medlandia",
      theme: ThemeData(),
      home: FutureBuilder(
        future: getStartWidget(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return   Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: const Color.fromARGB(255, 220, 221, 223),  
              child:   Center(
                //alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ 
                    CircleAvatar(
                      radius: 50, // size = radius * 2
                      backgroundImage: AssetImage('assets/images/logo-512.jpg'),
                    ),
                    SizedBox(height: 15,),
                    //Text("Loading Medlandia.", style: TextStyle(fontSize: 14, fontFamily: 'Arial', color: const Color.fromARGB(255, 61, 63, 72)), textAlign: TextAlign.center,),
                    SizedBox(height: 15,),                    
                    SizedBox( width: 200, child: LinearProgressIndicator(minHeight: 3,)),
                    
                  ]
                ),
              ));
          } else {            
            if (currentUser == null) {
              return Wellcome();
            } else {
              
              /*--Cant check server or local device--*/
              if (version == null || appVersion == null || appBuildNumber == null || version['version'] == null || version['buildNumber'] == null) {
                return MedlandiaHome();
              }
              /*--Build number and version is latest --*/
              if (version['version'].toString().trim() == appVersion!.trim() && version['buildNumber'].toString().trim() == appBuildNumber!.trim()) {
                  return MedlandiaHome();
              }
               
              return Updater(version: version,);

              
            }
          }
        },
      ),
    );
  }
}
