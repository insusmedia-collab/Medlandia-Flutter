import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:medlandia/main.dart';
import 'package:medlandia/style.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key, required this.callback, required this.hospitalId, required this.hospitalName});
  final Function(String hospital, int hospitalId) callback;
  final String hospitalName;
  final int hospitalId;

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  final ValueNotifier<bool> listChanged = ValueNotifier<bool>(false);
  List<dynamic> hospitls = [];
  final _controller = TextEditingController();

 @override
  void initState() {
    placeSuggestion(null);
    _controller.addListener((){
      _onChange();
    });
    super.initState();
  }

  void _onChange() {
    placeSuggestion(_controller.text);
  }

  Future<void> placeSuggestion(String? str) async {
    var url = Uri.https('medlandia.org', 'medlandia.jsp');
    var obj = {'func': 'getWorkplaces', 'p1': '0', 'p2' : '100'};
    if (str != null && str.trim().isNotEmpty) {
      obj['p3'] = str;
    }
    var response = await http.post(url, body: obj);
    var resp = jsonDecode(response.body);
    hospitls = resp;
    listChanged.value = !listChanged.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: APP_TAB_COLOR,
        title: Text("Hospitals"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                valueListenable: listChanged,
                builder : (context, _,__) => ListView.builder(
                  itemCount: hospitls.length,
                  itemBuilder: (context, index) => ListTile(
                    onTap: () {
                      widget.callback(hospitls[index]['work'], hospitls[index]['id']);
                      Navigator.pop(context);
                    },
                      leading: Icon(Icons.home, color: ICON_COLOR),
                      title: Text(hospitls[index]['work'], style: TextStyle(fontWeight: FontWeight.bold),),
                    )
                   ),
              )
                ),
                Divider(height: 2,),
                SizedBox(height: 5,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Type hospital name (in English only)", style: BASIC_TEXT_STYLE,),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 240, 240, 244),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // Only letters
                          ],
                        )
                        ),
                      TextButton(
                        style: BASIC_BUTTON_STYLE,
                        onPressed: () async {
                          // add workplace to database if not exists
                          // get id
                          showDialogAddWorkplace();
                        }, 
                        child: Text("Add"))
                    ],
                  ),
                ),
                SizedBox(height: 15,)
            ],
          ),
          ),
      ),
    );
  }
  void showDialogAddWorkplace() {

    if (_controller.text.trim().length == 0) {
      Toast(context: context, text: "Hospitql name empty");
      return;
    }

    showDialog(context: context, 
    builder: (BuildContext context) => AlertDialog(
      title: Text("Add hiospital"),
      content: Text("Do you really want to add ${_controller.text} ?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          child: Text("Cancel")),

        TextButton(
          onPressed: () async {
            var url = Uri.https('medlandia.org', 'medlandia.jsp');
            var response = await http.post(url, body: {'func': 'addWorkplace', 'p1': _controller.text});
            print(response.body);
            
            var resp = jsonDecode(response.body);
            if (resp['id'] > 0) {
              placeSuggestion(resp['work']);
            } else {
              Toast(context: context, text: "Something is wrong, try again later.");
            }
            Navigator.pop(context);
          }, 
          child: Text("OK")),

      ],
    )
    );
  }
}
