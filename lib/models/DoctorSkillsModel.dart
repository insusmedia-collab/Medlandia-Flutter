import 'package:medlandia/http/httpRequest.dart';

class DoctorSkillsModel {
  final String skillName;
  String skillDescr;
  final int user2skillId;
  final int skillId;
  final int userId;
  DoctorSkillsModel({required this.user2skillId, required this.userId, required this.skillId, required this.skillName, required this.skillDescr});
}

List<dynamic> allSkills = [];

Future<void> loadSkills(String lang) async {
   final response = await call(null, {'func' : 'loadSkills', 'p1' : lang});
    if (response == null) {
      print("==>Cant load skills list");
      return;
    }

     allSkills = response as List<dynamic>;
   
}