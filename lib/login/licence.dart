import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medlandia/login/LoginScreen.dart';
import 'package:medlandia/style.dart';

class LicenceScreen extends StatefulWidget {
  const LicenceScreen({super.key});

  @override
  State<LicenceScreen> createState() => _LicenceScreenState();
}

class _LicenceScreenState extends State<LicenceScreen> {
  String _loadedText = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTextFromAsset();
  }

  Future<void> _loadTextFromAsset() async {
    try {
      final String text = await rootBundle.loadString(
        'assets/licence/licence.txt',
      );
      setState(() {
        _loadedText = text;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadedText = 'Error loading text: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: APP_TAB_COLOR,
        leading: CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage("assets/images/logo-512.jpg"),
        ),
        title: Text(
          "Medlandia",
          style: TextStyle(color: BASIC_HEADER_COLOR, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child:  SizedBox.expand(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _loadedText,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ),
              ),              
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text("Decline", style: TextStyle(fontSize: 18)),
                  ),

                  Expanded(child: Container()),

                  TextButton(
                    onPressed: () {
                      // create user here
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text("Accept", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              SizedBox(height: 22),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Container()
      ],
    );
  }
}
