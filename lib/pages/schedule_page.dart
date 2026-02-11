import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/scheduleModel.dart';
import 'package:medlandia/screens/VisitScreen.dart';
import 'package:medlandia/http/httpRequest.dart';
 


class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}
class _SchedulePageState extends State<SchedulePage> {
    
   
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 240, 240, 244),
      child: ValueListenableBuilder(
        valueListenable: scheduleListChanged,
        builder: (context, _, __) =>
         GroupedListView<ScheduleModel, DateTime>(
                elements: dummySchedules,
                groupBy: (schedule) => schedule.date,
                groupSeparatorBuilder: (groupByValue) =>  Text(groupByValue.toString()), 
                groupHeaderBuilder:
                            (element) => Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: const Color.fromARGB(255, 87, 77, 225),
                                  border: Border.all(
                                    color: Colors.white, // Border color
                                    width: 1.0, // Border thickness
                                  ),
                                ),
                                child: Text(
                                  DateFormat(
                                    'MMMM d, y',
                                  ).format(element.date),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),//buildHeader(context, groupByValue),
                itemBuilder: (context, element) => buildScheduleItem(element),
                itemComparator: (e1, e2) =>  DateTime(e1.date.year, e1.date.month, e1.date.day, 0,0,0,0,0).compareTo(DateTime(e2.date.year, e2.date.month, e2.date.day, 0,0,0,0,0)),// isSameDate(e1.date, e2.date) ? 0 : 1, // optional
                //elementIdentifier: (element) => element.id, // optional - see below for usage
                //itemScrollController: itemScrollController, // optional
                //order: StickyGroupedListOrder.ASC, // optional
                floatingHeader: true,                                    
                
               ),
      ),
    );
  }

  void editItem(ScheduleModel sh) {
    call(context, {'func' : 'getUser', 'p1' : sh.clientId.toString()}).then((item) {
                      BaseMemberModel? user;
                      if (item != null && item['id'] != null) {
                        user = toMember(item);
                      }
                      VisitScreen screen =  VisitScreen(client: user, model: sh, selected: (date, place, job) {

                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
                    });
  }

  void deleteItem(ScheduleModel sh) {
    showDialog(context: context, 
                      builder: (context) => AlertDialog(
                        title: Text("Delete"),
                        content: Text("Do you really want to delete schedule item?"),
                        actions: [
                          TextButton(onPressed: () {
                              Navigator.pop(context);
                          }, child: Text("No")),
                          TextButton(onPressed: () {
                            
                              delete(sh.id);
                            Navigator.pop(context);
                            /*                                                          
                            await Future.delayed(Duration(seconds: 1));
                            if (mounted) { // Only available in State class
                              Navigator.pop(context);
                            }*/
                          }, child: Text("Yes"))
                        ],
                      ));  
  }

  Widget buildScheduleItem(/*BuildContext context,*/ ScheduleModel sh) {
    return GestureDetector(
      onTap: () {
        
      },
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromARGB(255, 234, 234, 235),
          border: Border.all(
                            color: const Color.fromARGB(255, 197, 205, 225), // Border color
                            width: 1.0, // Border thickness
                          )
        ),
        child: Column(
          children: [            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('HH:mm').format(sh.date), style: TextStyle(fontSize: 14),),
              ],
            ),
           SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(                    
                          radius: 30,
                          foregroundColor: Colors.amber,
                          backgroundColor: Colors.blue,
                          backgroundImage: sh.name == null ? AssetImage('assets/images/unknown.jpeg') : NetworkImage("https://medlandia.org/medlandia.jsp?func=getAvatar&p1=${currentUser!.userType == 1 ? sh.clientId : sh.doctorId}"),
                        ),
                        Expanded(
                          child: Center(child: Text(sh.name ?? 'Unnamed', style: TextStyle(fontSize: 22),))
                          )
                  
                  
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child:  SizedBox( width: 250, child: Text(sh.job, style: TextStyle(fontSize: 12), softWrap: true,)),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(sh.hospitalName, style: TextStyle(fontSize: 14),),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(sh.address, style: TextStyle(fontSize: 14)),
            ),
            Row(
                  children: [
                    Expanded(child: Container()),
                    if (currentUser!.userType == 1)
                    IconButton(onPressed: () { editItem(sh);}, icon: Icon(Icons.edit)),
                    IconButton(onPressed: () { deleteItem(sh);}, icon: Icon(Icons.delete))
                  ],
                )
            
          ],
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

  Widget buildHeader(BuildContext context, ScheduleModel sh) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromARGB(255, 106, 106, 122)
      
        ),      
        
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: [
            Text(
                                        DateFormat('MMMM d, y',).format(sh.date), style: TextStyle(fontSize: 18,color:  Colors.white,),
                                      )
          ],
        ),
      ),
    );
}
 
}