import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/http/httpRequest.dart';


class ScheduleModel {
  final int id;
  final DateTime date;
  final int doctorId;
  final int clientId;
  final String? name;
  final int? userType;
  final String hospitalName;
  final String address;
  final String googlePlaceId;
  final double lon;
  final double lat;
  final String job;

  

   ScheduleModel({
      required this.id,
      required this.date, 
      required this.doctorId,
      required this.clientId,
      required this.name,
      required this.userType,
      required this.hospitalName,
      required this.address,
      required this.lon,
      required this.lat,
      required this.googlePlaceId,
      required this.job
    });
}


ScheduleModel toScheduleModel(dynamic item) {
  return ScheduleModel(
            id:             item['id'], 
            date:           DateFormat('yyyy-MM-dd HH:mm:ss').parse(item['date']), 
            doctorId:       item['doctor'], 
            clientId:       item['client'], 
            name:           item['name'],
            userType:       item['userType'],
            hospitalName:   item['hospName'], 
            address:        item['address'], 
            lon:            item['lon'], 
            lat:            item['lat'], 
            googlePlaceId:  item['placeId'],
            job:            item['job']); 
}
 

List<ScheduleModel> dummySchedules = [];
ValueNotifier<bool> scheduleListChanged = ValueNotifier<bool>(false);

Future<void> loadSchedulesByDate(DateTime from, DateTime? to) async {

final dateFrom = DateFormat('yyyy-MM-dd HH:mm:ss').format(from);

final String? dateTo = (to != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(to) : null);

late Map<String, dynamic> request; 
if (dateTo != null) {
  request = {
              'func'  : 'loadSchedules', 
              'p1'    : currentUser!.id.toString(),
              'p2'    : currentUser!.userType.toString(),
              'p3'    : dateFrom,
              'p4'    : dateTo
            };
} else {
  request = {
              'func'  : 'loadSchedules', 
              'p1'    : currentUser!.id.toString(),
              'p2'    : currentUser!.userType.toString(),
              'p3'    : dateFrom                                
            };
}                                 

final response = await call(null, request);
  if (response == null) {
    print("==> schedule list is null");
    return;
  }        
  List<dynamic> items = response as List<dynamic>;
  dummySchedules.clear();  
  for (var item in items) {
    dummySchedules.add(toScheduleModel(item));
  }                      
  scheduleListChanged.value = !scheduleListChanged.value;
}

Future<void> loadSchedules() async { 
  loadSchedulesByDate(DateTime.now().subtract(Duration(days: 30)), DateTime.now().add(Duration(days: 30)));
  //dummySchedules = await db.loadSchedules();  
  
} 