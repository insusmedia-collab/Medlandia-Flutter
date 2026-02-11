import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medlandia/models/countryModel.dart';
import 'package:medlandia/screens/CountryScreen.dart';
import 'package:medlandia/login/SMSConnfirmScreen.dart';
import 'package:http/http.dart' as http;
import 'package:medlandia/style.dart';

String conformationCode = "";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _textEdiController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  bool isSending = false;
  final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);
  bool _isSendDisabled = false;
  Timer? _timer;
  int _remainingSeconds = 60;

  late CountryModel country = CountryModel(
    country: "Unknown",
    code: "",
    flagUrl: "",
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<String?> sendSMS() async {
    var url = Uri.https('medlandia.org', 'medlandia.jsp');
    var response = await http.post(
      url,
      body: {
        'func': 'sendConfirmSMS',
        'p1': "${country.code}${_textEdiController.text}",
      },
    );
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      Map<String, dynamic> sets = jsonDecode(response.body);
      if (sets['result'][0].toString().trim().toLowerCase() != "ok") {
        setState(() {
          errorNotifier.value = "Error ${sets['result'][0]}";
        });
        return null;
      }
      if (sets['code'].toString().trim().isEmpty) {
        setState(() {
          errorNotifier.value = "Code format error";
        });
        return null;
      }
      return sets['code'][0];
    }
    setState(() {
      errorNotifier.value =
          "Request not sent. Status code=${response.statusCode}";
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: APP_TAB_COLOR,
        title: Row(
          children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.back_hand)),
            Expanded(
              child: Text(
                "Enter",
                style: TextStyle(fontWeight: FontWeight.w700, wordSpacing: 1.0),
              ),
            ),
            IconButton(
              onPressed: () {
                
              },
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),

        actions: [],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Text(
              "Send the SMS message for autorization",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            countryCard(),
            SizedBox(width: 15),
            telNumber(),
            SizedBox(height: 25),
            Center(
              child: Visibility(
                visible: isSending,
                child: CircularProgressIndicator(),
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: ValueListenableBuilder(
                valueListenable: errorNotifier,
                builder: (context, error, child) {
                  if (error != null) {
                    return Text(error, style: TextStyle(fontSize: 16));
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            Expanded(child: Container()),
            Center(
              child: TextButton(
                onPressed: () {
                  if (_textEdiController.text.isEmpty) {
                    return;
                  }
                  showTelSMSConfirmDialog();
                },
                style: TextButton.styleFrom(
                  foregroundColor: _isSendDisabled ? Colors.grey : Colors.black,
                ),
                child: Text(
                  _isSendDisabled
                      ? 'Please wait ($_remainingSeconds seconds)'
                      : 'Send',
                ),
              ),
            ),
            /*InkWell(
              onTap: () {
                if (_textEdiController.text.isEmpty) {
                  return;
                }
                showTelSMSConfirmDialog();
              },
              child: Container(
                color: Colors.green,
                height: 40,
                width: 70,
                child: Center(
                  child: Text("Next", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),*/
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void _startTimer() {
    setState(() {
      _isSendDisabled = true;
      _remainingSeconds = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;

        } else {
          _isSendDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  Widget countryCard() {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => CountryScreen(setCountry: setCountry),
            ),
          ),
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        padding: EdgeInsets.symmetric(vertical: 5.0),
        decoration: numberBoxDecoration(),
        child: Center(
          child: Row(
            children: [
              Expanded(
                child: Text(country.country, style: TextStyle(fontSize: 16.0)),
              ),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  void setCountry(CountryModel country) {
    setState(() {
      this.country = country;
    });
    Navigator.pop(context);
  }

  Widget telNumber() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      height: 40,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 70,
            //padding: EdgeInsets.only(top: 20),
            decoration: numberBoxDecoration(),
            child: Row(
              children: [
                Text("", style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Text(country.code.toString(), style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: numberBoxDecoration(),
            //padding: EdgeInsets.only(left: 30),
            width: MediaQuery.of(context).size.width / 1.5 - 100,
            child: TextFormField(
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Telephone number',
                border: InputBorder.none,
              ),
              controller: _textEdiController,
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration numberBoxDecoration() {
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: const Color.fromARGB(255, 90, 90, 91),
          width: 1.8,
        ),
      ),
    );
  }

  Future<void> showTelSMSConfirmDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "We will be verify your phone number",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 10),
                Text(
                  "${country.code}${_textEdiController.text}",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 10),
                Text(
                  "Is this your number or you like to edit?",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Edit"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isSending = true;
                  errorNotifier.value = "Please wait";
                });

                Navigator.pop(context);

                sendSMS().then((code) {
                  if (code == null || code.isEmpty) return;
                  if (mounted) {
                    setState(() {
                      isSending = false;
                      errorNotifier.value = null;
                      _isSendDisabled = false;
                      _timer?.cancel();
                      close(code);
                    });
                  }
                });
                _startTimer();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void close(code) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (builder) => SMSConfirmatScreen(
              telephone: country.code + _textEdiController.text,
              code: code,
              country: country.country,
            ),
      ),
    );
  }
}
