import 'package:flutter/material.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageQuee.dart';
import 'package:medlandia/models/messageRecipients.dart';
import 'package:medlandia/models/spetialityModel.dart';
import 'package:medlandia/models/workplaceModel.dart';
import 'package:medlandia/screens/DoctorPage.dart';
import 'package:medlandia/screens/messageScreen.dart';

class VisitCart extends StatefulWidget {
  final Recipient r;
  const VisitCart({super.key, required this.r});

  @override
  State<VisitCart> createState() => _VisitCartState();
}

class _VisitCartState extends State<VisitCart> {
  ValueNotifier<bool> viewLoaded = ValueNotifier(false); 
  BaseMemberModel? member; 
  @override
  void initState() {
    super.initState();
    ()async {
      member = await Connector.loadUser(id: widget.r.id);
      if (member != null) {
        viewLoaded.value = !viewLoaded.value;
      }
    }();
  }

  @override
  Widget build(BuildContext context) {    

    return Container(
          margin: EdgeInsets.all(3),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(150, 94, 145, 165),
              width: 1
            ),
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(100, 248, 233, 189)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage("https://medlandia.org/medlandia.jsp?func=getAvatar&p1=${widget.r.id}"),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    SizedBox(width: 10,),
                    Expanded(child: Text(widget.r.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color.fromARGB(238, 50, 84, 97)), softWrap: true,)),
                    
                    if (currentUser?.userType == 0)
                    IconButton(
                      onPressed: () async {
                        BaseMemberModel? member = getMemberFromItems(widget.r.id) ?? await Connector.loadUser(id: widget.r.id);
                        member!.isFriend = true;
                        await Connector.setUser2UserFriend(member);
                      },
                      icon: Icon(Icons.add, color: Color.fromARGB(150, 94, 145, 165),)),
                    IconButton(
                      onPressed: () {
                        MessageScreen.openedQuee = MessageQuee(messageUniqId: genId(), type: MQtypes.NORMAL);
                        MessageScreen.openedQuee.addUser(Recipient(id: widget.r.id, name: widget.r.name));
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MessageScreen()));
                      }, 
                      icon: Icon(Icons.message, color: Color.fromARGB(150, 94, 145, 165),)
                    )
                ],
              ),
              SizedBox(height: 5,),
              ValueListenableBuilder(
                valueListenable: viewLoaded, 
                builder: (context, value, _) {
                  if (member == null) return SizedBox();
                  if (member!.userType == 0) return SizedBox();
                  DoctorModel model = member as DoctorModel;
                  return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 5,),
        Divider(height: 1,),
        SizedBox(height: 5,),
        Text("Expierence: since ${model.expierenceFrom}", style: TextStyle(fontSize: 15, color: Color.fromARGB(238, 50, 84, 97), fontWeight: FontWeight.bold),),
        Text("Spetialities:", style: TextStyle(fontSize: 15, color: Color.fromARGB(238, 50, 84, 97), fontWeight: FontWeight.bold),),
        for(SpetialityModel sm in model.speciality)
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 12,),
            Icon(Icons.check_box_outlined, size: 14, color: Color.fromARGB(150, 94, 145, 165),),
            Expanded(child: Text(sm.name, softWrap: true, style: TextStyle(fontSize: 13),))
          ],
        ),
        SizedBox(height: 5,),
        Text("Workplace:", style: TextStyle(fontSize: 15, color: Color.fromARGB(238, 50, 84, 97), fontWeight: FontWeight.bold), ),
        for(Workplace sm in model.workplaceses)
        Row(
          children: [
            SizedBox(width: 12,),
            Icon(Icons.enhanced_encryption_sharp, size: 14, color: Color.fromARGB(150, 94, 145, 165),),
            Expanded(child: Text(sm.hospitalName, style: TextStyle(fontSize: 13), softWrap: true,))
          ],
        ),
        SizedBox(height: 5,),
        Divider(height: 1,),
        SizedBox(height: 5,),

        Row(
          children: [
            DoctorPage.getStarts(m: model),
            Expanded(child: SizedBox()),
            Icon(Icons.link_rounded, color: Color.fromARGB(150, 94, 145, 165),),
            Text(model.getBindsText(), style: TextStyle(color: Color.fromARGB(238, 50, 84, 97)),),
            SizedBox(width: 10,)
          ],
        )

      ],
    );
                })
              
            ],
          ),
      );


    
  }
}