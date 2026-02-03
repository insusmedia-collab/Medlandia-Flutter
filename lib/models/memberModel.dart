
import 'package:flutter/widgets.dart';
import 'package:medlandia/models/DoctorSkillsModel.dart';
import 'package:medlandia/models/spetialityModel.dart';
import 'package:medlandia/models/workplaceModel.dart';
import 'package:medlandia/http/httpRequest.dart';

abstract class BaseMemberModel {
  
  final id;
  final userType;
  late String name;
   String? email;
  final String chatName;
  ImageProvider userImage;
  final String country;
  final String language;
  int unreadedMessages = 0;
  bool isBlock = false;
  bool isFixed = false;
  bool isFriend = false;
  bool isChat = false;
  bool isDelete = false;
 
 ValueNotifier<bool> blockChanged = ValueNotifier(false);

  String getUserName();
  String getUserSubName();

final userImageChangedNotifier = ValueNotifier<bool>(false);
final userNamechangeNorifier = ValueNotifier<bool>(false);


void setUserName(String name) {
  this.name = name;
  userNamechangeNorifier.value = !userNamechangeNorifier.value;
}

void setUserImage(ImageProvider newImage) {
  userImage = newImage;
  userImageChangedNotifier.value = !userImageChangedNotifier.value;
}

  BaseMemberModel({
    required this.id,
    required this.language,
    this.userType, 
    this.name="", 
 
    required this.chatName,
    ImageProvider? userImage,    
    required this.country}) : userImage = userImage ?? AssetImage("assets/images/unknown.jpeg");
}

class MemberModel extends BaseMemberModel {
  MemberModel({  
                required super.id, required name, required chatName,  
                required userImage, required country, required language})
  :super( userType: 0, name: name,  country: country, language: language, chatName: chatName, userImage:userImage);
  @override
  String getUserName() { return name;}
  @override
  String getUserSubName() { return ""; }
}

class DoctorModel extends BaseMemberModel{
   List<SpetialityModel> speciality = [];
   List<Workplace> workplaceses = [];
   List<DoctorSkillsModel> skills = [];
  int expierenceFrom = 0;
  int rate = 0;
  int binds = 0;

  final expierenceChanged = ValueNotifier<bool>(false);
  final workplaceChaged = ValueNotifier<bool>(false);
  final spetializationChanged = ValueNotifier<bool>(false);

  String getBindsText() {
    if (binds < 1000) {
      return binds.toString();
    } else {
      return ( (binds ~/ 1000).toString() + "." + (binds - ((binds ~/ 1000))).toString() + 'K' ) ;
    }
  }

  void updateSpetializations() {
    spetializationChanged.value = !spetializationChanged.value;
  }

  void updateWorkplaces() {
    workplaceChaged.value = !workplaceChaged.value;
  }
  int getExpierenceYears() {
    return expierenceFrom <= 0 ? 0 : DateTime.now().year - expierenceFrom;
  }
  void setExpierenceYear(int year) {
    expierenceFrom = year;
    expierenceChanged.value = !expierenceChanged.value; 
  }

  static String spetialityToString(List<SpetialityModel> specs) {
    String result = "";
    for (SpetialityModel s in specs) {
      result += ("${s.name} ");
    }
    return result;
  }
  bool isSame(SpetialityModel sm) {
    for (SpetialityModel n in speciality) {
      if (n.id == sm.id) return true;
    }
    return false;
  }

  void removeSpetiality(int id) {
    int removablePosition = -1;
    for (int i = 0; i < speciality.length; i++) {
      if (speciality[i].id == id) {removablePosition = i; break;}
    }
    if (removablePosition  > -1) speciality.removeAt(removablePosition);

    //updateSpetializations();
  }

  @override
  String getUserName() { return name; }
  @override
  String getUserSubName() { return spetialityToString(speciality); }

  DoctorModel({ required super.id, required name, required chatName,  
  required this.speciality, required this.workplaceses, required userImage, 
  required country, required language, this.expierenceFrom=2025})
  :super(userType: 1, country: country, language: language, name:name, chatName: chatName, userImage: userImage);
}

class GroupModel extends BaseMemberModel {
  final bool isAnonimouse;
  final bool allowNonDoctorToComment;

  @override
  String getUserSubName() {
    if (isAnonimouse) {
      return "Anonimouse";
    } else {
      return id.toString();
    }
  }

  @override
  String getUserName() {
    return name;
  }

  GroupModel({required super.id, required this.isAnonimouse, required this.allowNonDoctorToComment,
  required super.chatName, required super.country, required super.language, required super.userImage, required super.userType, 
  required super.name})
  :super();
}


List<BaseMemberModel> dummyChatItems = <BaseMemberModel>[];
List<BaseMemberModel> dummyFriendsItems = <BaseMemberModel>[];
List<BaseMemberModel> dummyDeletedItems = <BaseMemberModel>[];

ValueNotifier<bool> dummyChatItemsChanged = ValueNotifier<bool>(false);
ValueNotifier<bool> dummyFriendsItemsChanged = ValueNotifier<bool>(false); 
ValueNotifier<bool> dummDeletedItemsChanged = ValueNotifier<bool>(false);

List<GroupModel> dummyGroups = <GroupModel>[];
List<DoctorModel> doctors = [];

