import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/connectivity/database.dart';
import 'package:medlandia/elements/centermenu.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/countryModel.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageQuee.dart';
import 'package:medlandia/models/scheduleModel.dart';
import 'package:medlandia/models/spetialityModel.dart';
import 'package:medlandia/pages/doctorsPage.dart';
import 'package:medlandia/pages/myDoctorsPage.dart';
import 'package:medlandia/pages/schedule_page.dart';
import 'package:medlandia/screens/DoctorPage.dart';
import 'package:medlandia/screens/VisitScreen.dart';
import 'package:medlandia/pages/messagePage.dart';
import 'package:medlandia/screens/messageScreen.dart';
import 'package:medlandia/screens/settings.dart';
import 'package:medlandia/style.dart';
import 'package:medlandia/xmpp/XMPP.dart';



//RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();


class MedlandiaHome extends StatefulWidget {
  const MedlandiaHome({super.key});

  @override
  State<MedlandiaHome> createState() => _MedlandiaHomeState();
}

class _MedlandiaHomeState extends State<MedlandiaHome>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabcontroller;



late TextEditingController _searchController;   
late TextEditingController _searchChatMemberController;   
late TextEditingController _searchMesagesByNameController;


CountryModel? searchCountry;
SpetialityModel? searchSpetiality;
final TextEditingController searchNameController = TextEditingController();
 

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        ('-->App is inactive');        
        Xmpp.disconnect(isConnectAfter: false);
        
        
        break;
      case AppLifecycleState.paused:
        print('-->App is paused');          
        Xmpp.disconnect(isConnectAfter: false);
        break;
      case AppLifecycleState.resumed:
        print('-->App is resumed');
        if (Xmpp.isConnected.value == XmppState.DISCONNECTED) {
          Xmpp.connect();
        }
        break;
      case AppLifecycleState.detached:
        print('-->App is detached');
        Xmpp.disconnect(isConnectAfter: false);
        break;
      case AppLifecycleState.hidden:
        if (Xmpp.isConnected.value == XmppState.CONNECTED) {
          Xmpp.disconnect(isConnectAfter: false);
        }
        //mainUser?.disconnect();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabcontroller = TabController(length: 4, vsync: this, initialIndex: 1);
    _tabcontroller.addListener(() {
      setState(() {
        if (_tabcontroller.indexIsChanging) return;
        if (_tabcontroller.index == 0) {
          () async {
            //messageQuees.sort(messageQueeSorterByDate);
            //messageQueesChanged.value = !messageQueesChanged.value;
          }();
        }
      });
    });
    _searchController = TextEditingController();
    _searchChatMemberController = TextEditingController();
    _searchMesagesByNameController  = TextEditingController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchChatMemberController.dispose();
    _searchMesagesByNameController.dispose();
    _tabcontroller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      title: 'Medlandia',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
          backgroundColor: APP_BACKGROUND_COLOR,
          persistentFooterAlignment: AlignmentDirectional.topStart,          
          appBar: AppBar(
            backgroundColor: APP_TAB_COLOR,
            title: Row(children: [ 
                Image(image: AssetImage('assets/images/Medlandia.png'), height: MediaQuery.of(context).size.height/22.5,),
                SizedBox(width: 35,),
                ValueListenableBuilder(
                  valueListenable: Xmpp.isConnected, 
                  builder: (context, value, __) {
                    late IconData state;
                    Color color;
                    if (Xmpp.isConnected.value == XmppState.CONNECTED) {
                      state = Icons.wechat_outlined;
                      color = Colors.green;
                      /*-- Clear new messages unreaded=0 in server becouse there is no meter for server, read it or not. Here messeges viewed.*/
                      Connector.clearAllUnreadedOnServer();
                      return Icon(state, color: color,);
                    } else {
                      state = Icons.error;
                      color = Colors.red;
                      return InkWell(
                        onTap: () async {
                            await Xmpp.disconnect(isConnectAfter: false);
                            await Xmpp.connect();
                        },
                        child: Icon(state, color: color,));
                    }
                  }
                  )
                
              ]),
            elevation: 0.7,
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              controller: _tabcontroller,
              indicatorColor: const Color.fromARGB(255, 121, 3, 3),
              tabs: <Widget>[
                Tab(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text("Messages"),
                      Positioned(
                        top: -5,
                        right: -15,
                        child: ValueListenableBuilder(
                          valueListenable: totalUnreadedMessages, 
                          builder: (context, count, _) {
                            if (count <= 0) {
                              return SizedBox.shrink(); 
                            }
                            return Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    constraints: BoxConstraints(
                                      minHeight: 20,
                                      minWidth: 20
                                    ),
                                    child: Text(count.toString(), style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center),
                            );
                          }
                          ),
                      )
                    ],
                  ),
                ),
                Tab(text: "Doctors"),
                Tab(
                  text: currentUser?.userType == 0 ? "My Doctors" : "My patients",
                ),
                Tab(text: "Schedule"),
              ],
            ),
            //),
            actions: <Widget>[
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == "My page" && currentUser is DoctorModel) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (builder) => DoctorPage(
                              doctorModel: currentUser! as DoctorModel,
                            ),
                      ),
                      //(route) => false,
                    );
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      //PopupMenuItem(value: "_login", child: Text("Login")),
                      if (currentUser != null && currentUser!.userType == 1)
                        PopupMenuItem(value: "My page", child: Text("My page")),
                        PopupMenuItem(
                          value: "Settings",
                          child: Text("Settings"),
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (builder) => SettingsScreen(),
                                ),
                              ),
                        ),
                    ],
              ),
            ],
          ),
          body: Stack(
            children: [
                TabBarView(
                  controller: _tabcontroller,
                  children: <Widget>[        
                   const MessagePage(),
                   const DoctorsPage(),
                   const MyDoctorsPage(),
                   const SchedulePage(),
                  ],
                )],
          ),
        
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              getBottomMenu();
            },
            backgroundColor: const Color.fromARGB(255, 188, 220, 245),
            child: Icon(Icons.menu),
          ),
          /*
          persistentFooterButtons: [
            
            TextButton(onPressed: () {}, child: Text("Some")),
          ],
          persistentFooterAlignment: AlignmentDirectional.center,*/
        ),
      )
    ;
  }



  void getBottomMenu() {
    
    if (_tabcontroller.index == 0) {
      showCenterMenuDialog(
        context, Column(
          children: [
            buildMenuOption(context, 'New message', Icons.email, () {
              MessageScreen.openedQuee = MessageQuee(messageUniqId: genId());
              Navigator.push(context, MaterialPageRoute(builder: (context) => MessageScreen()));
            }),
            Divider(height: 2,),            
            TextField(
              controller: _searchMesagesByNameController ,
              decoration: InputDecoration(
                prefix: Icon(Icons.person),
                hintText: "Search by name",
                suffixIcon: IconButton(onPressed: () async {
                  if (_searchMesagesByNameController.text.isEmpty) return;
                  if (_searchMesagesByNameController.text.trim().length < 3) {
                    Toast(context: context, text: "Need more than 3 digits");
                    return;
                  }
                  messageQuees = await db_searchMessageQueeByUserName(serach: _searchMesagesByNameController.text.trim());
                  messageQueesChanged.value = !messageQueesChanged.value;
                  _searchMesagesByNameController.text = "";
                  Navigator.pop(context);
                }, icon: Icon(Icons.search))
              ),
              
            ),
            Divider(height: 2,),
            buildMenuOption(context, 'Default', Icons.list, () async {
              MSG_QUEE_LOAD_INDEX = 0;
              messageQuees = await db_loadMessageQueeList(from: MSG_QUEE_LOAD_INDEX, count: MSG_QUEE_LOAD_COUNT);
              MSG_QUEE_LOAD_INDEX += MSG_QUEE_LOAD_COUNT;
              messageQueesChanged.value = !messageQueesChanged.value;
            }),  
            Divider(height: 2,),
            buildMenuOption(context, 'Unreaded', Icons.list_outlined, () async {
              MSG_QUEE_LOAD_INDEX = 0;
              messageQuees = await db_loadUnreadedMessageQueeList(from: MSG_QUEE_LOAD_INDEX, count: MSG_QUEE_LOAD_COUNT);
              MSG_QUEE_LOAD_INDEX += MSG_QUEE_LOAD_COUNT;
              messageQueesChanged.value = !messageQueesChanged.value;
            }),            
            Divider(height: 2,),
            buildMenuOption(context, 'By date', Icons.calendar_month, () async {
               final DateTime? picked = await showDatePicker(
                  context: context, 
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900), 
                  lastDate: DateTime(2100));
              //Navigator.pop(context);
              if (picked != null) {
                print("--Search between ${picked} ${picked.add(const Duration(days: 1))}");            
                messageQuees = await db_loadMessageQueeByDate(picked, picked.add(const Duration(days: 1)));
              }  else {
                MSG_QUEE_LOAD_INDEX = 0;
                messageQuees = await db_loadMessageQueeList(from: MSG_QUEE_LOAD_INDEX, count: MSG_QUEE_LOAD_COUNT);
                MSG_QUEE_LOAD_INDEX += MSG_QUEE_LOAD_COUNT;
              }
              messageQueesChanged.value = !messageQueesChanged.value;
            }),
            buildMenuOption(context, 'By period', Icons.calendar_month_rounded, () async {
              final DateTimeRange? picked = await showDateRangePicker(
                        context: context, 
                        firstDate: DateTime(2000), 
                        lastDate: DateTime(2100),
                        initialDateRange: DateTimeRange(
                          start: DateTime.now().subtract(Duration(days: 7)),
                          end: DateTime.now().add(Duration(days: 7)),
                        ),);
              if (picked != null) {
                messageQuees = await db_loadMessageQueeByDate(picked.start, picked.end);
                messageQueesChanged.value = !messageQueesChanged.value;
              }
            }),
            Divider(height: 2,),
          ],
        )
        );
    } else if (_tabcontroller.index == 1) {
      _searchChatMemberController.text = "";
      showCenterMenuDialog(
        context,
        Column(
          children: [
            
            Divider(height: 2,),            
            TextField(
              controller: _searchChatMemberController ,
              decoration: InputDecoration(
                prefix: Icon(Icons.person),
                hintText: "Search by name",
                suffixIcon: IconButton(onPressed: () {
                  if (_searchChatMemberController.text.isEmpty) return;
                    for (int i = 0; i < dummyChatItems.length; i++) {
                      if (dummyChatItems[i].name.toLowerCase().startsWith(_searchChatMemberController.text.toLowerCase())) {
                        BaseMemberModel mem = dummyChatItems.removeAt(i);
                        dummyChatItems.insert(0, mem);
                      }
                    }
                    dummyChatItemsChanged.value = !dummyChatItemsChanged.value;
                    Navigator.pop(context);
                }, icon: Icon(Icons.search))
              ),
              
            ),
            Divider(height: 2,),
            buildMenuOption(context, 'Default', Icons.public, () {
              //Navigator.pop(context);
              for (int i = 0; i < dummyChatItems.length; i++) {
                      if (dummyChatItems[i].unreadedMessages > 0) {
                        BaseMemberModel mem = dummyChatItems.removeAt(i);
                        dummyChatItems.insert(0, mem);
                      }
                    }
            }),
            buildMenuOption(context, 'Blocked', Icons.block, () {
              //Navigator.pop(context);
              for (int i = 0; i < dummyChatItems.length; i++) {
                      if (dummyChatItems[i].isBlock) {
                        BaseMemberModel mem = dummyChatItems.removeAt(i);
                        dummyChatItems.insert(0, mem);
                      }
                    }
                    dummyChatItemsChanged.value = !dummyChatItemsChanged.value;
                    //Navigator.pop(context);
            }),
            
          ],
        ),
      );
    } else if (_tabcontroller.index == 2) {
      searchCountry = null;
      searchSpetiality = null;
      setState(() {
        searchNameController.text = "";
      });

      showCenterMenuDialog(
        context,
        Column(
          children: [
            buildMenuOption(context, 'Default', Icons.public, () {
              doctorLoadIndex = 0;
              doctors.clear();
              loadDoctors(index: doctorLoadIndex);
            }),          
            Divider(height: 2,), 
            
            DropdownButtonFormField<SpetialityModel>(
              decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: "Spetiality",                       
                        labelText: "Spetiality serach",
                        enabledBorder: UnderlineInputBorder( // Normal border
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 2),
                          )                          
                      ),
                      isExpanded: true,  
              items: getSpetialityDropDownList(),
              onChanged: (value) {
                searchSpetiality = value;
                doctorLoadIndex = 0;
                searchDoctor(
                  spetialityId: searchSpetiality!.id, 
                  countryCode: null, 
                  name: null, 
                  index: doctorLoadIndex);
                Navigator.pop(context);
              },
            ),
            TextField(
              controller: searchNameController,
              decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: "Name",                       
                        labelText: "Search by name",
                        enabledBorder: UnderlineInputBorder( // Normal border
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 2),
                          ),
                          suffixIcon: IconButton(onPressed: () {
                            doctorLoadIndex = 0;
                            searchDoctor(
                              spetialityId:  -1, 
                              countryCode: null, 
                              name: searchNameController.text, 
                              index: doctorLoadIndex);
                              Navigator.pop(context);
                          }, icon: Icon(Icons.search))
                      ),
            ),           
            Divider(height: 2,)
          ],
        ),
      );
      return;
    } else if (_tabcontroller.index == 3) {
      showCenterMenuDialog(
        context,
        Column(
          children: [
            buildMenuOption(context, 'Default', Icons.timelapse, () {
              loadSchedules();
              //Navigator.pop(context);
            }),
            buildMenuOption(context, 'Today', Icons.calendar_today_rounded, () {              
              loadSchedulesByDate(DateTime.now(), null);
              //Navigator.pop(context);
            }),
            buildMenuOption(context, 'Tomorrow', Icons.calendar_today, () {
              loadSchedulesByDate(DateTime.now().add(Duration(days: 1)), null);
              //Navigator.pop(context);
            }),
            buildMenuOption(context, 'Custom date', Icons.calendar_month, () async {
               final DateTime? picked = await showDatePicker(
                  context: context, 
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900), 
                  lastDate: DateTime(2100));
              //Navigator.pop(context);
              if (picked != null) {
                loadSchedulesByDate(picked, null);
              }  else {
                loadSchedules();
              }
            }),
            
            buildMenuOption(context, 'Custom period', Icons.calendar_month_rounded, () async {
              loadSchedules();
              //Navigator.pop(context);

              final DateTimeRange? picked = await showDateRangePicker(
                        context: context, 
                        firstDate: DateTime(2000), 
                        lastDate: DateTime(2100),
                        initialDateRange: DateTimeRange(
                          start: DateTime.now().subtract(Duration(days: 7)),
                          end: DateTime.now().add(Duration(days: 7)),
                        ),);
              if (picked != null) {
                //print("Start: ${picked.start}, End: ${picked.end}");
                loadSchedulesByDate(picked.start, picked.end);
              }  
              
            }),
            const Divider(height: 1, thickness: 1),
            if (currentUser!.userType == 1)
              buildMenuOption(context, 'Add schedule', Icons.add, () {
                //Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => VisitScreen(client: null, model: null, 
                selected: (date, place, job) {
                  // SEND TO WHATS APP
                })));
              }),
            
          ],
        ),
      );
    }
  }


  
}
