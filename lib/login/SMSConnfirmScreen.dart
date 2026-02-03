import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/login/LoginScreen.dart';
import 'package:medlandia/login/regUserTypeScreen.dart';

class SMSConfirmatScreen extends StatefulWidget {
  final String telephone;
  final String code;
  final String country;
  const SMSConfirmatScreen({super.key, required this.telephone, required this.code, required this.country});

  @override
  State<SMSConfirmatScreen> createState() => _SMSConfirmatScreenState();
}

class _SMSConfirmatScreenState extends State<SMSConfirmatScreen> {
bool _isButtonDisabled = false;
  Timer? _timer;
  int _remainingSeconds = 60;

@override
  void initState() {
    _startTimer();
    super.initState();
  }

@override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

void _startTimer() {
    setState(() {
      _isButtonDisabled = true;
      _remainingSeconds = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 244),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 230, 230, 232),
        centerTitle: true,
        title: Text("Verify ${widget.telephone}"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          children: [
            SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "We have sent SMS ",
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                  TextSpan(
                    text: widget.telephone,
                    style: TextStyle(fontSize: 14.0, color: Colors.black),
                  ),
                  TextSpan(
                    text: " Wrong number?",
                    style: TextStyle(fontSize: 14.0, color: Colors.green),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            OtpTextField(
              //clearText: true,
              
              numberOfFields: 4,
              borderColor: Color(0xFF512DA8),
              //set to true to show as box or false to show as dash
              showFieldAsBox: true,
              //runs when a code is typed in
              onCodeChanged: (String code) {
                //handle validation or checks here
              },
              //runs when every textfield is filled
              onSubmit: (String verificationCode) async {
                if (verificationCode == widget.code) {
                  Toast(context: context, text: "Succsessfully confirmed");
                  /* If telephone is registeres in the system 
                  1) Save to phone
                  2) go MedlandiaHome() 
                  if not meen that new user
                  */
                  /*  Get it from serve, becouse  */
                  
                  currentUser = null;
                  bool hasUserInServer = false;
                  try {
                    hasUserInServer = await Connector.initMainUser(id:  widget.telephone);
                  } catch (err) {
                    Connector.err(codePlace: "SMSConfirmatScreen", e:  " ${err}  widget.telephone=${widget.telephone} AND userHasInServer=${hasUserInServer}");
                    currentUser = null;
                    print("==> register error loading user $err");
                  }
                  if (hasUserInServer && currentUser != null) {
                    // Connect to chat 
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainApp() ));
                  } else {
                    /* --- Very first time user--- register-- */
                    Navigator.pushReplacement(context, 
                    MaterialPageRoute(builder: (context) => RegUsrType(id: int.parse(widget.telephone),country: widget.country,) ));
                }

                  return;
                }
                /*
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Verification Code"),
                      content: Text('Code entered is $verificationCode'),
                    );
                  },
                );*/
              }, // end onSubmit
            ),
            SizedBox(height: 5,),
            Center(child: Text("Enter 4-digit code")),
            SizedBox(height: 20,),
            Divider(thickness: 1.5,),
            SizedBox(height: 5,),
            Expanded(child: Container()),
            TextButton(
              onPressed: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (b) => LoginScreen()));
              },
            style: TextButton.styleFrom(
                foregroundColor: _isButtonDisabled ? Colors.grey : Colors.blue,
              ),
              child: Text(_isButtonDisabled 
                  ? 'Resent ($_remainingSeconds seconds)' 
                  : 'Resent'),
                  ),
                  if (_isButtonDisabled) ...[
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: 1 - (_remainingSeconds / 60),
              ),
          ],
          SizedBox(height: 45,)
        ]),
      ),
    );
  }

  

}
