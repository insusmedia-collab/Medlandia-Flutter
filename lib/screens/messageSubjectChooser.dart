import 'package:flutter/material.dart';
import 'package:medlandia/http/httpRequest.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/models/messageModel.dart';
import 'package:medlandia/models/messageQuee.dart';
import 'package:medlandia/models/messageRecipients.dart';
import 'package:medlandia/style.dart';

class MessageUserChooser extends StatefulWidget {
  final MessageQuee quee;
  const MessageUserChooser({super.key, required this.quee});

  @override
  State<MessageUserChooser> createState() => _MessageUserChooserState();
}

class _MessageUserChooserState extends State<MessageUserChooser> {
  TextEditingController _searchController = TextEditingController();
  List<BaseMemberModel> _filteredItems = [];
  List<BaseMemberModel> _allItems = [];

@override
  void initState() {
    super.initState();
    for (BaseMemberModel m in dummyFriendsItems) {
      _allItems.add(m);
    }
    for (BaseMemberModel m in dummyChatItems) {
      if (_allItems.contains(m)) continue;
      _allItems.add(m);
    }

    _filteredItems = _allItems;// List.from(dummyFriendsItems);
    _searchController.addListener(_onSearchChanged);
  }

 void _onSearchChanged() {
  
    
      if (_searchController.text.trim().length == 0) {
          setState(() {
          _filteredItems = List.from(dummyFriendsItems);
         });
      } else {
        if (RegExp(r'^[0-9]+$').hasMatch(_searchController.text.trim()) && _searchController.text.trim().length > 7) {
          () async {
            dynamic result = await call(context, {'func' : 'getUsersByIds', 'p1' : _searchController.text.trim()});
            print(result);
            List<dynamic> items = result as List<dynamic>;
            if (items != null && items.length > 0) {
              setState(() {
                _filteredItems.clear();
                _filteredItems.add(toMember(items[0]));
              });              
            }
          }();          
        } else {
          setState(() {
            _filteredItems.clear();
            
            _filteredItems = _allItems
            .where((item) => item.name.toLowerCase().contains(_searchController.text.trim()) || item.id.toString().contains(_searchController.text.trim())) 
            .toList();
            

          });
        }
      }
    
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: APP_BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: APP_TAB_COLOR,
        title: TextField(
          controller: _searchController,
      autofocus: true,
          decoration: InputDecoration(
            hintText: "Name or tel number"
          ),
        ),
        actions: [
          ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _filteredItems.length,
          itemBuilder: (context, index) {
            bool isSelected = false;
            for (Recipient r in widget.quee.getUsers()) {
              if (r.id ==  _filteredItems[index].id) {
                isSelected = true;
              }
            }
            return CheckboxListTile(
              title: Text(_filteredItems[index].name),
              subtitle: Text(_filteredItems[index].userType == 0 ? "Member" : "Doctor"),
              value: isSelected,
              secondary: CircleAvatar(
                foregroundColor: Colors.amber,
                backgroundColor: Colors.blue,
                backgroundImage: NetworkImage("https://medlandia.org/medlandia.jsp?func=getAvatar&p1=${_filteredItems[index].id}"),
                radius: 20,
              ),
              onChanged: (_) {
                setState(() {
                    if (isSelected) {
                      widget.quee.removeUser(_filteredItems[index].id);
                    } else {
                      widget.quee.addUser( Recipient(id: _filteredItems[index].id, name: _filteredItems[index].name) );
                    }
                  });
              },
            );
          }
          ),
      ) 
      );
      }
  }