import 'package:flutter/material.dart';
import 'package:medlandia/models/DoctorSkillsModel.dart';
import 'package:medlandia/style.dart';

class DoctorSkills extends StatefulWidget {
  
  final Function updateFunc;
  
  const DoctorSkills({super.key, required this.updateFunc});
  

  @override
  State<DoctorSkills> createState() => _DoctorSkillsState();
}

class _DoctorSkillsState extends State<DoctorSkills> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: APP_TAB_COLOR,
        title: Text("Skills"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Expanded(
          child: ListView.builder(
            itemCount: allSkills.length,
            itemBuilder: (column, index) => ListTile(
              leading: Icon(Icons.circle, color: ICON_COLOR,),
              title: Text(allSkills[index]['value'].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: BASIC_TEXT_COLOR),),
              
              onTap: () {
                widget.updateFunc(allSkills[index]['id'], allSkills[index]['value']);
                Navigator.pop(context);
              },)
              
            )
          ),
      ),
    );
  }
}