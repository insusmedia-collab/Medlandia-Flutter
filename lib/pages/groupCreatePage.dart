
enum GroupType {PUBLIC_GROUP, PRIVATE_GROUP}

/*

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key, required this.type});
  final GroupType type;

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _allowNonDoctorsToComment = false;
  bool _setAsAnonimouse = false;
  bool _stateCreation = false;
  

  @override
  void dispose() {
    _nameController.dispose();
    //_emailController.dispose();
    //_passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new Ask"),
        leading: IconButton(onPressed: () {
            Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Form(
          key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children:  [
                  Text("Please describe question "),
                  TextFormField(
                    maxLines: 5,
                    controller: _nameController,
                    
                    decoration: InputDecoration(
                      labelText: 'Question',
                      //prefixIcon: Icon(Icons.question_answer),
                      border: OutlineInputBorder()
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter question';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  if (widget.type == GroupType.PUBLIC_GROUP) CheckboxListTile(
                    title: Text('Allow non doctors comment'),
                    value: _allowNonDoctorsToComment,
                    onChanged: (value) {
                      setState(() {
                        _allowNonDoctorsToComment = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(height: 16),
                  Visibility(
                    visible: _stateCreation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: LinearProgressIndicator()
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  if (widget.type == GroupType.PUBLIC_GROUP) CheckboxListTile(
                    title: Text('Set as anonimouse'),
                    value: _setAsAnonimouse,
                    onChanged: (value) {
                      setState(() {
                        _setAsAnonimouse = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(height: 7,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width/1.02,
                    child: ElevatedButton(
                    onPressed: () async{
                      setState(() {
                        _stateCreation = true;
                      });
                      String groupBody = ''' {"title":"${_nameController.text}","isAnonimouse":$_setAsAnonimouse,"allowNonDoctorComment":$_allowNonDoctorsToComment,"creationDate":"${DateTime.now().toIso8601String()}"}''';
                      await mainUser!.createGroup(
                                    roomName: "${XMPPServer.uniqId()}", 
                                    roomTitle: groupBody, 
                                    ownerName:  mainUser!.id.toString(),
                                    isModerator: true,
                                    isPasswordProtected: false,
                                    isPersistante: true,
                                    isPublic: widget.type == GroupType.PUBLIC_GROUP ? false : true,
                                    onSuccess: () {
                                        setState(() {
                                          _stateCreation = false;
                                        });
                                        GroupModel gmodel = GroupModel(id: 1, 
                                                                        isAnonimouse: _setAsAnonimouse, 
                                                                        allowNonDoctorToComment: _allowNonDoctorsToComment, 
                                                                        chatName: _nameController.text, 
                                                                        country: "ARM", 
                                                                        language: "eng",
                                                                        userImage: AssetImage("assets/images/unknown.jpeg"), 
                                                                        userType: 1, 
                                                                        name: "name");
                                                              dummyItems.insert(0, gmodel);
                                                              setState(() {
                                                                itemsChanged.value = !itemsChanged.value;
                                                              });
                                                              
                                        Navigator.pop(context);
                                    }); 
                      
                      
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Submit'),
                  ),
                  ),
                   
                  
                ],
              ),
              //Expanded(child: Container()),
              
              
            
          ),
        ),
    );
  }
}*/