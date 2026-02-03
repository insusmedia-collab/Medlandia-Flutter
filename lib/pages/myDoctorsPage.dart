import 'package:flutter/material.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/elements/centermenu.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/memberModel.dart';


class MyDoctorsPage extends StatefulWidget {
  const MyDoctorsPage({super.key});

  @override
  State<MyDoctorsPage> createState() => _MyDoctorsPageState();
}

class _MyDoctorsPageState extends State<MyDoctorsPage> {

@override
  void initState() {
   super.initState();   
  }

void deleteItem(BaseMemberModel member) async {
  member.isFriend = false;

  final response = await Connector.setUser2UserFriend(member);
  if (!response) {
    Toast(context: context, text: "Cant delete item");
    print("==> Cant delete from friends list");
    return;
  }
  for (int i = dummyFriendsItems.length-1; i >= 0; i-- ) {
    if (dummyFriendsItems[i].id == member.id) {
       dummyFriendsItems.removeAt(i);
       dummyFriendsItemsChanged.value = !dummyFriendsItemsChanged.value;      
      break;
    }
  }
   
}

  @override
  Widget build(BuildContext context) {
    return  ValueListenableBuilder(
      valueListenable: dummyFriendsItemsChanged, 
      builder: (context, _, __) =>
        ListView.builder(
          itemCount: dummyFriendsItems.length,
          itemBuilder: (context, index) {
            
             return  GestureDetector(
              onLongPress: () {
                showDialog(context: context, 
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Choose an Option',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          buildMenuOption(context, "Chat", Icons.message, () {
                            (() async {
                              dummyFriendsItems[index].isChat = true;
                              await Connector.setUser2UserChat(dummyFriendsItems[index]);
                              //await mainUser!.openChat(dummyFriendsItems[index]);

                            })();
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => ChatMessagesView(recipient: dummyFriendsItems[index].id)));                            
                          }),
                          //buildMenuOption(context, "Block", Icons.block, () {}),
                          buildMenuOption(context, "Remove", Icons.remove, () async {
                            showDialog(context: context, 
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Remove user?"),
                                content: Text("Do you really want to delete ${dummyFriendsItems[index].name} from user list?"),
                                actions: [
                                  TextButton(onPressed: () {
                                    Navigator.pop(context);
                                  }, child: Text("No") ),
                                  TextButton(onPressed: () {
                                    Navigator.pop(context);

                                    deleteItem(dummyFriendsItems[index]);

                                  }, child: Text("Yes") ),
                                ],
                              );
                            });
                          })
                        ],
                      ),
                    ),  
                  );
                });
              },
              child: Column(
                children: [ 
                  Divider(height: 5.0),
                  ListTile(
                    leading:  CircleAvatar(
                          foregroundColor: Colors.amber,
                          backgroundColor: Colors.blue,
                          backgroundImage: dummyFriendsItems[index].userImage,
                        ),
                    title: Text(dummyFriendsItems[index].name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    subtitle: Text(dummyFriendsItems[index].userType == 1 ? "Doctor" : "Member"),
                  ),
                  /*
                   Row( 
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,  
                            children: [ 
                              Expanded(child: Container()),
                              IconButton(onPressed: () {}, icon: Icon(Icons.message))
                            ]) */
                ],
              ),
            );
            
             }
          )
      );
  }
}