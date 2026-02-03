import 'dart:convert';

import 'package:http/http.dart' as http;

class SpetialityModel {
  final int id;
  final String name;
  
  SpetialityModel({required this.id, required this.name});
}

List<SpetialityModel> dummyAllSpetialities = <SpetialityModel> [
  SpetialityModel(id: 1, name: "Neurologiest"),
  SpetialityModel(id: 2, name: "Ortopetics"),
  SpetialityModel(id: 3, name: "Terapevtic"),
  SpetialityModel(id: 4, name: "Nears"),
];

Future<void> loadSpetialities() async {
var url = Uri.https('medlandia.org', 'medlandia.jsp');
              var response = await http.post(
                url,
                body: {
                  'func': 'getAllSpecs',
                  'p1': "am"
                },
              );
  List<dynamic> list = jsonDecode(response.body);      
  dummyAllSpetialities.clear();
  for (var item in list) {
    dummyAllSpetialities.add(SpetialityModel(id: item['id'], name: item['spec']));
  }
}
