import 'package:flutter/material.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageQuee.dart';
import 'package:medlandia/models/messageRecipients.dart';
import 'package:medlandia/screens/messageScreen.dart';
import 'package:medlandia/style.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/screens/DoctorSkillsScreen.dart';
import 'package:medlandia/login/RegUserPersonalSettings.dart';
import 'package:medlandia/screens/WorkplaceScreen.dart';
import 'package:medlandia/login/regUserSpeciality.dart';
import 'package:medlandia/http/httpRequest.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key, required this.doctorModel});
  final DoctorModel doctorModel;

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {

ValueNotifier skillsChangeNotifier = ValueNotifier<bool>(false);



void updateSkills() {
  skillsChangeNotifier.value = !skillsChangeNotifier.value; 
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 236, 240),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), 
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 230, 230, 232),
          leadingWidth: 80,
          titleSpacing: 0,
          leading: InkWell(
            onTap: ()=> Navigator.pop(context),
            child: Row(
                
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 24),
                  ValueListenableBuilder(
                        valueListenable: widget.doctorModel.userImageChangedNotifier,
                        builder: (context, _, __) => CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage: widget.doctorModel.userImage,
                                                  ),
                  )
                ],
              ),
          ),
          title: Container(
            margin: EdgeInsets.all(6.0),
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: widget.doctorModel.userNamechangeNorifier, 
                        builder: (context, _, __) => Text(
                                                    widget.doctorModel.name,
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                  )
                        )
                      ,
                      ValueListenableBuilder(valueListenable: widget.doctorModel.spetializationChanged, 
                      builder: (context, _, __) {
                          return Text(
                                    DoctorModel.spetialityToString(widget.doctorModel.speciality),
                                    style: TextStyle(fontSize: 14),
                                  );
                      }),
                      
                    ],
                  ),
          ),
          
          actions: [
            IconButton(
              onPressed: () {
                (() async {
                  BaseMemberModel? member = getMemberFromItems(widget.doctorModel.id);
                  member ??= widget.doctorModel;                  
                  member.isChat = true;
                  await Connector.setUser2UserChat(member);
                  
                })();

               /* Navigator.pushReplacement(context, 
                  MaterialPageRoute(builder: (cx) => ChatMessagesView(recipient: widget.doctorModel.id) ));
               */
              MessageQuee mq = MessageQuee(messageUniqId: genId());
              mq.addUser(Recipient(id: widget.doctorModel.id, name: widget.doctorModel.name));
              MessageScreen.openedQuee = mq.copy();
              Navigator.push(context, MaterialPageRoute(builder: (context) => MessageScreen()));

              }, icon: Icon(Icons.message)),

              if (currentUser!.userType == 0 && !widget.doctorModel.isFriend)
                IconButton(
                  onPressed: () {
                    BaseMemberModel? member = getMemberFromItems(widget.doctorModel.id);
                    member ??= widget.doctorModel;
                    member.isFriend = true;
                    Connector.setUser2UserFriend(member);
                    Toast(context: context, text: "User add to your friend list");
                }, icon: Icon(Icons.add_rounded)),
              if (currentUser!.userType == 0 && widget.doctorModel.isFriend)  
              Icon(Icons.handshake, size: 30, color: ICON_COLOR,),
              
            //IconButton(onPressed: () {}, icon: Icon(Icons.info)),
            PopupMenuButton<String>(
                itemBuilder:
                    (BuildContext context) => [  
                      PopupMenuItem(value: "block", child: Row(children: [ 
                      Icon(Icons.block, color: Colors.red,),
                      Text(widget.doctorModel.isBlock ? "Unblock" : "Block", style: TextStyle(color:Colors.red),)
                      ],)),
                      /*                    
                      PopupMenuItem(value: "Chat", child: Text("Some")),
                      PopupMenuItem(value: "Other", child: Text("Other")),
                      PopupMenuItem(value: "Another", child: Text("Another")),*/
                    ],
                onSelected: (value) {
                  if (value == 'block') {
                    Connector.lockUnlock(widget.doctorModel).then((value) {
                      Toast(context: context, text: "Doctor blocked");
                    });                            
                  }
                },
                icon: Icon(Icons.more_vert),
              )
          ],
        )
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: SafeArea(
              child: Column(
                children: [
                  Divider(height: 1, color: const Color.fromARGB(255, 206, 206, 207),),
                  getUserProfileSettingsButton(),
                  SizedBox(height: 15,),
                  Center(
                    child: ValueListenableBuilder(
                          valueListenable: widget.doctorModel.userImageChangedNotifier,
                          builder: (context, _, __) => CircleAvatar(
                                                      radius: MediaQuery.of(context).size.width / 3.8,
                                                      backgroundImage: widget.doctorModel.userImage,
                                                    ),
                    ),
                  ),
                  SizedBox(height: 25),
                  ValueListenableBuilder(valueListenable: widget.doctorModel.userNamechangeNorifier, 
                  builder: (context, _, __) => Text(widget.doctorModel.name, style: TextStyle(fontSize: 22, color: BASIC_HEADER_COLOR, fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height: 25,),
                  Divider(height: 1, color: const Color.fromARGB(255, 206, 206, 207),),
                  SizedBox(height: 25,),
                  /***************** Spetiality *********************** */
                  Container(
                    /*
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color.fromARGB(255, 229, 232, 228),
                        border: Border.all(color: Colors.grey, width: 1)
                      ),*/
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    //color: const Color.fromARGB(255, 229, 232, 228),
                    child: Row( 
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Text("Spetialities",
                      style: TextStyle(fontSize: 20, color: BASIC_HEADER_COLOR, fontWeight: FontWeight.bold),),
                      SizedBox(width: 5,),
                      //Expanded(child: Text("")),
                      getSpetialisationButton()
                      ] 
                    ),
                  ),
                  SizedBox(height: 2,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: widget.doctorModel.spetializationChanged, 
                          builder: (context, _, __){
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              width: MediaQuery.of(context).size.width / 1.4,
                              child:
                              ListView.builder(
                                shrinkWrap: true,
                                //physics: NeverScrollableScrollPhysics(),
                                itemCount: widget.doctorModel.speciality.length,
                                itemBuilder: (column, i) => ListTile(
                                    contentPadding: EdgeInsets.all(1),
                                    leading: Icon(Icons.book, color: ICON_COLOR, size: 28,),
                                    title: Text(widget.doctorModel.speciality[i].name, style: TextStyle(fontWeight: FontWeight.bold, color: BASIC_TEXT_COLOR),),
                                    //subtitle: Text(widget.doctorModel.workplaceses[i].address),
                                    //trailing: Icon(Icons.chevron_right),
                                ),
                              //Text(DoctorModel.spetialityToString(widget.doctorModel.speciality), softWrap: true, )
                              )
                              );
                          })
                    ],
                  ),
              
                  /***************** Expierence **************************** */
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      /*  
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color.fromARGB(255, 229, 232, 228),
                        border: Border.all(color: Colors.grey, width: 1)
                      ),*/
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      //color: Color.fromARGB(255, 229, 232, 228),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [ 
                          Row(
                            children: [
                              Text("Expierence", textAlign: TextAlign.left, 
                                  style: TextStyle(fontSize: 20, color: BASIC_HEADER_COLOR, fontWeight: FontWeight.bold, ),
                                  ),
                              SizedBox(width: 10,),
                        //Expanded(child: Text("33")),
                              ValueListenableBuilder(valueListenable: widget.doctorModel.expierenceChanged, 
                                  builder: (context, __, ___) {
                                    return Text((widget.doctorModel.getExpierenceYears()).toString(), style: TextStyle(fontWeight: FontWeight.bold, color: BASIC_TEXT_COLOR),);
                                  }
                              ),
                              SizedBox(width: 3,),
                              Text("years"),
                              ],)  ,
                              getUserExpierenceButon()
                      ]
                      ),
                    )
                    ),
                  SizedBox(height: 5,),
                  /******************* Workplacec********************** */
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      /*
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color.fromARGB(255, 229, 232, 228),
                        border: Border.all(color: Colors.grey, width: 1)
                      ),*/
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      //color: const Color.fromARGB(255, 229, 232, 228),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [ 
                          Text("Workplaces", textAlign: TextAlign.left, 
                        style: TextStyle(fontSize: 20, color: BASIC_HEADER_COLOR, fontWeight: FontWeight.bold),),
                        getUserWorkplaceSettingsButton()
                      ]
                      ),
                    )
                    ),
                  SizedBox(height: 5,),
                  ValueListenableBuilder(
                    valueListenable: widget.doctorModel.workplaceChaged, 
                    builder: (context, _, __) {
                        return Container(
                    //height: 50,
                    //width: MediaQuery.of(context).size.width-10,
                    child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.doctorModel.workplaceses.length,
                          itemBuilder: (column, i) {
                            return ListTile(
                              leading: Icon(Icons.work, size: 25, color: ICON_COLOR),
                              title: Text(widget.doctorModel.workplaceses[i].hospitalName, style: TextStyle(fontWeight: FontWeight.bold, color: BASIC_TEXT_COLOR),),
                              subtitle: Text(widget.doctorModel.workplaceses[i].address, style: TextStyle(color: BASIC_TEXT_COLOR),),
                              trailing: Icon(Icons.chevron_right, color: ICON_COLOR,),
                            );
                          }
                          ),
                  );
                    } 
                  ),
                  
                  SizedBox(height: 5,),
                  /*********** SKILLS **********************************/
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      /*
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color.fromARGB(255, 229, 232, 228),
                        border: Border.all(color: Colors.grey, width: 1)
                      ),*/
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      //color: const Color.fromARGB(255, 229, 232, 228),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [ 
                          Text("Skills", textAlign: TextAlign.left, 
                        style: TextStyle(fontSize: 20, color: BASIC_HEADER_COLOR, fontWeight: FontWeight.bold),),
                        getUserSkillsButton()
                      ]
                      ),
                    )
                    ),
                  ValueListenableBuilder(
                    valueListenable: skillsChangeNotifier, 
                    builder: (context, _, __) => getUserSkillsWindow()),
                  SizedBox(height: 5,),
                  /*
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Activities", textAlign: TextAlign.left, 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                    ),*/
                   SizedBox(height: 5,),
                   /*
                   SizedBox(
                    height: 180,
                    child: ListView.builder(
                      //shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      itemBuilder: (column, i) => Container(
                        width: 100, // Fixed width for each item
                        height: 150,
                        margin: EdgeInsets.all(8),
                        child: Column(
                          children: [
              
                            ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'https://picsum.photos/150/100?random=$i',
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Item ${i + 1}'),
                          ],
                        ),
                      )
                      )
                      ), */
                      
               
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget getUserExpierenceButon() {
    if (currentUser?.id != widget.doctorModel.id) {
      return Text("");
    } else {
      return IconButton(
        style: BASIC_BUTTON_STYLE,
              onPressed: () { 
                showYearPicker(context: context); 
                }, 
                icon: Icon(Icons.settings, ));
    }
  }

  Widget getSpetialisationButton() {
    if (currentUser?.id != widget.doctorModel.id) {
      return Container();
    } else {
      return IconButton( style: BASIC_BUTTON_STYLE, onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => UserSpetiality(creationMode: false))); }, icon: Icon(Icons.settings));
    }

  }

  Widget getUserSkillsButton() {
    if (currentUser?.id != widget.doctorModel.id) {
      return Text("");
    } else {
      return IconButton(
        style: BASIC_BUTTON_STYLE,
              onPressed: (){ 
                Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => DoctorSkillsScreen(updateFunc: updateSkills,)));
                }, 
                icon: Icon(Icons.settings));
    }
  }

  Widget getUserSkillsWindow() {
    return Container(
      child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.doctorModel.skills.length,
              itemBuilder: (column, i) => ListTile(
                      leading: Icon(Icons.check, size: 20, color: ICON_COLOR,),
                      title: Text(widget.doctorModel.skills[i].skillName, style: TextStyle(fontWeight: FontWeight.bold, color: BASIC_TEXT_COLOR),),
                      subtitle: Text(widget.doctorModel.skills[i].skillDescr, style: TextStyle(color: BASIC_TEXT_COLOR),),
                      trailing: Icon(Icons.chevron_right, color: ICON_COLOR,),
        )
        ),
    );
  }

  Widget getUserProfileSettingsButton() {
    if (currentUser?.id != widget.doctorModel.id) {
      return Container(); /*Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () {
            mainUser!.doAddRoster(widget.doctorModel.id.toString());            
            itemsChanged.value = !itemsChanged.value;
            Navigator.pushReplacement(context, 
              MaterialPageRoute(builder: (cx) => ChatScreen(recipient: widget.doctorModel) ));
          }, 
          icon: Icon(Icons.message)),
      );*/ 
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          style: BASIC_BUTTON_STYLE,
          onPressed: (){ 
            Navigator.push(context, 
            MaterialPageRoute(builder: (context) => SettingsPersonal(
                                                        userRegistered: true,
                                                        id: currentUser?.id,
                                                        name: currentUser?.name ?? "",
                                                        email: currentUser?.name, 
                                                        userType: currentUser?.userType, 
                                                        sameUser: widget.doctorModel,))); }, 
            icon: Icon(Icons.settings)),
      );
    }
  }

  Widget getUserWorkplaceSettingsButton() {
    if (currentUser?.id != widget.doctorModel.id) {
      return Text("");
    }
    return Align(
                alignment: Alignment.centerRight,
                child: IconButton(style: BASIC_BUTTON_STYLE, onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (contect) => WorkplaceScreen(creationMode: false)));
                }, 
                icon: Icon(Icons.settings)),
              );
  }
 
Future<int?> showYearPicker({
  required BuildContext context,
  int? initialYear,
  final int firstYear = 1950,
  final int lastYear = 2025,
}) async {
  //int selectedYear = initialYear ?? DateTime.now().year;
  
  return showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select Year'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ValueListenableBuilder(valueListenable: widget.doctorModel.workplaceChaged, 
          builder: (context, __, ___) {
            return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
            ),
            itemCount: lastYear - firstYear + 1,
            itemBuilder: (context, index) {
              final year = firstYear + index;
              return TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: year == widget.doctorModel.expierenceFrom 
                      ? Theme.of(context).colorScheme.primary 
                      : null,
                ),
                onPressed: () async{
                  final response = await call(context, {'func' : 'updateExpYear', 'p1' : widget.doctorModel.id.toString(), 'p2' : year.toString()});
                  if (response == null || response['result'] != "OK") return;
                  widget.doctorModel.setExpierenceYear(year);
                  Navigator.pop(context, widget.doctorModel.expierenceFrom);
                },
                child: Text(year.toString()),
              );
            },
          );
          })
        ),
      );
    },
  );
}

}