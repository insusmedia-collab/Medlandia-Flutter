import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medlandia/elements/imageHelper.dart';
import 'package:medlandia/main.dart';
import 'package:medlandia/models/spetialityModel.dart';
import 'package:medlandia/stores/localStore.dart';
import 'package:medlandia/models/memberModel.dart';
import 'package:medlandia/login/regUserSpeciality.dart';
import 'package:medlandia/login/regUserTypeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
// For base64Encode
import 'dart:typed_data';

import 'package:medlandia/xmpp/XMPP.dart'; // For Uint8List

class SettingsPersonal extends StatefulWidget {
  SettingsPersonal({
    super.key,

    required this.userType,
    required this.id,
    required this.name,
    required this.email,
    required this.userRegistered,
    required this.sameUser
  });
  final int userType;
  final int id;
  String name;
  String? email;
  final bool userRegistered;
  final BaseMemberModel? sameUser;

  @override
  State<SettingsPersonal> createState() => _SettingsPersonalState();
}

final Imagehelper _helper = Imagehelper(ImagePicker(), ImageCropper());

class _SettingsPersonalState extends State<SettingsPersonal> {
  late TextEditingController _controller;
  late TextEditingController _email;
  late final FocusNode _textFocusNode;
  //final ValueNotifier<bool> userImageChanged = ValueNotifier<bool>(false);
  //ImageProvider? image;
  bool isUpdating = false;
  ValueNotifier<String> updateStatusChanged = ValueNotifier<String>("");
  String? imageData;


  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
    _email = TextEditingController(text: widget.email);
    _textFocusNode = FocusNode();
    _textFocusNode.addListener(_handleFocusChange);
    if (!widget.userRegistered) {
      currentUser!.setUserImage(AssetImage("assets/images/unknown.jpeg"));      
    }
    
  }

  @override
  void dispose() {
    _textFocusNode.removeListener(_handleFocusChange);
    _controller.dispose();
    _email.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_textFocusNode.hasFocus) {
      setState(() {
        //currentUser.name = _controller.text;
        //print(currentUser.name);
      });
    }
  }

  List<Widget> actionsType() {
    if (!widget.userRegistered /*--First time registration--*/ ) {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegUsrType(id: widget.id, country: "", ),
                  ),
                );
              },
              child: Text("Previouse"),
            ),
            TextButton(
              onPressed: () async {
                widget.name = _controller.text;
                if (widget.name.isEmpty) {
                  alertUserNameEmpty();
                  return;
                }
                await updateData();
                if (currentUser!.userType == 1) {                  
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSpetiality(creationMode: true),
                    ),
                  );
                } else {
                  await Xmpp.disconnect(isConnectAfter: true);
                  await Xmpp.connect();
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(
                      builder: (context) => MainApp(),
                    ),
                  );
                }
              },
              child: Text("Next"),
            ),
          ],
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: () async {
            if (widget.name.isEmpty) {
                alertUserNameEmpty();
                return;
            }
            await updateData();
            Navigator.pop(context);
          },
          child: Text("Update"),
        ),
        SizedBox(height: 45),
      ];
    }

  }

