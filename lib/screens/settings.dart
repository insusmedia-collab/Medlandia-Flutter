import 'package:flutter/material.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/connectivity/database.dart';
import 'package:medlandia/screens/DoctorSkillsScreen.dart';
import 'package:medlandia/screens/language.dart';
import 'package:medlandia/style.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/login/RegUserPersonalSettings.dart';
import 'package:medlandia/screens/WorkplaceScreen.dart';
import 'package:medlandia/login/regUserSpeciality.dart';
import 'package:medlandia/wellcomeHome.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 244),
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: const Color.fromARGB(255, 230, 230, 232),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Personal data"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => 
                              SettingsPersonal(
                                  userType: currentUser?.userType, 
                                  id: currentUser?.id, 
                                  name: currentUser?.name ?? "", 
                                  email: currentUser?.email, 
                                  userRegistered: true, sameUser: currentUser,)))
                    ,
            ),
            if (currentUser?.userType == 1) ListTile(
              leading: Icon(Icons.cast_for_education),
              title: Text("Spetialities",style: TextStyle(color: BASIC_TEXT_COLOR, fontSize: 18),),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (builder) => UserSpetiality(creationMode: false))),
            ),
            if (currentUser?.userType == 1) ListTile(
              leading: Icon(Icons.home),
              title: Text("Workplaces",style: TextStyle(color: BASIC_TEXT_COLOR, fontSize: 18),),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (builder) => WorkplaceScreen(creationMode: false))),
            ),
            if (currentUser?.userType == 1) ListTile(
              leading: Icon(Icons.work),
              title: Text("Skills",style: TextStyle(color: BASIC_TEXT_COLOR, fontSize: 18),),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (builder) => DoctorSkillsScreen(updateFunc: () {},))),
            ),
            /*
            ListTile(
              leading: Icon(Icons.block),
              title: Text("Deleted users", style: TextStyle(color: BASIC_TEXT_COLOR, fontSize: 18),),
              onTap: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => DeletedMembersScreen()));
              },
            ),*/
            ListTile(
              leading: Icon(Icons.language),
              title: Text("Language", style: TextStyle(color: BASIC_TEXT_COLOR, fontSize: 18),),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Delete account", style: TextStyle(color: BASIC_TEXT_COLOR, fontSize: 18),),
              onTap: () {
                showDialog(context: context, 
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Delete account"),
                    content: Text("Do you really want to delete account?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        }, 
                        child: Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            Connector.deleteAccount();
                            dropDatabase();
                            currentUser = null;
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => Wellcome()));
                        }, 
                          child: Text("Delete"))
                    ],
                  );
                });
              },
            )
          ],
        ),
      ),
    );
  }
}