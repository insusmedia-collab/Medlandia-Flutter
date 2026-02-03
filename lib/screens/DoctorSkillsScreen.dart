import 'package:flutter/material.dart';
import 'package:medlandia/models/DoctorSkillsModel.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/screens/DoctorSkillsScreen2.dart';
import 'package:medlandia/style.dart';
import 'package:medlandia/http/httpRequest.dart';

class DoctorSkillsScreen extends StatefulWidget {
  const DoctorSkillsScreen({super.key, required this.updateFunc});

  final Function updateFunc;
  
  
  @override
  State<DoctorSkillsScreen> createState() => _DoctorSkillsScreenState();
}

class _DoctorSkillsScreenState extends State<DoctorSkillsScreen> {
  final TextEditingController _textSkillNameController = TextEditingController();
  final TextEditingController _textSkillAddressController = TextEditingController();
  ValueNotifier<bool> skillsListChanged = ValueNotifier<bool>(false);

  String? skillName;
  int skillId = -1; 


  @override
  void dispose() {
    _textSkillNameController.dispose();
    _textSkillAddressController.dispose();
    super.dispose();
  }

  void _addOrUpdateItem() {
    if (_textSkillNameController.text.isEmpty) return;
    
    setState(() {
      
    if (skillName == null || skillId < 1) return;
        (() async {
          final response = await call(context, {'func' : 'addSkillToDoctor' , 'p1' : skillId.toString(), 'p2' : (currentUser as DoctorModel).id.toString(), 'p3' :  _textSkillAddressController.text});
          (currentUser as DoctorModel).skills.add(DoctorSkillsModel(skillName: skillName!, skillId: skillId, user2skillId: response['id'], userId: (currentUser as DoctorModel).id,
            skillDescr: _textSkillAddressController.text));
            skillsListChanged.value = !skillsListChanged.value;

            _textSkillNameController.clear();
            _textSkillAddressController.clear();
            widget.updateFunc();
        })();
      
      //widget.doctorModel.updateWorkplaces();
    });
  }
/*
  void _editItem(int index) {
    setState(() {
      _textSkillNameController.text = widget.doctor.skills[index].skillName;
      _textSkillAddressController.text = widget.doctor.skills[index].skillDescr;
      _editingIndex = index;
    });
  }
*/
  Future<void> _deleteItem(int index) async {

    final response = await call(context, {'func' : 'deleteSkill', 'p1' : (currentUser as DoctorModel).skills[index].user2skillId.toString()});
    if (response == null || response['result'] != 'OK')  return;

    setState(() {      
      (currentUser as DoctorModel).skills.removeAt(index);
      _textSkillNameController.clear();
        _textSkillAddressController.clear();
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: APP_TAB_COLOR,
        title: Text("Skills"),
        centerTitle: true,
        //title: Text(_editingIndex != null ? 'Edit Item' : 'Add Item'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Input Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [ 
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Skill", style: BASIC_TEXT_STYLE,),
                        ),
                        TextField(
                          controller: _textSkillNameController,
                          readOnly: true,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorSkills(updateFunc: (id, name) {
                              if (id < 1 || name == null) return;
                              skillId = id;
                              skillName = name;
                              _textSkillNameController.text = name;
                            })));
                          },
                          decoration: InputDecoration(
                            labelText: 'Skill',
                            border: OutlineInputBorder(),
                          ),
                        ),                      
                        SizedBox(height: 15,),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Descroption", style: BASIC_TEXT_STYLE,),
                        ),
                        TextField(
                          controller: _textSkillAddressController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        ElevatedButton(
                          style: BASIC_BUTTON_STYLE,
                          onPressed: (){
                            _addOrUpdateItem();  
                            },
                          child: Icon(Icons.add,  size: 28,),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  
                ],
              ),
            ),
            // List Section
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: skillsListChanged,
                builder: (context, _, __) =>
                 ListView.builder(
                  itemCount: (currentUser as DoctorModel).skills.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: APP_TAB_COLOR,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        iconColor: ICON_COLOR,
                        leading: Icon(Icons.check, color: ICON_COLOR,),
                        title: Text((currentUser as DoctorModel).skills[index].skillName, style: TextStyle(fontWeight: FontWeight.bold, color: BASIC_TEXT_COLOR),),
                        subtitle: Text((currentUser as DoctorModel).skills[index].skillDescr, style: TextStyle(color: BASIC_TEXT_COLOR),),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /*
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editItem(index),
                            ),*/
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteItem(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}