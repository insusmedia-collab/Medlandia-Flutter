import 'package:flutter/material.dart';
import 'package:medlandia/http/httpRequest.dart';

class SpetialityModel {
  final int id;
  final String name;
  
  SpetialityModel({required this.id, required this.name});
}

List<SpetialityModel> dummyAllSpetialities = <SpetialityModel> [];
ValueNotifier<bool> spetialityListChanged = ValueNotifier(false);

Future<void> loadSpetialities(lang) async {

  List<dynamic>? list = await call(null, {'func': 'getAllSpecs', 'p1': lang});
  if (list == null) {
    print("==>List is NULL (spetialities) ");
    return;
  }
  dummyAllSpetialities.clear();
  for (var item in list) {
    dummyAllSpetialities.add(SpetialityModel(id: item['id'], name: item['spec']));
  }
  spetialityListChanged.value = !spetialityListChanged.value;
}
