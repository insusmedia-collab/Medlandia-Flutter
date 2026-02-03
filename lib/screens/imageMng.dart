import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medlandia/elements/imageHelper.dart';

class ImageMng extends StatefulWidget {
  const ImageMng({super.key, required this.initlials});
  final String initlials;
  @override
  State<ImageMng> createState() => _ImageMngState();
}

final Imagehelper _helper = Imagehelper(ImagePicker(), ImageCropper());

class _ImageMngState extends State<ImageMng> {
  File? image; 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: CircleAvatar(
              backgroundColor: Colors.amber,
              radius: 64,
              foregroundImage: image != null ? FileImage(image!) : null,
              child: Text(
                widget.initlials,
                style: TextStyle(fontSize: 48)),
            ),
          ),
        ),
        SizedBox(height: 16,),
        TextButton(onPressed: () async {

        }, 
        child: Text("Select photo"))
      ],
    );
  }
}