import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:medlandia/connectivity/connector.dart';
import 'package:medlandia/elements/centermenu.dart';
import 'package:medlandia/models/DoctorSkillsModel.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/scheduleModel.dart';
import 'package:medlandia/models/workplaceModel.dart';
import 'package:medlandia/http/httpRequest.dart';
import 'package:medlandia/style.dart';

class VisitScreen extends StatefulWidget {
    VisitScreen({super.key, 
          required this.client,         
          required this.model,
          required this.selected});
   BaseMemberModel? client;
  final ScheduleModel? model;         
  
  //final ImageProvider avatarUrl;
  
  final void Function(DateTime date, String place, String job) selected;
  
  

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {
 DateTime? selectedDate;
 Workplace? place;
 DoctorSkillsModel? job;
final ScrollController _scrollController = ScrollController();
List<ScheduleModel> daySchedule = [];
ValueNotifier<bool> dayScheduleChanged = ValueNotifier<bool>(false);
ValueNotifier<bool> userFindByTelephone = ValueNotifier<bool>(false); 
final TextEditingController _controler = TextEditingController();
String? _phoneError;
String? _workplaceError; 
String? _jobError;
String? _dateTimeError;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Called when dependencies change (before build)
  /*
  selectedDate = widget.model!.date;    
    (currentUser as DoctorModel).workplaceses.forEach((wp) {
      if (wp.placeId == widget.model!.googlePlaceId) {
        this.place = wp;
        return;
      }
    });*/
}
 
@override
void initState() {
 
 
   super.initState();
}

Widget dayActivityItem(ScheduleModel mdl) {
  return Column(
              
              children: <Widget>[
                Divider(height: 5.0),
                ListTile(
                  onTap: () {
                    //Navigator.push(context, 
                    //MaterialPageRoute(builder: (context) {}));
                  },
                  leading: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        foregroundColor: Colors.amber,
                        backgroundColor: Colors.blue,
                        backgroundImage: widget.client == null ? AssetImage('assets/images/unknown.jpeg') : NetworkImage("https://medlandia.org/medlandia.jsp?func=getAvatar&p1=${mdl.clientId}"),
                      ),
                      
                    ],
                  ),

                  title:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                       Text(
                        mdl.name ?? "Unnamed",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                       Text(
                        DateFormat('HH:mm').format(mdl.date),                        
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  subtitle:  Container(
                    padding: EdgeInsets.only(top: 5),
                    child:  Text(
                      mdl.address,
                      style: TextStyle(color: Colors.grey, fontSize: 15.0),
                    ),
                  ),
                ),
              ],
            );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: APP_BACKGROUND_COLOR,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: APP_TAB_COLOR,
          leadingWidth: 80,
          titleSpacing: 0,
          leading: InkWell(
            onTap: ()=> Navigator.pop(context),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 24),
                  ValueListenableBuilder(
                    valueListenable: userFindByTelephone, 
                    builder: (context, _, __) => 
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: widget.client == null ? AssetImage('assets/images/unknown.jpeg') :  widget.client!.userImage,
                      )
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
                        valueListenable: userFindByTelephone, 
                        builder: (context, _, __) =>
                          Text(
                            widget.client != null ? widget.client!.name : "Unknown user",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        ),                      
                      Text(
                        "Visit",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
          ),
          
