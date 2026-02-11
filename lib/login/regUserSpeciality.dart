import 'package:flutter/material.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/spetialityModel.dart';
import 'package:medlandia/screens/WorkplaceScreen.dart';
import 'package:medlandia/http/httpRequest.dart';

class UserSpetiality extends StatefulWidget {
  const UserSpetiality({super.key, required this.creationMode});
  //final DoctorModel doctorModel;
  final bool creationMode;

  @override
  State<UserSpetiality> createState() => _UserSpetialityState();
}

class _UserSpetialityState extends State<UserSpetiality> {
//List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
  //List<String> selectedItems = ["Item 1"];

List<Widget> getActions() {
  if (widget.creationMode) {
    return [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               Expanded(child: Container()),
                   TextButton(
                    onPressed: () {
                      saveSpecs();
                      Navigator.pushReplacement(context, 
                      MaterialPageRoute(builder: (context) => WorkplaceScreen(creationMode: widget.creationMode, )));
                    }, 
                    child: Text("Next")), 
              ],
            ),
          ];
  } else {
    return [
      //TextButton(onPressed: () => saveSpecs(), child: Text("Update"))
    ];
  }
}

Future<void> saveSpecs()  async{

String specsString = "";
DoctorModel model = currentUser as DoctorModel;
for (int i = 0; i < model.speciality.length; i++) {
  specsString += model.speciality[i].id.toString();
  if (i + 1 < model.speciality.length) {
    specsString += ",";
  }
}
  final response = await call(null, {
                  'func': 'updateUserSpecs',
                  'p1': currentUser?.id.toString(),
                  'p2': specsString
                });

  if (response == null) {
    print("==> Spetiality update error");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 244),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), 
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 230, 230, 232),
          centerTitle: true,
          
          title: Text("Your specialities"),
        )
        ),
        body: SafeArea(
          child: SizedBox.expand(            
            child: 
                ValueListenableBuilder(
                  valueListenable: spetialityListChanged,
                  builder: (context, _, __) => ListView.builder(
                    itemCount: dummyAllSpetialities.length,
                    itemBuilder: (column, index) => CheckboxListTile(
                      activeColor: const Color.fromARGB(255, 223, 138, 132),
                       title: Text(dummyAllSpetialities[index].name, style: TextStyle(fontWeight: FontWeight.bold),),
                       value: (currentUser as DoctorModel).isSame(dummyAllSpetialities[index]),  //.speciality.contains(dummyAllSpetialities[index]), //widget.doctorModel.speciality.contains(dummyAllSpetialities[index]),
                       onChanged: (bool? value) {
                         setState(() {
                          if (value == true) {
                            (currentUser as DoctorModel).speciality.add(dummyAllSpetialities[index]);
                          } else {
                            (currentUser as DoctorModel).removeSpetiality(dummyAllSpetialities[index].id);
                          }
                          (currentUser as DoctorModel).updateSpetializations();
                          saveSpecs();
                        });
                       },
                    )
                    ),
                ),
            ),
        ),
          persistentFooterButtons: getActions(),
        );
    
  }
}