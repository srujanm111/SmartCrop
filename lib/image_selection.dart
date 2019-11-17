import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart' as sharer;
import 'image_editor.dart';

class ImageSelection extends StatefulWidget {

  Map<String, File> testFiles;

  @override
  State createState() => ImageSelectionState();

  ImageSelection(this.testFiles);

  List<ImageCard> getImageCards() {
    List<ImageCard> imageCards = [];
    for (String fileName in testFiles.keys) {
      imageCards.add(ImageCard(testFiles[fileName], fileName, currentDateString()));
    }
    return imageCards.reversed.toList();
  }

  String currentDateString() {
    DateTime now = new DateTime.now();
    return "${month(now.month)} ${now.day}, ${now.year}";
  }

  String month(int month) {
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
    }
    return "November";
  }

}

class ImageSelectionState extends State<ImageSelection> {

  Future addImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    nameImage().then((name) {
      setState(() {
        widget.testFiles[name] = image;
      });
    });
  }

  Future addImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    nameImage().then((name) {
      setState(() {
        widget.testFiles[name] = image;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Smart Crop'),
        backgroundColor: Colors.black87,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info_outline), onPressed: (){},),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child:
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Container(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      height: 170,
                      width: 200,
                      decoration: BoxDecoration(
                          gradient: RadialGradient(colors: [Colors.lightBlue[700].withAlpha(60), Colors.black.withAlpha(20)], radius: .6)
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "Import a new image",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              child: Container(
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [Colors.blue, Colors.blue[300]])
                                ),
                                child: Center(
                                  child: Icon(Icons.add_photo_alternate),
                                ),
                              ),
                              onTap: () {
                                addImageFromGallery();
                              },
                            ),
                            Container(
                              width: 30,
                            ),
                            GestureDetector(
                              onTap: () {
                                addImageFromCamera();
                              },
                              child: Container(
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [Colors.blue, Colors.blue[300]])
                                ),
                                child: Center(
                                  child: Icon(Icons.add_a_photo),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              ...widget.getImageCards()
            ],
          ),
        ),
      ),
    );
  }

  Future<String> nameImage() async {
    TextEditingController controller = new TextEditingController();
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(child: Text("Name New Image")),
          content: Container(
            width: 150,
            height: 130,
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  controller: controller,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: GestureDetector(child: Center(child: Text('Done', style: TextStyle(color: Colors.white),),), onTap: () {Navigator.of(context).pop("${controller.text}.jpg");},),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );


  }

}

class ImageCard extends StatefulWidget {

  File imageFile;
  String imageName;
  String dateCreated;

  ImageCard(this.imageFile, this.imageName, this.dateCreated);

  @override
  State createState() => ImageCardState();

}

class ImageCardState extends State<ImageCard> {


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) => ImageEditor(widget.imageFile)));
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: Image.file(widget.imageFile).image,
              fit: BoxFit.cover
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  widget.imageName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.dateCreated,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white60,
                          shape: BoxShape.circle
                        ),
                        child: Icon(Icons.more_horiz),
                      ),
                      onTap: () {
                        _optionsModalBottomSheet(context);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _optionsModalBottomSheet(context){
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc){
          return Container(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            sharer.Share.share("Image");
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 23),
                            child: Center(
                              child: Text(
                                "Share Image",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            height: 1,
                            color: Colors.grey[600],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 23),
                            child: Center(
                              child: Text(
                                "Open Editor",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(
                          child: Text(
                            "Delete Image",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 17,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          );
        }
    );
  }
}
