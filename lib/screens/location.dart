import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medlandia/style.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

//typedef OnLoicationCallback = void Function({required int id, required double lon, required double lat, required String googlePlaceId, required String address });

class LocationChooserScren extends StatefulWidget {
   LocationChooserScren({
    super.key,
    required this.callback,
    required this.addr,
    required this.lon,
    required this.lat,
    required this.id,
    required this.googlePlaceId,
    required this.hospId
  });
  final Function callback;
String addr;
double lon;
double lat;
int id;
String? googlePlaceId = "";
int hospId = -1;

  @override
  State<LocationChooserScren> createState() => _LocationChooserScrenState();
}

class _LocationChooserScrenState extends State<LocationChooserScren> {
  final String apiKey = "AIzaSyBMlOYWBB3jeMPVK_R5-8kZtuymcehEF1U";
  final _serachController = TextEditingController();
  final uuid = Uuid();
  List<dynamic> listOfLocations = [];
  
  final ValueNotifier<bool> valuesChanged = ValueNotifier<bool>(false);
  final ValueNotifier<bool> listChanged = ValueNotifier<bool>(false);

  @override
  void initState() {
    _serachController.text = widget.addr;
   
     

    if (widget.hospId > 0) {
      loadByHospital(widget.hospId);
    }
    super.initState();
  }

  Future<void> loadByHospital(int hid) async {
    var url = Uri.https('medlandia.org', 'medlandia.jsp');
    var response = await http.post(url, body: {'func': 'getPalceByHospitalId', 'p1': widget.hospId.toString()});
    final result = jsonDecode(response.body);
    listOfLocations = result;
    listChanged.value = !listChanged.value;
  }

/*
  _onChange() {
    placeSugesstion(_serachController.text);
  }
*/

  Future<void> placeSugesstion(String sugestion) async {
    try {
      //https://maps.googleapis.com/maps/api/place/autocomplete/json?
      //print(sugestion);
      var url = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'key': apiKey,
          'input': sugestion,
          'sessiontoken': '12345',
          'fields': 'name,formatted_address,geometry',
        },
      );
      var response = await http.post(url);

      //print(response.body);
      final result = jsonDecode(response.body);
      listOfLocations = (result['predictions'] as List);
      //.map((prediction) => prediction['description'] as String)
      //.toList();

      //print(listOfLocations);
    } catch (e) {
      print("==>$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: APP_TAB_COLOR,
        title: Text("Location"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              TextField(
                controller: _serachController,
                decoration: InputDecoration(
                  hintText: "Choose address",
                  prefixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _serachController.clear();
                        listOfLocations.clear();
                      });
                    },
                    icon: Icon(Icons.clear),
                  ),
                  
                  suffixIcon: IconButton(
                    onPressed: () async {
                     //setState(() {
                        await placeSugesstion(_serachController.text);  
                        listChanged.value = !listChanged.value;
                      //});
                    }, 
                    icon: Icon(Icons.search)
                ),
                ),
                onChanged: (value) {
                  setState(() {
                    //placeSugesstion(value);
                    widget.lat = widget.lon = -1; 
                    widget.id = -1;
                    widget.addr = "";
                    widget.googlePlaceId = "";
                  });
                },
              ),
              SizedBox(height: 10),
              /*
              Row(             
                children: [
                  ValueListenableBuilder(
                    valueListenable: valuesChanged,
                    builder: (context, _, __) => Text("Location: ${widget.lon} ${widget.lat}"),
                  ),
                  
                ],
              ),*/
              SizedBox(height: 5),
              /*
              Container(
                margin: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_city, color: Colors.green),
                      SizedBox(width: 20),
                      Text("My location"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
        */
              Visibility(
                visible: true, //_serachController.text.isEmpty ? false : true,
                child: Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: listChanged,
                    builder: (context, _, __) => 
                      ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: listOfLocations.length,
                      itemBuilder:
                          (context, index) => GestureDetector(
                            onTap: () async {
                              try {
                                widget.addr = listOfLocations[index]['description'] ?? listOfLocations[index]['address'];
                                widget.googlePlaceId = listOfLocations[index]['place_id'] ?? listOfLocations[index]['googlePlaceId'];
                                Map<String, double>? log =
                                    await getLocationByPlaceId(widget.googlePlaceId!);
                                widget.lon = log?['lng'] ?? -1;
                                widget.lat = log?['lat'] ?? -1;
                                
                                widget.callback(widget.id,
                                                widget.lon,
                                                widget.lat,
                                                widget.addr,
                                                widget.googlePlaceId!);
        
                                  //widget.id, widget.lon, widget.lat, widget.addr, widget.googlePlaceId);
                                Navigator.pop(context);
                                
                              } catch (e) {
                                print("==>$e");
                              }
                            },
                            child: ListTile(
                              leading: Icon(Icons.map),
                              title: Text(listOfLocations[index]['description'] ?? listOfLocations[index]['address']),
                            ),
                          ),
                    ),
                  ),
                ),
              ),
              /*
              SizedBox(height: 5),
              ElevatedButton(onPressed: () {
                if (widget.placeId == null || widget.placeId?.trim().length == 0) {
                  showErrorAlert();
                  return;
                }
                widget.callback(widget.mapId, widget.lon, widget.lat, widget.addr, widget.placeId);
                Navigator.pop(context);
              }, child: Text("Update")),*/
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void showErrorAlert() {
    showDialog(context: context, builder: (BuildContext context) => 
            AlertDialog(
              title: Text("Error"),
              content: Text("You need choose addrerss from list"),
              actions: [
                TextButton(
                  child: Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ) 
            );
  }

  Future<Map<String, double>?> getLocationByPlaceId(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      try {
        final location = data['result']['geometry']['location'];
        return {
          'lat': location['lat'].toDouble(),
          'lng': location['lng'].toDouble(),
        };
      } catch (e) {
        return null;
      }
    } else {
      return null;
      //throw Exception('Failed to get location: ${data['status']}');
    }
  }
}