void alertUserNameEmpty() {
      if (widget.name.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("User name could not be empty"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                } 
    }


Future<void> updateData() async {
      
              isUpdating = true;
              updateStatusChanged.value = "Updating user, wait...";
              var url = Uri.https('medlandia.org', 'medlandia.jsp');
              var response = await http.post(
                url,
                body: {
                  'func': 'updateUser',
                  'p1': widget.id.toString(),
                  'p2': _controller.text,
                  'p3': _email.text,
                },
              );

              updateStatusChanged.value = "Uploading image";

              if (imageData != null) {
                url = Uri.https('medlandia.org', 'medlandia.jsp');
                response = await http.post(
                  url,
                  body: {
                    'func': 'setAvatar',
                    'p1': widget.id.toString(),
                    'p2': imageData,
                  },
                );

                //Map<String, dynamic> user = await jsonDecode(response.body);
                
                currentUser?.setUserImage(MemoryImage(base64Decode(imageData!)));
                currentUser?.userImageChangedNotifier.value = !currentUser!.userImageChangedNotifier.value;
                
              if (widget.sameUser != null) {
                  widget.sameUser!.setUserImage(MemoryImage(base64Decode(imageData!)));
                  widget.sameUser!.userImageChangedNotifier.value = !widget.sameUser!.userImageChangedNotifier.value;
              }
              }

              updateStatusChanged.value = "Update data local store";
              if (widget.userRegistered) {
                currentUser?.setUserName(_controller.text);
              
                await LocalStore.update(
                  key: "name",
                  value: _controller.text,
                );
                await LocalStore.update(key: "email", value: _email.text);
              }

              isUpdating = false;
             
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 244),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 230, 230, 232),
        centerTitle: true,
        title: Text("Personal Settings"),
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Please introduce yourself", style: TextStyle(fontSize: 22)),
              SizedBox(height: 35),
              Center(
                child: InkWell(
                  onTap: () async {
                    final file = await _helper.pickImage();
                    if (file != null) {
                      final croppedFile = await _helper.crop(
                        file: file,
                        cropStyle: CropStyle.circle,
                      );
                      if (croppedFile != null) {
                        await _processImage(File(croppedFile.path), 256);
          
                        //userImageChanged.value = !userImageChanged.value;
                        //image = MemoryImage(base64Decode(imageData!));
                        
                        currentUser!.setUserImage(MemoryImage(base64Decode(imageData!)));
                        
                        currentUser!.userImageChangedNotifier.value = !currentUser!.userImageChangedNotifier.value;
                        //setState(() => image = File(croppedFile.path));
                      }
                    }
                  },
                  child: ValueListenableBuilder<bool>(
                    valueListenable: currentUser!.userImageChangedNotifier,
                    builder:
                        (context, _, __) =>
                            CircleAvatar(radius: 80, backgroundImage: currentUser!.userImage),
                  ),
                ),
              ),
          
              SizedBox(height: 25),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.6,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter your username',
                  ),
                  //focusNode: FocusNode(),
                  onChanged: (value) {
                    if (widget.userRegistered) {
                      currentUser?.setUserName(value);                  
                    }
                    widget.name = value;
                   
                  },
                  controller: _controller,
                  //keyboardType: TextInputType.text,
                ),
              ),
              SizedBox(height: 25),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.6,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'E-mail',
                    hintText: 'Enter your email',
                  ),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    if (widget.userRegistered) {
                      //currentUser.email = value;
                      widget.email = value;
                    } else {
                      widget.email = value;
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              //Expanded(child: Container()),
              Visibility(
                visible: isUpdating,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: updateStatusChanged,
                      builder: (context, value, __) => Text(value),
                    ),
          
                    SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.2,
                      child: LinearProgressIndicator(value: 30),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(20),
        child: Row(children: [
            ],
          ),
      ),
      persistentFooterButtons: actionsType(),
    );
  }

  Future<void> _processImage(File imageFile, int w) async {
    //_showSnackBar('Processing image...');
    try {
      updateStatusChanged.value = "Prepring image...";

      // 1. Read image bytes
      final List<int> imageBytes = await imageFile.readAsBytes();

      // 2. Decode image using the 'image' package
      img.Image? originalImage = img.decodeImage(
        Uint8List.fromList(imageBytes),
      );

      if (originalImage == null) {
        updateStatusChanged.value = 'Failed to decode image.';
        return;
      }

      // 3. Resize the image
      // You can choose to resize proportionally or to a fixed size.
      // Option A: Fixed dimensions, might distort if aspect ratio is different
      // img.Image resizedImage = img.copyResize(originalImage, width: _targetWidth, height: _targetHeight);

      // Option B: Resize to fit within target width, maintaining aspect ratio

      img.Image resizedImage;
      if (originalImage.width > w) {
        resizedImage = img.copyResize(originalImage, width: w);
      } else {
        resizedImage = originalImage; // No resize needed if smaller
      }

      // Option C: Resize to fit within a target height
      // if (originalImage.height > _targetHeight) {
      //   resizedImage = img.copyResize(originalImage, height: _targetHeight);
      // } else {
      //   resizedImage = originalImage;
      // }

      // 4. Encode the resized image back to a format (e.g., JPEG or PNG)
      // For web use or general purposes, JPEG is often preferred for smaller file sizes.
      // Use img.encodePng(resizedImage) for PNG.
      Uint8List resizedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: 85),
      ); // Quality from 0-100

      // 5. Encode the resized image bytes to Base64
      String base64String = base64Encode(resizedBytes);

      setState(() {
        imageData = base64String;
        //_base64Image = base64String;
        //_resizedImageBytes = resizedBytes;
      });
      updateStatusChanged.value = ('Image processed and encoded!');
      
      
    } catch (e) {
      updateStatusChanged.value = ('Error processing image: $e');
      print('==>Error processing image: $e');
    }
  }
}