//ValueNotifier<bool> itemsChanged = ValueNotifier<bool>(false);
ValueNotifier<bool> groupsChanged = ValueNotifier<bool>(false);
ValueNotifier<bool> doctorsChanged = ValueNotifier<bool>(false);

BaseMemberModel? getMemberFromItems(int id) {  
  for (BaseMemberModel m in dummyChatItems) {
    if (m.id == id) return m;
  }
  for (BaseMemberModel m in dummyFriendsItems) {
    if (m.id == id) return m;
  }
  return null;
}

BaseMemberModel toMember(result) {
  BaseMemberModel member;
  if (result['userType'] == 0) {
          member = MemberModel(id: result['id'], 
                                name: result['name'], 
                                chatName: result['name'], 
                                userImage: NetworkImage(result['avatar']), 
                                country: result['country'],
                                language: result['language']);
        } else {
          member = DoctorModel(id: result['id'], 
                                name: result['name'], 
                                chatName: result['name'], 
                                speciality: [], 
                                workplaceses: [], 
                                userImage: NetworkImage(result['avatar']), 
                                country: result['country'],
                                language: result['language']);
                              if (result['specs'] !=null) {           
                                List<dynamic> sp = result['specs'][0];    
                                (member as DoctorModel).speciality = wrapSpetialities(sp);
                              }
                              if (result['workplaces'] != null) {
                                List<dynamic> wp = result['workplaces'][0];    
                                (member as DoctorModel).workplaceses = wrapWorkplaces(wp);     
                              }
                              if (result['skills'] != null) {
                                List<dynamic> sk = result['skills'][0];
                                (member as DoctorModel).skills = wrapSkills(sk);
                              }
          (member as DoctorModel).expierenceFrom = result['expYear'] ?? -1;          
          (member).rate = result['rate'] ?? 0;
          (member).binds = result['binds'] ?? 0;

        } 
        // in case where loaded chat and friends
          if (result['isChat'] != null)  member.isChat = result['isChat'];
          if (result['isBlock'] != null)  member.isBlock = result['isBlock'];
          if (result['isFixed'] != null)  member.isFixed = result['isFixed'];
          if (result['isFriend'] != null)  member.isFriend = result['isFriend'];
          if (result['isDelete'] != null)  member.isDelete = result['isDelete'];
           

        return member;
}

Future<void> searchDoctor({required int spetialityId, required String? countryCode, required String? name, required int index}) async {

  

  final request = {
    'func'    : 'searchUsers',
    'p1'      : '1',
    'p2'      : spetialityId.toString(),
    'p3'      : countryCode ?? 'null',
    'p4'      : name ?? 'null',
    'p5'      : doctorLoadIndex.toString(),
    'p6'      : doctorLoadCount.toString()
  };

  final response = await call(null, request);
  if (response == null) {
    print("==> search doctor error");
    return;
  }
  doctors.clear();
  wrapDoctorList(response);
}

Future<void> loadDeletedMembers() async {
  final response = await call(null, {
      'func'    : 'loadDeletedUsers',
      'p1'      : currentUser!.id.toString()
  });
  if (response == null) return;
  dummyDeletedItems.clear();
  List<dynamic> items = response as List<dynamic>;
  for (var item in items) {
    dummyDeletedItems.add(toMember(item));
  }
  dummDeletedItemsChanged.value = !dummDeletedItemsChanged.value;
}

int doctorLoadIndex = 0;
int doctorLoadCount = 50;
int doctorsLoaded = 0;

Future<void> loadDoctors({required int index}) async {
   
    doctorsLoaded = 0;
    var response = await call(null, {'func' : 'listUsers' ,'p1': '1', 'p2': index.toString(), 'p3' : doctorLoadCount.toString()});

    if (response == null) {
      print("==>Cant load doctor list");
      return;
    }
    wrapDoctorList(response);
    
}

void wrapDoctorList(dynamic response) {
  List<dynamic> items = response as List<dynamic>;
    for (var item in items) {
      DoctorModel member = toMember(item) as DoctorModel;
      doctors.add(member);
    }    
    doctorLoadIndex += doctorLoadCount;    
    doctorsLoaded = items.length;
    doctorsChanged.value = !doctorsChanged.value;
}

List<SpetialityModel> wrapSpetialities(List<dynamic> mm) {
  List<SpetialityModel> lst = [];
  for (var s in mm) {
      lst.add(SpetialityModel(id: s['id'], name: s['spec']));
  }
  return lst;
}

List<DoctorSkillsModel> wrapSkills(List<dynamic> sk) {
  List<DoctorSkillsModel> lst = [];
  for (var s in sk) {
      lst.add(DoctorSkillsModel(user2skillId: s['id'], userId: s['userId'], skillId: s['skillsId'], skillName: s['value'], skillDescr: s['descr']));
  }
  return lst;
}

List<Workplace> wrapWorkplaces(List<dynamic> mm) {
  List<Workplace> lst = [];
  for (var w in mm) {
      lst.add(Workplace(address: w['address'], 
                                      googlePlaceId: w['googlePlaceId'],
                                      hospitalName: w['work'],
                                      hospitalId: w['workplaceId'], 
                                      placeId: w['placeId'], 
                                      lon: w['lon'],
                                      lat: w['lat'],
                                      id: w['id']));
    }
    return lst;
}

BaseMemberModel? currentUser; 
int chatUser = -1;