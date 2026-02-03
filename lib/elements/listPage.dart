import 'package:flutter/material.dart';

enum ListItemType {LIST_TILE, CHECK_BOX_LIST_TILE}

class ListViewBuilder {
final List<dynamic> list;
void    Function(int)? onTap;
ImageProvider  Function(int)? getAvatar;
String  Function(int)? getName;
String  Function(int)? getTime;
String Function(int)? getMessage;
int     Function(int)? getUnreadedCount;
ListItemType listItemType;


ListViewBuilder({ this.listItemType=ListItemType.LIST_TILE, required this.list, required this.onTap, this.getAvatar, this.getName, this.getTime,
this.getMessage, this.getUnreadedCount});

Widget build(BuildContext context) {
  return ListView.builder(
      itemCount: list.length,
      itemBuilder: (column, i) => Column(
              
              children: <Widget>[
                Divider(height: 5.0),
                getItem(i)
                ],
            ),
          
    );
  }

  Widget getItem(int i) {
    //if (listItemType == ListItemType.LIST_TILE) {
              return ListTile(
                  onTap: () {
                    onTap != null ? onTap!(i) : (){};
                  },
                  leading: Stack(
                    
                    children: <Widget>[
                      CircleAvatar(
                        radius: 32,
                        foregroundColor: Colors.amber,
                        backgroundColor: Colors.blue,
                        backgroundImage: getAvatar != null ? ( getAvatar!(i)) : AssetImage("assets/images/unknown.jpeg"),
                      ),
                      Positioned(
                        
                        bottom: 0.0,
                        right: 1.0,
                        child: Visibility(
                          visible: getUnreadedCount != null && getUnreadedCount!(i) > 0,
                          child: Container(
                            height: 20,
                            width: 20,
                            
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                getUnreadedCount != null ? getUnreadedCount!(i).toString() : "",
                                style: TextStyle(color: Colors.white),
                              ),
                            ), //Icon(Icons.add, color: Colors.white, size: 15),
                            
                          ),
                        ),
                      ),
                    ],
                  ),

                  title:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                       Text(
                        getName != null ? getName!(i) : "Unname",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                       Text(
                        getTime != null ? getTime!(i) : "Untime" ,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  subtitle:  Container(
                    padding: EdgeInsets.only(top: 5),
                    child:  Text(
                      getMessage != null ? getMessage!(i).toString() : "",
                      style: TextStyle(color: Colors.grey, fontSize: 15.0),
                    ),
                  ),
                );
/*              
    } else if (listItemType == ListItemType.CHECK_BOX_LIST_TILE) {
      return CheckboxListTile(
                  onChanged: () {
                    onTap != null ? onTap!(i) : (){};
                  },
                  leading: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        foregroundColor: Colors.amber,
                        backgroundColor: Colors.blue,
                        backgroundImage: getAvatar != null ? ( getAvatar!(i)) : AssetImage("assets/images/unknown.jpeg"),
                      ),
                      Positioned(
                        
                        bottom: 0.0,
                        right: 1.0,
                        child: Visibility(
                          visible: getUnreadedCount != null && getUnreadedCount!(i) > 0,
                          child: Container(
                            height: 20,
                            width: 20,
                            
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                getUnreadedCount != null ? getUnreadedCount!(i).toString() : "",
                                style: TextStyle(color: Colors.white),
                              ),
                            ), //Icon(Icons.add, color: Colors.white, size: 15),
                            
                          ),
                        ),
                      ),
                    ],
                  ),

                  title:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                       Text(
                        getName != null ? getName!(i) : "Unname",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                       Text(
                        getTime != null ? getTime!(i) : "Untime" ,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  subtitle:  Container(
                    padding: EdgeInsets.only(top: 5),
                    child:  Text(
                      getMessage != null ? getMessage!(i).toString() : "",
                      style: TextStyle(color: Colors.grey, fontSize: 15.0),
                    ),
                  ),
                );
              
    }*/
  }

}