          actions: [
            /*
            if (widget.model != null) 
            IconButton(onPressed: () {
                 
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Delete schedule?"),
                        content: Text("Do you really want to delete current schedule?"),
                        actions: [
                          TextButton(onPressed: (){
                            Navigator.pop(context, false);
                          }, child: Text("No")),
                          TextButton(onPressed: ()  {
                             delete(widget.model!.id);
                             Navigator.pop(context, true);
                          }, child: Text("Yes")),
                        ],
                      );
                      });
            }, icon: Icon(Icons.delete, color: Colors.red,)),*/
            //IconButton(onPressed: () {}, icon: Icon(Icons.info)),
            PopupMenuButton<String>(
                itemBuilder:
                    (BuildContext context) => [
                      /*PopupMenuItem(value: "Some", child: Text("Some")),
                      PopupMenuItem(value: "Other", child: Text("Other")),
                      PopupMenuItem(value: "Another", child: Text("Another")),*/
                    ],
                onSelected: (value) {
                  
                },
                icon: Icon(Icons.more_vert),
              )
          ],
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(height: 20),            
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: widget.client != null || widget.model != null ? Container() : Row(
                    children: [
                      Icon(Icons.phone, size: 25,),
                      SizedBox(width: 18,),
                      Expanded(child: 
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            errorText: _phoneError,
                            labelText: 'Phone Number',
                            hintText: 'Ex: 374xxxxxxxxxx',
                            border: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder( // Normal border
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 2),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            )
                          ),
                          controller: _controler,
                          onChanged: (value) {
                            _phoneError = null;                          
                            return _validatePhoneManual(); 
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9+()-\s]')), // Allowed characters
                            LengthLimitingTextInputFormatter(15), // Maximum length
                          ]
                        ), 
                        
                      ),
                      
                        //SizedBox(width: 5,),
                        //TextButton(onPressed: (){}, child: Text("Add") )
                    ],
                  ),
                  ),
              SizedBox(height: 20),
              /************************** WHEN *********************************/ 
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: DateTimePicker(
                  decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "Date and time",                        
                          errorText: _dateTimeError,
                          labelText: "Enter the visit date time",
                          enabledBorder: UnderlineInputBorder( // Normal border
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 2),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            )
                        ),
                            type: DateTimePickerType.dateTimeSeparate,
                            dateMask: 'd MMM, yyyy',
                            initialValue: widget.model == null ? DateTime.now().toString() : widget.model!.date.toString(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            icon: Icon(Icons.event),
                            dateLabelText: 'Date',
                            timeLabelText: "Hour",
                            initialDate: selectedDate, 
                            selectableDayPredicate: (date) {
                              return true;
                            },
                            onChanged: (val) {
                              selectedDate = DateFormat('yyyy-MM-dd HH:mm').parse(val); //val;
                              (() async {
                                final result = await call(context, 
                                          {
                                            'func' : 'loadSchedules', 
                                            'p1' : currentUser!.id.toString(),
                                            'p2' : currentUser!.userType.toString(), 
                                            'p3' : DateFormat('yyyy-MM-dd').format(selectedDate!) 
                                          });
                                if (result == null) return;
                                daySchedule.clear();
                                List<dynamic> items = result as List<dynamic>;
                                for (var item in items) {
                                  daySchedule.add(toScheduleModel(item));                                
                                }
                                dayScheduleChanged.value = !dayScheduleChanged.value;
                              })();
                            },
                            validator: (val) {
                              
                              return null;
                            },
                            onSaved: (val) {
                              
                            },
                          ),
                ),
                /******************************** WHY  ********************************* */ 
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    children: [
                      Icon(Icons.work_history, size: 25,),
                      SizedBox(width: 18,),
                      Expanded(
                      child: DropdownButtonFormField<DoctorSkillsModel>(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "Porpose",                        
                          errorText: _jobError,
                          labelText: "Enter the visit goal",
                          enabledBorder: UnderlineInputBorder( // Normal border
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 2),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            )
                        ),
                        isExpanded: true,
                          value: job,
                          hint: Text('Select an job'),
                          items: getSkillsDropDownList(),
                          
                          onChanged: (DoctorSkillsModel? newValue) {
                            _jobError = null;
                            setState(() {
                              job = newValue;
                            });
                          },
                        )
                        ),
                        //SizedBox(width: 5,),
                        //TextButton(onPressed: (){}, child: Text("Add") )
                    ],
                  ),
                  ),
                  
                   /******************************** WHERE  ********************************* */ 
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    children: [
                      Icon(Icons.work_history, size: 25,),
                      SizedBox(width: 18,),
                      Expanded(
                      child: DropdownButtonFormField<Workplace>(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "Workplace",                        
                          errorText: _workplaceError,
                          labelText: "Enter workplace",
                          enabledBorder: UnderlineInputBorder( // Normal border
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 2),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            )
                        ),
                        isExpanded: true,  
                          value: place,
                          //hint: Text('Select an option'),
                          items: getWorkplacesDropDownList(),
                          onChanged: (Workplace? newValue) {
                            _workplaceError = null;
                            setState(() {
                              place = newValue;
                            });
                          },
                        )
                        ),
                        //SizedBox(width: 5,),
                        //TextButton(onPressed: (){}, child: Text("Add") )
                    ],
                  ),
                  ),  
                
                SizedBox(height: 10,),
        
                Container(
                  color: const Color.fromARGB(255, 230, 230, 232),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    children: [
                      Icon(Icons.list, size: 25,),
                      SizedBox(width: 18,),
                      Text("Day activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      
                    ],
                  ),
                ),
                
                SizedBox(height: 10,),
                Expanded(
                    
                  child: ValueListenableBuilder(
                    valueListenable: dayScheduleChanged,
                    builder: (context, _, __) =>
                    ListView.builder( itemCount: daySchedule.length,
                            itemBuilder: (context, i) => dayActivityItem(daySchedule[i])
                                  ),
                  )
                  ),
                  
                  Align(
                    alignment: Alignment.bottomCenter,
                    
                    child: TextButton(
                      onPressed: () {                      
                        //ScheduleModel newModel = ScheduleModel( doctor: currentUser! as DoctorModel, client: widget.client, date: selectedDate!, place: place!, job: job!);
                        setState(() {});
                        _jobError = null;
                        _dateTimeError = null;
                        _workplaceError = null;
        
                        if (selectedDate == null) {
                          _dateTimeError = "DateTime not selected";
                          return;
                        }
                        if (job == null) {
                          _jobError = "Purpose is not selected";
                          return;
                        }
                        if (place == null) {
                          _workplaceError = "Workplace error"; 
                          return;
                        }  
        
                        if (widget.model != null) {  
                            call(context, {
                            'func'  : 'updateSchedule',
                            'p1'    : widget.model!.id.toString(),  //widget.client != null ? widget.client!.id.toString() : (widget.model != null ? widget.model!.clientId.toString() : _controler.text),
                            'p2'    : DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate!),
                            'p3'    : place!.hospitalName,
                            'p4'    : place!.address,
                            'p5'    : place!.googlePlaceId,
                            'p6'    : place!.lon.toString(),
                            'p7'    : place!.lat.toString(),
                            'p8'    : '${job!.skillName}: ${job!.skillDescr}',
                            'p9'    : currentUser!.userType.toString()
                          }).then((item) {
                            ScheduleModel m = toScheduleModel(item);
                            for (int i = 0; i < dummySchedules.length; i++) {
                              if (dummySchedules[i].id == m.id) {
                                dummySchedules[i] = m;
                              }
                            }
                            scheduleListChanged.value = !scheduleListChanged.value;
                            if (widget.client != null) {
                              Connector.notify('new_schedule', widget.client!.id, currentUser!.id,"");
                            } else {
                              Connector.notifyWhatsInvite(widget.model!.clientId);
                            }
                          }); 
                          
                        } else {
                          if (widget.client == null) {
                            _validatePhoneManual();
                            if (_phoneError != null) {
                              return;
                            }
                          }
                          
                          call(context, {
                            'func'  : 'addSchedule',
                            'p1'    : currentUser!.id.toString(),
                            'p2'    : widget.client != null ? widget.client!.id.toString() : _controler.text,   
                            'p3'    : DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate!),
                            'p4'    : place!.hospitalName,
                            'p5'    : place!.address,
                            'p6'    : place!.googlePlaceId,
                            'p7'    : place!.lon.toString(),
                            'p8'    : place!.lat.toString(),
                            'p9'    : '${job!.skillName}: ${job!.skillDescr}',
                            'p10'    : currentUser!.userType.toString()
                          }).then((response) {
                            if (response == null) return;                        
                            ScheduleModel model = toScheduleModel(response);
                            dummySchedules.add(model);
                            scheduleListChanged.value = !scheduleListChanged.value; 
                            if (widget.client != null) {
                              Connector.notify('new_schedule', widget.client!.id, currentUser!.id, "");
                            } else {
                              Connector.notifyWhatsInvite(int.parse(_controler.text));
                            }
                          });
                        }
                        if (widget.client != null) {
                              widget.client!.isFriend = true;
                              Connector.setUser2UserFriend(widget.client!);
                            }   
                        widget.selected(selectedDate!, '${place!.hospitalName}: ${place!.address}', '${job!.skillName}: ${job!.skillDescr}');
                        Navigator.pop(context);
                      },
                       
                    child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                color: const Color.fromARGB(255, 124, 124, 125), // Background color
                              ),
                              //color: const Color.fromARGB(255, 124, 124, 125),
                              height: 50,
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width / 1.8,
                              alignment: Alignment.center,
                              child: Center (
                                child: Text( widget.model == null ? "Register" : "Update", 
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold ))
                                ),
                            )
                    )
                   
                  ),
                  SizedBox(
                    height: 20,
                  )
                
                  ],
          )
        ),
      ),
    );
  }

  Future<void> delete(id) async {
    final response = await call(context, {'func' : 'deleteSchedule', 'p1' : id.toString()});
                              
                                if (response == null) return;
                                for (int i = dummySchedules.length-1; i >= 0; i--) {
                                  if (dummySchedules[i].id == id) {
                                    dummySchedules.removeAt(i);
                                    scheduleListChanged.value = !scheduleListChanged.value;
                                    break;
                                  }
                                }     
  }

  

void _validatePhoneManual() {
  final value = _controler.text;
  
  setState(() {
    if (value.isEmpty) {
      _phoneError = 'Phone number is required';
      return;
    } 
    else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
      _phoneError = 'Invalid phone format';
      return;
    }
    else {
      _phoneError = null; // Clear error if valid
      if (widget.client != null) return; // dont search where is client defined
      // TRY TO FIND USER BY TELEPHONE
                          (() async {
                            final request = await call(null, {
                              'func'    :   'getUser',
                              'p1'      :   value    
                            });
                            if (request == null || request['result'] != null) {
                              print("==> getUser From tel number error");
                              return;
                            }
                            widget.client = toMember(request);
                            userFindByTelephone.value  =!userFindByTelephone.value;
                          })();  

    }
  });
}

}