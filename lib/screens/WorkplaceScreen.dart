import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/stores/localStore.dart';
import 'package:medlandia/style.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/workplaceModel.dart';
import 'package:medlandia/screens/hospitals.dart';
import 'package:medlandia/screens/location.dart';
import 'package:medlandia/login/regUserSpeciality.dart';
import 'package:medlandia/http/httpRequest.dart';

class WorkplaceScreen extends StatefulWidget {
  const WorkplaceScreen({
    super.key,
    required this.creationMode    
  });
  final bool creationMode;  

  @override
  State<WorkplaceScreen> createState() => _WorkplaceScreenState();
}

class _WorkplaceScreenState extends State<WorkplaceScreen> {
  /*final TextEditingController _textHospitalNameController =
      TextEditingController();
  final TextEditingController _textHospitalAddressController =
      TextEditingController();*/
  //int? _editingIndex;
  int placeId = -1;
  double lon = -1;
  double lat = -1;
  String addr = "";
  String googlePlaceId = "";
  String hospital = "";
  int hospitalId = -1;
  int id = -1;

  final ValueNotifier<String> addressChanged = ValueNotifier<String>("");
  final ValueNotifier<String> hospitalChanged = ValueNotifier<String>("");
  final ValueNotifier<bool> workplaceListChanged = ValueNotifier<bool>(false);

