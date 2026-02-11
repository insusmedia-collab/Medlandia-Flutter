

import 'package:flutter/material.dart';
import 'package:medlandia/MedlandiaHome.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/countryModel.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/login/licence.dart';
import 'package:medlandia/stores/localStore.dart';
import 'package:medlandia/style.dart';
import 'package:medlandia/http/httpRequest.dart';

String? languageForRegistrationUser;

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: APP_TAB_COLOR,
        leadingWidth: 80,
        leading: CircleAvatar(          
          backgroundColor: ICON_COLOR,
            child: Icon(Icons.language),   
        ),
        title: Text("Select language", style: TextStyle(color: BASIC_HEADER_COLOR, fontSize: 18)),
        centerTitle: true,        
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) => ListTile(
            onTap: () =>  updateLanguage(languages[index]),
            title: Text(languages[index].nativeName, style: TextStyle(color: BASIC_TEXT_COLOR, fontSize: 18, fontWeight: FontWeight.bold),),
            subtitle: Text(languages[index].englishName, ),
            trailing: Text(languages[index].flag, style: TextStyle(fontSize: 25),),
          )
          ),
      ),
    );
  }

  void updateLanguage(Language lang) {
    if (currentUser != null) { // in settings
      (() async {
        call(null, {
          'func'  : 'updateLanguage',
          'p1'    : currentUser!.id.toString(),
          'p2'    : lang.code
        }).then((v) {
          (() async {
            await LocalStore.write(key: "language", value: lang.code);                        
            Toast(context: context, text: "Update loaded. Please restart application for language pack become active");
            Navigator.pop(context);
          })();          
        });
      })();
    } else {
      languageForRegistrationUser = lang.code;
      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LicenceScreen()));
    }
  }

}