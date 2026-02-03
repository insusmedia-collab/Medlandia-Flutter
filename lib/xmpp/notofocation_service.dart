
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/connectivity/device.dart';
import 'package:medlandia/http/httpRequest.dart';
import 'package:medlandia/stores/localStore.dart';

late String? tocken;

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  initFCM() async {
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true,);
    
    try {      
      final fcmToken = await _firebaseMessaging.getToken();
      print("Token = ${fcmToken}");
    tocken = fcmToken;
    } catch (e) {
      print("--Error-- $e");
      try {        
          final id = await LocalStore.read("id");
         await call(null, {
            'func' : 'userError', 
            'p1' : id ?? "37444545250", 
            'p2' : devModel ?? "undefined", 
            'p3' : devVersion ?? "undefined",
            'p4' : appVersion ?? "undefined",
            'p5' : "NotificationService->initFCM",
            'p6' : e.toString()
            });          
      } catch (f) {}

      //Connector.err(codePlace: "NotificationService->initFCM", e: e.toString());
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      print("--Info-- somewhere come it");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      print("--Info-- also somewhere come it");
    });
    /*
    FirebaseMessaging.onBackgroundMessage((RemoteMessage msg) async {
      if (msg.notification != null) {
        print("MEssage ${msg.notification?.title}");
      }
    });*/
  }
}