  List<Widget> getActions() {
    if (widget.creationMode) {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UserSpetiality(
                          creationMode: widget.creationMode,                          
                        ),
                  ),
                );
              },
              child: Text("Previouse"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainApp()),
                );
              },
              child: Text("Next"),
            ),
          ],
        ),
      ];
    } else {
      return [];
    }
  }

  @override
  void dispose() {
    //_textHospitalNameController.dispose();
    //_textHospitalAddressController.dispose();
    super.dispose();
  }

  void initData() {
    placeId = -1;
    lon = -1;
    lat = -1;
    addr = "";
    googlePlaceId = "";
    hospital = "";
    hospitalId = -1;
    id = -1;
  }

  void _addOrUpdateItem() async {
     if (hospitalId < 1) return;
      if (placeId < 1) {
        if (googlePlaceId.isEmpty) return;
        final r = await call(null, {
          'func': "addPlace",
          'p1': lon.toString(),
          'p2': lat.toString(),
          'p3': googlePlaceId,
          'p4': addr,
        });
        if (r == null) return;
        placeId = r['id'];
      }

      Map<String,dynamic> p = {
        'func': "addUserToWork",
        'p1': currentUser?.id.toString(),
        'p2': placeId.toString(),
        'p3': hospitalId.toString(),
      };

      final result = await call(null, p);
      if (result == null) return;

      Workplace wp = Workplace(
          id: result['id'],
          placeId: placeId,
          hospitalId: hospitalId,
          hospitalName: hospital,
          lat: lat,
          lon: lon,
          address: addr,
          googlePlaceId: googlePlaceId,
        );

      (currentUser as DoctorModel).workplaceses.add(wp);
      (currentUser as DoctorModel).updateWorkplaces();
 

      List<Map<String, dynamic>> jsonList = (currentUser as DoctorModel).workplaceses.map((w) => w.toJson()).toList();
      LocalStore.update(key:  "workplaces", value: jsonEncode(jsonList));
      /*
    }*/

    initData();
    hospitalChanged.value = "";
    addressChanged.value = "";
    workplaceListChanged.value = !workplaceListChanged.value;

    
    //});
  }

  void _editItem(int index) {
    setState(() {
      //_editingIndex = index;
    });
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Delete?"),
            content: Text(
              "Do you really wont to delete ${(currentUser as DoctorModel).workplaceses[index].hospitalName}  ${(currentUser as DoctorModel).workplaceses[index].address}",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {

                  Navigator.pop(context);  

                  final result = await call(context, {
                    'func': 'deleteUserWorkplace',
                    'p1': (currentUser as DoctorModel).workplaceses[index].id.toString(),
                  });
                  if (result == null) return;

                  setState(() {
                    (currentUser as DoctorModel).workplaceses.removeAt(index);
                    (currentUser as DoctorModel).updateWorkplaces();
                    try {
                      (currentUser as DoctorModel).workplaceses.removeAt(index);
                      (currentUser as DoctorModel).updateWorkplaces();
                    } catch (e) {}
                    List<Map<String, dynamic>> jsonList = (currentUser as DoctorModel).workplaceses.map((w) => w.toJson()).toList();
                    LocalStore.update(key:  "workplaces", value: jsonEncode(jsonList));

                    initData();
                    hospitalChanged.value = "";
                    addressChanged.value = "";
                    workplaceListChanged.value = !workplaceListChanged.value;
                    
                    /*
                    if (_editingIndex == index) {
                      _editingIndex = null;
                    }*/
                  });
                },
                child: Text("Yes, delete"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BACKGROUND_COLOR,  
      appBar: AppBar(
        title: Text("Workplace", ), 
        centerTitle: true, 
        backgroundColor: APP_TAB_COLOR,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Hospital", style: BASIC_TEXT_STYLE,),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: const Color.fromARGB(255, 191, 191, 196)
                            ), // BoxBorder.lerp(a, b, t) .all(width: 1, ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.all(15),
                          child: InkWell(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (builder) => HospitalsScreen(
                                          hospitalId: hospitalId,
                                          hospitalName: hospital,
                                          callback: (hospName, hospId) {
                                            hospital = hospName;
                                            hospitalId = hospId;
                                            hospitalChanged.value = hospName;
                                          },
                                        ),
                                  ),
                                ),
                            child: Row(
                              children: [
                                Icon(Icons.home, color: ICON_COLOR),
                                Expanded(child: Container()),
                                ValueListenableBuilder(
                                  valueListenable: hospitalChanged,
                                  builder: (context, _, __) => Text(hospital),
                                ),
                              ],
                            ),
                          ),
                        ),
        
                        SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Location", style: BASIC_TEXT_STYLE,),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: const Color.fromARGB(255, 191, 191, 196)
                            ), //BoxBorder.all(width: 1, ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.all(7),
                          child: InkWell(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (builder) => LocationChooserScren(
                                          addr: addr,
                                          lat: lat,
                                          lon: lon,
                                          googlePlaceId: googlePlaceId,
                                          id: placeId,
                                          hospId: hospitalId,
                                          callback: (
                                            id,
                                            ln,
                                            lt,
                                            add,
                                            googlePlace,
                                          ) {
                                            //(String address, String googlePlaceId, int id, double lat, double lon) {  //(int id, double ln, double lt, String add,  String place) {
        
                                            placeId = id;
                                            addr = add;
                                            lat = lt;
                                            lon = ln;
                                            googlePlaceId = googlePlace;
                                            setState(() {
                                              addressChanged.value = addr;
                                            });
                                          },
                                        ),
                                  ),
                                ),
                            child: Padding(
                              padding: EdgeInsets.all(7),
        
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
        
                                children: [
                                  Icon(Icons.place, color: ICON_COLOR),
                                  Expanded(child: Container()),
                                  ValueListenableBuilder(
                                    valueListenable: addressChanged,
                                    builder: (context, value, _) => Text(value),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
        
                        ElevatedButton(
                          style: BASIC_BUTTON_STYLE,  
                          onPressed: () {
                            _addOrUpdateItem();
                          },
                          child: Text("Add", style: TextStyle(fontSize: 18),),
                        ),
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
                valueListenable: workplaceListChanged,
                builder:
                    (context, _, __) => ListView.builder(
                      itemCount: (currentUser as DoctorModel).workplaceses.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color:APP_TAB_COLOR,
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          
                          child: ListTile(
                            iconColor: ICON_COLOR,
                            leading: Icon(Icons.place),
                            title: Text(
                              (currentUser as DoctorModel).workplaceses[index].hospitalName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              (currentUser as DoctorModel).workplaceses[index].address,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /*
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Workplace w =
                                        widget.doctorModel.workplaceses[index];
                                    id = w.id;
                                    placeId = w.placeId;
                                    googlePlaceId = w.googlePlaceId;
                                    lon = w.lon!;
                                    lat = w.lat!;
                                    addr = w.address;
                                    hospital = w.hospitalName;
                                    hospitalId = w.hospitalId;
                                    addressChanged.value =
                                        addr; //!addressChanged.value;
                                    hospitalChanged.value = hospital;
                                    _editItem(index);
                                  },
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

      persistentFooterButtons: getActions(),
    );
  }
}
