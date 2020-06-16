import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String modeCamera = 'camera';
  final String modeGallery = 'gallery';

  File pickedImage;

  var text = '';
  var awaitImage;
  bool _isImageLoaded = false;
  bool _isLoading = false;

  Future<void> pickImage(String mode) async{
    if(mode.contains(modeGallery))
      awaitImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    else if(mode.contains(modeCamera))
      awaitImage = await ImagePicker.pickImage(source: ImageSource.camera);
    if(awaitImage == null)
      setState(() {
        text = 'No image selected';
        //return;
      });
    else {
      setState(() {
        _isLoading = true;
      });

      setState(() {
        pickedImage = awaitImage;
        _isImageLoaded = true;
        text = '';
      });

      FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(
          pickedImage);

      final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
      final List<ImageLabel> labels = await labeler.processImage(visionImage);

      for (ImageLabel imageLabel in labels) {
        final double confidence = imageLabel.confidence;
        setState(() {
          _isLoading = false;
          text =
          '$text ${imageLabel.text}  ${confidence.toStringAsFixed(2)} \n';
        });
      }
      labeler.close();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
        children: <Widget>[
          SizedBox(height: 100,),
          _isImageLoaded
              ? Expanded(
                child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(blurRadius: 20),
                        ]
                      ),
                      margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                      height: 250,
                      child: Image.file(
                        pickedImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              )
              : Container(),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: () async{
                          pickImage(modeGallery);
                        },
                        icon: Icon(Icons.image, size: 60, color: Colors.blue,),
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Select from gallery'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: () async{
                          pickImage(modeCamera);
                        },
                        icon: Icon(Icons.camera, size: 60, color: Colors.blue,),
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Capture Image'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          text == ''
              ? Text('Details will be displayed here')
              : Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(text),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
