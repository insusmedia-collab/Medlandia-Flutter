import 'package:flutter/material.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/login/RegUserPersonalSettings.dart';
import 'package:medlandia/screens/language.dart';
import 'package:medlandia/style.dart';
import 'package:medlandia/http/httpRequest.dart';

class RegUsrType extends StatefulWidget {
  const RegUsrType({super.key, required this.id, required this.country});
  final int id;
  final String country;

  @override
  State<RegUsrType> createState() => _RegUsrTypeState();
}

class _RegUsrTypeState extends State<RegUsrType> {

ValueNotifier<String> regStatus = ValueNotifier("");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 244),
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            alignment: Alignment.center,
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: regStatus, 
                        builder: (context, value, _) {
                          return Text(value);
                        }
                      ),
                      SizedBox(height: 50,),
                      Text(
                        "Who you are?",
                        style: TextStyle(color: Colors.black, fontSize: 26),
                      ),
                      SizedBox(height: 35),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              regStatus.value = "Preparing to registration.";
                              bool isCreate = await Connector.createNewUser(widget.id,1,widget.country,languageForRegistrationUser ?? "ENG",);
                              regStatus.value = "Server responde ${isCreate}.";
                              if (isCreate) {
                                regStatus.value = "Registering mainUser.";
                                try {
                                  await Connector.initMainUser(id: widget.id.toString(),);
                                } catch (e) {
                                  Connector.err(codePlace: "regUserTypeScreen.dart->initMainUser", e: e.toString());
                                }
                                regStatus.value = "Main user registered";
                              } else {
                                regStatus.value = "Not successed for registration";
                                //Toast(context: context,text: "Could not create user",);
                                regStatus.value = "Has a lock";
                                return;
                              }
                              setState(() {
                                Navigator.pushReplacement(context,MaterialPageRoute(builder:
                                      (context) => SettingsPersonal(
                                        userRegistered: false,
                                        userType: 1,
                                        id: widget.id,
                                        name: "",
                                        email: "",
                                        sameUser: null,
                                      ),
                                ),
                              );
                              });
                              
                            },
                            child: Container(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 70,
                                    backgroundColor: const Color.fromARGB(255,157,238,155,),
                                    backgroundImage:
                                        Image.asset(
                                          "assets/images/doctor-icon.png",
                                        ).image,
                                  ),
                                  Text(
                                    "I am doctor",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 45),
                          InkWell(
                            onTap: () async {
                              regStatus.value = "Preparing to registration.";                           
                              bool isCreate = await Connector.createNewUser(widget.id,0,widget.country,languageForRegistrationUser ?? "ENG",);
                              regStatus.value = "Server responde ${isCreate}.";
                              if (isCreate) {
                                regStatus.value = "Registering mainUser.";
                                try {
                                  await Connector.initMainUser(id: widget.id.toString(),);
                                } catch (e) {
                                  Connector.err(codePlace: "regUserTypeScreen.dart->initMainUser", e: e.toString());                                  
                                }
                                regStatus.value = "Main user registered";
                              } else {
                                regStatus.value = "Not successed for registration";
                                //Toast(context: context,text: "Could not create user",);
                                regStatus.value = "Has a lock";
                                return;
                              }

                              setState(() {
                                Navigator.pushReplacement(context,MaterialPageRoute(builder:
                                      (context) => SettingsPersonal(
                                        userRegistered: false,
                                        userType: 0,
                                        id: widget.id,
                                        name: "",
                                        email: "",
                                        sameUser: null,
                                      ),
                                ),
                              );  
                              });                              
                            },
                            child: Container(
                              //padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 70,
                                    backgroundColor: const Color.fromARGB(255,157,238,155,),
                                    backgroundImage:
                                        Image.asset("assets/images/user-icon.png",).image,
                                  ),
                                  Text(
                                    "I am NOT doctor",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )               
          ),
        ),
      ),
    );
  }
}
